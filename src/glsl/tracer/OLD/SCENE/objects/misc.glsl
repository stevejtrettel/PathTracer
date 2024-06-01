
Bunny bunny;

void buildMisc(){

    vec3 color;
    float specularity, roughness;
    vec3 brownAbsorb=(vec3(1.)-vec3(204./255.,142./255.,105./255.));
    vec3 redAbsorb=vec3(0.2,1.,0.6);
    vec3 whiskey=vec3(0.18,0.43,0.62);


    bunny.center=vec3(0,-0.12,0);
    bunny.scale=2.;
    bunny.mat=makeGlass(0.1*vec3(0.3,0.05,0.2),1.5,0.95);

    bunny.mat=makeGlass(3.*(brownAbsorb+0.25*redAbsorb),1.2,0.9);

    bunny.mat.diffuseColor=vec3(1);
    bunny.mat.absorbColor=vec3(0.1);
    //vec3(1)-0.9*vec3(0,0.65,0.35);
    bunny.mat.emitColor =  0.4*extra2*vec3(1.,0.15,0.);
    bunny.mat.surfaceEmit =  0.1*extra3*vec3(0.75,0.25,0.);
    //vec3(0.01);
    //vec3(1)-0.9*vec3(0.3,0.2,0.6);
    bunny.mat.refractionChance=0.;
    bunny.mat.subSurface=true;
    bunny.mat.meanFreePath=0.2;
    bunny.mat.isotropicScatter=extra;
    bunny.mat.roughness=0.0;


}