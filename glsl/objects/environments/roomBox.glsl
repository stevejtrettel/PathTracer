//-------------------------------------------------
// THE ROOM BOX
// the standard scene environment: a closed axis-aligned box of six walls,
// each with its own material (so any wall can be a light, a mirror, or a
// different color). The walls are analytically traced planes: call trace()
// from trace_Environment and setData() from setData_Environment; there is
// nothing to raymarch.
//
// assign every field explicitly in buildEnvironment() — the twelve fields
// are the knobs of the room:
//
//     room.low   = -1.;    room.high  = 14.;   //y of floor / ceiling
//     room.left  = -20.;   room.right = 8.5;   //x of left / right wall
//     room.front = -20.;   room.back  = 10.;   //z of front / back wall
//     room.floorMat = makeDielectric(color, 0., 0.1);
//     room.ceilMat  = makeLight(vec3(1.), scratch4);
//     ...and leftMat / rightMat / frontMat / backMat
//
// (wall semantics replicate basic/plane.glsl: walls are one-sided, visible
// from inside the room; trace returns maxDist for rays leaving a wall.)
//-------------------------------------------------

struct RoomBox {
    float low;    //y of the floor
    float high;   //y of the ceiling
    float left;   //x of the left wall
    float right;  //x of the right wall
    float front;  //z of the front wall
    float back;   //z of the back wall
    Material floorMat;
    Material ceilMat;
    Material leftMat;
    Material rightMat;
    Material frontMat;
    Material backMat;
};


//initialize: unit box, default materials
void initObject( out RoomBox room ){
    room.low = -1.;  room.high = 1.;
    room.left = -1.; room.right = 1.;
    room.front = -1.; room.back = 1.;
    initMat(room.floorMat);
    initMat(room.ceilMat);
    initMat(room.leftMat);
    initMat(room.rightMat);
    initMat(room.frontMat);
    initMat(room.backMat);
}


//one axis-aligned wall: s = signed distance from the ray origin to the wall
//along its inward normal, denom = dot(ray dir, inward normal).
//same semantics as trace() in basic/plane.glsl.
float traceWall( float s, float denom ){
    if( denom > 0. ){ return maxDist; }
    return -s / denom;
}


//analytic intersection with all six walls
float trace( Vector tv, RoomBox room ){
    vec3 p = tv.pos;
    vec3 d = tv.dir;

    float dist = maxDist;
    dist = min(dist, traceWall(p.y - room.low,     d.y));   //floor,   normal (0, 1,0)
    dist = min(dist, traceWall(room.high - p.y,   -d.y));   //ceiling, normal (0,-1,0)
    dist = min(dist, traceWall(p.z - room.front,   d.z));   //front,   normal (0,0, 1)
    dist = min(dist, traceWall(room.back - p.z,   -d.z));   //back,    normal (0,0,-1)
    dist = min(dist, traceWall(p.x - room.left,    d.x));   //left,    normal ( 1,0,0)
    dist = min(dist, traceWall(room.right - p.x,  -d.x));   //right,   normal (-1,0,0)
    return dist;
}


//set the surface data for whichever wall the path is at
//(same at()/inside() semantics as basic/plane.glsl: |signed dist| < AT_THRESH)
void setData( inout Path path, RoomBox room ){
    vec3 p = path.tv.pos;

    float s;

    s = p.y - room.low;     //floor
    if( abs(s) < AT_THRESH ){ setObjectInAir(path.dat, s<0., Vector(p, vec3(0, 1,0)), room.floorMat); }

    s = room.high - p.y;    //ceiling
    if( abs(s) < AT_THRESH ){ setObjectInAir(path.dat, s<0., Vector(p, vec3(0,-1,0)), room.ceilMat); }

    s = p.z - room.front;   //front
    if( abs(s) < AT_THRESH ){ setObjectInAir(path.dat, s<0., Vector(p, vec3(0,0, 1)), room.frontMat); }

    s = room.back - p.z;    //back
    if( abs(s) < AT_THRESH ){ setObjectInAir(path.dat, s<0., Vector(p, vec3(0,0,-1)), room.backMat); }

    s = p.x - room.left;    //left
    if( abs(s) < AT_THRESH ){ setObjectInAir(path.dat, s<0., Vector(p, vec3( 1,0,0)), room.leftMat); }

    s = room.right - p.x;   //right
    if( abs(s) < AT_THRESH ){ setObjectInAir(path.dat, s<0., Vector(p, vec3(-1,0,0)), room.rightMat); }
}
