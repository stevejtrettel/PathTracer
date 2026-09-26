//-------------------------------------------------
// HDR (Radiance .hdr / RGBE) LOADER
//-------------------------------------------------
// Decodes a Radiance RGBE file into linear float RGB, for HDR skies
// (docs/hdr-environment-plan.md). No dependencies; ~the format as written by
// every HDRI site (Poly Haven etc.):
//
//   #?RADIANCE                     header: text lines, blank line ends it
//   FORMAT=32-bit_rle_rgbe         (EXPOSURE=... is allowed and ignored)
//
//   -Y <height> +X <width>         resolution: rows top to bottom
//   <scanlines>                    each pixel R G B E: value = (c + 0.5)/256 * 2^(E-128)
//
// Scanlines are usually "new-style" run-length encoded: 2 2 <width hi> <width lo>,
// then the four channels one after another, each as runs (a byte > 128 is a run
// of the next byte, count - 128; otherwise that many literal bytes). Anything
// else is flat 4-byte pixels.
//
// parseHDR(arrayBuffer) -> {width, height, data}: data is a Float32Array of RGBA
// (alpha 1), rows ordered BOTTOM to top — the order WebGL uploads expect, so the
// texture matches an <img> uploaded with UNPACK_FLIP_Y.


function parseHDR(buffer){
    let bytes = new Uint8Array(buffer);
    let pos = 0;

    //one header line (ASCII, '\n'-terminated)
    let line = () => {
        let start = pos;
        while(pos < bytes.length && bytes[pos] !== 0x0a) pos++;
        let s = String.fromCharCode(...bytes.subarray(start, pos));
        pos++;   //skip the newline
        return s;
    };

    let magic = line();
    if(!magic.startsWith('#?')) throw new Error('not a Radiance .hdr file (no #? header)');
    for(let l = line(); l !== ''; l = line()){
        if(l.startsWith('FORMAT=') && l !== 'FORMAT=32-bit_rle_rgbe'){
            throw new Error(`unsupported .hdr format: ${l} (only 32-bit_rle_rgbe)`);
        }
        if(pos >= bytes.length) throw new Error('.hdr header never ends');
    }
    let res = line().match(/^-Y (\d+) \+X (\d+)$/);
    if(!res) throw new Error('unsupported .hdr orientation (only "-Y h +X w")');
    let height = parseInt(res[1], 10), width = parseInt(res[2], 10);

    let data = new Float32Array(width * height * 4);
    let scan = new Uint8Array(width * 4);   //one scanline, RGBE per pixel

    for(let y = 0; y < height; y++){
        let rle = width >= 8 && width < 32768 && bytes[pos] === 2 && bytes[pos + 1] === 2
               && ((bytes[pos + 2] << 8) | bytes[pos + 3]) === width;
        if(rle){
            pos += 4;
            for(let c = 0; c < 4; c++){
                for(let x = 0; x < width; ){
                    //every run must advance x: past the end of the file a count
                    //reads as undefined (and a corrupt one as 0), and either would
                    //spin here forever and freeze the page
                    if(pos >= bytes.length) throw new Error('.hdr file is truncated');
                    let count = bytes[pos++];
                    let run = count > 128;
                    if(run) count -= 128;
                    if(count === 0 || x + count > width) throw new Error('.hdr file is corrupt (bad run length)');
                    if(run){
                        let v = bytes[pos++];
                        while(count--) scan[4 * x++ + c] = v;
                    } else {
                        while(count--) scan[4 * x++ + c] = bytes[pos++];
                    }
                }
            }
        } else {
            scan.set(bytes.subarray(pos, pos + width * 4));
            pos += width * 4;
        }
        if(pos > bytes.length) throw new Error('.hdr file is truncated');

        //decode, writing the row bottom-to-top
        let row = (height - 1 - y) * width * 4;
        for(let x = 0; x < width; x++){
            let e = scan[4 * x + 3];
            let f = e ? Math.pow(2, e - 136) : 0;   //2^(e-128) / 256
            data[row + 4 * x]     = e ? (scan[4 * x]     + 0.5) * f : 0;
            data[row + 4 * x + 1] = e ? (scan[4 * x + 1] + 0.5) * f : 0;
            data[row + 4 * x + 2] = e ? (scan[4 * x + 2] + 0.5) * f : 0;
            data[row + 4 * x + 3] = 1;
        }
    }
    return {width, height, data};
}


export {parseHDR};
