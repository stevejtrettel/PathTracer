//---------------------------------------------------------------------
//INCLUDES
//all the other code that are needed to set up a scene
//-----------------------------------------------------------------------

#include 1Setup/_setup.glsl
#include 2Space/_space.glsl
#include 3Materials/_materials.glsl

//shared sdf helpers (op* combinators, bounding shapes). Pure math with plain
//arguments — no object structs, no Material, no setData. The old object library
//(objectAPI + basic/ + roomBox) is gone: an object is now six functions the
//scene supplies, and everything structural about it is written (eventually
//generated) per scene. See 5Scene/scene.glsl for the contract.
#include ../objects/computations.glsl
