#include ../../../glsl/objects/basic/tetrahedron.glsl;
#include ../../../glsl/objects/basic/icosahedron.glsl;
#include ../../../glsl/objects/basic/dodecahedron.glsl;

//-------------------------------------------------
// OBJECTS OF THE SCENE
// demo of Frame placement: each polyhedron is authored unit-sized
// at the origin, then rotated / scaled / placed by its frame
//-------------------------------------------------

Dodecahedron dod;
Icosahedron ico;
Tetrahedron tet;

void buildObjects(){

    //start each object with an identity frame and zeroed material
    initObject(dod);
    initObject(ico);
    initObject(tet);

    //centerpiece: tilted, enlarged dodecahedron
    dod.frame = makeFrame( vec3(0., 1.4, 0.), vec3(1.,1.,0.), 30., 1.4 );
    dod.mat = makeGlass( vec3(0.25, 0.05, 0.3), 1.5 );

    //gold icosahedron, rotated about the vertical, smaller
    ico.frame = makeFrame( vec3(-2.6, 0.8, 1.), vec3(0.,1.,0.), 25., 0.8 );
    ico.mat = makeMetal( vec3(0.9, 0.6, 0.2), 0.8, 0.1 );

    //blue tetrahedron balanced on an edge
    tet.frame = makeFrame( vec3(2.6, 0.9, 0.5), vec3(0.,0.,1.), 45., 0.9 );
    tet.mat = makeDielectric( vec3(0.15, 0.3, 0.8), 0.3, 0.1 );

}

bool render_Objects = true;

//no analytic intersections: everything is raymarched via the sdf
float trace_Objects( Vector tv ){
    return maxDist;
}

float sdf_Objects( Vector tv ){
    float dist = maxDist;
    dist = min(dist, sdf(tv, dod));
    dist = min(dist, sdf(tv, ico));
    dist = min(dist, sdf(tv, tet));
    return dist;
}

bool inside_Object( Vector tv ){
    return inside(tv, dod) || inside(tv, ico) || inside(tv, tet);
}

void setData_Objects( inout Path path ){
    setData(path, dod);
    setData(path, ico);
    setData(path, tet);
}
