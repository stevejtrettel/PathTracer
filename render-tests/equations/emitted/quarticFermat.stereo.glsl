vec4 data_quarticFermat(vec3 p){
    vec4 x, y, z, w;
    invStereo(vec4(p.x, 1.0, 0.0, 0.0),
              vec4(p.y, 0.0, 1.0, 0.0),
              vec4(p.z, 0.0, 0.0, 1.0), x, y, z, w);
    vec4 x2 = tsqr(x);
    vec4 x4 = tsqr(x2);
    vec4 y2 = tsqr(y);
    vec4 y4 = tsqr(y2);
    vec4 z2 = tsqr(z);
    vec4 z4 = tsqr(z2);
    vec4 w2 = tsqr(w);
    vec4 w4 = tsqr(w2);
    vec4 v = x4 + y4 + z4 - w4;
    return v.yzwx;
}
