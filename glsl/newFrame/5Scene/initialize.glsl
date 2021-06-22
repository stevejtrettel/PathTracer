//-------------------------------------------------
//The OBJECTS
//-------------------------------------------------


//global variables which are the names of the possible objects in the scene
Sphere light1;
Sphere light2;
Sphere light3;
Sphere light4;

Sphere ball1;
Sphere ball2;
Sphere ball3;

Plane wall1;
Plane wall2;
Plane wall3;








//this function assigns all the objects their parameters
void buildScene(){

    //some useful variables for setting parameters
    vec3 color;
    float intensity;
    float specularity;
    float roughness;
    float IOR;

    vec3 normal;
    float offset;
    vec3 absorb;
    float thickness;
    vec3 axis;
    vec3 center;
    float radius;
    float length;
    float width;



    //----------- LIGHT 2 -------------------------
    light2.center=Point(vec3(-10,15.5,-5));
    light2.radius=3.;

    color= vec3(255./255., 147./255., 41./255.);
    // vec3(1.,0.6,0.4);
    intensity=35.;

    light2.mat=makeLight(color,intensity);



    //----------- LIGHT 3 -------------------------
    light3.center=Point(1.25*vec3(0,2,-4));
    light3.radius=0.6;

    color= vec3(1.,0.6,0.4);
    intensity=5.;

    light3.mat=makeLight(color,intensity);



    //----------- LIGHT 4 -------------------------
    light4.center=Point(vec3(3,0,-2));
    light4.radius=0.2;

    color= vec3(1.,0.6,0.4);
    intensity=10.;

    light4.mat=makeLight(color,intensity);



    //----------- BALL 1 -------------------------
    ball1.center=Point(vec3(-1,0,-4));
    ball1.radius=1.;

    color= vec3(0.9,0.9,0.5);
    specularity=0.8;
    roughness=0.;

    ball1.mat= makeMetal(color,specularity,roughness);
    //ball1.mat=makeGlass(vec3(0.1),1.53);




    //----------- BALL 2 -------------------------
    ball2.center=Point(vec3(0,0,4));
    ball2.radius=0.55;

    color= 0.7*vec3(0.3,0.2,0.6);
    specularity=0.2;
    roughness=0.01;

    ball2.mat=makeDielectric(color,specularity,roughness);

    //absorb=vec3(0.3,0.05,0.2);
    //ball2.mat=makeGlass(absorb,2.3);




    //----------- BALL 3 -------------------------
    ball3.center=Point(vec3(0.,0.,-2));
    ball3.radius=0.6;

    color= 0.1*vec3(0.7,0.1,0.2);
    specularity=0.4;
    roughness=0.1;

    //ball3.mat=makeMetal(color,specularity,roughness);

    ball3.mat=makeGlass(0.3*vec3(0.3,0.05,0.2),1.3);










    //----------- WALL 1 -------------------------
    normal=vec3(0,1,0);
    offset=1.6;

    //color=vec3(0.5,0.9,0.5);
    color= vec3(.2);
    specularity=0.0;
    roughness=0.1;

    setPlane(wall1,normal,offset);
    wall1.mat=makeDielectric(color,specularity,roughness);



    // wall1.mat=makeGlass(0.3*vec3(0.3,0.05,0.2),1.3,0.6);




    //----------- WALL 2 -------------------------
    normal=vec3(0,0,1);
    offset=19.;

    //color=vec3(0.9,0.5,0.5);
    color= vec3(0.2);
    //color=vec3(0.7,0.7,0.8);
    specularity=0.0;
    roughness=0.;

    setPlane(wall2,normal,offset);
    wall2.mat=makeDielectric(color,specularity,roughness);







    //----------- WALL 3 -------------------------
    normal=vec3(1,0,0.2);
    //normal=vec3(1,0,0);
    offset=15.;
    //offset=5.;

    // color=vec3(0.7,0.7,0.8);
    color= vec3(0.2);
    //color=vec3(0.5,0.9,0.5);
    specularity=0.0;
    roughness=0.5;

    setPlane(wall3,normal,offset);
    wall3.mat=makeDielectric(color,specularity,roughness);

}

