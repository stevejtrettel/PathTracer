//----------------------------------------------------------------------------
// BOTTLE — a rounded-cylinder base and neck, smooth-unioned, hollowed to a glass
// shell with the neck chopped open (and a punt dimple in the base).
//
// glsl/shapes/ is the math-only library: plain functions of a point and floats.
// Built from cylinderDistance + opSmoothUnion/Intersect/Onion (glsl/shapes/ops/,
// always compiled). `bottleCavity` is the interior surface, for a liquid region
// in a group (bottleLiquid); `bottleDistance` is the glass shell for a plain object.
//----------------------------------------------------------------------------


//the solid profile BEFORE hollowing — the shared source for the shell and the
//cavity, so the two can never drift (file-private)
float bottle_solid(vec3 p, float baseRadius, float baseHeight, float neckRadius,
                   float neckHeight, float rounded, float smoothJoin, float bump){
    float base = cylinderDistance(p, baseRadius, baseHeight, rounded);
    vec3  q    = p - vec3(0.0, baseHeight + neckHeight, 0.0);
    float neck = cylinderDistance(q, neckRadius, neckHeight, rounded);
    float solid = opSmoothUnion(base, neck, smoothJoin);       //smooth union
    if(bump != 0.0){
        float dimple = length(p + vec3(0.0, baseHeight, 0.0)) - 0.25;
        solid = opSmoothIntersect(solid, -dimple, 1.0);             //punt at the base
    }
    return solid;
}


// p is in the bottle's own coordinates (origin at the base centre). The glass
// SHELL: the solid hollowed to a wall of `thickness`, neck chopped open.
float bottleDistance(vec3 p, float baseRadius, float baseHeight, float neckRadius,
                     float neckHeight, float thickness, float rounded, float smoothJoin, float bump){
    float solid = bottle_solid(p, baseRadius, baseHeight, neckRadius, neckHeight, rounded, smoothJoin, bump);
    float shell = opOnion(solid, thickness);
    float top   = (p.y - (baseHeight + neckHeight)) - neckHeight/3.0;   //chop the neck open
    return opSmoothIntersect(shell, top, thickness);
}


// the interior cavity — the solid inset by the wall. For a liquid region in a
// group: `drink = max(bottleCavity(q, ...), q.y - level)`.
float bottleCavity(vec3 p, float baseRadius, float baseHeight, float neckRadius,
                   float neckHeight, float thickness, float rounded, float smoothJoin, float bump){
    return bottle_solid(p, baseRadius, baseHeight, neckRadius, neckHeight, rounded, smoothJoin, bump) + thickness;
}


// tight bounding cylinder, centred on the (asymmetric) shape, not the origin
float bottleBound(vec3 p, float baseRadius, float baseHeight, float neckHeight,
                  float thickness, float rounded, float smoothJoin){
    float yTop = baseHeight + (4.0/3.0)*neckHeight + thickness + 0.1;
    float yBot = -(baseHeight + rounded + thickness + 0.1);
    float R    = baseRadius + thickness + 0.25*smoothJoin + 0.1;
    return cylinderSlab(p - vec3(0.0, 0.5*(yTop + yBot), 0.0), R, 0.5*(yTop - yBot));
}
