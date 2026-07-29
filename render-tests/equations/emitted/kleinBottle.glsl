vec4 data_kleinBottle(vec3 p){
    vec4 x = vec4(p.x, 1.0, 0.0, 0.0);
    vec4 y = vec4(p.y, 0.0, 1.0, 0.0);
    vec4 z = vec4(p.z, 0.0, 0.0, 1.0);
    vec4 x2 = tsqr(x);
    vec4 y2 = tsqr(y);
    vec4 z2 = tsqr(z);
    vec4 v = tmul(x2 + y2 + z2 + 2.0*y - vec4(1.0, 0.0, 0.0, 0.0), tsqr(x2 + y2 + z2 - 2.0*y - vec4(1.0, 0.0, 0.0, 0.0)) - 8.0*z2) + 16.0*tmul(x, z, x2 + y2 + z2 - 2.0*y - vec4(1.0, 0.0, 0.0, 0.0));
    return v.yzwx;
}
