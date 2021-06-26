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
    sextic.center=vec3(1,0,3);
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
    iso.scale=6.;

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
//Finding the Bounding Boxes
//-------------------------------------------------

int varIndex;

float trace_VarietyBBox( Vector tv, out bool insideVar ){

    float dist1 = trace( tv, sextic.boundingBox );
    float dist2 = trace( tv, iso.boundingBox );

    bool var1=inside( tv, sextic.boundingBox );
    bool var2=inside( tv, iso.boundingBox );

    insideVar=var1||var2;
    if(var1){
        varIndex=1;
    }
    if(var2){
        varIndex=2;
    }

    float dist=min(dist1,dist2);

    //move back a little bit so we are not RIGHT on the surface...
    //prevents some weird things
    return dist-EPSILON/2.;
}



//-------------------------------------------------
//Finding the Variety in the Box
//-------------------------------------------------

float variety( Vector tv ){

    if(varIndex==1){
        return variety(tv, sextic);
    }
    if(varIndex==2){
        return variety(tv, iso);
    }
     return maxDist;
}



//-------------------------------------------------
//Setting the Walls Data
//-------------------------------------------------

void setData_Varieties(inout Path path){
    setData(path, sextic);
    setData(path,iso);
}