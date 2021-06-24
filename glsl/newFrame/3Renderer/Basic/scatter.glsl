

//-------------------------------------------------
// Setting DIRECTIONS and PROBABILITIES
//-------------------------------------------------



void updateProbabilities( inout Path path ){

    //update using Fresnel
    if(path.dat.probSpecular!=0.){
        //always assume the normal is outward facing for the surface we are at
        Vector normal=path.dat.normal;

        float origSpec=path.dat.probSpecular;

        path.dat.probSpecular = FresnelReflectAmount(path.dat.IOR, path.tv, normal, origSpec, 1.0);

        //--- update diffuse and refract accordingly
        float chanceMultiplier = (1.0 - path.dat.probSpecular) / (1.0 - origSpec);

        path.dat.probRefract  *= chanceMultiplier;
        path.dat.probDiffuse = 1.-path.dat.probRefract-path.dat.probSpecular;
    }

}






void scatter( inout Path path ){

        updateProbabilities(path);

        //random number we will use to select ray type
        float random=randomFloat();

        //----- useful vectors in the following computation ----------
        Vector normal=path.dat.normal;
        Vector randomDir=randomVector(path.tv.pos);
        Vector diffuseDir=normalize(add(normal,randomDir));
        Vector newDir;

        //------useful parameters--------
        float rough2=path.dat.surfRoughness * path.dat.surfRoughness;

        if(random<path.dat.probSpecular){

            //its a specular ray
            path.type=2;
            path.prob=path.dat.probSpecular;
            path.absorb=path.dat.reflectAbsorb;

            newDir=reflect(path.tv,normal);
            //newDir=normalize(mix(newDir, diffuseDir,rough2));

        }

        else if(random<path.dat.probRefract+path.dat.probSpecular){

            //its a refractive ray
            path.type=3;
            path.prob=path.dat.probRefract;
            path.absorb=path.dat.refractAbsorb;

            newDir=refract(path.tv,normal,path.dat.IOR);
            //newDir=normalize(mix(newDir, negate(diffuseDir),rough2));

        }

        else{

          //its a diffuse ray
            path.type=1;
            path.prob=path.dat.probDiffuse;
            path.absorb=path.dat.reflectAbsorb;

            newDir=diffuseDir;

        }


        //fix up the path probability:
        path.prob=max(path.prob,0.001);
        path.light /= path.prob;

        //----set the new vector and push off the surface
        path.tv=newDir;

        //which side to push the point: in or out rel the normal?
        float side=(path.type == 3) ?-1.:1.;
        nudge(path.tv,multiplyScalar(side,normal),5.*EPSILON);
        //flow(path.tv,5.*EPSILON);
}