//-------------------------------------------------
// SPECTRAL DISPERSION  (RGB, hero-wavelength Monte Carlo)
//
// The tracer stays RGB, but when dispersion is on each ray carries ONE random
// wavelength: its throughput is tinted by that wavelength's colour and the
// refractive index is shifted by it (blue bends more than red). Averaging over
// many samples — which the accumulation buffer already does — integrates the
// spectrum, so refraction SEPARATES colours (prism rainbows, chromatic caustics)
// while everything non-refractive still resolves to its correct RGB (the tints
// average to white). vRefract()/Fresnel() need no changes: they already take the
// index as a parameter, and here that index becomes wavelength-dependent.
//
// waveLength in [0,1] spans the visible band (0 ~ red end, 1 ~ violet end); it is
// set once per pixel/frame in newFrame (traceShader.glsl), like `seed`.
//
// GATE: controlled by the `dispersion` render uniform. At dispersion == 0 the
// caller pins waveLength = 0.5 and path.light = vec3(1), and iorAt() returns the
// base index unchanged — so the tracer is byte-identical to the non-spectral one.
//-------------------------------------------------


float waveLength;   // this ray's wavelength, 0..1 across the visible band


// wavelength -> RGB tint. Three saturated Gaussian bands (R,G,B), each divided by
// its own mean over [0,1] so the tint AVERAGES TO WHITE — that normalization is
// what keeps non-dispersive surfaces correctly white-balanced under spectral
// sampling. (AVG computed numerically; verified the normalized mean is (1,1,1).)
vec3 spectralWeight(float t){
    const float s = 0.14;
    const vec3 AVG = vec3(0.24276, 0.24814, 0.24276);   // per-channel mean over t in [0,1]
    vec3 d = (vec3(t) - vec3(0.20, 0.50, 0.80)) / s;    // signed distance to each band centre
    return exp(-d*d) / AVG;                             // d*d, not pow(): base may be negative
}


// wavelength-dependent refractive index — a linear approximation of Cauchy
// dispersion. Blue (waveLength -> 1) bends more, red (-> 0) less; the mid
// wavelength (0.5) is the base index, so a mid-wavelength ray OR dispersion == 0
// returns baseIOR exactly. Apply only to MATERIAL indices in setImpactData; the
// air side (a literal 1.0) is left undispersed.
float iorAt(float baseIOR){
    return baseIOR + dispersion * (waveLength - 0.5);
}
