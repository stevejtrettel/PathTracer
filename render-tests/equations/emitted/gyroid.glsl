vec4 data_gyroid(vec3 p){
    vec4 x = vec4(p.x, 1.0, 0.0, 0.0);
    vec4 y = vec4(p.y, 0.0, 1.0, 0.0);
    vec4 z = vec4(p.z, 0.0, 0.0, 1.0);
    vec4 v = tmul(tsin(x), tcos(y)) + tmul(tsin(y), tcos(z)) + tmul(tsin(z), tcos(x));
    return v.yzwx;
}
