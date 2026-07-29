vec4 bump(vec4 t){
    return tmul(t, t) - vec4(1.0, 0.0, 0.0, 0.0);
}

vec4 pickB(vec4 x, vec4 y, vec4 z){
    return bump(x) + bump(y) - tmul(z, z);
}

vec4 data_selector(vec3 p){
    vec4 x = vec4(p.x, 1.0, 0.0, 0.0);
    vec4 y = vec4(p.y, 0.0, 1.0, 0.0);
    vec4 z = vec4(p.z, 0.0, 0.0, 1.0);
    vec4 v = pickB(x, y, z);
    return v.yzwx;
}
