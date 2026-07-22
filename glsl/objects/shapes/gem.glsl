

//-------------------------------------------------
//The GEM sdf — a brilliant-ish cut stone
//
// 8 crown facets rising to an octagonal table, 8 pavilion facets falling to the
// culet point, offset half a sector so the two rings alternate (the classic
// brilliant look), and an octagonal girdle band between them. Built as an exact
// convex intersection of planes: after folding the angle into one wedge,
// r*cos(foldedAngle) IS the support function dot(p, facetNormal) for every
// rotated copy of that facet, so max() over the plane set is a true convex sdf
// (exact inside, conservative at the edges) — it sphere-traces cleanly at any
// relaxation. Unit proportions: girdle radius 1 (polygon corners reach 1/cos(22.5)
// = 1.082), girdle band y in [-0.05, 0.08], table at y = 0.38, culet at (0,-0.85).
//-------------------------------------------------

struct Gem{
    Frame frame;
    float size;      //girdle radius in world units
    Material mat;
};


//fold the angle into the +/- sector/2 wedge about phase, and return the folded
//radial support r*cos(a) (private helper)
float gem_support(float r, float ang, float sector, float phase){
    float a = mod(ang + phase + 0.5*sector, sector) - 0.5*sector;
    return r*cos(a);
}


//the local-frame sdf: unit-proportioned stone at the origin, scaled by gem.size
float sdf( vec3 p, Gem gem ){
    p /= gem.size;
    float r   = length(p.xz);
    float ang = atan(p.z, p.x);
    const float sector = 2.*PI/8.;

    float rc = gem_support(r, ang, sector, 0.);            //crown + girdle wedge
    float rp = gem_support(r, ang, sector, 0.5*sector);    //pavilion wedge (alternates)

    //facet planes in the (radial, y) slice:
    float table    = p.y - 0.38;
    float girdle   = rc - 1.;
    //crown: through the girdle top (1.0, 0.08) and the table edge (0.55, 0.38)
    float crown    = dot(vec2(rc, p.y), vec2(0.5547, 0.8321)) - 0.6213;
    //pavilion: through the girdle bottom (1.0,-0.05) and the culet (0,-0.85)
    float pavilion = dot(vec2(rp, p.y), vec2(0.6247,-0.7809)) - 0.6637;

    return gem.size * max( max(table, girdle), max(crown, pavilion) );
}


//bounding sphere: girdle polygon corners reach r = 1.082, everything else is inside
float bound( vec3 p, Gem gem ){
    return length(p) - 1.15*gem.size;
}

//the standard interface: initObject, at, inside, sdf, normalVec, setData (custom bound above)
OBJECT_API_B(Gem)
