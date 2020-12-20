//-------------------------------------------------
//The LOCAL GEOMETRY
//-------------------------------------------------


float dot(Vector u, Vector v){
    mat3 g = mat3(
    exp(-2. * u.pos.coords.z), 0., 0.,
    0., exp(2. * u.pos.coords.z), 0.,
    0., 0., 1.
    );
    return dot(u.dir, g * v.dir);
}


float norm(Vector v){
    return sqrt(dot(v,v));
}


Vector normalize(Vector v){
    float length=norm(v);
   return multiplyScalar(1./length,v);
}

float cosAng(Vector v, Vector w){
    return dot(normalize(v),normalize(w));
}


Vector rotateFacing(mat4 A, Vector v){
    // apply an isometry to the tangent vector (both the point and the direction)
    
    return Vector(v.pos, (A*vec4(v.dir,0)).xyz);
}


//reflect the unit tangent vector u off the surface with unit normal n
Vector reflect(Vector v, Vector n){
    return add(multiplyScalar(-2.0 * dot(v, n), n), v);
}


//refract the vector v through the surface with normal vector n, coming from a material with refactive index n1 and entering a material with index n2.
Vector refract(Vector v, Vector n, float IOR){
   
    float r=IOR;
    float cosI=-dot(n,v);
    float sinT2=r*r* (1.0 - cosI * cosI);
    if(sinT2>1.){return Vector(v.pos,vec3(0.,0.,0.));}//TIR  
    //if we are not in this case, then refraction actually occurs
    float cosT=sqrt(1.0 - sinT2);
    vec3 dir=r*v.dir+(r * cosI - cosT) * n.dir;
    return Vector(v.pos, dir);
}



float FresnelReflectAmount(float n1, float n2, Vector normal, Vector incident, float f0, float f90)
{
        // Schlick aproximation
        float r0 = (n1-n2) / (n1+n2);
        r0 *= r0;
        float cosX = -dot(normal, incident);
        if (n1 > n2)
        {
            float n = n1/n2;
            float sinT2 = n*n*(1.0-cosX*cosX);
            // Total internal reflection
            if (sinT2 > 1.0)
                return f90;
            cosX = sqrt(1.0-sinT2);
        }
        float x = 1.0-cosX;
        float ret = r0+(1.0-r0)*x*x*x*x*x;
 
        // adjust reflect multiplier for object reflectivity
        return mix(f0, f90, ret);
}




void init_ellip(Vector u) {
    // initializes all the parameters needed to march along the geodesic directed by u
    // we assume that the position of u is the origin
    // if ab = 0 (hyperbolic sheets), all the parameters are not needed,
    // however their computations are trivial
    // (all the elliptic integrals becomes, trivial, the AGM stops where it starts, etc)
    // instead of adding cases, we simply run the computations

    // some renaming to simplify the formulas
    // by assumption a^2 + b^2 + c^2 = 1
    float ab = abs(u.dir.x * u.dir.y);

    // some auxiliary value to avoind redundant computations of roots.
    float aux1 = sqrt(1. - 2. * ab);
    float aux2 = 2. * sqrt(ab);

    // frequency
    ell_mu = sqrt(1. + 2. * ab);

    // parameters of the elliptic functions
    ell_k = aux1 / ell_mu;
    ell_kprime = aux2 / ell_mu;
    ell_m = (1. - 2. * ab) / (1. + 2. * ab);

    // complete elliptic integrals and related quantities
    agm();
    vec2 KE = ellipke();
    ell_K = KE.x;
    ell_E = KE.y;

    // if ab = 0 (hyperbolic sheets) then k' = 0, in which case, L will not be needed and makes no sense here
    if (ab != 0.) {
        ell_L = ell_E / (ell_kprime * ell_K) - 0.5 * ell_kprime;
    }

}










//-------------------------------------------------
//Using ISOMETRIES 
//-------------------------------------------------



Isometry makeLeftTranslation(Point p) {
    mat4 matrix =  mat4(
    exp(p.coords.z), 0., 0., 0.,
    0., exp(-p.coords.z), 0., 0.,
    0., 0., 1., 0,
    p.coords.x, p.coords.y, p.coords.z, 1.
    );
    return Isometry(matrix);
}

Isometry makeInvLeftTranslation(Point p) {
    mat4 matrix =  mat4(
    exp(-p.coords.z), 0., 0., 0.,
    0., exp(p.coords.z), 0., 0.,
    0., 0., 1., 0,
    -exp(-p.coords.z) * p.coords.x, -exp(p.coords.z) * p.coords.y, -p.coords.z, 1.
    );
    return Isometry(matrix);
}






