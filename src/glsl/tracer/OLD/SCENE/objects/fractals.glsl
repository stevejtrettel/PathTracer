
Gasket gasket;
Kleinian klein;


void buildFractals(){

    vec3 color;
    float specularity, roughness;
    vec3 brownAbsorb=(vec3(1.)-vec3(204./255.,142./255.,105./255.));
    vec3 redAbsorb=vec3(0.2,1.,0.6);
    vec3 whiskey=vec3(0.18,0.43,0.62);

    //----------- GASKET -------------------------
    gasket.center=vec3(0,1.8,0);
    gasket.radius=1.;

    color= vec3(0.4,0.3,0.2);
    specularity=0.5;
    roughness=0.01;
    // gasket.mat= makeMetal(color,specularity,roughness);
    // makeDielectric(color,specularity,roughness);
    //  gasket.mat.surfaceEmit=0.1*vec3(0.02,0.02,0.04);

    gasket.mat=makeGlass(vec3(1)-0.9*vec3(0,0.65,0.35),1.2,0.8);







    klein.center=vec3(0,0,-3);
    color= 0.7*vec3(0.3,0.2,0.6);
    specularity=0.2;
    roughness=0.01;
    //klein.mat=makeDielectric(color,specularity,roughness);

    klein.mat=makeGlass(7.*vec3(0.4,0.25,0.05),1.5,0.95);
    //klein.mat=makeGlass(3.*(brownAbsorb+0.25*redAbsorb),1.2,0.99);
    //makeGlass(7.*vec3(0.5,0.1,0.05),1.5,0.95);
    //makeGlass(3.*vec3(0.3,0.05,0.2),1.5,0.95);

    //klein.mat=makeGlass(3.*(brownAbsorb+0.25*redAbsorb),1.2,0.99);

    // klein.mat.diffuseColor=vec3(1);
    //klein.mat.absorbColor=vec3(0.1);
    //vec3(1)-0.9*vec3(0,0.65,0.35);
    //klein.mat.emitColor =  0.4*extra2*vec3(1.,0.15,0.);
    //klein.mat.surfaceEmit =  0.1*extra3*vec3(0.75,0.25,0.);
    //vec3(0.01);
    //vec3(1)-0.9*vec3(0.3,0.2,0.6);
    klein.mat.refractionChance=0.;
    klein.mat.subSurface=true;
    klein.mat.meanFreePath=0.5*extra2;
    klein.mat.isotropicScatter=extra;
    klein.mat.roughness=0.04;



}