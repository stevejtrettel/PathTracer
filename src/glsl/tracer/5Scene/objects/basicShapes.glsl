//set the names of global variables for the walls here:
Sphere ball1, ball2, ball3;
Box table, box;


void buildBasicShapes(){

    vec3 color;
    float specularity, roughness;
    vec3 brownAbsorb=(vec3(1.)-vec3(204./255.,142./255.,105./255.));
    vec3 redAbsorb=vec3(0.2,1.,0.6);
    vec3 whiskey=vec3(0.18,0.43,0.62);

    //----------- BALL 1 -------------------------
    ball1.center=vec3(1,0.3,-2);
    ball1.radius=1.3;

    color= vec3(0.9,0.9,0.5);
    specularity=0.8;
    roughness=0.;
    ball1.mat= makeMetal(color,specularity,roughness);

    //----------- BALL 2 -------------------------
    ball2.center=vec3(0,-0.5,2);
    ball2.radius=0.55;

    color= 0.7*vec3(0.3,0.2,0.6);
    specularity=0.2;
    roughness=0.01;
    ball2.mat=makeDielectric(color,specularity,roughness);


    //----------- BALL 3 -------------------------
    ball3.center=vec3(0);
    //vec3(1.5,0.6,2);
    ball3.radius=6.6;

    color= 0.1*vec3(0.7,0.1,0.2);
    specularity=0.4;
    roughness=0.1;
    //ball3.mat=makeMetal(color,specularity,roughness);
    ball3.mat=makeGlass(0.3*vec3(0.3,0.05,0.2),1.5);





    //----------- BOX  -------------------------
    box.center=vec3(0.,-2.75,0.);
    box.sides=vec3(3,0.25,3);
    box.rounded=0.1;

    color= 0.25*vec3(0.4,0.3,0.2);
    specularity=0.5;
    roughness=0.01;

    zeroMat(box.mat);
    box.mat = makeMetal(color,specularity,roughness);
    //  box.mat = makeGlass(0.5*vec3(0.3,0.05,0.2),1.75,0.95);


    //----------- TABLE  -------------------------
    table.center=vec3(-1,-3.35,-2);
    table.sides=vec3(3,0.25,3);
    table.rounded=0.1;

    color= vec3(0.1);
    specularity=0.05;
    roughness=0.2;
    table.mat=makeMetal(color,specularity,roughness);



}