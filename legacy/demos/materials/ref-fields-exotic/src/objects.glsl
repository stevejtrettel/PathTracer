//-------------------------------------------------
// OBJECTS — FIELD CHART · FILMS, EMISSION & THE RAW MECHANISM
// (3Materials/fields.glsl §3b) the fields that drive something OTHER than
// albedo. One row, left to right:
//   pearl (thin film over a milky subsurface body), oil slick (film thickness
//   pooling over asphalt), lava (surf.emit in worley cracks — the `heat`
//   knob), planet (ocean/land/ice by latitude + noise), smudged glass
//   (roughness-ONLY field), and the bare mixMaterial gradient (gold -> blue
//   tile by local x) showing the stochastic blend converging smooth in
//   accumulation.
// spectral is ON in settings: the two films need per-ray wavelengths to make
// true rainbows rather than angle-only banding.
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


//the pearl has a scattering interior, the smudged glass a clear one
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

            if(i == 0){ applyMaterial(path, pearlField(p)); }
            if(i == 1){ applyMaterial(path, oilSlickField(p, vec3(0.05))); }
            if(i == 2){ applyMaterial(path, lavaField(p, heat)); }
            if(i == 3){ applyMaterial(path, planetField(p/ball[i].radius)); }
            if(i == 4){ applyMaterial(path, smudgeField(p, 1.5)); }
            if(i == 5){
                //the raw mechanism: stochastic blend swept by local x
                float t = smoothstep(-1.2, 1.2, p.x);
                applyMaterial(path, mixMaterial(makeGold(0.1), makeTile(vec3(0.12,0.32,0.55)), t));
            }
        }
    }
}
