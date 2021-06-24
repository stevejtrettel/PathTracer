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
    sextic.center=Point(vec3(0,1.,-3.));
    sextic.scale=3.;
    sextic.boundingBox.center=sextic.center;
    sextic.boundingBox.radius=1.;

    color= vec3(0.9,0.9,0.5);
    specularity=0.8;
    roughness=0.;
    sextic.mat= makeMetal(color,specularity,roughness);

}




//-------------------------------------------------
//Finding the Bounding Boxes
//-------------------------------------------------

float traceBBox( Path path, float stopDist ){

    float dist=stopDist;

    dist=sphereTrace(path, sextic.boundingBox, dist);

    //add a little so you end up on the other side
    return dist+5.*EPSILON;

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