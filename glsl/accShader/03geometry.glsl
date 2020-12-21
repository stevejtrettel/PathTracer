//-------------------------------------------------
//The LOCAL GEOMETRY
//-------------------------------------------------


float dot(Vector u, Vector v){
    return dot(u.dir,v.dir);
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


Vector rotateFacing(mat3 A, Vector v){
    // apply an isometry to the tangent vector (both the point and the direction)
    return Vector(v.pos, A*v.dir);
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
    // we assume that u's direction is stored at origin
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
    
    return length(qOrigin.coords);
}

float fakeDistance(Vector u, Vector v){
    // overload of the previous function in case we work with tangent vectors
    return fakeDistance(u.pos, v.pos);
}










//----------------------------------------------------------------------------------------------------------------------
// THE LOCAL GEODESIC FLOW
//----------------------------------------------------------------------------------------------------------------------



Vector numflow(Vector tv, float t) {
    // follow the geodesic flow during time t
    // using a numerical integration
    // fix the noise for small steps
    float NUM_STEP = 0.2 * EPSILON;

    // Isometry moving back to the origin and conversely
    Isometry isom = makeLeftTranslation(tv);

    // tangent vector used updated during the numerical integration
    Vector aux = Vector(ORIGIN, tv.dir);

    // integrate numerically the flow
    int n = int(floor(t/NUM_STEP));
    for (int i = 0; i < n; i++){
        vec3 fieldPos = vec3(
        exp(aux.pos.coords.z) * aux.dir.x,
        exp(-aux.pos.coords.z) * aux.dir.y,
        aux.dir.z
        );
        vec3 fieldDir = vec3(
        aux.dir.x * aux.dir.z,
        -aux.dir.y * aux.dir.z,
        -pow(aux.dir.x, 2.) + pow(aux.dir.y, 2.)
        );

        aux.pos.coords= aux.pos.coords + NUM_STEP * fieldPos;
        aux.dir = aux.dir + NUM_STEP * fieldDir;
        aux = normalize(aux);
    }

    Vector res = translate(isom, aux);
    res = normalize(res);

    return res;

}


Vector hypXflow(Vector tv, float t) {
    // flow in (the neighborhood of) the hyperbolic sheets {x = 0}
    // use an taylor expansion at the order 2 around a = 0
    // if need one could use a higher order expansion...
    // one "just" need to do a few ugly computations before!


    // Isometry moving back to the origin and conversely
    Isometry isom = makeLeftTranslation(tv);

    // result to be populated
    Vector resOrigin;

    // renaming the coordinates of the tangent vector to simplify the formulas
    float a = tv.dir.x;
    float b = tv.dir.y;
    float c = tv.dir.z;

    // preparing the material to write down the formula in an easy way
    // and avoid redundant computation
    // look at the notes for the definitions of all the quantities


    float b2 = b * b;
    float c2 = c * c;
    // norm of the yz component of the tagent vector, i.e. sqrt(b^2 + c^2) and its powsers
    float n1 = sqrt(b2 + c2);
    float n2 = n1 * n1;
    float n3 = n1 * n2;
    float n4 = n1 * n3;
    // sign of b
    float sign = 1.;
    if (b < 0.) {
        sign = -1.;
    }
    // cosh(s), sinh(s), and tanh(s) where s = n(t+t0)
    float shs = (c * cosh(n1 * t) + n1 * sinh(n1 * t)) / abs(b);
    float chs = (n1 * cosh(n1 * t) + c * sinh(n1 * t)) / abs(b);
    float ths = shs / chs;


    vec3 u0 = vec3(
    0.,
    sign * n1 / chs,
    n1 * ths
    );

    vec3 u1 = vec3(
    abs(b) * chs / n1,
    0.,
    0.
    );

    vec3 u2 = vec3(
    0.,
    sign * b2 * chs / (4. * n3)
    + sign * (b2 - 2. * c2)  * (n1 * t * shs / pow(chs, 2.) - 1. / chs) / (4. * n3)
    - 3. * sign * c * shs / (4. * n2 * pow(chs, 2.)),
    - b2 * shs * chs / (2. * n3)
    - (b2 - 2. * c2) * (ths - n1 * t / pow(chs, 2.)) / (4. * n3)
    + 3. * c / (4. * n2 * pow(chs, 2.))
    );

    resOrigin.dir = u0  + a * u1 + a * a * u2;


    vec3 p0 = vec3(
    0.,
    n1 * ths / b - c / b,
    log(abs(b) * chs / n1)
    );

    vec3 p1 = vec3(
    b2 * (shs * chs + n1 * t) / (2. * n3) - c / (2. * n2),
    0.,
    0.
    );

    vec3 p2 = vec3(
    0.,
    b * n1 * t / (2. * n3)
    - (b2 - 2. * c2) * ( n1 * t / pow(chs, 2.) + ths) / (4. * b * n3)
    + 3. * c / (4. * b * n2 * pow(chs, 2.))
    - c / (2. * b * n2),
    - b2 * pow(chs, 2.) / (4. * n4)
    - (b2 - 2. * c2) * (n1 * t * ths - 1.) / (4. * n4)
    + 3. * c * ths / (4. * n3)
    );

    resOrigin.pos.coords = p0 + a * p1 + a * a * p2;


    resOrigin = normalize(resOrigin);
    Vector res = translate(isom, resOrigin);
    res = normalize(res);

    return res;
}


Vector hypYflow(Vector tv, float t) {
    // flow in (the neighborhood of) the hyperbolic sheets {y = 0}

    Vector tvAux;
    tvAux.pos.coords = vec3(tv.pos.coords.y, tv.pos.coords.x, -tv.pos.coords.z);
    tvAux.dir = vec3(tv.dir.y, tv.dir.x, -tv.dir.z);

    Vector resAux = hypXflow(tvAux, t);
    Vector res;
    res.pos.coords = vec3(resAux.pos.coords.y, resAux.pos.coords.x, -resAux.pos.coords.z);
    res.dir = vec3(resAux.dir.y, resAux.dir.x, -resAux.dir.z);

    res = normalize(res);

    return res;
}




Vector ellflow(Vector tv, float t){
    // follow the geodesic flow during a time t
    // generic case

    // Isometry moving back to the origin and conversely
    Isometry isom = makeLeftTranslation(tv);

    // result to be populated
    Vector resOrigin = Vector(ORIGIN, vec3(0.));

    // renaming the coordinates of the tangent vector to simplify the formulas
    float a = tv.dir.x;
    float b = tv.dir.y;
    float c = tv.dir.z;


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

        a * sqrt(abs(b/a)) * (kOkprime * jacobi_ss0.y + oneOkprime * jacobi_ss0.z),


        - b * sqrt(abs(a/b)) * (kOkprime * jacobi_ss0.y - oneOkprime * jacobi_ss0.z),

        - ell_k * ell_mu * jacobi_ss0.x
        );
    }

    resOrigin = normalize(resOrigin);
    Vector res = translate(isom, resOrigin);
    res = normalize(res);

    return res;

}


Vector flow(Vector tv, float t) {

    float tolerance = 0.0001;

    if (abs(t) < 50. * EPSILON) {
        return numflow(tv, t);
        //return ellflow(tv, t);
    }
    else {
        if (abs(tv.dir.x * t) < tolerance) {
        //if (tv.dir.x ==0.) {
            return hypXflow(tv, t);
        }
        else if (abs(tv.dir.y * t) < tolerance) {
        //else if (tv.dir.y ==0.) {
            return hypYflow(tv, t);
        }
        else {
            return ellflow(tv, t);
        }
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
