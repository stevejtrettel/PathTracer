//-------------------------------------------------
// LIGHT-AIMED DIFFUSE BOUNCES — still forward only
//
// A diffuse bounce picks its next direction from the cosine lobe. In a room lit
// by a small bright sphere almost none of those directions reach the light, so
// a wall's direct light arrives through rare lucky paths: speckle, and an image
// that keeps brightening for thousands of frames.
//
// Here the direction comes from a MIX instead: with probability AIM_PROB it is
// drawn uniformly inside the cone one of the sphere lights subtends from this
// point (a straight-line guess), otherwise from the cosine lobe as before.
// Either way the ray is then traced FORWARD exactly like any other bounce:
// nothing is connected to the light and nothing checks that it gets there.
//
// The one price is a weight on the throughput — the lobe's own density over
// the mixture's density at the chosen direction,
//
//     w = (cos/π) / ( (1-AIM_PROB)·cos/π + AIM_PROB·mean_k cone_k )
//
// all closed form (cone_k = 1/(2π(1-cosMax)) inside light k's cone, else 0).
// It keeps the estimate unbiased WHATEVER the guess: in curved space a cone of
// straight directions is just a worse guess, never a wrong answer. With no
// sphere lights, or AIM_PROB = 0, w is exactly 1 and this is the plain lobe.
// The Render tab's "Aim at Lights" toggle (the aimLights knob) switches it off,
// to compare.
//
// The lights come from the scene chunk (the generator emits every emissive
// analytic sphere); it is compiled after this file, hence the prototypes.
//-------------------------------------------------

int  numLights();
void lightSphere(int i, out vec3 c, out float r);

const float AIM_PROB = 0.5;


//can light i be aimed at from p? (p outside it, and its cone not entirely
//below the surface.) Fills the cone's axis and cos(half-angle).
bool aimCone(int i, vec3 p, vec3 n, out vec3 axis, out float cosMax){
    vec3 c; float r;
    lightSphere(i, c, r);
    vec3 d = c - p;
    float dist = length(d);
    if(dist <= 1.001*r){ return false; }
    axis = d/dist;
    float sinMax = r/dist;
    cosMax = sqrt(1. - sinMax*sinMax);
    return dot(axis, n) > -sinMax;
}


//the direction for a diffuse bounce at p (outward normal n). cosDir is the
//cosine-lobe direction scatter() already drew; u is a fresh 2D sample for the
//cone. Multiplies the throughput by the mixture weight.
Vector aimDiffuse(inout Path path, Vector normal, Vector cosDir, vec2 u){
    //the Render tab's "Aim at Lights" toggle (an engine knob): off = the plain lobe
    if(!aimLights){ return cosDir; }

    vec3 p = normal.pos, n = normal.dir;

    //how many lights can be aimed at from here
    int K = 0;
    vec3 axis; float cosMax;
    for(int i = 0; i < numLights(); i++){
        if(aimCone(i, p, n, axis, cosMax)){ K++; }
    }
    if(K == 0){ return cosDir; }

    //draw: aim at one of them, or take the cosine direction
    Vector w = cosDir;
    if(randomFloat() < AIM_PROB){
        int pick = min(int(randomFloat()*float(K)), K-1);
        int k = 0;
        for(int i = 0; i < numLights(); i++){
            if(!aimCone(i, p, n, axis, cosMax)){ continue; }
            if(k == pick){
                float cosT = 1. - u.x*(1. - cosMax);
                float sinT = sqrt(max(1. - cosT*cosT, 0.));
                float phi  = 2.*PI*u.y;
                vec3 t1; vec3 t2;
                tangentFrame(axis, t1, t2);
                w = Vector(p, normalize(cosT*axis + sinT*(cos(phi)*t1 + sin(phi)*t2)));
                break;
            }
            k++;
        }
    }

    //the weight: lobe density over mixture density, at the chosen direction
    float cosW = vDot(w, normal);
    if(cosW <= 0.){ path.light = vec3(0.); return w; }   //aimed below the surface: no light that way
    float lobe = cosW/PI;
    float cone = 0.;
    for(int i = 0; i < numLights(); i++){
        if(aimCone(i, p, n, axis, cosMax) && dot(w.dir, axis) >= cosMax - 1e-6){
            cone += 1./(2.*PI*(1. - cosMax));
        }
    }
    cone /= float(K);
    float weight = lobe / ((1. - AIM_PROB)*lobe + AIM_PROB*cone);
    path.light *= weight;
    //a direction aimed at a bright light gets a SMALL weight (~0.03 for a small
    //light): judged on the weighted throughput, roulette would kill ~97% of
    //exactly the paths that were sent to find the light, and boost the survivors
    //30x — handing back all the variance aiming removed. So roulette looks past it.
    path.rrWeight = weight;
    return w;
}
