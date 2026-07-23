//-------------------------------------------------
// OBJECTS — FIELD CHART · WEATHERING (3Materials/fields.glsl §3, §3b)
// every sphere here is the SAME mechanism: a layer accumulating on top of some
// base material, blended stochastically by mixMaterial (the probability IS the
// coverage fraction, so it is energy-correct with no weights). One row:
//   rust on iron, patina on copper, dust on polished copper, lichen on
//   granite, snow on dark rock, waterline on terracotta.
// Drag ONE knob — coverage — and watch six different weathering processes
// advance together from bare to fully covered. That shared parameter is the
// point of the page: these are not six effects, they are one.
//-------------------------------------------------

const int NUM = 6;
Sphere ball[NUM];


void buildObjects(){

    for(int i = 0; i < NUM; i++){
        float x = -6.75 + 2.7*float(i);
        ball[i].frame  = makeFrame(vec3(x, 1.2, 0.));
        ball[i].radius = 1.2;
        ball[i].mat    = makeMatte(vec3(0.8));   //base; the followup overrides
    }

}


//-------------------------------------------------
// Finding the Objects  (spheres are analytic: traced, not marched)
//-------------------------------------------------

float trace_Objects( Vector tv ){
    float dist=maxDist;
    for(int i = 0; i < NUM; i++){
        dist = min(dist, trace(tv, ball[i]));
    }
    return dist;
}

float sdf_Objects( Vector tv ){
    return maxDist;
}


//the snow cap is porcelain — a scattering interior, so the walk needs this
bool inside_Object( Vector tv ){
    for(int i = 0; i < NUM; i++){
        if(inside(tv, ball[i])){ return true; }
    }
    return false;
}


//-------------------------------------------------
// Setting the Objects Data — the material-field followup per sphere
//-------------------------------------------------

void setData_Objects(inout Path path){
    for(int i = 0; i < NUM; i++){
        setData(path, ball[i]);
        if( at(path.tv, ball[i]) ){
            vec3 p = toLocal(ball[i].frame, path.tv.pos);

            if(i == 0){ applyMaterial(path, rustField(p, makeIron(0.25), coverage)); }
            if(i == 1){ applyMaterial(path, patinaField(p, makeCopper(0.2), coverage)); }
            if(i == 2){ applyMaterial(path, dustField(p, makeCopper(0.05), coverage)); }
            if(i == 3){
                //lichenField has no amount of its own: scale it by blending the
                //lichened material back against the bare base
                Material granite = graniteField(p);
                applyMaterial(path, mixMaterial(granite, lichenField(p, granite), coverage));
            }
            if(i == 4){
                Material rock = makeGloss(vec3(0.16, 0.15, 0.14), 0.05, 0.4);
                applyMaterial(path, snowCapField(p, rock, coverage));
            }
            if(i == 5){
                //the waterline rides up the sphere as coverage grows: below
                //`level` is wet (darkened + clear-coated), above is dry
                float level = mix(-1.4, 1.4, coverage);
                applyMaterial(path, wetLineField(p, makeTerracotta(), level));
            }
        }
    }
}
