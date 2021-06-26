//-------------------------------------------------
// VARIETIES IN THE SCENE
// describes the bounding box / equation for algebraic varieties in the scene
//-------------------------------------------------




//-------------------------------------------------
//Defining the Varieties
//-------------------------------------------------

BarthSextic sextic;

//this function constructs the varieties
void buildVarieties(){

    vec3 color;
    float specularity,roughness;


    //----------- BARTH SEXTIC -------------------------
    sextic.center=vec3(2,1,0);
    sextic.scale=4.;

    color= 0.7*vec3(0.3,0.2,0.6);
    specularity=0.2;
    roughness=0.01;
    sextic.mat=makeDielectric(color,specularity,roughness);
    sextic.mat.diffuseColorBack=0.7*vec3(109,194,242)/255.;
    sextic.mat.diffuseColor=0.7*vec3(163,124,250)/255.;

    sextic.boundingBox.center=sextic.center;
    sextic.boundingBox.radius=1.5;
    sextic.boundingBox.mat=makeGlass(0.5*vec3(0.3,0.05,0.08),1.4,0.99);
    //air(vec3(0));

}




//-------------------------------------------------
//Finding the Bounding Boxes
//-------------------------------------------------

float trace_VarietyBBox( Vector tv, out bool insideVar ){

    float dist = trace( tv, sextic.boundingBox );

    insideVar = inside( tv, sextic.boundingBox );

    //move back a little bit so we are not RIGHT on the surface...
    //prevents some weird things
    return dist-EPSILON/2.;
}



//-------------------------------------------------
//Finding the Variety in the Box
//-------------------------------------------------

float variety( Vector tv ){
    return variety(tv, sextic);
}



//-------------------------------------------------
//Setting the Walls Data
//-------------------------------------------------

void setData_Varieties(inout Path path){
    setData(path, sextic);
}