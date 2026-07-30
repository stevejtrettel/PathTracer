//----------------------------------------------------------------------------
// SPIKE — a vendored model from NVIDIA's sdf-explorer corpus.
//
// VENDORED, NOT OURS. The original copyright and licence block follows this
// header verbatim and governs the maths below it; most of this corpus is
// CC BY-NC-SA 3.0, a few files MIT. That is why vendor/ is its own folder: the
// condition travels with the file and must never be mixed into models/.
//
// PORTED, minimally: the corpus's bare `sdf(vec3)` became `spike_sdf`, and the
// two functions at the foot of the file are ours — a `size` parameter (the
// corpus had none) and a bounding sphere.
//
// THE BOUND IS A GUESS, deliberately loose. The corpus documented "most models
// <= 1.5, PixarMike and Serpinski ~3" and nothing per-model, so this uses
// 2.2 and errs large: too tight punches a visible hole, too loose only costs
// march steps. Tighten it by eye once the model has a scene.
//
// CAVEAT INHERITED FROM THE CORPUS: these files were written to be compiled ONE
// AT A TIME and their internal helper names collide with each other. Naming two
// vendor models in a single scene may not compile — see docs/shape-library.md §7.
//----------------------------------------------------------------------------

/*
Copyright 2013 @Patapom
License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
Link: https://www.shadertoy.com/view/lds3WH
*/

/******************************************************************************
 This work is a derivative of work by Patapom used under CC BY-NC-SA 3.0.
 This work is licensed also under CC BY-NC-SA 3.0 by NVIDIA CORPORATION.
 ******************************************************************************/

#ifndef spike_glsl
#define spike_glsl

float spikeball(vec3 p)
{
vec3 c[19];
c[0] = vec3(1,0,0);
c[1] = vec3(0,1,0);
c[2] = vec3(0,0,1);
c[3] = vec3(.577,.577,.577);
c[4] = vec3(-.577,.577,.577);
c[5] = vec3(.577,-.577,.577);
c[6] = vec3(.577,.577,-.577);
c[7] = vec3(0,.357,.934);
c[8] = vec3(0,-.357,.934);
c[9] = vec3(.934,0,.357);
c[10] = vec3(-.934,0,.357);
c[11] = vec3(.357,.934,0);
c[12] = vec3(-.357,.934,0);
c[13] = vec3(0,.851,.526);
c[14] = vec3(0,-.851,.526);
c[15] = vec3(.526,0,.851);
c[16] = vec3(-.526,0,.851);
c[17] = vec3(.851,.526,0);
c[18] = vec3(-.851,.526,0);

	float	MinDistance = 1e4;
	for ( int i=3; i < 19; i++ )
	{
		float	d = clamp( dot( p, c[i] ), -1.0, 1.0 );
		vec3	proj = d * c[i];
		d = abs( d );
		
		float	Distance2Spike = length( p - proj );
		float	SpikeThickness = 0.25 * exp( -5.0*d ) + 0.0;
		float	Distance = Distance2Spike - SpikeThickness;
		
		MinDistance = min( MinDistance, Distance );
	}
	
	return MinDistance;	
}

float spike_sdf(vec3 p)
{
	return spikeball(p);
}

#endif

// p is in the model's own coordinates; `size` scales it about the origin
float spikeDistance(vec3 p, float size){
    return spike_sdf(p/size)*size;
}

// bounding sphere — see the header: loose on purpose, tighten by eye
float spikeBound(vec3 p, float size){
    return length(p) - 2.2*size;
}
