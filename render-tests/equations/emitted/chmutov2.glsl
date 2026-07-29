vec4 data_chmutov2(vec3 p){
    vec4 x = vec4(p.x, 1.0, 0.0, 0.0);
    vec4 y = vec4(p.y, 0.0, 1.0, 0.0);
    vec4 z = vec4(p.z, 0.0, 0.0, 1.0);
    vec4 x2 = tsqr(x);
    vec4 y2 = tsqr(y);
    vec4 z2 = tsqr(z);
    vec4 v = 2.0*tsqr(2.0*x2 - vec4(1.0, 0.0, 0.0, 0.0)) + 2.0*tsqr(2.0*y2 - vec4(1.0, 0.0, 0.0, 0.0)) + 2.0*tsqr(2.0*z2 - vec4(1.0, 0.0, 0.0, 0.0)) - vec4(2.0, 0.0, 0.0, 0.0);
    return v.yzwx;
}
