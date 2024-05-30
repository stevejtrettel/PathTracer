HypDod dod,dodE;
PoincareMarble poin;
HypCoxCube cube5,cube6;


void buildHypGeo(){
    vec3 color;
    float specularity, roughness;
    vec3 brownAbsorb=(vec3(1.)-vec3(204./255.,142./255.,105./255.));
    vec3 redAbsorb=vec3(0.2,1.,0.6);
    vec3 whiskey=vec3(0.18,0.43,0.62);






    dod = buildHypDod();

    dod.mat=makeGlass(6.*(brownAbsorb+0.25*redAbsorb),1.5,0.97);
    dod.center = vec3(1.5,-0.5,2.25);
    //dod.mat = makeMetal(color,specularity,roughness);
    //    dod.mat = makeGlass(0.5*vec3(0.3,0.05,0.05),1.5,extra2);
    //    dod.mat.refractionChance=0.;
    //    dod.mat.subSurface=true;
    //    dod.mat.meanFreePath=0.5*extra2;
    //    dod.mat.isotropicScatter=extra;
    //    dod.mat.roughness=0.04;


    dodE = buildHypDod(0.4);
    dodE.center = vec3(-2,-0.5,2);
    //dod.mat=makeGlass(3.*(brownAbsorb+0.25*redAbsorb),1.2,0.99);
    dodE.mat = makeDielectric(vec3(0.5,0.2,0.4),specularity,roughness);
    dodE.mat=makeGlass(20.*(0.5*brownAbsorb+0.5*redAbsorb),1.5,0.95);
    dodE.mat.refractionChance=0.;
    dodE.mat.subSurface=true;
    dodE.mat.meanFreePath=0.5*extra2;
    dodE.mat.isotropicScatter=extra;
    dodE.mat.roughness=0.04;

    //dod.mat=makeGlass(20.*(0.5*brownAbsorb+0.5*redAbsorb),1.5,0.95);
    //dod.mat.refractionChance=0.;
    //dod.mat.subSurface=true;
    //dod.mat.meanFreePath=0.5*extra2;
    //dod.mat.isotropicScatter=extra;
    //dod.mat.roughness=0.04;
    //

    Material dodMat = makeGlass(30.*(brownAbsorb+0.25*redAbsorb),2.5,0.95);
    Material glassMat = makeGlass(0.2*vec3(0.3,0.05,0.2),1.5,0.99);
    poin = createPoincareMarble(dodMat, glassMat);

    //    poin.dod.mat.refractionChance=0.;
    //    poin.dod.mat.subSurface=true;
    //    poin.dod.mat.meanFreePath=0.5*extra2;
    //    poin.dod.mat.isotropicScatter=extra;
    //    poin.dod.mat.roughness=0.04;


    cube5 = buildCoxCube(3.);
    //makeMetal(color,specularity,roughness);
    //cube5.mat = makeGlass(0.5*vec3(0.3,0.05,0.05),1.5,extra2);
    cube5.mat=makeGlass(20.*(vec3(1)-vec3(0.6,0.1,0.5)),1.5,0.95);
    cube5.mat.refractionChance=0.;
    cube5.mat.subSurface=true;
    cube5.mat.meanFreePath=0.5*extra2;
    cube5.mat.isotropicScatter=extra;
    cube5.mat.roughness=0.04;


}