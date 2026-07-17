//-------------------------------------------------
//The DOUBLECONE sdf
//-------------------------------------------------

struct DoubleCone{
    Frame frame;
    Material mat;
};


//a single cone: c = (sin,cos) of the half-angle, h = height below the tip
float singleCone(vec3 p, vec2 c, float h){
    float q = length(p.xz);
    return max(dot(c.xy, vec2(q, p.y)), -h - p.y);
}

float sdf_singleCone(vec3 p){
    const float a = 0.785; //half-angle: ~45 degrees
    return singleCone(p - vec3(0.0, 1.0, 0.0), vec2(sin(a), cos(a)), 2.0);
}

//mirror the single cone vertically to make the double cone
float sdf_doubleCone(vec3 p){
    vec3 q = vec3(p.x,-p.y,p.z);
    q += vec3(0,2.,0);
    float top = sdf_singleCone(q);
    float bottom = sdf_singleCone(p);
    return min(top,bottom);
}


//the local-frame sdf: the unit-sized shape at the origin
float sdf( vec3 p, DoubleCone obj ){
    return sdf_doubleCone(p);
}

//the standard interface (placement handled by the frame)
OBJECT_API(DoubleCone)