// overlaod using Vector
Isometry makeLeftTranslation(Vector v) {
    return makeLeftTranslation(v.pos);
}

// overlaod using Vector
Isometry makeInvLeftTranslation(Vector v) {
    return makeInvLeftTranslation(v.pos);
}












//----------------------------------------------------------------------------------------------------------------------
// DISTANCE FUNCTIONS
//----------------------------------------------------------------------------------------------------------------------


float fakeDistance(Point p, Point q){
    // measure the distance between two points in the geometry
    // fake distance

    Isometry shift = makeInvLeftTranslation(p);
    Point qOrigin = translate(shift, q);
    
    return length(q.coords-p.coords);
}

float fakeDistance(Vector u, Vector v){
    // overload of the previous function in case we work with tangent vectors
    return fakeDistance(u.pos, v.pos);
}






























//----------------------------------------------------------------------------------------------------------------------
// THE GEODESIC FLOW
//----------------------------------------------------------------------------------------------------------------------



Vector numflow(inout Vector tv, float t) {
    // follow the geodesic flow using a numerical integration
    // fix the noise for small steps
    float NUM_STEP = 0.2 * EPSILON;

    // Isometry moving back to the origin and conversely
    Isometry isom = makeLeftTranslation(tv);
    Isometry isomInv = makeInvLeftTranslation(tv);


    // pull back of the tangent vector at the origin
    Vector tvOrigin = translate(isomInv, tv);

    // tangent vector used updated during the numerical integration
    Vector aux = tvOrigin;

    // integrate numerically the flow
    int n = int(floor(t/NUM_STEP));
    for (int i = 0; i < n; i++){
        vec3 fieldPos = aux.dir;
        vec3 fieldDir = vec3(
        2. * aux.dir.x * aux.dir.z,
        -2. * aux.dir.y * aux.dir.z,
        -exp(-2. * aux.pos.coords.z) * pow(aux.dir.x, 2.) + exp(2. * aux.pos.coords.z) * pow(aux.dir.y, 2.)
        );

        aux.pos.coords = aux.pos.coords + NUM_STEP * fieldPos;
        aux.dir = aux.dir + NUM_STEP * fieldDir;
        aux = normalize(aux);
    }

    Vector res = translate(isom, aux);
    res = normalize(res);

    
    tv=res;
    return res;

}


