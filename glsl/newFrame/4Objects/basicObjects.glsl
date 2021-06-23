//-------------------------------------------------
// BASIC OBJECTS
// a basic object is built using a single signed distance function
// or some simple computation, and has one material
//-------------------------------------------------








//-------------------------------------------------
//The SPHERE sdf
//-------------------------------------------------

//the data of a sphere is its center and radius
struct Sphere{
    Point center;
    float radius;
    Material mat;
};

//----distance and normal functions

float sphereDistance(Vector tv, Sphere sph){
    tv.pos.coords-=sph.center.coords;
    return sphereDist(tv,sph.radius);
}

Vector sphereNormal(Vector tv, Sphere sph){
    tv.pos.coords-=sph.center.coords;
    vec3 dir=sphereGrad(tv,sph.radius);
    return Vector(tv.pos,dir);
}


//------sdf
float sphereSDF(Vector tv, Sphere sph,inout localData dat){

    //distance to closest point:
    float dist = sphereDistance(tv,sph);

    if(abs(dist)<EPSILON){

        //compute the normal
        Vector normal=sphereNormal(tv,sph);

        //set the material
        setObjectInAir(dat,dist,normal,sph.mat);
    }

    return dist;
}









//-------------------------------------------------
//The PLANE sdf
//-------------------------------------------------

//the data of a plane is its normal and a constant:

struct Plane{
    vec3 normal;
    float offset;
    Material mat;
};


//normalize the plane's vector before adding it:
void setPlane(inout Plane plane,vec3 normal,float offset){
    normal=normalize(normal);
    plane.normal=normal;
    plane.offset=offset;
}


float planeDistance(Vector tv, Plane plane){
    return planeDist(tv,plane.normal)+plane.offset;
}


Vector planeNormal(Vector tv,Plane plane){
    vec3 dir=planeGrad(tv.pos.coords,plane.normal);
    return Vector(tv.pos, dir);
}


float planeSDF(Vector tv, Plane plane, inout localData dat){

    float dist=planeDistance(tv,plane);

    if(abs(dist)<EPSILON){

        //compute the normal
        Vector normal=planeNormal(tv,plane);

        //set the material
        setObjectInAir(dat,dist,normal,plane.mat);
    }

    return dist;

}



