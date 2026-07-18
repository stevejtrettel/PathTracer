//-------------------------------------------------
// DEBUG PASS — cheap one-shot diagnostics + preview shading
//-------------------------------------------------
// Entered only when uDebugMode != 0 (the fork in traceShader newFrame). It does its
// OWN primary-ray march of sdf_Scene, so it never touches pathTrace / raymarch / the
// object macros — with debug off the normal render is byte-identical. Because it
// marches the shared sdf_Scene it automatically covers every object, present and
// future. No bounce loop and no accumulation dependence: a clean, deterministic image
// every frame, so the scene is fast AND noise-free to navigate.
//
// modes (uDebugMode):
//   1 matcap preview | 2 normals | 3 cost heatmap | 4 DE quality
//
// (colours pass through the display stage's ACES tonemap + gamma like any frame;
//  fine for the preview, and the diagnostics stay qualitatively readable. Exact-value
//  readouts could later bypass tonemapping — see docs/debug-suite.md.)


// scene surface normal by central differences on sdf_Scene (generic: all objects).
// the ray dir is fed to every sample so direction-dependent sdfs (Plane) stay consistent.
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


// own primary-ray march: finds the hit and counts steps. Mirrors raymarch() semantics
// (abs distance, 0.9 march factor). out: hit position, step count, distance marched.
bool dbgMarch(Vector tv, out vec3 hitPos, out int steps, out float total){
    float t = 0.;
    steps = 0;
    for(int i = 0; i < maxMarchSteps; i++){
        steps = i + 1;
        float d = abs(sdf_Scene(tv));
        if(d < EPSILON){ hitPos = tv.pos; total = t; return true; }
        d *= 0.9;                       // marchFactor, matches raymarch
        t += d;
        if(t > maxDist){ break; }
        flow(tv, d);
    }
    hitPos = tv.pos; total = t; return false;
}


vec3 debugPass(int mode, Vector tv){
    vec3 rayDir = tv.dir;
    vec3 hitPos; int steps; float total;
    bool hit = dbgMarch(tv, hitPos, steps, total);

    // cost heatmap: colour by march steps whether or not we hit (long misses are
    // expensive too, and reveal loose bounds).
    if(mode == 3){
        return dbgHeat(float(steps) / max(dbgHeatScale, 1.));
    }

    if(!hit){
        // matcap preview shows the sky (reads like a real preview); the diagnostics
        // use a neutral backdrop so the surface stands out.
        return (mode == 1) ? getSky(rayDir) : vec3(0.02);
    }

    vec3 n = dbgNormal(hitPos, rayDir);

    if(mode == 2){                     // normals: xyz -> rgb
        return 0.5 + 0.5*n;
    }

    if(mode == 4){                     // DE quality: |grad| ~ 1, warming to red as it strays
        float dev = clamp(abs(dbgGradMag(hitPos, rayDir) - 1.), 0., 1.);
        return mix(vec3(0.1, 0.9, 0.2), vec3(1.0, 0.15, 0.1), dev);
    }

    // mode 1: matcap-style clay preview — ambient + hemisphere fill + headlight key.
    float key  = clamp(0.5 + 0.5*dot(n, -rayDir), 0., 1.);   // headlight from the camera
    float fill = 0.5 + 0.5*n.y;                              // sky/ground hemisphere
    return clamp(vec3(0.85) * (0.2 + 0.3*fill + 0.6*key), 0., 1.);
}
