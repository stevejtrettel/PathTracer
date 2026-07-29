vec4 data_cubicGenus(vec3 p){
    vec4 x = vec4(p.x, 1.0, 0.0, 0.0);
    vec4 y = vec4(p.y, 0.0, 1.0, 0.0);
    vec4 z = vec4(p.z, 0.0, 0.0, 1.0);
    vec4 x2 = tsqr(x);
    vec4 x3 = tmul(x2, x);
    vec4 y2 = tsqr(y);
    vec4 y3 = tmul(y2, y);
    vec4 z2 = tsqr(z);
    vec4 z3 = tmul(z2, z);
    vec4 v = x3 + y3 + z3 - x - y - z;
    return v.yzwx;
}
