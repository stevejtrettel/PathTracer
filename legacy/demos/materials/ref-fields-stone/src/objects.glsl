//-------------------------------------------------
// OBJECTS — FIELD CHART · STONE & GRAIN (3Materials/fields.glsl §3)
// procedural materials whose pattern IS the substance: solids with internal
// structure. One row, left to right:
//   marble (veins), granite (speckle), lapis (gold-flecked), agate (banded
//   translucent — a MEDIUM-varying field), wood (rings), damascus (forged
//   folded steel — a domain-warped metal).
// All fields sample LOCAL position, so the pattern rides with the object.
// Knob: polish (marble's surface finish). Companions: ref-fields-weathered
// (layers ON a base), ref-fields-exotic (films, emission, raw mechanism).
//-------------------------------------------------

const int NUM = 6;
Sphere ball[NUM];


void buildObjects(){

    //one row: every sphere legible, no screen overlap
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


//the agate has a scattering interior: the walk needs the inside test
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

            if(i == 0){ applyMaterial(path, marbleField(p, 3.5, polish)); }
            if(i == 1){ applyMaterial(path, graniteField(p)); }
            if(i == 2){ applyMaterial(path, lapisField(p)); }
            if(i == 3){ applyMaterial(path, agateField(p)); }
            if(i == 4){ applyMaterial(path, woodField(p)); }
            if(i == 5){ applyMaterial(path, damascusField(p)); }
        }
    }
}
