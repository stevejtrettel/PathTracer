vec4 data_quadricCone(vec3 p){
    vec4 x = vec4(p.x, 1.0, 0.0, 0.0);
    vec4 y = vec4(p.y, 0.0, 1.0, 0.0);
    vec4 z = vec4(p.z, 0.0, 0.0, 1.0);
    vec4 w = vec4(1.0, 0.0, 0.0, 0.0);      //the affine patch: w = 1
    vec4 x2 = tsqr(x);
    vec4 y2 = tsqr(y);
    vec4 z2 = tsqr(z);
    vec4 w2 = tsqr(w);
    vec4 v = x2 + y2 - z2 - w2;
    return v.yzwx;
}
