
//-------------------------------------------------
// A variety with a glass clearcoat, bounded by a sphere
// ------------------------------------------------

struct VarSphereClearcoat{
    VarSphere variety;
    VarSphere clearcoat;
};

//create one starting from a variety, a coat material, and a coat thickness: (set the sphere size appropriately)
VarSphereClearcoat createVarSphereClearcoat(VarSphere var, Material coatMat, float coatThickness){

    VarSphereClearcoat obj;

    obj.variety = var;
    obj.clearcoat = var;

    //update the clearcoat: make it slightly bigger, replace the material
    obj.clearcoat.radius = var.radius + 2.*coatThickness;
    obj.clearcoat.thickness = var.thickness + vec2(coatThickness);
    obj.clearcoat.mat = coatMat;

    return obj;

}

//composite sdf, inside, and two-region setData
VARIETY_IN_SHELL_API(VarSphereClearcoat, clearcoat)
