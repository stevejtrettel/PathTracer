//-------------------------------------------------
// OBJECTS — THE METAL CHART (material.glsl, the measured F0 constants)
// every named conductor in the library, in one place. Left to right:
//   WARM:    gold, brass, bronze, copper
//   NEUTRAL: silver, aluminum, chrome, iron
// Rows: front = polished (roughness 0.05), back = brushed (the `brushed` knob).
//
// PHYSICS WORTH KNOWING: most metals are nearly COLOURLESS. Silver and
// aluminum are bright neutrals, chrome and iron are darker neutrals — the only
// strongly coloured conductors are gold, copper, and their alloys (brass =
// copper+zinc, bronze = copper+tin), which is why the warm half of this chart
// is all one family. If a "metal" reads as strongly tinted and is not in that
// family, it is not a metal.
//
// The specular tint is F0 (reflectance at normal incidence, always <= 1); the
// engine whitens it toward total reflection at grazing, per channel. That
// whitening is what makes gold read as gold rather than as shiny yellow paint,
// and it is why the brushed row SATURATES instead of greying: a reflection
// that dips below the horizon strikes another facet and picks up the tint
// again (the multi-bounce loop in scatter.glsl).
//
// This page uses the accent studio — metals are mirrors, so they show you the
// ROOM, not themselves. Warm and cool side walls give them something to say.
//-------------------------------------------------

const int NUM = 8;
Sphere polished[NUM];
Sphere brushedRow[NUM];


//the library's named conductors, warm family first
Material metalAt(int i, float rough){
    if(i == 0){ return makeGold(rough); }
    if(i == 1){ return makeBrass(rough); }
    if(i == 2){ return makeBronze(rough); }
    if(i == 3){ return makeCopper(rough); }
    if(i == 4){ return makeSilver(rough); }
    if(i == 5){ return makeAluminum(rough); }
    if(i == 6){ return makeChrome(rough); }
    return makeIron(rough);
}


void buildObjects(){

    for(int i = 0; i < NUM; i++){
        float x = -8.4 + 2.4*float(i);

        polished[i].frame  = makeFrame(vec3(x, 1.0, 2.));
        polished[i].radius = 1.0;
        polished[i].mat    = metalAt(i, 0.05);

        brushedRow[i].frame  = makeFrame(vec3(x, 1.0, -2.5));
        brushedRow[i].radius = 1.0;
        brushedRow[i].mat    = metalAt(i, brushed);
    }

}


//-------------------------------------------------
// Finding the Objects  (spheres are analytic: traced, not marched)
//-------------------------------------------------

float trace_Objects( Vector tv ){
    float dist=maxDist;
    for(int i = 0; i < NUM; i++){
        dist = min(dist, trace(tv, polished[i]));
        dist = min(dist, trace(tv, brushedRow[i]));
    }
    return dist;
}

float sdf_Objects( Vector tv ){
    return maxDist;
}


bool inside_Object( Vector tv ){
    return false;   //conductors are opaque
}


//-------------------------------------------------
// Setting the Objects Data
//-------------------------------------------------

void setData_Objects(inout Path path){
    for(int i = 0; i < NUM; i++){
        setData(path, polished[i]);
        setData(path, brushedRow[i]);
    }
}
