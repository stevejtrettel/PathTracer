
//-------------------------------------------------
// A variety with a glass clearcoat, bounded by a sphere
// ------------------------------------------------

struct VarBoxClearcoat{
    VarBox variety;
    VarBox clearcoat;
};

//create one starting from a variety and some glass: (set the sphere size appropriately)
VarBoxClearcoat createVarBoxClearcoat(VarBox var, Material coatMat, float coatThickness){

    VarBoxClearcoat obj;

    obj.variety = var;
    obj.clearcoat = var;

    //update the clearcoat: make it slightly bigger, replace the material
    obj.clearcoat.box = var.box + vec3(2.*coatThickness);
    obj.clearcoat.thickness = var.thickness + vec2(coatThickness);
    obj.clearcoat.mat = coatMat;

    return obj;

}



// -------------The Required Functions-----------------------------------

//overload of sdf for the cocktail struct
float sdf( Vector tv, VarBoxClearcoat obj){

    float varDist = sdf(tv, obj.variety);
    float glassDist = sdf(tv, obj.clearcoat);
    return min(abs(varDist),abs(glassDist));

}


bool inside(Vector tv, VarBoxClearcoat obj){
    return inside(tv, obj.variety);
}


//overload of set data
void setData(inout Path path, VarBoxClearcoat obj){

    Vector normal;

    float varDist = sdf(path.tv, obj.variety);
    float glassDist = sdf(path.tv, obj.clearcoat);

    if(abs(glassDist)<abs(varDist)) {
        //----if we hit the the marble glass sphere

        //get outward pointing normal to this glass sphere
        normal = normalVec(path.tv, obj.clearcoat);

        //figure out if we are incoming or outgoing:
        bool inside = dot(path.tv.dir,normal.dir)>0.;

        //if we are outgoing: we are leaving the glass material and going into the air
        if (inside) {
            setObjectInAir(path.dat, true, normal, obj.clearcoat.mat);
        }

        else {
            //if we are ingoing: we are leaving the air and going into the glass
            setObjectInAir(path.dat, false, normal, obj.clearcoat.mat);
        }

    }

    else {
        //----if we hit the variety

        //get outward pointing normal to this shell
        normal = normalVec(path.tv, obj.variety);

        //figure out if we are incoming or outgoing:
        bool inside = dot(path.tv.dir,normal.dir)>0.;

        //if we are outgoing: we are leaving the variety material and going into the glass
        if (inside) {
            path.dat.normal=negate(normal);
            setMaterialInterface(path.dat, obj.variety.mat, obj.clearcoat.mat, obj.variety.mat);
        }

        else {
            //if we are ingoing: we are leaving the glass material and going into the variety
            path.dat.normal=normal;
            setMaterialInterface(path.dat, obj.clearcoat.mat, obj.variety.mat, obj.variety.mat);
        }

    }



}


