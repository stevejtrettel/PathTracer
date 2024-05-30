
CocktailGlass cGlass;
Cocktail negroni;
Pint pint;
Beer beer;



void buildGlasses(){

    vec3 color;
    float specularity, roughness;
    vec3 brownAbsorb=(vec3(1.)-vec3(204./255.,142./255.,105./255.));
    vec3 redAbsorb=vec3(0.2,1.,0.6);
    vec3 whiskey=vec3(0.18,0.43,0.62);


    //-------- COCKTAIL GLASS----------------

    cGlass.center=vec3(-1.,-0.15,-1.2);
    cGlass.radius=1.;
    cGlass.height=1.;
    cGlass.thickness=0.1;
    cGlass.base=0.3;
    cGlass.mat=makeGlass(0.1*vec3(0.3,0.05,0.05),1.5,0.99);


    //-------- NEGRONI ----------------
    negroni.glass=cGlass;
    negroni.cup=makeGlass(0.1*vec3(0.3,0.05,0.2),1.5,0.95);
    negroni.drink=makeGlass(3.*(brownAbsorb+0.25*redAbsorb),1.2,0.99);

    //    negroni.drink=makeGlass(vec3(0.),1.2,0.99);
    //    negroni.drink.refractionChance=0.0;
    //    negroni.drink.subSurface=true;
    //    negroni.drink.meanFreePath=0.1;
    //    negroni.drink.roughness=0.4;

    //----------PINT GLASS----------
    pint.center=vec3(-1,-0.9,-2);
    pint.height=2.;
    pint.base=0.75;
    pint.flare=1.5;
    pint.thickness=0.01;
    pint.rounded=0.;
    pint.mat=makeGlass(0.1*vec3(0.3,0.05,0.2),1.5,0.95);

    //-------- BEER ----------------
    beer.glass=pint;
    beer.cup=makeGlass(0.2*vec3(0.3,0.05,0.2),1.5,0.95);


    //    negroni.drink.diffuseColor=vec3(1.);
    //    negroni.drink.absorbColor=vec3(0.);
    //    //vec3(1)-0.9*vec3(0.3,0.2,0.6);
    //    negroni.drink.refractionChance=0.;
    //    negroni.drink.subSurface=true;
    //    negroni.drink.meanFreePath=0.05;
    //    negroni.drink.roughness=1.;

    // beer.drink=makeGlass(3.*(brownAbsorb+0.25*redAbsorb),1.2,0.99);
    //0.5*vec3(0.02,0.02,0.06)
    //beer.drink.refractionChance=0.0;
    //beer.drink.subSurface=true;
    //beer.drink.meanFreePath=0.4;
    //beer.drink.roughness=0.5;


    beer.drink=makeGlass(2.5*vec3(0.03,0.15,0.9),1.2,0.99);
    //beer.drink.diffuseColor=vec3(1);
    //beer.drink.absorbColor=vec3(0);
    //vec3(1)-0.9*vec3(0.3,0.2,0.6);
    beer.drink.refractionChance=0.;
    beer.drink.subSurface=true;
    beer.drink.meanFreePath=0.1;
    beer.drink.isotropicScatter=0.;
    //beer.drink.roughness=0.9;



}