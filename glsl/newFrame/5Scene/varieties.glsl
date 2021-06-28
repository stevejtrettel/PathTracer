//-------------------------------------------------
// VARIETIES IN THE SCENE
// describes the bounding box / equation for algebraic varieties in the scene
//-------------------------------------------------




//-------------------------------------------------
//Defining the Varieties
//-------------------------------------------------

BarthSextic sextic,sextic2;
IsoSurface iso;

//this function constructs the varieties
void buildVarieties(){

    vec3 color;
    float specularity,roughness;


    //----------- BARTH SEXTIC -------------------------
    sextic.center=vec3(1,0,4);
    sextic.scale=4.;

    color= 0.7*vec3(0.3,0.2,0.6);
    specularity=0.2;
    roughness=0.01;
    sextic.mat=makeDielectric(color,specularity,roughness);
    sextic.mat.diffuseColorBack=0.7*vec3(109,194,242)/255.;
    sextic.mat.diffuseColor=0.7*vec3(163,124,250)/255.;

    sextic.boundingBox.center=sextic.center;
    sextic.boundingBox.radius=1.;
    sextic.boundingBox.mat=makeGlass(0.5*vec3(0.3,0.05,0.08),1.4,0.99);
    //air(vec3(0));


    //----------- ENDRASS -------------------------
    iso.center=vec3(-3,0,2);
    iso.scale=10.;

    color= 0.7*vec3(0.3,0.2,0.6);
    specularity=0.2;
    roughness=0.01;
    iso.mat=makeDielectric(color,specularity,roughness);
    iso.mat.diffuseColorBack=0.7*vec3(255,194,130)/255.;
    iso.mat.diffuseColor=0.7*vec3(250,124,163)/255.;

    iso.boundingBox.center=iso.center;
    iso.boundingBox.radius=1.;
    iso.boundingBox.mat=makeGlass(0.5*vec3(0.3,0.05,0.08),1.4,0.99);
    //air(vec3(0));


}




//-------------------------------------------------
//DO WE RENDER THEM?
//-------------------------------------------------

bool render_Varieties=true;




//-------------------------------------------------
//Finding the Bounding Boxes
//-------------------------------------------------

//global variable keeping track of what variety we hit
int varID=0;

float trace_VarietyBBox( Vector tv ){

    bool in1 = inside( tv, sextic.boundingBox );
    float dist1 = trace( tv, sextic.boundingBox );
    if(in1){
        varID=1;
        return dist1-EPSILON/2.;
    }

    bool in2 = inside( tv, iso.boundingBox );
    float dist2 = trace( tv, iso.boundingBox );
    if(in2){
        varID=2;
        return dist2-EPSILON/2.;
    }

    //if inside neither
    varID=0;
    return min(dist1,dist2)-EPSILON/2.;
}



//-------------------------------------------------
//Finding the Variety in the Box
//-------------------------------------------------

float variety( Vector tv ){

    switch(varID){
        case 1: return variety(tv, sextic);
        case 2: return variety(tv, iso);
        default: return maxDist;
    }

}



//-------------------------------------------------
//Setting the Walls Data
//-------------------------------------------------

void setData_Varieties(inout Path path){
    setData(path, sextic);
    setData(path, iso);
}