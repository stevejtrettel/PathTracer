





float variety(vec3 pos){
    // return fermat(pos,4.);
    //return chmutov(pos,-1.);
    //return  sexticEqn(pos);
    //return kummer(pos,1.3);
    return endrass(pos);

}






float variety(Vector tv){
    return variety(tv.pos.coords.xyz);
}


vec3 gradient(Vector tv){

    vec3 pos=tv.pos.coords.xyz;

    const float ep = 0.0001;
    vec2 e = vec2(1.0,-1.0)*0.5773;

    float vxyy=variety( pos + e.xyy*ep);
    float vyyx=variety( pos + e.yyx*ep);
    float vyxy=variety( pos + e.yxy*ep);
    float vxxx=variety( pos + e.xxx*ep);

    vec3 dir=  e.xyy*vxyy + e.yyx*vyyx + e.yxy*vyxy + e.xxx*vxxx;

    return normalize(dir);
}
