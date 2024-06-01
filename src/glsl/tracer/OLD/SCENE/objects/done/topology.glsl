
Torus torus;
Mobius mobius;
Mobius mobius2;
KleinBottle kB;




void buildTopology(){

    vec3 color;
    float specularity, roughness;
    vec3 brownAbsorb=(vec3(1.)-vec3(204./255.,142./255.,105./255.));
    vec3 redAbsorb=vec3(0.2,1.,0.6);
    vec3 whiskey=vec3(0.18,0.43,0.62);



    mobius.center=vec3(-5,1,-2);
    mobius.twists=1.;
    mobius.radius=1.;
    mobius.width =0.4;
    mobius.thickness=0.04;
    mobius.offset=false;
    //mobius.borderMat = makeGlass(0.5*vec3(0.3,0.05,0.05),1.5,extra2);

    mobius.bandMat=makeGlass(30.*(0.75*brownAbsorb+0.5*redAbsorb),1.5,0.99);
    mobius.bandMat.refractionChance=0.;
    mobius.bandMat.subSurface=true;
    mobius.bandMat.meanFreePath=0.2*extra2;
    mobius.bandMat.isotropicScatter=extra;
    mobius.bandMat.roughness=0.7;

    //mobius.borderMat=makeMetal(vec3(0.02),specularity,0.4);
    mobius.borderMat=makeGlass(10.*(brownAbsorb+0.25*redAbsorb),1.5,0.99);
    mobius.borderMat.refractionChance=0.;
    mobius.borderMat.subSurface=true;
    mobius.borderMat.meanFreePath=0.05;
    mobius.borderMat.isotropicScatter=0.4;
    mobius.borderMat.roughness=0.3;


    mobius2.center=vec3(-5,1,-2);
    mobius2.twists=1.;
    mobius2.radius=1.;
    mobius2.width =0.4;
    mobius2.thickness=0.04;
    mobius2.offset=true;

    //mobius2.bandMat = makeGlass(0.5*vec3(0.3,0.05,0.05),1.1,extra2);
    mobius2.bandMat=makeGlass(20.*vec3(1,0.6,0.3),1.5,0.99);
    mobius2.bandMat.refractionChance=0.;
    mobius2.bandMat.subSurface=true;
    mobius2.bandMat.meanFreePath=0.2*extra2;
    mobius2.bandMat.isotropicScatter=extra;
    mobius2.bandMat.roughness=0.7;

    mobius2.borderMat=makeGlass(0.5*vec3(1,0.6,0.3),1.5,0.99);
    mobius2.borderMat.refractionChance=0.;
    mobius2.borderMat.subSurface=true;
    mobius2.borderMat.meanFreePath=0.1;
    mobius2.borderMat.isotropicScatter=0.6;
    mobius2.borderMat.roughness=0.3;
    //makeMetal(vec3(0.2),specularity,0.4);



    kB.center=vec3(-2,1,-2);
    kB.size=1.;
    kB.thickness=0.05;
    kB.mat = makeGlass(2.5*vec3(0.3,0.05,0.05),1.5,0.95);


}