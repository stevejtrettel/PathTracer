This is a path tracer which renders images via monte carlo integration over light paths.
The code is built out of two pieces, JS and GLSL.
JS runs the PathTracer class, which manages keyboard controls and uniforms, 
for a full screen shader with three stages: tracing the scene (one pass), accumulation (the monte carlo integration)
and display ( outputting the result to the screen)

GLSL contains the code for these three independent shaders.
Each are eventually imported into JS as strings, by the magic of the bundler VITE

**To Render a Scene**
Scenes are built by adding a new folder to "scenes", and declaring files lights.glsl objects.glsl walls.glsl (which 
all import into a placeholder file _scene.glsl) and settings.js.  The glsl files hold the data for lights, walls and 
objects respectively.  They will be inserted into the tracer shader after 4Objects and before 6Trace, so can use any 
functions defined in sections 4 and above.  Settings is formatted as the output of "Download Settings" from the 
pathtracer UI.

Once a scene has been written, to actually run it in the pathtracer you need to tell the program where the scene 
lives in TWO SEPARATE PLACES (sorry :/) one for JS and one for GLSL.  The two places are at the root of the scenes 
directory, sceneSettings.js and sceneShader.glsl.