//----------------------------------------------------------------------------
// OPS · CARVE — erode (or grow) a solid with an fbm of sphere lattices.
//
// Vocabulary: always compiled (glsl/shapes/_vocabulary.glsl). Depends on
// ops/smooth.glsl (blends) and the engine's fieldHash (3Materials/fields.glsl),
// so it is included last. See docs/shape-library.md §1.
//
// IQ's fbmSDF (https://iquilezles.org/articles/fbmsdf). The point is what it is
// NOT: displacement. `d + amp*noise(p)` is not a distance field, which is why
// displace() pays a Lipschitz divisor at every march step and has to inflate its
// bound. This SUBTRACTS a distance field instead — a lattice of spheres, smooth-
// maxed out of the solid octave by octave — and a smooth max of two distance
// fields is still one. So the detail is free to march, and because carving only
// ever ERODES, the uncarved base remains a valid bound.
//
// FUTURE US: the carving field is hard-wired to the sphere lattice, the way
// repLim hard-wires its fold. The natural generalization is to let carve() take
// a caller-supplied DISTANCE field (`by:`), whose metadata would be a declared
// Lipschitz constant rather than displace's {gradBound, range}. Call sites would
// not change; opCarveFbm would take the field's function instead of calling
// opCarveCell. Deferred until a second carving field actually exists.
//----------------------------------------------------------------------------

const float CARVE_LACUNARITY = 2.0;

//the rotation between octaves, so the lattices never line up (IQ's matrix)
const mat3 CARVE_ROT = mat3( 0.00,  0.80,  0.60,
                            -0.80,  0.36, -0.48,
                            -0.60, -0.48,  0.64);

//one sphere per corner of the unit cell, radius from the corner's own hash.
//`erosion` scales every radius: 0 bites nothing, 1 is the full 0.7 of a cell.
//
//A min over the 8 CORNERS is IQ's approximation — a lattice point one cell over
//sits as close as 1.0 while a corner can be 1.73 away, so a big enough neighbour
//sphere can in principle be nearer than all eight. Used subtractively, as here,
//the error is small and bounded; do not lift this out as a general-purpose sdf.
float opCarveCell(vec3 p, float erosion){
    vec3  i = floor(p);
    vec3  f = p - i;
    float d = 1.0e9;
    for(int x = 0; x <= 1; x++){
        for(int y = 0; y <= 1; y++){
            for(int z = 0; z <= 1; z++){
                vec3  c = vec3(float(x), float(y), float(z));
                float r = fieldHash(i + c);
                d = min(d, length(f - c) - erosion*r*r*0.7);
            }
        }
    }
    return d;
}

//carve `d` with `octaves` of that lattice, each half the size and `gain` of the
//amplitude of the last. Returns a CONSERVATIVE distance.
//
//THE DIVISOR. Octave i carries amplitude gain^i at frequency LACUNARITY^i, so its
//gradient is (gain*LACUNARITY)^i, and a smooth max is bounded by the steepest of
//its operands. With gain <= 1/LACUNARITY every octave is 1-Lipschitz and the
//field is a true distance function — divisor 1, nothing paid. Above that the
//divisor is real and the marcher needs it, so it is tracked in the loop rather
//than assumed away. This is why gain is worth exposing: it is the dial between
//"free to march" and "richer, and paying for it".
float opCarveFbm(vec3 p, float d, int octaves, float erosion, float gain, float blend, float seed){
    vec3  q   = p + vec3(seed);
    float s   = 1.0;      //this octave's amplitude
    float g   = 1.0;      //this octave's gradient bound
    float lip = 1.0;      //the steepest octave so far

    for(int i = 0; i < octaves; i++){
        lip = max(lip, g);
        d   = opSmoothIntersect(d, -s*opCarveCell(q, erosion), blend*s);
        q   = CARVE_LACUNARITY*(CARVE_ROT*q);
        s  *= gain;
        g  *= gain*CARVE_LACUNARITY;
    }
    return d/lip;
}

//ACCRETE: carve's mirror image — the same lattice octaves GROW on the surface
//instead of being eaten from it (the union form of IQ's fbmSDF). One extra move
//vs carve: each octave's spheres are first CLAMPED to a thin neighborhood of the
//running surface (smax against d dilated by REACH of that octave's scale) —
//without it the infinite lattice would sprout blobs everywhere in space — and
//then smooth-unioned on. Divisor bookkeeping is opCarveFbm's, unchanged.
//
//Growth is bounded: an octave attaches at most REACH*s past the surface, and the
//smooth union bulges at most blend*s/4 more, so the total over all octaves is the
//geometric series (REACH + blend/4)*(1 + gain + gain^2 + ...). That closed form,
//(REACH + 0.25*blend)/(1 - gain), is the bound inflation the generator derives —
//and why accrete's gain must stay below 1 (the series, and the growth, diverge).
const float ACCRETE_REACH = 0.1;

float opAccreteFbm(vec3 p, float d, int octaves, float erosion, float gain, float blend, float seed){
    vec3  q   = p + vec3(seed);
    float s   = 1.0;      //this octave's amplitude
    float g   = 1.0;      //this octave's gradient bound
    float lip = 1.0;      //the steepest octave so far

    for(int i = 0; i < octaves; i++){
        lip     = max(lip, g);
        float n = s*opCarveCell(q, erosion);
        n = opSmoothIntersect(n, d - ACCRETE_REACH*s, blend*s);   //only near the current surface
        d = opSmoothUnion(d, n, blend*s);                         //grow it on
        q = CARVE_LACUNARITY*(CARVE_ROT*q);
        s *= gain;
        g *= gain*CARVE_LACUNARITY;
    }
    return d/lip;
}
