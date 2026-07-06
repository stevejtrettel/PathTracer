//-------------------------------------------------
// THE STANDARD OBJECT API
//
// an object type is a struct with a `Frame frame` field (its placement:
// see 2Space/geometry.glsl), a `Material mat` field, any shape parameters,
// plus ONE hand-written function — the geometry in the object's OWN
// local coordinates, authored at the origin:
//
//     float sdf( vec3 p, Type obj )
//
// (negative inside; exact distance or a conservative underestimate.)
//
// the convention throughout: a vec3 argument means the object's own
// local chart; a Vector argument means ray state in the world. the
// macros generate the world-facing interface from the local sdf:
//
//     OBJECT_INIT(Type)        initObject(): identity frame, zeroed material
//     OBJECT_LOCATORS(Type)    world sdf(Vector), at(), inside()
//     OBJECT_NORMAL_FD(Type)   normalVec(): finite difference in local
//                              coordinates, gradient rotated to world
//     OBJECT_SETDATA(Type)     setData(): normal + side + material on a hit
//
//     OBJECT_API(Type)         all four of the above
//
// use the pieces individually when a type overrides part of the interface
// (analytic normal or trace, custom at(), multi-material setData).
// trace( Vector, Type ) is never generated: only shapes with an analytic
// ray intersection define it (work in the local frame, then rescale the
// returned distance by obj.frame.scale).
//
// (no comments inside the macro bodies: they use backslash continuations)
//-------------------------------------------------


#define OBJECT_INIT(Type)                                       \
void initObject( out Type obj ){                                \
    obj.frame = IDENTITY_FRAME;                                 \
    zeroMat(obj.mat);                                           \
}


#define OBJECT_LOCATORS(Type)                                   \
float sdf( Vector tv, Type obj ){                               \
    return obj.frame.scale * sdf( toLocal(obj.frame, tv.pos), obj ); \
}                                                               \
bool at( Vector tv, Type obj ){                                 \
    float d = sdf( tv, obj );                                   \
    return ((abs(d) - AT_THRESH) < 0.);                         \
}                                                               \
bool inside( Vector tv, Type obj ){                             \
    return ( sdf( tv, obj ) < 0. );                             \
}


#define OBJECT_NORMAL_FD(Type)                                  \
Vector normalVec( Vector tv, Type obj ){                        \
    vec3 q = toLocal(obj.frame, tv.pos);                        \
    const float ep = 0.0001;                                    \
    vec2 e = vec2(1.0,-1.0)*0.5773;                             \
    vec3 dir = e.xyy*sdf( q + e.xyy*ep, obj )                   \
             + e.yyx*sdf( q + e.yyx*ep, obj )                   \
             + e.yxy*sdf( q + e.yxy*ep, obj )                   \
             + e.xxx*sdf( q + e.xxx*ep, obj );                  \
    return Vector( tv.pos, dirToWorld(obj.frame, normalize(dir)) ); \
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
OBJECT_INIT(Type)                                               \
OBJECT_LOCATORS(Type)                                           \
OBJECT_NORMAL_FD(Type)                                          \
OBJECT_SETDATA(Type)


//-------------------------------------------------
// TRANSITIONAL: UNFRAMED OBJECTS
//
// the old contract, for types not yet migrated to Frame placement:
// the hand-written sdf( vec3 p, Type obj ) is in WORLD coordinates
// (the object handles its own `center` internally). these macros are
// deleted once the migration is complete — do not use them in new code.
//-------------------------------------------------

#define UNFRAMED_LOCATORS(Type)                                 \
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

#define UNFRAMED_NORMAL_FD(Type)                                \
Vector normalVec( Vector tv, Type obj ){                        \
    const float ep = 0.0001;                                    \
    vec2 e = vec2(1.0,-1.0)*0.5773;                             \
    vec3 dir = e.xyy*sdf( tv.pos + e.xyy*ep, obj )              \
             + e.yyx*sdf( tv.pos + e.yyx*ep, obj )              \
             + e.yxy*sdf( tv.pos + e.yxy*ep, obj )              \
             + e.xxx*sdf( tv.pos + e.xxx*ep, obj );             \
    return Vector( tv.pos, normalize(dir) );                    \
}

#define UNFRAMED_OBJECT_API(Type)                               \
UNFRAMED_LOCATORS(Type)                                         \
UNFRAMED_NORMAL_FD(Type)                                        \
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


//-------------------------------------------------
// VARIETY IN A TRANSPARENT SHELL
//
// for a struct of the form { InnerType variety; OuterType shell; }
// (a variety inside a glass/clearcoat shell), generates the composite
// sdf( Vector, Type ), inside( Vector, Type ), and the two-region
// setData: hits on the shell are an object-in-air interface; hits on
// the variety are a material interface between shell and variety
// (variety dominant). `shell` is the name of the outer field.
//-------------------------------------------------

#define VARIETY_IN_SHELL_API(Type, shell)                                                    \
float sdf( Vector tv, Type obj ){                                                            \
    float varDist = sdf(tv, obj.variety);                                                    \
    float shellDist = sdf(tv, obj.shell);                                                    \
    return min(abs(varDist), abs(shellDist));                                                \
}                                                                                            \
bool inside( Vector tv, Type obj ){                                                          \
    return inside(tv, obj.variety);                                                          \
}                                                                                            \
void setData( inout Path path, Type obj ){                                                   \
    float varDist = sdf(path.tv, obj.variety);                                               \
    float shellDist = sdf(path.tv, obj.shell);                                               \
    Vector normal;                                                                           \
    if( abs(shellDist) < abs(varDist) ){                                                     \
        normal = normalVec(path.tv, obj.shell);                                              \
        bool outgoing = dot(path.tv.dir, normal.dir) > 0.;                                   \
        setObjectInAir(path.dat, outgoing, normal, obj.shell.mat);                           \
    }                                                                                        \
    else{                                                                                    \
        normal = normalVec(path.tv, obj.variety);                                            \
        bool outgoing = dot(path.tv.dir, normal.dir) > 0.;                                   \
        if( outgoing ){                                                                      \
            path.dat.normal = negate(normal);                                                \
            setMaterialInterface(path.dat, obj.variety.mat, obj.shell.mat, obj.variety.mat); \
        }                                                                                    \
        else{                                                                                \
            path.dat.normal = normal;                                                        \
            setMaterialInterface(path.dat, obj.shell.mat, obj.variety.mat, obj.variety.mat); \
        }                                                                                    \
    }                                                                                        \
}
