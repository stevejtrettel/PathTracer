
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

//composite sdf, inside, and two-region setData
VARIETY_IN_SHELL_API(VarBoxGlass, glass)
