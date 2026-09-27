# Camera models — plan, and what was built

> **Status (Sep 2026): built as planned.** `glsl/tracer/2Space/camera.glsl`
> (Film / Lens / Pose), the `lens` setting (`js/shaderData/engineKnobs.js`,
> a `choice` knob — `js/shaderData/knobs.js`, `js/gui/widgets.js`), focus
> peaking through `focusError` (`glsl/tracer/6Trace/debugPass.glsl`), the
> `lenses` scene, and three camera cases in the energy test. Notes from building
> it are in §7.

## 1. The structure

Every camera has all three parts. A camera is one struct holding one of each:

```glsl
struct Film {          //the image
    vec2  resolution;  //in pixels (iResolution.xy)
    bool  tiled;       //an HD render in tiles?       (renderPanel)
    float tiles;       //how many, a perfect square   (numPanels)
    float tile;        //which one this frame renders (panelToRender)
};

struct Lens {          //the camera model
    int   model;       //LENS_PINHOLE | LENS_SPHERE_FOCUS | LENS_THIN | LENS_ORTHO
    float fov;         //degrees across the image width
    float aperture;    //radius of the lens opening, world units (0 = no blur)
    float focus;       //distance to what is sharp    (the focalLength setting)
};

struct Pose {          //where the camera is
    vec3 position;     //location + CAMERA_OFFSET
    mat3 facing;       //columns: the camera's right, up and back, in world coordinates
};

struct Camera { Film film; Lens lens; Pose pose; };
```

**The camera type is `lens.model`.** Changing type changes nothing in `film` or
`pose`.

Each part has one function, which reads only that part:

```glsl
//pixel (plus jitter) -> image point: x in [-1, 1] across the width,
//y in [-1/aspect, 1/aspect]. Handles the HD-tile mapping.
vec2   filmPoint(Film film, vec2 pixel, vec2 jitter);

//image point (plus an aperture sample in [0,1)²) -> a ray in the CAMERA FRAME:
//the lens centre at the origin, looking down -z, x right, y up.
Vector lensRay(Lens lens, vec2 point, vec2 apertureSample);

//camera frame -> world: rotate by facing, move to position.
Vector toWorld(Pose pose, Vector ray);
```

and the camera is those three in a row:

```glsl
Vector cameraRay(Camera cam, vec2 pixel){
    vec2   point = filmPoint(cam.film, pixel, ldSample2D(LD_JITTER) - 0.5);
    Vector ray   = lensRay(cam.lens, point, ldSample2D(LD_APERTURE));
    return toWorld(cam.pose, ray);
}
```

`buildCamFromUniforms()` fills all three parts from the uniforms. On the JS side
each part already has one owner, and that does not change:

| part | set by | uniforms |
|---|---|---|
| film | `PathTracer` (window size, HD render) | `iResolution`, `renderPanel`, `numPanels`, `panelToRender` |
| lens | the Camera tab | `lens` (new), `fov`, `aperture`, `focalLength` |
| pose | keyboard and mouse (`KeyControls`, `OrbitControls`) | `location`, `facing` |

## 2. The four lens models

`lensRay` picks one of four functions by `lens.model`. With `t = tan(fov/2)`,
`p` the image point and `a` the aperture sample:

```glsl
vec3 d  = normalize(vec3(p, -1.0/t));                 //the pinhole direction
vec2 ap = lens.aperture * disc(a);                    //a point on the lens opening
                                                      //(disc: today's sampleAperture)
```

