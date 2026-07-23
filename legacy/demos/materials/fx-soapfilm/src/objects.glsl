//-------------------------------------------------
// OBJECTS — SOAP FILMS (thin-film interference, scatter.glsl thinFilmReflect)
// four bubbles sweeping film thickness left to right (thin -> thick). Each is
// a THIN spherical shell: the sphere's surface is a two-sided film with no
// interior (setSurfaceInMat), so rays reflect with the interference color or
// pass straight through. Spectral is ON in this scene's settings — that is
// what turns the interference into true rainbows (off = angle-only bands).
// The dark room makes the reflected colors read; thickScale sweeps the whole
// row through the interference orders. Each bubble's thickness DRAINS — thin
// at the top, swelling toward the bottom (bubbleThickness in fields.glsl) —
// so the interference bands slide down the shell like a real bubble's.
//-------------------------------------------------

const int NUM = 4;
Sphere bubble[NUM];
Material airMat;


void buildObjects(){

    initMat(airMat);   //the ambient material the films float in

    for(int i = 0; i < NUM; i++){
        float x = -5.1 + 3.4*float(i);
        float thickness = thickScale*(200. + 150.*float(i));   //200 -> 650 nm

        bubble[i].frame  = makeFrame(vec3(x, 2.6, 0.));
        bubble[i].radius = 1.5;
        bubble[i].mat    = makeSoapFilm(thickness);
    }

}


//-------------------------------------------------
// Finding the Objects  (spheres are analytic: traced, not marched;
// trace() already returns the far intersection once the ray is inside,
// so the shell is hit from both sides)
//-------------------------------------------------

float trace_Objects( Vector tv ){
    float dist=maxDist;
    for(int i = 0; i < NUM; i++){
        dist = min(dist, trace(tv, bubble[i]));
    }
    return dist;
}

float sdf_Objects( Vector tv ){
    return maxDist;
}


bool inside_Object( Vector tv ){
    return false;   //films have no interior
}


//-------------------------------------------------
// Setting the Objects Data — thin two-sided surfaces in air
//-------------------------------------------------

void setData_Objects(inout Path path){
    for(int i = 0; i < NUM; i++){
        if( at(path.tv, bubble[i]) ){
            Vector normal = normalVec(path.tv, bubble[i]);
            float side = inside(path.tv, bubble[i]) ? -1. : 1.;

            //material-field followup, thin-surface style: resample the film
            //thickness by drainage (local coords, radius-normalized), then
            //hand the varied material to the same interface call
            vec3 p = toLocal(bubble[i].frame, path.tv.pos)/bubble[i].radius;
            Material m = bubble[i].mat;
            m.surf.film = bubbleThickness(p, m.surf.film);

            setSurfaceInMat(path.dat, side, normal, m, airMat);
        }
    }
}