Vector ellflow(inout Vector tv, float t){
    // follow the geodesic flow during a time t

    // Isometry moving back to the origin and conversely
    Isometry isom = makeLeftTranslation(tv);
    Isometry isomInv = makeInvLeftTranslation(tv);

    // pull back of the tangent vector at the origin
    Vector tvOrigin = translate(isomInv, tv);

    // result to be populated
    Vector resOrigin = Vector(ORIGIN, vec3(0.));

    // renaming the coordinates of the tangent vector to simplify the formulas
    float a = tvOrigin.dir.x;
    float b = tvOrigin.dir.y;
    float c = tvOrigin.dir.z;

    // we need to distinguish three cases, depending on the type of geodesics

    // tolerance used between the difference cases
    //float tolerance = 0.0000001;

    //if (abs(a) < tolerance) {
    if (a == 0.) {
        // GEODESIC IN THE HYPERBOLIC SHEET X = 0
        float sht = sinh(t);
        float cht = cosh(t);
        float tht = sht/cht;

        resOrigin.pos.coords = vec3(
        0.,
        b * sht / (cht + c * sht),
        log(cht + c * sht)
        );
        resOrigin.dir = vec3(
        0.,
        b / pow(cht + c * sht, 2.),
        (c + tht) / (1. + c * tht)
        );
    }
    //else if (abs(b) < tolerance) {
    else if (b == 0.) {
        // GEODESIC IN THE HYPERBOLIC SHEET Y = 0
        float sht = sinh(t);
        float cht = cosh(t);
        float tht = sht/cht;

        resOrigin.pos.coords = vec3(
        a * sht / (cht - c * sht),
        0.,
        - log(cht - c * sht)
        );
        resOrigin.dir = vec3(
        a / pow(cht - c * sht, 2.),
        0.,
        (c - tht) / (1. - c * tht)
        );
    }
    else {

        // GENERIC CASE
        // In order to minimizes the computations we adopt the following trick
        // For long steps, i.e. if mu * t > 4K, then we only march by an integer multiple of the period 4K.
        // In this way, there is no elliptic function to compute : only the x,y coordinates are shifted by a translation
        // We only compute elliptic functions for small steps, i.e. if mu * t < 4K

        float steps = floor((ell_mu * t) / (4. * ell_K));

        if (steps > 0.5) {
            resOrigin.pos.coords = vec3(ell_L * steps * 4. * ell_K, ell_L * steps * 4. * ell_K, 0.);
            resOrigin.dir = vec3(a, b, c);
        }
        else {

            // parameters related to the initial condition of the geodesic flow

            // phase shift (Phi in the handwritten notes)
            float aux = sqrt(1. - 2. * abs(a * b));
            // jacobi functions applied to s0 (we don't care about the amplitude am(s0) here)
            vec3 jacobi_s0 = vec3(
            - c / aux,
            (abs(a) - abs(b)) / aux,
            (abs(a) + abs(b)) / ell_mu
            );


            // sign of a (resp. b)
            float signa = 1.;
            if (a < 0.) {
                signa = -1.;
            }
            float signb = 1.;
            if (b < 0.) {
                signb = -1.;
            }

            // some useful intermediate computation
            float kOkprime = ell_k / ell_kprime;
            float oneOkprime = 1. / ell_kprime;

            // we are now ready to write down the coordinates of the endpoint

            // amplitude (without the phase shift of s0)
            // the functions we consider are 4K periodic, hence we can reduce the value of mu * t modulo 4K.
            // (more a safety check as we assumed that mu * t < 4K)
            float s = mod(ell_mu * t, 4. * ell_K);
            // jabobi functions applied to the amplitude s
            vec3 jacobi_s = ellipj(s);

            // jacobi function applied to mu * t + s0 = s + s0  (using addition formulas)
            float den = 1. - ell_m * jacobi_s.x * jacobi_s.x * jacobi_s0.x * jacobi_s0.x;
            vec3 jacobi_ss0 = vec3(
            (jacobi_s.x * jacobi_s0.y * jacobi_s0.z + jacobi_s0.x * jacobi_s.y * jacobi_s.z) / den,
            (jacobi_s.y * jacobi_s0.y - jacobi_s.x * jacobi_s.z * jacobi_s0.x * jacobi_s0.z) / den,
            (jacobi_s.z * jacobi_s0.z - ell_m * jacobi_s.x * jacobi_s.y * jacobi_s0.x * jacobi_s0.y) / den
            );

            // Z(mu * t + s0) - Z(s0) (using again addition formulas)
            float zetaj = ellipz(jacobi_s.x / jacobi_s.y) - ell_m * jacobi_s.x * jacobi_s0.x * jacobi_ss0.x;


            // wrapping all the computation
            resOrigin.pos.coords = vec3(

            signa * sqrt(abs(b / a)) * (
            oneOkprime * zetaj
            + kOkprime * (jacobi_ss0.x - jacobi_s0.x)
            + ell_L * ell_mu * t
            ),

            signb * sqrt(abs(a / b)) * (
            oneOkprime * zetaj
            - kOkprime * (jacobi_ss0.x - jacobi_s0.x)
            + ell_L * ell_mu * t
            ),

            0.5 * log(abs(b / a)) + asinh(kOkprime * jacobi_ss0.y)
            );

            resOrigin.dir = vec3(

            signa * abs(b) * pow(kOkprime * jacobi_ss0.y + oneOkprime * jacobi_ss0.z, 2.),

            signb * abs(a) * pow(kOkprime * jacobi_ss0.y - oneOkprime * jacobi_ss0.z, 2.),

            - ell_k * ell_mu * jacobi_ss0.x
            );
        }
    }

    resOrigin = normalize(resOrigin);
    Vector res = translate(isom, resOrigin);
    res = normalize(res);
    
    
 tv=res;
    return res;

}

Vector flow(inout Vector tv, float t) {

    if (abs(t) < 50. * EPSILON) {
        return numflow(tv, t);
        //return ellflow(tv, t);
    }
    else {
        return ellflow(tv, t);
    }
}






































//
//
////-------------------------------------------------
////The GEODESIC FLOW
////-------------------------------------------------
//
//
//
//
//actually flowing along a geodesic
//Vector flow(inout Vector tv, float t){
//    //flow distance t in direction tv
//    tv.pos.coords+=t*tv.dir;
//    return tv;
//}
