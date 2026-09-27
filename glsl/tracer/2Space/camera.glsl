//-------------------------------------------------
// THE CAMERA  (docs/camera-plan.md)
//
// A camera turns one image sample into one ray in the world. It is one struct
// made of three parts, and each part has one function that reads only it:
//
//     Film   the image            filmPoint   pixel (+ jitter) -> a point on the image
//     Lens   the camera model     lensRay     image point -> a ray in the CAMERA FRAME
//     Pose   where the camera is  toWorld     camera frame -> world
//
// cameraRay runs the three in a row. The camera frame has the lens centre at
// the origin, looking down -z, x right, y up. An image point is x in [-1, 1]
// across the width and y in [-1/aspect, 1/aspect] (square pixels).
//
// The camera TYPE is lens.model; changing it touches neither film nor pose, so
// anti-aliasing and HD tiles (film) and keyboard, mouse and Save to Scene
// (pose) work the same for every model.
//-------------------------------------------------


//LEGACY GLOBAL CAMERA OFFSET
//every ray origin is shifted by this before applying location/facing.
//all saved settings.js camera positions were authored with this baked in,
//so removing it would re-frame every existing scene.
const vec3 CAMERA_OFFSET = vec3(-2., 0., 6.);


struct Film {
    vec2  resolution;   //in pixels
    bool  tiled;        //an HD render in tiles?
    float tiles;        //how many (a perfect square)
    float tile;         //which one this frame renders
};

struct Lens {
    int   model;        //the camera model: a LENS_* const, generated from the lens knob
    float fov;          //degrees across the image width
    float aperture;     //radius of the lens opening, world units (0 = no blur)
    float focus;        //distance to what is sharp (the focalLength setting)
};

struct Pose {
    vec3 position;      //world position of the lens centre (location + CAMERA_OFFSET)
    mat3 facing;        //columns: the camera's right, up and back, in world coordinates
};

struct Camera {
    Film film;
    Lens lens;
    Pose pose;
};


//the camera the settings describe (built with constructors: see the note on
//nested-struct writes in 3Materials/material.glsl). The focus distance is kept
//off 0, where every lens model would aim a ray at its own origin (a NaN).
Camera buildCamFromUniforms(){
    return Camera(
        Film(iResolution.xy, renderPanel, numPanels, panelToRender),
        Lens(lens, fov, aperture, max(focalLength, 1e-4)),
        Pose(location + CAMERA_OFFSET, facing)
    );
}



//-------------------------------------------------
// FILM — which point of the image a sample lands on
//-------------------------------------------------

//an HD render's tile: the tiles form a grid of sqrt(tiles) x sqrt(tiles), each
//rendered at the full resolution; this maps the tile's pixel to its place in
//the whole image. Integer-safe: sqrt and floor(fract(i/r)*r) can land a hair
//below an integer on some GPUs (e.g. tile 5 of 9 -> 1.9999999 -> column 1),
//rendering one tile twice and never rendering another. Must agree with
//PathTracer.newFrame's row = floor(pr/root), col = pr % root.
vec2 tilePixel(Film film, vec2 pixel){
    if(film.tile >= film.tiles){ return pixel; }   //no valid tile chosen

    float resize = floor(sqrt(film.tiles) + 0.5);
    float row    = floor((film.tile + 0.5)/resize);
    float column = film.tile - resize*row;

    return pixel/resize + vec2(row, column)*film.resolution/resize;
}

//pixel (+ jitter, in pixels) -> image point. The jitter goes on BEFORE the tile
//mapping, which divides by sqrt(tiles): jitter added after it would spread each
//HD-tile pixel over sqrt(tiles) output pixels (a box blur).
vec2 filmPoint(Film film, vec2 pixel, vec2 jitter){
    pixel += jitter;
    if(film.tiled){ pixel = tilePixel(film, pixel); }

    vec2 point = (pixel/film.resolution)*2.0 - 1.0;
    point.y /= film.resolution.x/film.resolution.y;   //square pixels
    return point;
}



//-------------------------------------------------
// LENS — the camera model: image point -> ray in the camera frame
//-------------------------------------------------

//a point on the lens opening from a sample in [0,1)^2: uniform over the disc
//of radius `aperture`
vec2 apertureDisc(Lens lens, vec2 u){
    float theta  = 2.*PI*u.x;
    float radius = lens.aperture*sqrt(u.y);
    return radius*vec2(cos(theta), sin(theta));
}

