//-------------------------------------------------
// DEBUG PASS — cheap one-shot diagnostics + preview shading
//-------------------------------------------------
// Entered only when uDebugMode != 0 (the fork in traceShader newFrame). It replaces
// path tracing with a single-hit pass: no bounce loop and no accumulation dependence,
// so the image is clean and deterministic every frame — the scene is fast AND
// noise-free to navigate. With debug off (mode 0) none of this runs and the normal
// render is byte-identical.
//
// Every mode shows every object (SDF-marched AND analytic-trace), because both the
// surface modes and the diagnostic march mirror the real first hit.
//   SURFACE modes reuse stepForward() (real material + normal):
//     1 normals | 4 depth | 6 albedo | 7 lit preview | 8 focus peaking
//   MARCH-INTERNALS modes use dbgMarch() (measure the march itself):
//     2 cost heatmap | 3 DE quality | 5 overstep / convergence
//   BOUND SHELLS (9): the object macro makes each bounded object return its bound, so
//     marching sdf_Scene hits the bounding volumes — see their true size/shape.
//
// (colours pass through the display stage's ACES tonemap + gamma like any frame.)


// scene surface normal by central differences on sdf_Scene (used by bound shells,
// which march the bound field). the ray dir is fed to every sample so direction-
// dependent sdfs stay consistent.
vec3 dbgNormal(vec3 p, vec3 dir){
    const float e = 0.0006;
    vec2 k = vec2(1.,-1.);
    return normalize(
        k.xyy*sdf_Scene(Vector(p + k.xyy*e, dir)) +
        k.yyx*sdf_Scene(Vector(p + k.yyx*e, dir)) +
        k.yxy*sdf_Scene(Vector(p + k.yxy*e, dir)) +
        k.xxx*sdf_Scene(Vector(p + k.xxx*e, dir))
    );
}


// magnitude of the sdf_Scene gradient at p. ~1 for a true distance field; the DE
// quality lens colours by how far this strays from 1.
float dbgGradMag(vec3 p, vec3 dir){
    const float e = 0.0006;
    return length(vec3(
        sdf_Scene(Vector(p+vec3(e,0,0), dir)) - sdf_Scene(Vector(p-vec3(e,0,0), dir)),
        sdf_Scene(Vector(p+vec3(0,e,0), dir)) - sdf_Scene(Vector(p-vec3(0,e,0), dir)),
        sdf_Scene(Vector(p+vec3(0,0,e), dir)) - sdf_Scene(Vector(p-vec3(0,0,e), dir))
    )) / (2.*e);
}


// black -> red -> yellow -> white ramp for the cost heatmap
vec3 dbgHeat(float t){
    t = clamp(t, 0., 1.);
    return clamp(vec3(3.*t, 3.*t-1., 3.*t-2.), 0., 1.);
}


// clay shading from a normal: ambient + hemisphere fill + headlight key
vec3 dbgClay(vec3 base, vec3 n, vec3 rayDir){
    float key  = clamp(0.5 + 0.5*dot(n, -rayDir), 0., 1.);
    float fill = 0.5 + 0.5*n.y;
    return clamp(base * (0.25 + 0.3*fill + 0.6*key), 0., 1.);
}


// primary-ray first hit, mirroring stepForward: the analytic trace gives a stop
// distance, then we march sdf_Scene up to it (counting steps). Reports the hit, the
// step count, the distance, and whether the winner was the analytic surface (reached
// on the step that would overshoot the stop — so a clear analytic hit costs ~1 step).
//
// Mirrors raymarch() exactly (over-relaxed sphere tracing + adaptive cone epsilon,
// MARCH_RELAX / MARCH_CONE from raymarch.glsl), plus the step count and the analytic-
// vs-marched bookkeeping the diagnostic lenses need — so the cost heatmap / overstep /
// DE modes measure the real marcher.
bool dbgMarch(Vector tv, out vec3 hitPos, out int steps, out float total, out bool analytic){
    float stop = trace_Scene(tv);        // nearest analytic surface (or maxDist)
    float t = 0.;
    float prevRadius = 0.;
    float stepLength = 0.;
    float sgn = (sdf_Scene(tv) < 0.) ? -1. : 1.;
    steps = 0;
    analytic = false;
    for(int i = 0; i < maxMarchSteps; i++){
        steps = i + 1;
        float raw = sdf_Scene(tv);
        float radius = abs(raw);
        float signedRadius = sgn * raw;

        bool sorFail = (MARCH_RELAX > 1.) && (prevRadius + radius < stepLength);
        stepLength = sorFail ? (prevRadius - stepLength) : (signedRadius * MARCH_RELAX);
        prevRadius = radius;
        float eps = EPSILON * (1. + MARCH_CONE * t);

        if(!sorFail && radius < eps){ hitPos = tv.pos; total = t; return true; }   // marched (SDF) hit
        if(stepLength > 0. && t + stepLength >= stop){                            // analytic surface first
            analytic = true;
            flow(tv, stop - t);
            hitPos = tv.pos; total = stop; return true;
        }
        t += stepLength;
        if(t > maxDist){ break; }
        flow(tv, stepLength);
    }
    hitPos = tv.pos; total = t; return false;
}


