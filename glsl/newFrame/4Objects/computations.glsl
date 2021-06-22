//-------------------------------------------------
// COMPUTATIONS FOR CREATING OBJECTS
// every function here  is only used in basicObject and compoundObject
// these should never appear outside this folder
//-------------------------------------------------




//-------------------------------------------------
//  Basic Functions
//-------------------------------------------------

float sphereDist(vec3 pos, float radius){

    return length(pos)-radius;
}


//the directed distance function: this can be improved with a better sphere locator test
float sphereDist(Vector tv, float radius){

    float d = sphereDist(tv.pos.coords, radius);

    //if you are looking away from the sphere, stop
    if(d>0.&&dot(tv.dir,tv.pos.coords)>0.){return maxDist;}

    //otherwise return the actual distance
    return d;
}


//----normal vector
vec3 sphereGrad(vec3 pos,  float radius){
    return normalize(pos);
}

//----normal vector
vec3 sphereGrad(Vector tv,  float radius){
    return normalize(tv.pos.coords);
}










//-------------------------------------------------
//-------------------------------------------------
//=====distance to a
//========PLANE
//-------------------------------------------------
//-------------------------------------------------


//-------------------------------------------------
//  Basic Functions
//-------------------------------------------------


float planeDist(vec3 pos, vec3 normal){

    return dot(pos,normal);
}


float planeDist(Vector tv, vec3 normal){

    if(dot(tv.dir,normal)>0.){return maxDist;}
    //otherwise, aimed at plane
    return planeDist(tv.pos.coords,normal);
}


vec3 planeGrad(vec3 pos, vec3 normal){
    return normal;
}





