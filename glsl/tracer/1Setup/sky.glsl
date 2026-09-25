//-------------------------------------------------
//Image Processing for Textures
//-------------------------------------------------



vec3 LessThan(vec3 f, float value)
{
    return vec3(
    (f.x < value) ? 1.0f : 0.0f,
    (f.y < value) ? 1.0f : 0.0f,
    (f.z < value) ? 1.0f : 0.0f);
}


vec3 SRGBToLinear(vec3 rgb)
{
    rgb = clamp(rgb, 0.0f, 1.0f);

    return mix(
    pow(((rgb + 0.055f) / 1.055f), vec3(2.4f)),
    rgb / 12.92f,
    LessThan(rgb, 0.04045f)
    );
}





//-------------------------------------------------
//Getting an equirectangular image as the sky
//-------------------------------------------------


//plain spherical coordinates (unused by the tracer itself: skyTex uses the
//seam-free variant below; kept as the simpler reference version)
vec2 toSphCoords(vec3 v){
    float theta=atan(-v.z,v.x);
    float phi=acos(v.y);
    return vec2(theta,phi);
}



vec3 toSphCoordsNoSeam(vec3 v){
    float theta=atan(-v.z,v.x);
    float theta2=atan(v.y,abs(v.x));
    float phi=acos(v.y);
    return vec3(theta,phi,theta2);
}



vec3 skyTex(vec3 v){

    //equirectangular lookup at full resolution. This used to be textureGrad with
    //the screen derivatives of a DIFFERENT angle (atan(y,|x|), to dodge the seam):
    //that picked mip ~7 at the image centre and ~9 after a bounce, so the sky
    //was blurred and image-sky lighting collapsed toward its average colour, and
    //derivatives inside the bounce loop's divergent control flow are undefined
    //(blackholeCube did not render the same twice). Accumulating jittered
    //samples already anti-aliases, so level 0 is the right lookup.
    float x=(atan(-v.z,v.x)+PI)/(2.*PI);
    float y=1.-acos(clamp(v.y,-1.,1.))/PI;

    return SRGBToLinear(textureLod(sky,vec2(x,y),0.).rgb);

}



//-------------------------------------------------
//The sky a ray sees: image, solid color, or vertical gradient
//-------------------------------------------------

vec3 getSky(vec3 dir){
    if(skyMode == 1){
        return SRGBToLinear(skyColor1);
    }
    if(skyMode == 2){
        float t = 0.5*(dir.y + 1.0);            //-1 (down) .. +1 (up)
        return SRGBToLinear(mix(skyColor2, skyColor1, t));
    }
    return skyTex(dir);                          //image (already sRGB->linear)
}



