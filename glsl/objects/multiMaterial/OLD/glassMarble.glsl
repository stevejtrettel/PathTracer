
//-------------------------------------------------
// The GLASS MARBLE sdf
//-------------------------------------------------


struct GlassMarble{
    Variety innerVar;
    Variety outerVar;
    Sphere glass;
};

GlassMarble createGlassMarble(Variety surf, Material outerMat, Material glassMat ){

    float thickness = 0.04;

    GlassMarble obj;
    obj.innerVar = surf;

    obj.outerVar.center = surf.center;
    obj.outerVar.size = surf.size;
    obj.outerVar.boundingSphere = 0.75*surf.boundingSphere;
    obj.outerVar.inside = surf.inside;
    obj.outerVar.outside = surf.outside+thickness;
    obj.outerVar.smoothing = surf.smoothing;
    obj.outerVar.mat = outerMat;

    obj.glass = Sphere(surf.center, 1.2*surf.boundingSphere,glassMat);
    return obj;

}


//overload of sdf for the cocktail struct
float sdf( Vector tv, GlassMarble marble){

    float innerDist = sdf(tv, marble.innerVar);
    float outerDist = sdf(tv, marble.outerVar);
    float glassDist = sdf(tv, marble.glass);

    //make the total distance:
    float dist = min(abs(glassDist), min( abs(innerDist), abs(outerDist)));

    return dist;
}



//overload of set data
void setData(inout Path path, GlassMarble marble){

    Vector normal;

    float innerDist = sdf(path.tv, marble.innerVar);
    float outerDist = sdf(path.tv, marble.outerVar);
    float glassDist = sdf(path.tv, marble.glass);

    if((abs(glassDist) < abs(outerDist)) && (abs(glassDist) < abs(innerDist)) ){
        //----if we hit the glass outside of the marble:
        //get outward pointing normal to this shell
        normal = normalVec(path.tv, marble.glass);

        //figure out if we are incoming or outgoing:
        bool insideGlass = dot(path.tv.dir,normal.dir)>0.;

        //if we are outgoing: we are leaving the glass material and going into the air
        if (insideGlass) {
            setObjectInAir(path.dat, true, normal, marble.glass.mat);
        }

        else {
            //if we are ingoing: we are leaving the air and going into the glass
            setObjectInAir(path.dat, false, normal, marble.glass.mat);
        }

    }



    else if( abs(outerDist)<abs(innerDist) ) {
        //----if we hit the outer variety, inside the glass
        //the only way to hit the surface of the outer variety is if we are at an outer/glass interface:

        //get outward pointing normal to this shell
        normal = normalVec(path.tv, marble.outerVar);

        //figure out if we are incoming or outgoing:
        bool insideOuterMat = dot(path.tv.dir,normal.dir)>0.;

        //if we are outgoing: we are leaving the variety material and going into the glass
        if (insideOuterMat) {
            path.dat.normal=negate(normal);
            setMaterialInterface(path.dat, marble.outerVar.mat, marble.glass.mat, marble.outerVar.mat);
        }

        else {
            //if we are ingoing: we are leaving the clear glass and going into the variety
            path.dat.normal=normal;
            setMaterialInterface(path.dat, marble.glass.mat, marble.outerVar.mat, marble.outerVar.mat);
        }

    }

    else {
        //----if we hit the inner shell
        // there's two ways to do this: we can be going directly inner/glass
        //or we can be going outer/inner.

        //get outward pointing normal to this shell
        normal = normalVec(path.tv, marble.innerVar);

        //figure out if we are incoming or outgoing:
        bool insideInnerMat = dot(path.tv.dir,normal.dir)>0.;
        //figure out which material interface we are at:
        bool outerMatInterface = inside(path.tv,marble.outerVar);


        if (insideInnerMat) {
            //inside the mat means negate its normal:
            path.dat.normal=negate(normal);

            if(outerMatInterface){
                //if we are outgoing, from inner material to outer
                setMaterialInterface(path.dat, marble.innerVar.mat, marble.outerVar.mat, marble.outerVar.mat);
            }

            else{
                //if we are outgoing, from inner material to glass
                setMaterialInterface(path.dat, marble.innerVar.mat, marble.glass.mat, marble.innerVar.mat);
            }
        }


        else{
            //if we are incoming, do not negate the normal:
            path.dat.normal=normal;

            if(outerMatInterface){
                //from outer to inner
                setMaterialInterface(path.dat, marble.outerVar.mat, marble.innerVar.mat, marble.innerVar.mat);
            }

            else{
                //from glass material to inner
                setMaterialInterface(path.dat, marble.glass.mat, marble.innerVar.mat, marble.innerVar.mat);
            }
        }

    }

}









