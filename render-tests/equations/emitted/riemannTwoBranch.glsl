vec4 data_riemannTwoBranch(vec3 p){
    vec4 x = vec4(p.x, 1.0, 0.0, 0.0);
    vec4 y = vec4(p.y, 0.0, 1.0, 0.0);
    vec4 z = vec4(p.z, 0.0, 0.0, 1.0);
    vec4 x2 = tsqr(x);
    vec4 y2 = tsqr(y);
    vec4 z2 = tsqr(z);
    vec4 z4 = tsqr(z2);
    vec4 v = tmul(z2, x2) + tmul(z2 + vec4(1.0, 0.0, 0.0, 0.0), y2) - 5.0*(z4 + z2);
    return v.yzwx;
}
