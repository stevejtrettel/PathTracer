//----------------------------------------------------------------------------
// CUBEGRID — a lattice of rounded bars, one per cell, standing on y = 0.
//
// After IQ's audio "equalizer city" (shadertoys/cube-grid.glsl), with the audio
// taken out: a STILL wants a height FIELD, not four moving bands. So a cell's
// height is a smooth district `swell` mixed with per-cell `jitter`, shaped by
// `contrast` — how big the neighbourhoods are, how ragged they are, and how few
// towers rise above them.
//
// THE DISTANCE is the one thing the original did not have to solve. It walked
// the grid cell by cell (a 2D DDA) and only ever measured the bar it was inside;
// a sphere tracer needs an estimate valid everywhere at once. So this measures
// the 3x3 cells around the query point and then FLOORS the result with the
// clearance to everything outside that block. Without the floor, a min over 9
// bars is an OVER-estimate — a tower two cells away can be nearer than all nine
// — and the marcher walks straight through it.
//
// `tiles` cuts the lattice to a finite block on CELL WALLS, so the edge is a
// clean last row of bars rather than a sawn one.
//
// glsl/shapes/ is the math-only library. Exposes a vec4 `cellData` output for
// coloring (docs/shape-data.md): the cell's id, its height fraction, how far up
// the bar the point sits, and the district swell.
//----------------------------------------------------------------------------


//the cell's own random number, in [0,1). fieldHash is the canonical hash
//(3Materials/fields.glsl) — a shapes file never rolls its own.
float cubeGrid_id(vec2 cell, float seed){
    return fieldHash(vec3(cell, seed));
}

//the cell's height fraction, in [0,1]: districts mixed with per-cell jitter,
//then shaped. contrast > 1 leaves a few towers standing over many low blocks.
float cubeGrid_f(vec2 cell, float clumpFreq, float jitter, float contrast, float seed){
    float swell = valueNoise(vec3(clumpFreq*cell, seed));
    float f     = mix(swell, cubeGrid_id(cell, seed), jitter);
    return pow(clamp(f, 0.0, 1.0), contrast);
}

//one bar: a box of footprint barHalf standing on y = 0, its edges rounded by
//bevel. The box is shrunk by the bevel before inflating, so barHalf and h stay
//the bar's TRUE half-width and height. A bar shorter than the bevel flattens
//into a paving slab rather than inverting.
float cubeGrid_bar(vec3 q, float h, float barHalf, float bevel){
    vec3 ext = vec3(max(barHalf - bevel, 0.0),
                    max(0.5*h    - bevel, 0.0),
                    max(barHalf - bevel, 0.0));
    return boxDistance(q - vec3(0.0, 0.5*h, 0.0), ext) - bevel;
}


// p is in the lattice's own coordinates: cell (0,0) spans [0,spacing] in x and z,
// and every bar stands on the plane y = 0.
float cubeGridDistance(vec3 p, float spacing, float barHalf, float bevel, float height,
                       float clumpFreq, float jitter, float contrast, float seed, vec2 tiles){
    vec2 base = floor(p.xz/spacing);
    vec2 frac = p.xz/spacing - base;              //where we sit in the home cell, [0,1)

    //---- the 3x3 block around us: the only bars that can be nearest ----------
    float d = 1.0e9;
    for(int j = -1; j <= 1; j++){
        for(int i = -1; i <= 1; i++){
            vec2  cell = base + vec2(float(i), float(j));
            float h    = height*cubeGrid_f(cell, clumpFreq, jitter, contrast, seed);
            vec3  q    = p - spacing*vec3(cell.x + 0.5, 0.0, cell.y + 0.5);
            d = min(d, cubeGrid_bar(q, h, barHalf, bevel));
        }
    }

    //---- and the floor that makes the estimate honest -----------------------
    //every cell we skipped lies outside the block, so it is at least `ring` away
    //horizontally; and no bar reaches above `height` or below y = 0, so it is at
    //least `clear` away vertically. The two clearances are orthogonal.
    float ring  = spacing*min(min(frac.x + 1.0, 2.0 - frac.x),
                              min(frac.y + 1.0, 2.0 - frac.y));
    float clear = max(max(p.y - height, 0.0), max(-p.y, 0.0));
    d = min(d, length(vec2(ring, clear)));

    //---- the block: cells |cell| <= tiles, cut on cell walls ----------------
    //bars are inset from their cell by spacing/2 - barHalf, so this never slices
    //one; outside the block it reads as the distance to the wall, an underestimate
    vec2  e     = abs(p.xz) - spacing*(tiles + 0.5);
    float block = min(max(e.x, e.y), 0.0) + length(max(e, 0.0));
    return max(d, block);
}


// the block, as a bounding box: the tile extent in xz, the tallest possible bar
// in y. IQ's own bounding volume was this same slab.
float cubeGridBound(vec3 p, float spacing, float bevel, float height, vec2 tiles){
    vec3 c   = vec3(0.0, 0.5*height, 0.0);
    vec3 ext = vec3(spacing*(tiles.x + 0.5), 0.5*height + bevel, spacing*(tiles.y + 0.5));
    return boxDistance(p - c, ext);
}


// the cell under q (shape data): (id, height fraction, height up the bar, swell).
// A bar is inset well inside its own cell, so a point ON one always resolves to
// the cell that owns it.
vec4 cubeGridCellData(vec3 q, float spacing, float height,
                      float clumpFreq, float jitter, float contrast, float seed){
    vec2  cell  = floor(q.xz/spacing);
    float f     = cubeGrid_f(cell, clumpFreq, jitter, contrast, seed);
    float swell = valueNoise(vec3(clumpFreq*cell, seed));
    float up    = clamp(q.y/max(height*f, 1.0e-3), 0.0, 1.0);
    return vec4(cubeGrid_id(cell, seed), f, up, swell);
}
