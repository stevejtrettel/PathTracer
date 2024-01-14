

// given a sphere-shaped light, sample it and update the path
void sampleLight( inout Path path, Sphere sphere ){
    float distToLight;
    Vector lightDir = toLight( path.tv.pos,  sphere,   distToLight);

    //now trace the scene, and see if we hit anything before we hit the light:
    float distance=maxDist;
    distance=raytrace( path.tv, distance );
    distance=raymarch( path.tv, distance );

    if(distance < distToLight - 0.1 ){
        //if the distance is less than the distToLight: our view is obstructed by an object
        //do nothing
    }
    else{
        //update quantities using the light!
        //figure out the probability of this path:
        //first: whats the probability we choose this outgoing direction uniformly?
        float probAngSize = solidAngle(path.tv.pos,sphere)/(2.*PI);
        //second: whats the probability that our lgiht ray reflects at such a strong angle?
        float probReflectDir = 1.;
        //these are independent: multiply them
        float prob = 0.001;
        //probAngSize*probReflectDir;
        path.pixel += prob * path.light * sphere.mat.surfaceEmit;
    }

}





void sampleLights( inout Path path){

    sampleLight(path, light1);
    sampleLight(path,light2);

}