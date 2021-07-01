//-------------------------------------------------
// IMPORTANCE SAMPLING
// after stepping forward, this samples a light
//  used in pathTrace.glsl
//-------------------------------------------------


//given a spherical light source, choose a tangent vector at your current location
//pointing to a random point on its surface
Vector dirToLight(Vector tv, Sphere sphere){
    vec3 q=tv.pos;
    vec3 p=sphere.center;
    vec3 rand=sphere.radius*randomUnitVec3();

    //get the new direction
    vec3 dir=p-q+rand;
    dir=normalize(dir);

    return Vector(tv.pos,dir);
}


float lightArea(Vector tv, Sphere sphere){
    float dist=length(tv.pos-sphere.center);
    float rad=sphere.radius;

    //the half angle subtended from sphere center to its edge
    float cosTheta=dist/length(vec2(dist,rad));
    float area = 2.*PI*(1.-cosTheta);
    return area;
}


bool pathIsClear(Vector tv, vec3 pos){
    //check if the path is clear between tv.pos and pos, along the ray in direction tv.dir
    return true;
}












void importanceSample(inout Path path){

    //choose light source to sample
    Sphere light = chooseLightSource();

    //get a direction from your location to this light source
    Vector sampleLight = dirToLight(path.tv, light);

    float cosFactor=clamp(dot(sampleLight,path.dat.normal),0.,1.);

    if(cosFactor>0.){
        //that is, if the light is above the horizon:

        nudge(sampleLight,path.dat.normal,0.01);

        //get the distance to the light source along this direction
        float distToLight = trace(sampleLight, light);
       // path.pixel+=vec3(1./distToLight,0,0);
        //compare this with the distance to the scene:
        float distToScene = distToObj( sampleLight );

        if(distToScene<distToLight+2.*light.radius){
            //we hit something else before we hit the light
            return;
        }

        //otherwise: we hit the light!
        //otherwise, add the light color
        vec3 lightAmt=light.mat.emitColor;

        lightAmt *= lightArea(path.tv, light)/(4.*PI);

        //we should not be scaling by cosFactor (this is a uniformly diffuse surface)
        //but rather by the PROBABILITY of a ray reflecting / diffusing in that direction for the material?
        lightAmt *= cosFactor;


        // add in emissive lighting
        path.pixel += path.light*lightAmt*path.dat.surfDiffuse;
    }

}