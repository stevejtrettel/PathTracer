//----------------------------------------------------------------------------
// SERPINSKI — a vendored model from NVIDIA's sdf-explorer corpus.
//
// VENDORED, NOT OURS. The original copyright and licence block follows this
// header verbatim and governs the maths below it; most of this corpus is
// CC BY-NC-SA 3.0, a few files MIT. That is why vendor/ is its own folder: the
// condition travels with the file and must never be mixed into models/.
//
// PORTED, minimally: the corpus's bare `sdf(vec3)` became `serpinski_sdf`, and the
// two functions at the foot of the file are ours — a `size` parameter (the
// corpus had none) and a bounding sphere.
//
// THE BOUND IS A GUESS, deliberately loose. The corpus documented "most models
// <= 1.5, PixarMike and Serpinski ~3" and nothing per-model, so this uses
// 3.5 and errs large: too tight punches a visible hole, too loose only costs
// march steps. Tighten it by eye once the model has a scene.
//
// CAVEAT INHERITED FROM THE CORPUS: these files were written to be compiled ONE
// AT A TIME and their internal helper names collide with each other. Naming two
// vendor models in a single scene may not compile — see docs/shape-library.md §7.
//----------------------------------------------------------------------------

/*
Copyright al13n 2014 @al13n
License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
Link: https://www.shadertoy.com/view/Xd2XDW
*/

/******************************************************************************
 This work is a derivative of work by al13n used under CC BY-NC-SA 3.0.
 This work is licensed also under CC BY-NC-SA 3.0 by NVIDIA CORPORATION.
 ******************************************************************************/

// This is a serpinski tetrahedron where
// the leaves are spheres (for efficiency). They can
// be made into tetrahedrons using sdTetrahedron.
float serpinski_sdf(vec3 p)
{

    if(length(p)>3.){
        return length(p)-2.9;
    }

    p *= 2.5;
    const vec3 p0 = vec3(-1, -1, -1);
    const vec3 p1 = vec3(1, 1, -1);
    const vec3 p2 = vec3(1, -1, 1);
    const vec3 p3 = vec3(-1, 1, 1);

    const int maxit = 25;
    // Scale factor for each iteration
    const float scale = 2.0;
    const float minSize = pow(scale, -float(maxit - 2));

    for (int i = 0; i < maxit; ++i) {
        float d = distance(p, p0);
        vec3 c = p0;

        float t = distance(p, p1);
        if (t < d) {
            d = t;
            c = p1;
        }

        t = distance(p, p2);
        if (t < d) {
            d = t;
            c = p2;
        }

        t = distance(p, p3);
        if (t < d) {
            d = t;
            c = p3;
        }

        p = (p - c) * scale;
    }

    return (1.0/2.5) * (length(p) * pow(scale, float(-maxit)) - minSize);
}

// p is in the model's own coordinates; `size` scales it about the origin
float serpinskiDistance(vec3 p, float size){
    return serpinski_sdf(p/size)*size;
}

// bounding sphere — see the header: loose on purpose, tighten by eye
float serpinskiBound(vec3 p, float size){
    return length(p) - 3.5*size;
}
