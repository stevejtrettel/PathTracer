
//-------------------------------------------------
// A variety in a glass sphere
// ------------------------------------------------

struct VarBoxGlass{
    VarBox variety;
    Box glass;
};

//create one starting from a variety and some glass: (set the sphere size appropriately)
VarBoxGlass createVarBoxGlass(VarBox var, Material glassMat){

    VarBoxGlass marble;

    Box glass;
    glass.center = var.center;
    glass.sides = 1.2*var.box;
    glass.rounded = 0.1;
    glass.mat = glassMat;

    marble.variety = var;
    marble.glass = glass;

    return marble;

}



// -------------The Required Functions-----------------------------------

//overload of sdf for the cocktail struct
float sdf( Vector tv, VarBoxGlass marble){

    float varDist = sdf(tv, marble.variety);
    float glassDist = sdf(tv, marble.glass);
    return min(abs(varDist),abs(glassDist));

}


bool inside(Vector tv, VarBoxGlass marble){
    return inside(tv, marble.variety);
}


//overload of set data
void setData(inout Path path, VarBoxGlass marble){

    Vector normal;

    float varDist = sdf(path.tv, marble.variety);
    float glassDist = sdf(path.tv, marble.glass);

    if(abs(glassDist)<abs(varDist)) {
        //----if we hit the the marble glass sphere

        //get outward pointing normal to this glass sphere
        normal = normalVec(path.tv, marble.glass);

        //figure out if we are incoming or outgoing:
        bool inside = dot(path.tv.dir,normal.dir)>0.;

        //if we are outgoing: we are leaving the glass material and going into the air
        if (inside) {
            setObjectInAir(path.dat, true, normal, marble.glass.mat);
        }

        else {
            //if we are ingoing: we are leaving the air and going into the glass
            setObjectInAir(path.dat, false, normal, marble.glass.mat);
        }

    }

    else {
        //----if we hit the variety

        //get outward pointing normal to this shell
        normal = normalVec(path.tv, marble.variety);

        //figure out if we are incoming or outgoing:
        bool inside = dot(path.tv.dir,normal.dir)>0.;

        //if we are outgoing: we are leaving the variety material and going into the glass
        if (inside) {
            path.dat.normal=negate(normal);
            setMaterialInterface(path.dat, marble.variety.mat, marble.glass.mat, marble.variety.mat);
        }

        else {
            //if we are ingoing: we are leaving the glass material and going into the variety
            path.dat.normal=normal;
            setMaterialInterface(path.dat, marble.glass.mat, marble.variety.mat, marble.variety.mat);
        }

    }



}


