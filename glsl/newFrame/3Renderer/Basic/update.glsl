
//-------------------------------------------------
// The LIGHTING FUNCTIONS
//-------------------------------------------------

void volumeColor(inout Path path,localData dat){
    path.light *= exp(-path.absorb*path.distance);
}




void surfaceColor(inout Path path,localData dat){

    // add in emissive lighting
    path.pixel += path.light*dat.mat.emitColor ;

    // update the colorMultiplier
    //only do if not refractive (those taken care of with volume)
    if(path.type.refract==0.){
        //color choice depends on specular or diffuse
        path.light *= (path.type.specular==1.)?dat.mat.specularColor:dat.mat.diffuseColor;
    }

}


void skyColor(inout Path path,inout localData dat){
    vec3 skyColor=skyTex(path.tv.dir);
    //vec3 skyColor=0.1*checkerTex(path.tv.dir);
    //  vec3 skyColor=vec3(0.05);
    path.pixel +=path.light*skyColor;
}


//-------------------------------------------------
// The FOCUS CHECK
//-------------------------------------------------

void focusCheck(inout Path path){

    if(abs(path.distance-focalLength)<0.5){
        path.pixel+=vec3(1.,0.,0.);
    }

}

