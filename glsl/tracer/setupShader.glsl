//---------------------------------------------------------------------
//INCLUDES
//all the other code that are needed to set up a scene
//-----------------------------------------------------------------------

#include 1Setup/_setup.glsl
#include 2Space/_space.glsl
#include 3Materials/_materials.glsl

//the VOCABULARY half of the shape library: the exact primitives every composite
//is built from, and the operators that combine and fold them. Pure math with
//plain arguments — no object structs, no Material, no setData. Always compiled,
//so any shape file or authored scene body may call it with no declaration; the
//CONTENT half (models, fractals, tilings, varieties, vendor) is inlined by the
//emitter only when a scene names it. See docs/shape-library.md §1.
#include ../shapes/_vocabulary.glsl
