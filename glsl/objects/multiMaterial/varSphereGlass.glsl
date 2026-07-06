
//-------------------------------------------------
// A variety in a glass sphere
// ------------------------------------------------

struct VarSphereGlass{
    VarSphere variety;
    Sphere glass;
};

//create one starting from a variety and some glass: (set the sphere size appropriately)
VarSphereGlass createVarSphereGlass(VarSphere var, Material glassMat){

    VarSphereGlass marble;
    marble.variety = var;

    Sphere glass;
    glass.frame = makeFrame(var.frame.pos);
    glass.radius = 1.2*var.radius;
    glass.mat = glassMat;

    marble.glass = glass;

    return marble;

}

//composite sdf, inside, and two-region setData
VARIETY_IN_SHELL_API(VarSphereGlass, glass)
