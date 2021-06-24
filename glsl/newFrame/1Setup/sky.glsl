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


vec3 LinearToSRGB(vec3 rgb)
{
    rgb = clamp(rgb, 0.0f, 1.0f);

    return mix(
    pow(rgb, vec3(1.0f / 2.4f)) * 1.055f - 0.055f,
    rgb * 12.92f,
    LessThan(rgb, 0.0031308f)
    );
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

    vec3 angles=toSphCoordsNoSeam(v);

    //theta coordinates (x=real, y=to trick the derivative so there's no seam)
    float x=(angles.x+PI)/(2.*PI);
    float z=(angles.z+PI)/(2.*PI);

    float y=1.-angles.y/PI;

    vec2 uv=vec2(x,y);
    vec2 uv2=vec2(z,y);//grab the other arctan piece;

    return SRGBToLinear(textureGrad(sky,uv,dFdx(uv2), dFdy(uv2)).rgb);

}



