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
    vec3 dir=normalize(tv.pos.coords-sph.center.coords);
    return Vector(tv.pos,dir);
}




vec2 sphereIntersections(Vector tv, Sphere sph){
    //return all intersections with the sphere along the line:
    vec3 p=tv.pos.coords-sph.center.coords;
    vec3 v=tv.dir;

    float a=dot(v,v);
    float b=2.*dot(p,v);
    float c=(dot(p,p)-sph.radius*sph.radius)/a;

    float disc=b*b-4.*a*c;
    if(disc<0.){
        //intersections do not exist
        return 2.*vec2(maxDist,maxDist);
    }
    //else, return the two intersection points:
    else {
        float D=sqrt(abs(disc));
        return vec2(-b-D, -b+D)/(2.*a);
    }
}


//float sphereTrace(inout Path path, Sphere sphere, float stopDist){
//
//    vec2 intPt=sphereIntersections(path.tv,sphere);
//
//    if(intPt.y<0.||intPt.x>stopDist){
//        //the sphere is not in front of us
//        return stopDist;
//    }
//
//    //otherwise, find the first intersection of the sphere:
//    float dist=intPt.x<0.?intPt.y:intPt.x;
//
//    if(dist<stopDist){
//
//        Vector test=path.tv;
//        flow(test,dist);
//
//        //compute the normal
//        Vector normal=sphereNormal(test,sphere);
//
//        //set the material
//        setObjectInAir(path.dat,dist,normal,sphere.mat);
//
//    }
//
//    return min(dist,stopDist);
//}





//------sdf
//float sphereSDF(inout Path path, Sphere sph, float stopDist){
//
//    if(stopDist<EPSILON){return stopDist;}
//
//    //distance to closest point:
//    float dist = sphereDistance(path.tv,sph);
//
//    if(abs(dist)<EPSILON){
//
//        //compute the normal
//        Vector normal=sphereNormal(path.tv,sph);
//
//        //set the material
//        setObjectInAir(path.dat,dist,normal,sph.mat);
//
//    }
//
//    return min(dist,stopDist);
//}

float sphereSDF(Path path, Sphere sph){

    float dist = sphereDistance(path.tv,sph);
    return dist;
}






float sphereTrace(Path path, Sphere sphere, float stopDist){

    vec2 intPt=sphereIntersections(path.tv,sphere);

    if(intPt.y<0.||intPt.x>stopDist){
        //the sphere is not in front of us
        return stopDist;
    }
    //otherwise, find the first intersection of the sphere:
    float dist=intPt.x<0.?intPt.y:intPt.x;
    return min(dist,stopDist);

}

void setSphereData(inout Path path, Sphere sphere){

    //see if we are at the plane: if not, do nothing
    float dist=sphereDistance(path.tv,sphere);

    if(abs(dist)<EPSILON){
        //compute the normal
        Vector normal=sphereNormal(path.tv,sphere);

        //set the material
        setObjectInAir(path.dat,dist,normal,sphere.mat);
    }

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



float planeIntersection(Vector tv, Plane plane){

    float denom=dot(tv.dir,plane.normal);

    if(denom>0.){return maxDist;}

    //otherwise, aimed at plane
    return -(plane.offset+dot(tv.pos.coords.xyz,plane.normal))/denom;
}




float planeSDF(Path path,  Plane plane, float stopDist){

    float dist=planeDistance(path.tv,plane);
    return min(dist,stopDist);

}



float planeTrace(Path path, Plane plane, float stopDist){

    float dist=planeIntersection(path.tv,plane);
    return min(dist,stopDist);

}



void setPlaneData(inout Path path, Plane plane){

    //see if we are at the plane: if not, do nothing
    float dist=planeDistance(path.tv,plane);

    if(abs(dist)<EPSILON){
        //compute the normal
        Vector normal=planeNormal(path.tv,plane);

        //set the material
        setObjectInAir(path.dat,dist,normal,plane.mat);
    }

}