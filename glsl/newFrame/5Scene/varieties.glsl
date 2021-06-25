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
    sextic.center=Point(vec3(-3,1.,2.));
    sextic.scale=1.5;

    color= 0.7*vec3(0.3,0.2,0.6);
    specularity=0.2;
    roughness=0.01;
    sextic.mat=makeDielectric(color,specularity,roughness);


    sextic.boundingBox.center=sextic.center;
    sextic.boundingBox.radius=1.5;
    sextic.boundingBox.mat=air(vec3(0.2,0.1,0.));
    
}




//-------------------------------------------------
//Finding the Bounding Boxes
//-------------------------------------------------

float trace_VarietyBBox( Path path, float stopDist, out bool insideVar ){

    float dist=stopDist;

    dist=sphereTrace(path, sextic.boundingBox, dist);

    insideVar = (sphereDistance(path.tv,sextic.boundingBox)<0.);

    //add a little so you end up on the other side
    return dist;

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

void setDataVarieties(inout Path path){
    setData(path, sextic);
}