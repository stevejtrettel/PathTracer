//-------------------------------------------------
// OBJECTS OF THE SCENE — the CONDUCTOR (metal) demo
// six named metals at their measured F0 colours, two rows:
//   FRONT: polished (low roughness) — mirror reflections tinted by F0, whitening
//     to total reflection at the grazing silhouettes (the conductor Fresnel).
//   BACK: brushed (higher roughness) — same metals, soft highlights.
// left to right: silver, gold, brass, copper, bronze, iron — the two neutrals
// bookend the coloured alloys (most real metals are colourless; gold/copper and
// their alloys are the exceptions, so the lineup leans on them).
// Knobs: polish/brushed roughness, lightPower, roomLight.
//-------------------------------------------------

const int NUM = 6;
Sphere polished[NUM];
Sphere brushed[NUM];


void buildObjects(){

    for(int i = 0; i < NUM; i++){
        float x = -6.25 + 2.5*float(i);

        polished[i].frame  = makeFrame(vec3(x, 1.1, 2.));
        polished[i].radius = 1.1;

        brushed[i].frame  = makeFrame(vec3(x, 1.1, -2.5));
        brushed[i].radius = 1.1;
    }

    polished[0].mat = makeSilver(polish);    brushed[0].mat = makeSilver(brushRough);
    polished[1].mat = makeGold(polish);      brushed[1].mat = makeGold(brushRough);
    polished[2].mat = makeBrass(polish);     brushed[2].mat = makeBrass(brushRough);
    polished[3].mat = makeCopper(polish);    brushed[3].mat = makeCopper(brushRough);
    polished[4].mat = makeBronze(polish);    brushed[4].mat = makeBronze(brushRough);
    polished[5].mat = makeIron(polish);      brushed[5].mat = makeIron(brushRough);

}


//-------------------------------------------------
// Finding the Objects  (spheres are analytic: traced, not marched)
//-------------------------------------------------

float trace_Objects( Vector tv ){
    float dist=maxDist;
    for(int i = 0; i < NUM; i++){
        dist = min(dist, trace(tv, polished[i]));
        dist = min(dist, trace(tv, brushed[i]));
    }
    return dist;
}

float sdf_Objects( Vector tv ){
    return maxDist;
}


bool inside_Object( Vector tv ){
    return false;
}


//-------------------------------------------------
// Setting the Objects Data
//-------------------------------------------------

void setData_Objects(inout Path path){
    for(int i = 0; i < NUM; i++){
        setData(path, polished[i]);
        setData(path, brushed[i]);
    }
}
