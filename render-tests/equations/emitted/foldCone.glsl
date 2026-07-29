vec4 foldCone(vec4 x, vec4 y, vec4 z){
    vec4 h = y;
    if(h.x < 0.0){
        h = -h;
    }
    return tmul(x, x) + tmul(z, z) - h;
}

vec4 data_foldCone(vec3 p){
    vec4 x = vec4(p.x, 1.0, 0.0, 0.0);
    vec4 y = vec4(p.y, 0.0, 1.0, 0.0);
    vec4 z = vec4(p.z, 0.0, 0.0, 1.0);
    vec4 v = foldCone(x, y, z);
    return v.yzwx;
}
