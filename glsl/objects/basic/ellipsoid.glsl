//-------------------------------------------------
//The ELLIPSOID sdf
// radii = the three semi-axes. NOTE: this is IQ's well-known APPROXIMATE
// ellipsoid distance (not exact); it is accurate near the surface and a mild
// under/over-estimate elsewhere, which is fine for the raymarcher.
//-------------------------------------------------

struct Ellipsoid{
    Frame frame;
    vec3 radii;    //semi-axes (x, y, z)
    Material mat;
};


//the local-frame sdf (IQ's approximate ellipsoid)
float sdf( vec3 p, Ellipsoid e ){
    float k0 = length(p / e.radii);
    float k1 = length(p / (e.radii*e.radii));
    return k0*(k0 - 1.0) / max(k1, 1e-7);
}

//local bounding radius: the largest semi-axis
float bound( Ellipsoid e ){ return max(e.radii.x, max(e.radii.y, e.radii.z)); }

//the standard interface (custom bound above)
OBJECT_API_B(Ellipsoid)
