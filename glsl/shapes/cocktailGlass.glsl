//----------------------------------------------------------------------------
// COCKTAIL GLASS
//
// glsl/shapes/ is the ported math-only library: plain functions of a point and
// some floats. No structs, no Frame, no Material, no at()/inside()/setData().
// Placement, materials and the region interface are all emitted by the scene.
//
// Ported from the old objects/shapes/cocktailGlass.glsl — the math is
// unchanged; only the CocktailGlass struct is gone from the signature.
//----------------------------------------------------------------------------


// The bowl wall, with the cavity carved out of it and the underside scooped by
// a ball. `cavity` hands back the sdf of the enclosed volume, so a caller can
// build the liquid from the SAME evaluation — one shape, two outputs.
//
// p is in the glass's own coordinates (origin at the bowl centre).
float cocktailGlassDistance(vec3 p, float radius, float height,
                            float thickness, float base, out float cavity){

    float outside = cylinderDist(p, radius, height, 0.1);

    vec3  q      = p - vec3(0., 2.*base, 0.);
    float inside = cylinderDist(q, radius - thickness, height, 0.05);

    float dist = max(outside, -inside);

    q = p + vec3(0., height - 1.75*base/2.5, 0.);
    float ball = length(q) - 2.*base/2.5;

    cavity = inside;
    return smax(dist, -ball, 0.2);
}


// A conservative bounding cylinder for the whole glass: the bowl plus the base
// ball below it, about the y axis. Never overestimates the distance to the
// surface, so it is safe as an acceleration bound.
float cocktailGlassBound(vec3 p, float radius, float height, float base){
    return bCyl(p, vec2(radius + 0.3, height + 2.*base + 1.));
}