//the straight-through direction for an image point: through (point, -1/t) with
//t = tan(fov/2), so the image's width spans the field of view
vec3 pinholeDir(Lens lens, vec2 point){
    return normalize(vec3(point, -1./tan(radians(lens.fov*0.5))));
}

//PINHOLE: no lens at all. Every ray leaves the lens centre, so everything is
//sharp; aperture and focus are ignored.
Vector lensPinhole(Lens lens, vec2 point){
    return Vector(vec3(0.), pinholeDir(lens, point));
}

//SPHERE FOCUS (the original camera): the ray starts at a point of the lens
//opening and aims at the point `focus` along the straight-through direction.
//Focus is measured ALONG EACH RAY, so what is sharp is a sphere around the lens.
Vector lensSphereFocus(Lens lens, vec2 point, vec2 u){
    vec3 d      = pinholeDir(lens, point);
    vec3 target = lens.focus*d;
    vec3 origin = vec3(apertureDisc(lens, u), 0.);
    return Vector(origin, normalize(target - origin));
}

//THIN LENS: the same, but aimed at where the straight-through direction meets
//the PLANE z = -focus. What is sharp is that flat plane, as with a real lens.
//Identical to sphere focus at the image centre; toward the edges sphere focus
//puts the sharp distance closer (by 1 - cos of the angle off the axis).
Vector lensThin(Lens lens, vec2 point, vec2 u){
    vec3 d      = pinholeDir(lens, point);
    vec3 target = d*(lens.focus/(-d.z));
    vec3 origin = vec3(apertureDisc(lens, u), 0.);
    return Vector(origin, normalize(target - origin));
}

//ORTHOGRAPHIC: parallel rays, so nothing shrinks with distance. The image spans
//what a perspective camera sees AT THE FOCUS DISTANCE (half-width focus*t), so
//switching between the two keeps the in-focus subject the same size; the fov
//and the focus distance are the zoom. With the aperture open, each ray starts
//on its own point of the lens opening and aims at its image point on the focus
//plane: a flat plane of focus, like the thin lens.
Vector lensOrtho(Lens lens, vec2 point, vec2 u){
    vec2 onImage = point*lens.focus*tan(radians(lens.fov*0.5));
    vec3 target  = vec3(onImage, -lens.focus);
    vec3 origin  = vec3(onImage + apertureDisc(lens, u), 0.);
    return Vector(origin, normalize(target - origin));
}

//the camera model the lens setting picks (LENS_* are generated from the knob)
Vector lensRay(Lens lens, vec2 point, vec2 u){
    if(lens.model == LENS_PINHOLE)     { return lensPinhole(lens, point); }
    if(lens.model == LENS_THIN_LENS)   { return lensThin(lens, point, u); }
    if(lens.model == LENS_ORTHOGRAPHIC){ return lensOrtho(lens, point, u); }
    return lensSphereFocus(lens, point, u);
}

//how far a point (in the camera frame) is from being in focus, in world units —
//each model's own in-focus surface. The focus-peaking view colours by this.
float focusError(Lens lens, vec3 point){
    if(lens.model == LENS_PINHOLE)     { return 0.; }                             //all sharp
    if(lens.model == LENS_SPHERE_FOCUS){ return abs(length(point) - lens.focus); } //a sphere
    return abs(-point.z - lens.focus);                                             //a plane
}



//-------------------------------------------------
// POSE — the camera frame into the world
//-------------------------------------------------

Vector toWorld(Pose pose, Vector ray){
    return Vector(pose.facing*ray.pos + pose.position, pose.facing*ray.dir);
}

//and back: a world point in the camera frame (facing is a rotation, so its
//inverse is its transpose, which v*M applies)
vec3 toCameraFrame(Pose pose, vec3 point){
    return (point - pose.position)*pose.facing;
}



//-------------------------------------------------
// THE CAMERA — film, lens, pose in a row
//-------------------------------------------------

Vector cameraRay(Camera cam, vec2 pixel){
    vec2   point = filmPoint(cam.film, pixel, ldSample2D(LD_JITTER) - 0.5);
    Vector ray   = lensRay(cam.lens, point, ldSample2D(LD_APERTURE));
    return toWorld(cam.pose, ray);
}
