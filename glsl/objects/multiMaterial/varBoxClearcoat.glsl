
//-------------------------------------------------
// A variety with a glass clearcoat, bounded by a box
// ------------------------------------------------

struct VarBoxClearcoat{
    VarBox variety;
    VarBox clearcoat;
};

//create one starting from a variety and some glass: (set the box size appropriately)
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

//composite sdf, inside, and two-region setData
VARIETY_IN_SHELL_API(VarBoxClearcoat, clearcoat)
