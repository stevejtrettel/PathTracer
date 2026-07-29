vec4 tangle(vec4 x, vec4 y, vec4 z, float c){
    vec4 x2 = tmul(x, x);
    vec4 y2 = tmul(y, y);
    vec4 z2 = tmul(z, z);
    return tmul(x2, x2) - 5.0*x2 + tmul(y2, y2) - 5.0*y2 + tmul(z2, z2) - 5.0*z2 + vec4(c, 0.0, 0.0, 0.0);
}

vec4 data_tangleFns(vec3 p){
    vec4 x = vec4(p.x, 1.0, 0.0, 0.0);
    vec4 y = vec4(p.y, 0.0, 1.0, 0.0);
    vec4 z = vec4(p.z, 0.0, 0.0, 1.0);
    vec4 v = tangle(x, y, z, c);
    return v.yzwx;
}
