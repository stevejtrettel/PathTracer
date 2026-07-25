//----------------------------------------------------------------------------
// ROOM — a closed box, seen from the inside.
//
// The room is ONE region whose solid is everything OUTSIDE the box, so the
// interior is open air and regionAt() returns ID_NONE there. Its six walls are
// not six objects: they are a material FIELD over that one region, read off by
// asking which face a point is nearest. roomFace() answers that.
//
// glsl/shapes/ is the math-only library: plain functions of a point and some
// floats. No structs, no Frame, no Material.
//----------------------------------------------------------------------------


const int ROOM_FLOOR   = 0;
const int ROOM_CEILING = 1;
const int ROOM_LEFT    = 2;
const int ROOM_RIGHT   = 3;
const int ROOM_FRONT   = 4;
const int ROOM_BACK    = 5;


// p is in the room's own coordinates (origin at the box centre).
// Negative in the WALLS, positive in the open interior — the sign convention
// every other region uses, just turned inside out.
float roomDistance(vec3 p, vec3 halfSize){
    return -bBox(p, halfSize);
}


// Exact ray intersection, in world coordinates. The ray is inside the box, so
// this is simply the distance at which it leaves: the nearest of the three
// far slab crossings.
float roomTrace(Vector tv, vec3 centre, vec3 halfSize){
    vec3  o  = tv.pos - centre;
    vec3  tm = max((-halfSize - o)/tv.dir, (halfSize - o)/tv.dir);
    float t  = min(tm.x, min(tm.y, tm.z));
    if(t < 0.){ return maxDist; }
    return min(t, maxDist);
}


// Which wall p is on (or nearest to) — a shape DATA output (docs/shape-data.md):
// a material that reads `faceData` gets it injected. d is negative inside the
// room, so its LARGEST component names the axis the point is closest to leaving
// through, and the sign of p picks which of that axis's two faces.
int roomFaceData(vec3 p, vec3 halfSize){
    vec3 d = abs(p) - halfSize;

    if(d.y >= d.x && d.y >= d.z){
        return (p.y > 0.) ? ROOM_CEILING : ROOM_FLOOR;
    }
    if(d.x >= d.z){
        return (p.x > 0.) ? ROOM_RIGHT : ROOM_LEFT;
    }
    return (p.z > 0.) ? ROOM_BACK : ROOM_FRONT;
}
