Variety var;
GlassVariety gVar;
GlassMarble marble;


void buildVarieties(){

    vec3 color;
    float specularity, roughness;
    vec3 brownAbsorb=(vec3(1.)-vec3(204./255.,142./255.,105./255.));
    vec3 redAbsorb=vec3(0.2,1.,0.6);
    vec3 whiskey=vec3(0.18,0.43,0.62);


    var.center=vec3(-2,1.5,-2);
    var.size=2.;
    var.inside=0.0075;
    var.outside=0.00;
    var.boundingSphere=2.;
    //3.1415;
    var.smoothing =0.065;

    //color= vec3(0.4,0.3,0.2);
    //specularity=0.5;
    //roughness=0.01;

    //    color = 0.6*vec3(0.3,0.2,0.6);
    //var.mat= makeMetal(color,specularity,roughness);
    //    var.mat.diffuseColorBack = 0.4*vec3(0.2,0.6,0.3);

    //var.mat=makeGlass(10.*vec3(0.05,0.1,0.15),1.4,0.95);
    //var.mat=makeGlass(10.*vec3(0.3,0.05,0.2),1.5,0.95);
    //var.mat=makeGlass(8.*vec3(0.3,0.2,0.01),1.6,0.95);

    //    var.mat= makeMetal(color,specularity,roughness);
    //    var.mat.diffuseColorBack=vec3(1,0,0);

    //    var.mat= makeGlass(0.75*vec3(0.3,0.05,0.2),1.5,0.995);
    //    var.mat=makeGlass(40.*vec3(0.2,0.4,0.05),1.5,0.99);
    var.mat=makeGlass(30.*(brownAbsorb+0.25*redAbsorb),1.5,0.99);
    var.mat.refractionChance=0.;
    var.mat.subSurface=true;
    var.mat.meanFreePath=0.2*extra2;
    var.mat.isotropicScatter=extra;
    var.mat.roughness=0.7;



    Material glassMat = makeGlass(0.25*vec3(0.3,0.05,0.2),1.1,0.99);
    float glassThickness=0.005;
    gVar = createGlassVariety(var,glassMat,glassThickness);

    Material outerVarMat = makeGlass(5.*vec3(0.05,0.5,0.05),1.4,0.95);
    marble = createGlassMarble(var,outerVarMat, glassMat);


}