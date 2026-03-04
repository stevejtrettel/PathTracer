
//----------------------------------------------------------------------------------------------
// LINE PRIMITIVE
// An infinite line in R3 defined by a point and a unit direction.
//----------------------------------------------------------------------------------------------

struct Line {
    vec3 point;
    vec3 dir;    // must be unit length
};

// Distance from p to the infinite line
float lineDist(vec3 p, Line l) {
    vec3 diff = p - l.point;
    return length(diff - dot(diff, l.dir) * l.dir);
}

// Normal: radial direction away from line axis
vec3 lineNormal(vec3 p, Line l) {
    vec3 diff = p - l.point;
    return normalize(diff - dot(diff, l.dir) * l.dir);
}
