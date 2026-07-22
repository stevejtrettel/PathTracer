//-------------------------------------------------
// OBJECTS — FIELD CHART II (3Materials/fields.glsl §3b)
// one row, left to right:
//   lapis (gold-flecked stone), damascus (warped folded steel),
//   pearl (film over milk), oil slick (swirling film over asphalt),
//   lava (emission in worley cracks — the `heat` knob), wet line
//   (dry terracotta above, coated+darkened below the waterline)
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


//the pearl has a scattering interior: the walk needs the inside test
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

            if(i == 0){ applyMaterial(path, lapisField(p)); }
            if(i == 1){ applyMaterial(path, damascusField(p)); }
            if(i == 2){ applyMaterial(path, pearlField(p)); }
            if(i == 3){ applyMaterial(path, oilSlickField(p, vec3(0.05))); }
            if(i == 4){ applyMaterial(path, lavaField(p, heat)); }
            if(i == 5){ applyMaterial(path, wetLineField(p, makeTerracotta(), -0.2)); }
        }
    }
}
