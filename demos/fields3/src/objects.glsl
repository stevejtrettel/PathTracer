//-------------------------------------------------
// OBJECTS — FIELD CHART III (3Materials/fields.glsl §3b)
// one row, left to right:
//   agate (banded translucent — a MEDIUM-varying field), dust on polished
//   copper (`dustAmount`), lichen on granite, planet (ocean/land/ice),
//   smudged glass (roughness-only field), snow cap on dark rock
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


//the agate has a scattering interior, the smudged glass a clear one
bool inside_Object( Vector tv ){
    for(int i = 0; i < NUM; i++){
        if(inside(tv, ball[i])){ return true; }
    }
    return false;
}


void setData_Objects(inout Path path){
    for(int i = 0; i < NUM; i++){
        setData(path, ball[i]);
        if( at(path.tv, ball[i]) ){
            vec3 p = toLocal(ball[i].frame, path.tv.pos);

            if(i == 0){ applyMaterial(path, agateField(p)); }
            if(i == 1){ applyMaterial(path, dustField(p, makeCopper(0.05), dustAmount)); }
            if(i == 2){ applyMaterial(path, lichenField(p, graniteField(p))); }
            if(i == 3){ applyMaterial(path, planetField(p/ball[i].radius)); }
            if(i == 4){ applyMaterial(path, smudgeField(p, 1.5)); }
            if(i == 5){ applyMaterial(path, snowCapField(p, makeGloss(vec3(0.16,0.15,0.14), 0.05, 0.4), 1.)); }
        }
    }
}
