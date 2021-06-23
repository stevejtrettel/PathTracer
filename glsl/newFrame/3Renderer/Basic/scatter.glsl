
void scatterRay(inout Path path){

    Vector normal=path.dat.normal;

    //----- get a uniformly distributed vector on the sphere ----------
    Vector randomSph=Vector(path.tv.pos,randomUnitVector());

    // Diffuse uses a normal oriented cosine weighted hemisphere sample.
    Vector diffuseDir= normalize(add(normal,randomSph));

    path.tv=diffuseDir;
    nudge(path.tv,normal,5.*EPSILON);
}



