//-------------------------------------------------
// SUB SURFACE SCATTERING
// this function maybe conceptually belongs in the '3Renderer' folder
// as it updates a path before the next bounce.  But it needs the sdfs
//-------------------------------------------------


void subSurfScatter(inout Path path){

    int scatterSteps=500;
    float depth=0.;

    //length of a mean free path in the material:
    float mfp=0.003;
    float flowDist;

    //set the vector we will carry along for the ride
    Vector tv=path.tv;

    //do the subsurface scattering for the surface we are at
    for (int i = 0; i < scatterSteps; i++){

        //if we have left the object
        if(!inside_Object(tv)){
            //FUTURE: find the surface
            path.tv=tv;
            path.distance=depth;
            path.subSurface=false;
            return;
        }

        //if we are inside still:
        //choose the direction of scatter
        tv=randomVector(tv.pos);
        //choose the distance to flow
        flowDist=mfp;
        //travel this distance
        depth+=flowDist;
        flow(tv,flowDist);

    }

    //we got stuck inside the material
    path.keepGoing=false;
}