| model | ray origin | ray direction | what is sharp |
|---|---|---|---|
| **pinhole** | `0` | `d` | everything |
| **sphere focus** (today's) | `vec3(ap, 0)` | `normalize(focus·d − origin)` | a sphere of radius `focus` around the camera |
| **thin lens** | `vec3(ap, 0)` | `normalize(d·focus/(−d.z) − origin)` | the plane `z = −focus` |
| **orthographic** | `vec3(p·w + ap, 0)` | `normalize(vec3(p·w, −focus) − origin)` | the plane `z = −focus` |

- Orthographic's half-width is `w = focus·t`: what a perspective camera sees at
  the focus distance. Switching between perspective and orthographic keeps the
  subject in focus the same size, and the fov slider is still the zoom.
- With the aperture closed (`ap = 0`), sphere focus and thin lens both reduce
  to the pinhole, and orthographic to straight parallel rays.
- Sphere focus is today's arithmetic, operation for operation, so scenes using
  it render byte-identically.

The focus-peaking view needs each model's idea of "sharp". It gets one more
function per model, returning how far a point is from being in focus:

```glsl
//distance from the in-focus surface, for a point in the camera frame
float focusError(Lens lens, vec3 point);
//  pinhole       0 (everything is sharp)
//  sphere focus  abs(length(point) - focus)
//  thin lens     abs(-point.z - focus)
//  orthographic  abs(-point.z - focus)
```

## 3. Settings and the panel

- **`lens`** is a new Camera-tab setting, a dropdown: Pinhole / Sphere Focus /
  Thin Lens / Orthographic. It is saved in `settings.js` by name
  (`lens: 'thinLens'`). A scene with none saved gets Sphere Focus, today's
  camera, so every existing scene renders identically.
- The dropdown is a new knob type, `choice`: `{type: 'choice', options: [...]}`.
  The panel shows it as a dropdown; the shader gets an `int` uniform, plus one
  generated constant per option (`const int LENS_THIN = 2;`), so the shader and
  the panel share one numbering.
- The "Focal Length" slider is relabelled "Focus Distance", which is what it
  is. The saved name stays `focalLength`, so old settings files still load.
- Pinhole greys out Aperture and Focus Distance.

## 4. What else changes

- **Focus peaking** (the Camera tab's focus aid, debug view 8) calls
  `focusError` instead of comparing the distance along the ray with the focus
  distance itself (which is the sphere-focus rule only).
- **Nothing else.** Anti-aliasing and HD tiles are `filmPoint`; keyboard, mouse
  and Save to Scene only move the pose. In orthographic, flying forward or
  pinch-zooming does not change the size of things; the fov slider zooms.

## 5. Order of work, and the check for each step

1. **`choice` knob type** (JS only). Check: goldens, generator checks and
   render-diff all identical.
2. **The three-part structure, with sphere focus as the only model.** Check:
   render-diff byte-identical on all 47 scenes — the proof that the restructure
   changed nothing.
3. **Pinhole, thin lens, orthographic**, the `lens` dropdown, greying out, and
   `focusError` for focus peaking. Check: render-diff still identical (every
   scene defaults to sphere focus); each model rendered and looked at; the
   energy test still passes.
4. **A `lenses` scene:** spheres receding in depth over a checker floor, thin
   lens with the aperture open. It shows the flat plane of focus at a glance
   and becomes the render-diff reference for the new models.

## 6. Decisions

- Default for scenes with no `lens` saved: **Sphere Focus**, for now — the
  owner means to make **Thin Lens** the default later. That is the `value` of
  the `lens` knob in `js/shaderData/engineKnobs.js`, one word. Save to Scene
  writes each scene's lens out, so saved scenes keep theirs.
- Orthographic zoom: `w = focus·t`. Orthographic depth of field: yes.
- "Focal Length" is shown as "Focus Distance".

## 7. Notes from building it

- **The restructure (step 2) was byte-identical** on every scene. Adding the
  three new models to `lensRay` (step 3) was not: with four branches to choose
  from, the GPU compiler arranges the sphere-focus arithmetic differently, and
  a few pixels round differently (fractal scenes then amplify it, e.g. 17% of
  apollonian's pixels at 32 samples). Brightness did not move; at 512 samples
  apollonian and bottleTorus agreed with the old camera to 0.05%. A `switch`
  and a sphere-focus-first `if` chain compiled the same way, so the references
  were re-baked rather than bending the code around the compiler.
- **Focus distance 0** made every model aim a ray at its own origin (a NaN
  sample; today's camera did it too). `buildCamFromUniforms` keeps it at 1e-4
  or more — no saved scene is anywhere near.
- **Orthographic rays start on a flat rectangle the size of the view**
  (`2w` across), centred on the camera. In a room that rectangle can reach
  through the floor or a wall — in `lenses`, from 1.8 above the floor, the
  bottom of the frame starts under the floor and renders the dark outside.
  Frame orthographic views from higher up, or narrower. (A "start the rays
  further back" setting would lift this; not built.)
- **Floating-point dust in positions:** `-7.2 + 2.4*3` is not 0 in JS, and
  scenegen (rightly) refuses to print -8.9e-16. Write such positions out.
