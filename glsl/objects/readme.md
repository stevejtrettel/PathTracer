These are objects meant to be used in "tracer".

`objectAPI.glsl`, `computations.glsl`, the shapes listed in `basic/_basic.glsl`,
and `environments/roomBox.glsl` are included in every scene automatically
(see `tracer/setupShader.glsl`).

Every other object must be included explicitly by a scene. Files state at the
top which other files they depend on — include those first.
