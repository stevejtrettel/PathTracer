

//-------------------------------------------------
// The POINCARE BALL MARBLE sdf
//-------------------------------------------------


struct PoincareMarble{
    HypDod dod;
    Sphere glass;
};

PoincareMarble createPoincareMarble(Material dodMat, Material glassMat ){

    float thickness = 0.04;

    PoincareMarble obj;
    //obj.dod = buildHypDod();
    obj.dod = buildHypDod(0.4);
    obj.dod.mat = dodMat;

    obj.glass = Sphere(vec3(0,0,0), 1.,glassMat);
    return obj;

}


//overload of sdf for the cocktail struct
float sdf( Vector tv, PoincareMarble marble){

    float innerDist = sdf(tv, marble.dod);
    float glassDist = sdf(tv, marble.glass);

    //make the total distance:
    float dist = min( abs(glassDist), abs(innerDist) );

    return dist;
}



//overload of set data
void setData(inout Path path, PoincareMarble marble){

    Vector normal;

    float innerDist = sdf(path.tv, marble.dod);
    float glassDist = sdf(path.tv, marble.glass);

    if( (abs(glassDist) < abs(innerDist)) ){
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



    else {
        //----if we hit the outer variety, inside the glass
        //the only way to hit the surface of the outer variety is if we are at an outer/glass interface:

        //get outward pointing normal to this shell
        normal = normalVec(path.tv, marble.dod);

        //figure out if we are incoming or outgoing:
        bool insideOuterMat = dot(path.tv.dir,normal.dir)>0.;

        //if we are outgoing: we are leaving the variety material and going into the glass
        if (insideOuterMat) {
            path.dat.normal=negate(normal);
            setMaterialInterface(path.dat, marble.dod.mat, marble.glass.mat, marble.dod.mat);
        }

        else {
            //if we are ingoing: we are leaving the clear glass and going into the variety
            path.dat.normal=normal;
            setMaterialInterface(path.dat, marble.glass.mat, marble.dod.mat, marble.dod.mat);
        }

    }

}










