//-------------------------------------------------
// PATH-TRACING
// this is the main path tracing loop
//  used in main.glsl
//-------------------------------------------------


vec3 pathTrace(Path path){

        maxBounces=50;

        for (int bounceIndex = 0; bounceIndex < maxBounces; ++bounceIndex)
        {
                //move forward until the next intersection, update localData
                stepForward(path);

                //help with focusing
                focusCheck(path);

                //pick up color from traveling through the medium
                updateFromVolume(path);

                // if you hit the sky: stop
                updateFromSky(path);

                //scatter the path off in a new direction
                //false=we did not just subsurface scatter
                scatter(path,false);

                if(path.subSurface){
                       //do the subsurface scattering: stop at the surface
                       //set the new ray's directoin
                        subSurfScatter(path);
                        //update the color from the trajectory
                        updateFromSubSurf(path);
                        //update data for new ray exit point
                        setData_Scene(path);
                        //choose new ray direction/type:
                        path.absorb=vec3(0);
                        //path.dat.refractAbsorb;
                        //path.tv=refract(path.tv,path.dat.normal,path.dat.IOR);
                        flow(path.tv,2.*EPSILON);
                        //scatter(path,true);//true=dont' choose another subsurf scattering event
                }
                else{
                        //pick up any color from the reflection off surface
                        updateFromSurface(path);
                }

                //probabilistically kill rays
                roulette(path);

                if(!path.keepGoing){ break; }

        }



        return path.pixel;

}
