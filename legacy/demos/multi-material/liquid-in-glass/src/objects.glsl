//-------------------------------------------------
// OBJECTS — LIQUID IN GLASS: THE VANISHING WALL
// (docs/material-system.md §2; multiMaterial/bottleLiquid.glsl)
//
// The applied version of nested-spheres, and the single best argument for
// putting ior on the Medium instead of the Surface.
//
// A filled bottle has THREE media (air, glass, liquid) and therefore four
// kinds of boundary, and the same pane of glass behaves completely differently
// depending on what is on its far side:
//
//   air | glass          ratio 1.5 / 1.0  = 1.50   strong. The dry wall.
//   glass | liquid       ratio 1.5 / 1.33 = 1.13   WEAK. The wet wall.
//   air | liquid         the meniscus, where the drink meets the air.
//
// Look at where the waterline crosses the wall: BELOW it the glass nearly
// disappears, because glass against water is barely an interface at all —
// about a tenth the index step of glass against air. Above the line the same
// wall is bright and obvious. Nothing about the glass changed. Only its
// neighbour did.
//
// Then drag `liquidIOR` up to meet `glassIOR` (1.5) and the submerged wall
// vanishes COMPLETELY — index matching, live. This is the trick behind
// invisible-glass demos: drop a borosilicate rod into oil of the same index
// and it disappears. Push liquidIOR past the glass and the interface comes
// back INVERTED, the wall reappearing from the other direction.
//
// The composite itself is the library's BottleLiquid — the dispatcher pattern
// from nested-spheres, applied to a vessel with a fill level. Read its setData
// in glsl/objects/multiMaterial/bottleLiquid.glsl: it is the same
// setObjectInAir / setMaterialInterface decision, branched on which of the
// cup / drink surfaces was hit and from which side.
//-------------------------------------------------

#include ../../../../glsl/objects/shapes/bottle.glsl
#include ../../../../glsl/objects/multiMaterial/bottleLiquid.glsl

Bottle bottle;
BottleLiquid filled;


void buildObjects(){

    bottle.frame      = makeFrame(vec3(0., 0.1, 0.));
    bottle.baseHeight = 2.2;
    bottle.baseRadius = 1.5;
    bottle.neckHeight = 1.4;
    bottle.neckRadius = 0.42;
    bottle.thickness  = 0.13;
    bottle.rounded    = 0.12;
    bottle.smoothJoin = 0.35;
    bottle.bump       = 1.;

    //the vessel: near-colourless glass, so the liquid supplies the colour
    bottle.mat = makeGlass(vec3(0.02, 0.03, 0.025), glassIOR);

    filled.glass = bottle;
    filled.cup   = bottle.mat;
    filled.drink = makeGlass(absorbFor(liquidTint, liquidDepth), liquidIOR);
    filled.fill  = fill;

}


//-------------------------------------------------
// Finding the Objects  (the composite is an SDF: marched, not traced)
//-------------------------------------------------

float trace_Objects( Vector tv ){
    return maxDist;
}

float sdf_Objects( Vector tv ){
    return sdf(tv, filled);
}


bool inside_Object( Vector tv ){
    return false;   //both media are ballistic (clear): no medium walk
}


//-------------------------------------------------
// Setting the Objects Data
// one call: the composite owns its own four-way dispatch
//-------------------------------------------------

void setData_Objects(inout Path path){
    setData(path, filled);
}
