/********************************************************************
*  Conformally‑flat geodesic ray‑marcher  (U⁴ δ metric)
*  Author : ChatGPT (o3)  |  May 2025
********************************************************************/

/* -----------------------------------------------------------------
   0.  Parameters you must bind from JavaScript
   -----------------------------------------------------------------*/
const int    BH_COUNT = 4;                   // number of black holes
uniform vec3  bhPos [BH_COUNT];              // positions  p_k
uniform float bhMass[BH_COUNT];              // masses     m_k

/* Scene SDF and surface‑data callback – keep your originals */
float sdf_Scene(in vec3 x);
void  setData_Scene(inout Path p);

/* -----------------------------------------------------------------
   1.  Tunables
   -----------------------------------------------------------------*/
const float marchFactor = 0.90;   // sphere‑tracing style safety
const float tol         = 1e-4;   // ≤ 10⁻⁴ world‑units local error
const float safety      = 0.40;   // never step ≥ 40 % to a singularity
const float dtMin       = 1e-5;
const float dtMax       = 5.0;
const int   maxMarchSteps = 256;

/* -----------------------------------------------------------------
   2.  Data structures
   -----------------------------------------------------------------*/
struct MetricInfo {
    float U;                // conformal factor
    vec3  gradU;            // ∇U
    float gradLnU_norm;     // |∇lnU|
    float rMin;             // nearest singularity distance
};

//struct TangentVector {
//    vec3 pos;
//    vec3 dir;
//};
//
//struct Path {
//    TangentVector tv;
//    float distance;
//    float totalDistance;
//    Data  dat;              // your existing surface‑data struct
//};

/* -----------------------------------------------------------------
   3.  Metric helper – single source of spacetime data
   -----------------------------------------------------------------*/
MetricInfo metric(in vec3 x)
{
    MetricInfo m;
    m.gradU  = vec3(0.0);
    m.U      = 1.0;          // start with the “+1”
    m.rMin   = 1e30;

    for (int k = 0; k < BH_COUNT; ++k) {
        vec3  d   = x - bhPos[k];
        float r   = length(d) + 1e-6;          // avoid /0
        float ri  = 1.0 / r;
        float mri = bhMass[k] * ri;

        m.U     += mri;
        m.gradU += -mri * ri * ri * d;         // −m r⁻³ d
        m.rMin   = min(m.rMin, r);
    }
    m.gradLnU_norm = length(m.gradU) / m.U;
    return m;
}

/* -----------------------------------------------------------------
   4.  Spatial acceleration  x'' = −2∇lnU + 2(x'⋅∇lnU / |x'|²)x'
   -----------------------------------------------------------------*/
vec3 acceleration(in vec3 pos, in vec3 vel)
{
    MetricInfo m = metric(pos);
    vec3  gLnU = m.gradU / m.U;
    float v2   = dot(vel, vel);
    return -2.0 * gLnU + 2.0 * dot(vel, gLnU) / v2 * vel;
}

/* -----------------------------------------------------------------
   5.  Forest–Ruth (Yoshida) 4th‑order symplectic step
   -----------------------------------------------------------------*/
const float c1 =  0.6756035959798289;
const float c2 = -0.1756035959798289;
const float c3 =  0.6756035959798289;

const float d1 =  1.3512071919596578;
const float d2 = -1.7024143839193153;
const float d3 =  1.3512071919596578;

void forestRuth(inout TangentVector tv, float dt)
{
    tv.pos += c1 * dt * tv.dir;

    tv.dir += d1 * dt * acceleration(tv.pos, tv.dir);

    tv.pos += c2 * dt * tv.dir;

    tv.dir += d2 * dt * acceleration(tv.pos, tv.dir);

    tv.pos += c3 * dt * tv.dir;

    tv.dir += d3 * dt * acceleration(tv.pos, tv.dir);
}

/* -----------------------------------------------------------------
   6.  Step‑doubling with error estimate
   -----------------------------------------------------------------*/
bool tryStep(inout TangentVector tv, float dt,
out TangentVector tvAccurate, out float err)
{
    /* one big step */
    TangentVector tvBig = tv;
    forestRuth(tvBig, dt);

    /* two half‑steps */
    TangentVector tvHalf = tv;
    forestRuth(tvHalf, 0.5*dt);
    forestRuth(tvHalf, 0.5*dt);

    err         = length(tvBig.pos - tvHalf.pos);
    tvAccurate  = tvHalf;
    return (err < tol);
}

/* -----------------------------------------------------------------
   7.  Proposed time‑step  Δλ  (geometry + curvature + singularity)
   -----------------------------------------------------------------*/
float propose_dt(in TangentVector tv)
{
    MetricInfo m = metric(tv.pos);
    float v      = length(tv.dir);

    float dt_geom = marchFactor * abs(sdf_Scene(tv.pos)) / v;
    float dt_curv = sqrt(tol / (m.gradLnU_norm + 1e-6)) / v;
    float dt_sing = safety * m.rMin / v;

    return clamp(min(dt_geom, min(dt_curv, dt_sing)), dtMin, dtMax);
}

/* -----------------------------------------------------------------
   8.  Geodesic sphere‑tracing
   -----------------------------------------------------------------*/
float raymarch(inout TangentVector tv, float stopDist)
{
    float travelled = 0.0;
    float dt        = 1.0;                  // initial guess

    for (int i = 0; i < maxMarchSteps; ++i) {

        float distScene = abs(sdf_Scene(tv.pos));
        if (distScene < 1e-4) return travelled;       // hit!

        /* keep dt within safe bounds before the trial */
        dt = min(dt, propose_dt(tv));
        float v = length(tv.dir);
        if (travelled + dt * v > stopDist)
        dt = (stopDist - travelled) / v;

        /* adaptive Forest‑Ruth */
        TangentVector tvOK;
        float err;
        if (tryStep(tv, dt, tvOK, err)) {             // accept
            tv        = tvOK;
            travelled += dt * v;
            dt        = min(dt * 1.5, dtMax);         // grow a bit
        } else {                                     // reject
            dt = max(dt * 0.5, dtMin);
            --i;                                     // don’t count
        }

        if (travelled >= stopDist - 1e-6)             // sky
        return stopDist;
    }
    return stopDist;     // maxMarchSteps reached
}

/* -----------------------------------------------------------------
   9.  Path‑tracer entry point
   -----------------------------------------------------------------*/
void stepForward(inout Path path)
{
    float distance = raymarch(path.tv, maxDist);

    path.distance        = distance;
    path.totalDistance  += distance;

    path.dat.isSky = (distance > maxDist - 0.1);
    if (!path.dat.isSky) setData_Scene(path);
}
