//-------------------------------------------------
// OBJECTS — THE FIELD CHART (3Materials/fields.glsl)
// procedural materials via the setData-followup idiom. One row, left to right:
//   marble, granite, wood, rust-on-iron, patina-on-copper, and a raw
//   mixMaterial gradient (gold -> blue tile by local x) showing the
//   stochastic blend converging smooth in accumulation.
// All fields sample LOCAL position: the pattern rides with the object.
// Knobs: weathering (crust coverage), lightPower, roomLight.
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


bool inside_Object( Vector tv ){
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

            if(i == 0){ applyMaterial(path, marbleField(p)); }
            if(i == 1){ applyMaterial(path, graniteField(p)); }
            if(i == 2){ applyMaterial(path, woodField(p)); }
            if(i == 3){ applyMaterial(path, rustField(p, makeIron(0.25), weathering)); }
            if(i == 4){ applyMaterial(path, patinaField(p, makeCopper(0.2), weathering)); }
            if(i == 5){
                //the raw mechanism: stochastic blend swept by local x
                float t = smoothstep(-1.2, 1.2, p.x);
                applyMaterial(path, mixMaterial(makeGold(0.1), makeTile(vec3(0.12,0.32,0.55)), t));
            }
        }
    }
}
