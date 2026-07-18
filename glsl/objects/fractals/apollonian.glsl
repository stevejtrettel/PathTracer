
//-------------------------------------------------
// APOLLONIAN
//
// the evilryu / mla Apollonian gasket (shadertoy 4ds3zn). a domain-repeat +
// sphere-inversion IFS wrapped in an outer inversion that bounds it. distinct
// from objects/fractals/apollonianGasket.glsl (a fract-fold variant); kept a
// separate file.
//
// UNIFORM PARAMETER: r2 = 1 + K, the squared inversion radius, is the "morph"
// that deforms the gasket (the shadertoy animates K as 0.2*cos(t)). here it's a
// struct field, driven live from a scratch knob in the scene.
//
// COLORING lives in the scene: the object exposes a 4-component orbit trap via
// orbitTrap(); the scene recolors in a setData followup. see [[shadertoy-integration]].
//-------------------------------------------------


//the data of the gasket: frame, material, and the morph parameter r2 (~0.9-1.3;
//1.2 is the shadertoy's still preset). set in buildObjects.
struct Apollonian{
    Frame frame;
    Material mat;
    float r2;
};


//the core gasket: domain-repeat into +/-1 cubes, invert in a sphere of radius^2
//r2, accumulate the conformal scale. orb = orbit trap (min of |p| and |p|^2).
float apo_gasket(vec3 p, float r2, out vec4 orb){
    float scale = 1.0;
    orb = vec4(1000.0);
    for(int i=0;i<10;i++){
        p -= 2.0*round(0.5*p);               //fold into the +/-1 cube
        float p2 = dot(p,p);
        orb = min(orb, vec4(abs(p), p2));    //orbit trap for coloring
        float k = r2/p2;                     //conformal inversion scale
        p     *= k;
        scale *= k;
    }
    //distance to the nearest coordinate-plane edge, undone by the scale
    float res = min(abs(p.z)+abs(p.x), min(abs(p.x)+abs(p.y), abs(p.y)+abs(p.z)));
    return res/scale;
}

//the outer inversion that maps the space-filling gasket to a bounded object
float apo_map(vec3 p, float r2, out vec4 orb){
    float s = 4.0/dot(p,p);
    p *= s;
    p += vec3(1.0);
    return 0.25 * apo_gasket(p, r2, orb) / s;
}


//the local-frame sdf (used for marching, at/inside, and normals)
float sdf( vec3 p, Apollonian obj ){
    vec4 orb;
    return apo_map(p, obj.r2, orb);
}

//local bounding sphere: the outer inversion maps the space-filling gasket into a
//compact region near the origin. radius set generously; verified by render.
float bound( vec3 p, Apollonian obj ){ return length(p) - 6.0; }

OBJECT_INIT(Apollonian)
OBJECT_LOCATORS_B(Apollonian)


//hand-written normalVec with the shadertoy's larger epsilon (0.002); the
//inversion makes a tiny epsilon noisy
Vector normalVec( Vector tv, Apollonian obj ){
    vec3 q = toLocal(obj.frame, tv.pos);
    const float ep = 0.002;
    vec2 e = vec2(1.0,-1.0)*0.5773;
    vec3 dir = e.xyy*sdf( q + e.xyy*ep, obj )
             + e.yyx*sdf( q + e.yyx*ep, obj )
             + e.yxy*sdf( q + e.yxy*ep, obj )
             + e.xxx*sdf( q + e.xxx*ep, obj );
    return Vector( tv.pos, dirToWorld(obj.frame, normalize(dir)) );
}


//SHADING PROBE: the orbit trap at a local point (scene maps it to color)
vec4 orbitTrap( vec3 p, Apollonian obj ){
    vec4 orb;
    apo_map(p, obj.r2, orb);
    return orb;
}


//standard flat-material setData (uses obj.mat); the scene overrides the color
OBJECT_SETDATA(Apollonian)
