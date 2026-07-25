//----------------------------------------------------------------------------
// GEM — a brilliant-ish cut stone, girdle radius `size`.
//
// 8 crown facets rising to an octagonal table, 8 pavilion facets falling to the
// culet point, offset half a sector so the rings alternate (the classic
// brilliant look), plus an octagonal girdle band. Built as an exact convex
// intersection of planes: folding the angle into one wedge makes r*cos(folded)
// the support function of every rotated facet copy, so max() over the plane set
// is a true convex sdf that sphere-traces cleanly. Unit proportions: girdle
// radius 1, table at y=0.38, culet at (0,-0.85).
//
// glsl/shapes/ is the math-only library: plain functions of a point and floats.
//----------------------------------------------------------------------------


//fold the angle into the +/- sector/2 wedge about phase, and return the folded
//radial support r*cos(a) (file-private helper)
float gem_support(float r, float ang, float sector, float phase){
    float a = mod(ang + phase + 0.5*sector, sector) - 0.5*sector;
    return r*cos(a);
}


// p is in the gem's own coordinates (origin at the girdle centre)
float gemDistance(vec3 p, float size){
    p /= size;
    float r   = length(p.xz);
    float ang = atan(p.z, p.x);
    const float sector = 2.*PI/8.;

    float rc = gem_support(r, ang, sector, 0.);            //crown + girdle wedge
    float rp = gem_support(r, ang, sector, 0.5*sector);    //pavilion wedge (alternates)

    float table    = p.y - 0.38;
    float girdle   = rc - 1.;
    float crown    = dot(vec2(rc, p.y), vec2(0.5547, 0.8321)) - 0.6213;
    float pavilion = dot(vec2(rp, p.y), vec2(0.6247, -0.7809)) - 0.6637;

    return size * max( max(table, girdle), max(crown, pavilion) );
}


// bounding sphere: girdle polygon corners reach r = 1.082, all else is inside
float gemBound(vec3 p, float size){
    return length(p) - 1.15*size;
}
