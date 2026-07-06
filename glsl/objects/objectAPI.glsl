//-------------------------------------------------
// THE STANDARD OBJECT API
//
// an object type is a struct (with a Material mat field) plus one function,
// the only per-object code you write by hand:
//
//     float sdf( vec3 p, Type obj )
//
// the point-level signed distance field: negative inside, and either exact
// or a conservative underestimate. all else derives from it mechanically.
//
// the macros below generate the rest of the standard interface, overloaded
// on the struct type (dispatch is GLSL function overloading):
//
//     OBJECT_LOCATORS(Type)    at(), inside(), and the Vector-level sdf()
//     OBJECT_NORMAL_FD(Type)   normalVec() by tetrahedral finite difference
//     OBJECT_SETDATA(Type)     setData(): normal + side + material on a hit
//
//     OBJECT_API(Type)         all three of the above
//
// use the pieces individually when a type overrides part of the interface:
//     analytic normalVec / trace   (sphere, plane)
//     custom at()                  (apollonian gasket)
//     custom setData()             (the multiMaterial objects)
// trace( Vector, Type ) is never generated: only shapes with an analytic
// ray intersection define it; everything else is raymarched via sdf.
//
// (no comments inside the macro bodies: they use backslash continuations)
//-------------------------------------------------


#define OBJECT_LOCATORS(Type)                                   \
bool at( Vector tv, Type obj ){                                 \
    float d = sdf( tv.pos, obj );                               \
    return ((abs(d) - AT_THRESH) < 0.);                         \
}                                                               \
bool inside( Vector tv, Type obj ){                             \
    return ( sdf( tv.pos, obj ) < 0. );                         \
}                                                               \
float sdf( Vector tv, Type obj ){                               \
    return sdf( tv.pos, obj );                                  \
}


#define OBJECT_NORMAL_FD(Type)                                  \
Vector normalVec( Vector tv, Type obj ){                        \
    const float ep = 0.0001;                                    \
    vec2 e = vec2(1.0,-1.0)*0.5773;                             \
    vec3 dir = e.xyy*sdf( tv.pos + e.xyy*ep, obj )              \
             + e.yyx*sdf( tv.pos + e.yyx*ep, obj )              \
             + e.yxy*sdf( tv.pos + e.yxy*ep, obj )              \
             + e.xxx*sdf( tv.pos + e.xxx*ep, obj );             \
    return Vector( tv.pos, normalize(dir) );                    \
}


#define OBJECT_SETDATA(Type)                                    \
void setData( inout Path path, Type obj ){                      \
    if( at(path.tv, obj) ){                                     \
        Vector normal = normalVec(path.tv, obj);                \
        bool side = inside(path.tv, obj);                       \
        setObjectInAir(path.dat, side, normal, obj.mat);        \
    }                                                           \
}


#define OBJECT_API(Type)                                        \
OBJECT_LOCATORS(Type)                                           \
OBJECT_NORMAL_FD(Type)                                          \
OBJECT_SETDATA(Type)


//-------------------------------------------------
// VARIETIES
//
// an algebraic variety file supplies its defining equation as a
// dual-number function `T eqnFn(T x, T y, T z)` (see 1Setup/algVariety.glsl);
// VARIETY_DATA generates the standard evaluator
//
//     vec4 dataFn( vec3 p )   // xyz = gradient, w = value
//
// used by the variety's sdf for the distance estimate DE(val, |grad|).
//-------------------------------------------------

#define VARIETY_DATA(dataFn, eqnFn)                             \
vec4 dataFn( vec3 p ){                                          \
    T vx = eqnFn( T(p.x, 1.), T(p.y, 0.), T(p.z, 0.) );         \
    T vy = eqnFn( T(p.x, 0.), T(p.y, 1.), T(p.z, 0.) );         \
    T vz = eqnFn( T(p.x, 0.), T(p.y, 0.), T(p.z, 1.) );         \
    return vec4( vec3(vx.y, vy.y, vz.y), vx.x );                \
}
