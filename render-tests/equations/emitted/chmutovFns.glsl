vec4 cheb(vec4 x, int n){
    for(int i = 0; i < n; i++){
        x = 2.0*tmul(x, x) - vec4(1.0, 0.0, 0.0, 0.0);
    }
    return x;
}

vec4 chmutov(vec4 x, vec4 y, vec4 z){
    int n = 2;
    return cheb(x, n) + cheb(y, n) + cheb(z, n) + vec4(1.0, 0.0, 0.0, 0.0);
}

vec4 data_chmutovFns(vec3 p){
    vec4 x = vec4(p.x, 1.0, 0.0, 0.0);
    vec4 y = vec4(p.y, 0.0, 1.0, 0.0);
    vec4 z = vec4(p.z, 0.0, 0.0, 1.0);
    vec4 v = chmutov(x, y, z);
    return v.yzwx;
}
