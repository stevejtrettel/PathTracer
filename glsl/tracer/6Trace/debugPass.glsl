//-------------------------------------------------
// DEBUG PASS — cheap one-shot diagnostics + preview shading
//-------------------------------------------------
// Entered only when uDebugMode != 0 (the fork in traceShader newFrame). It replaces
// path tracing with a single-hit pass: no bounce loop and no accumulation dependence,
// so the image is clean and deterministic every frame — the scene is fast AND
// noise-free to navigate. With debug off (mode 0) none of this runs and the normal
// render is byte-identical.
//
// EVERY mode shows EVERY object (SDF-marched AND analytic-trace: sphere/plane/roomBox),
// because both the surface modes and the diagnostic march mirror the real first-hit:
//   - SURFACE modes reuse stepForward() (real raytrace + raymarch → real material/normal)
//   - MARCH-INTERNALS modes use dbgMarch(), which takes the analytic hit as a stop
//     distance and marches sdf_Scene up to it. An analytic surface is reached on the
//     first step (cost ~1 step, converged, exact) — exactly how it renders.
//
// modes:  1 matcap | 2 normals | 3 cost heatmap | 4 DE quality
//         5 depth   | 6 overstep | 7 albedo      | 8 lit preview
//
// (colours pass through the display stage's ACES tonemap + gamma like any frame.)


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


// primary-ray first hit, mirroring stepForward: the analytic trace gives a stop
// distance, then we march sdf_Scene up to it (counting steps). Reports the hit, the
// step count, the distance, and whether the winner was the analytic surface (reached
// on the step that would overshoot the stop — so a clear analytic hit costs ~1 step).
bool dbgMarch(Vector tv, out vec3 hitPos, out int steps, out float total, out bool analytic){
    float stop = trace_Scene(tv);        // nearest analytic surface (or maxDist)
    float t = 0.;
    steps = 0;
    analytic = false;
    for(int i = 0; i < maxMarchSteps; i++){
        steps = i + 1;
        float d = abs(sdf_Scene(tv));
        if(d < EPSILON){ hitPos = tv.pos; total = t; return true; }      // marched (SDF) hit
        d *= 0.9;                                                        // marchFactor
        if(t + d >= stop){                                              // analytic surface first
            analytic = true;
            flow(tv, stop - t);
            hitPos = tv.pos; total = stop; return true;
        }
        t += d;
        if(t > maxDist){ break; }
        flow(tv, d);
    }
    hitPos = tv.pos; total = t; return false;
}


vec3 debugPass(int mode, Path path){
    Vector cam = path.tv;              // camera ray (dir preserved through stepForward)

    //--- SURFACE modes: the real first-hit pipeline. stepForward does the (bounded)
    //    raytrace + raymarch and fills path.dat with the real material + normal, so
    //    these show every object — SDF and analytic-trace alike.
    if(mode == 1 || mode == 2 || mode == 5 || mode == 7 || mode == 8){
        stepForward(path);
        if(path.dat.isSky){
            return (mode == 1 || mode == 8) ? getSky(cam.dir) : vec3(0.02);
        }
        vec3 n = path.dat.normal.dir;                                   // real per-object normal
        if(mode == 2){ return 0.5 + 0.5*n; }                           // normals: xyz -> rgb
        if(mode == 5){ return vec3(exp(-0.15 * path.totalDistance)); } // depth: near = bright
        vec3 albedo = path.dat.surfDiffuse;
        if(mode == 7){ return albedo; }                                // albedo: flat surface colour

        float key  = clamp(0.5 + 0.5*dot(n, -cam.dir), 0., 1.);        // headlight from the camera
        float fill = 0.5 + 0.5*n.y;                                    // sky/ground hemisphere
        if(mode == 8){ return albedo * (0.25 + 0.35*fill + 0.55*key); }// lit: real albedo, cheap shading
        return clamp(vec3(0.85) * (0.2 + 0.3*fill + 0.6*key), 0., 1.); // matcap: neutral clay
    }

    //--- MARCH-INTERNALS modes: the sdf_Scene march, with the analytic hit as a stop.
    Vector tv = cam;
    vec3 hitPos; int steps; float total; bool analytic;
    bool hit = dbgMarch(tv, hitPos, steps, total, analytic);

    if(mode == 3){                     // cost heatmap (misses count too: they reveal loose bounds)
        return dbgHeat(float(steps) / max(dbgHeatScale, 1.));
    }
    if(mode == 6){                     // overstep / convergence: where marching fails
        if(hit)                  return vec3(0.12, 0.5, 0.16);   // converged (SDF or analytic): green
        if(total < maxDist*0.99) return vec3(1.0, 0.12, 0.1);    // ran out of steps: red hole
        return vec3(0.02);                                       // escaped to infinity
    }
    // mode 4: DE quality — |grad| ~ 1 (green), warming to red as it strays. Analytic
    // surfaces are exact by construction, so they read green.
    if(!hit){ return vec3(0.02); }
    if(analytic){ return vec3(0.1, 0.9, 0.2); }
    float dev = clamp(abs(dbgGradMag(hitPos, cam.dir) - 1.), 0., 1.);
    return mix(vec3(0.1, 0.9, 0.2), vec3(1.0, 0.15, 0.1), dev);
}