vec3 debugPass(int mode, Path path){
    Vector cam = path.tv;              // camera ray (dir preserved through stepForward)

    //--- BOUND SHELLS: with uDebugMode == 9 the object macro returns each bounded
    //    object's bound as its surface, so marching sdf_Scene hits the shells.
    if(mode == 9){
        Vector tv = cam;
        vec3 hitPos; int steps; float total; bool analytic;
        if(!dbgMarch(tv, hitPos, steps, total, analytic)){ return getSky(cam.dir); }
        return dbgClay(vec3(0.45, 0.6, 0.9), dbgNormal(hitPos, cam.dir), cam.dir);  // bluish shells
    }

    //--- SURFACE modes: the real first-hit pipeline. stepForward does the (bounded)
    //    raytrace + raymarch and fills path.dat with the real material + normal.
    if(mode == 1 || mode == 4 || mode == 6 || mode == 7 || mode == 8){
        stepForward(path);
        if(path.dat.isSky){
            return (mode == 7 || mode == 8) ? getSky(cam.dir) : vec3(0.02);   // lit/focus show sky
        }
        vec3 n = path.dat.normal.dir;                                   // real per-object normal
        if(mode == 1){ return 0.5 + 0.5*n; }                           // normals: xyz -> rgb
        if(mode == 4){ return vec3(exp(-0.15 * path.totalDistance)); } // depth: near = bright
        vec3 albedo = path.dat.surfDiffuse;
        if(mode == 6){ return albedo; }                                // albedo: flat surface colour

        vec3 lit = albedo * (0.25 + 0.35*(0.5+0.5*n.y)
                             + 0.55*clamp(0.5+0.5*dot(n, -cam.dir), 0., 1.));  // real albedo, cheap shading
        if(mode == 7){ return lit; }                                   // lit preview
        // mode 8: focus peaking — concentric focus zones over a GRAYSCALE preview, so
        // the zone colours read clearly. The overlay strength is graduated (vivid at the
        // sharp focal plane, faint far out), so the scene stays grayscale with colour
        // concentrated where focus matters. cyan = sharp, green -> yellow -> red = out.
        float ad = abs(path.totalDistance - focalLength) / max(dbgFocusBand, 0.0002);
        float gray = dot(lit, vec3(0.299, 0.587, 0.114));   // desaturated scene
        vec3  fcol; float amt;                              // zone colour + overlay strength
        if(ad < 1.0)      { fcol = vec3(0.1, 1.0, 1.0);  amt = 0.75; }  // cyan: sharp focus
        else if(ad < 2.5) { fcol = vec3(0.2, 1.0, 0.3);  amt = 0.55; }  // green: near
        else if(ad < 5.0) { fcol = vec3(1.0, 0.9, 0.2);  amt = 0.38; }  // yellow: mid
        else              { fcol = vec3(1.0, 0.35, 0.25); amt = 0.0; }   // out of focus: plain gray
        return mix(vec3(gray), fcol, amt);
    }

    //--- MARCH-INTERNALS modes: the sdf_Scene march, with the analytic hit as a stop.
    Vector tv = cam;
    vec3 hitPos; int steps; float total; bool analytic;
    bool hit = dbgMarch(tv, hitPos, steps, total, analytic);

    if(mode == 2){                     // cost heatmap (misses count too: they reveal loose bounds)
        return dbgHeat(float(steps) / max(dbgHeatScale, 1.));
    }
    if(mode == 5){                     // overstep / convergence: where marching fails
        if(hit)                  return vec3(0.12, 0.5, 0.16);   // converged (SDF or analytic): green
        if(total < maxDist*0.99) return vec3(1.0, 0.12, 0.1);    // ran out of steps: red hole
        return vec3(0.02);                                       // escaped to infinity
    }
    // mode 3: DE quality — |grad| ~ 1 (green), warming to red as it strays. Analytic
    // surfaces are exact by construction, so they read green.
    if(!hit){ return vec3(0.02); }
    if(analytic){ return vec3(0.1, 0.9, 0.2); }
    float dev = clamp(abs(dbgGradMag(hitPos, cam.dir) - 1.), 0., 1.);
    return mix(vec3(0.1, 0.9, 0.2), vec3(1.0, 0.15, 0.1), dev);
}
