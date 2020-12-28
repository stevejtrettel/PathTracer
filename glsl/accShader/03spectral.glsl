












//-------------------------------------------------
//SPECTRAL TRACING
//-------------------------------------------------

float redResponse(float wavelength){
    float R=0.;
    
    if(wavelength>575.){
        return 1.;
    }
    return 0.;
}


float greenResponse(float wavelength){
        if(wavelength>500.&&wavelength<575.){
        return 1.;
    }
    return 0.;
    
}


float blueResponse(float wavelength){
    if(wavelength<500.){
        return 1.;
    }
    return 0.;
}


//converting a wavelength into an rgb color
//from http://www.noah.org/wiki/Wavelength_to_RGB_in_Python

vec3 WaveLengthColor(float wavelength){
    
    
    float gamma=0.8;
    float attenuation;
    float R,G,B;
    
    
    
    float wl=wavelength;
     
        if (wl >= 380. && wl < 440.) {
            R = -1. * (wl - 440.) / (440. - 380.);
            G = 0.;
            B = 1.;
       } else if (wl >= 440. && wl < 490.) {
           R = 0.;
           G = (wl - 440.) / (490.- 440.);
           B = 1.;  
        } else if (wl >= 490. && wl < 510.) {
            R = 0.;
            G = 1.;
            B = -1. * (wl - 510.) / (510. - 490.);
        } else if (wl >= 510. && wl < 580.) {
            R = (wl - 510.) / (580. - 510.);
            G = 1.;
            B = 0.;
        } else if (wl >= 580. && wl < 645.) {
            R = 1.;
            G = -1. * (wl - 645.) / (645. - 580.);
            B = 0.0;
        } else if (wl >= 645. && wl <= 780.) {
            R = 1.;
            G = 0.;
            B = 0.;
        } else {
            R = 0.;
            G = 0.;
            B = 0.;
        }
    
//    
//    R=redResponse(wavelength);
//    G=greenResponse(wavelength);
//    B=blueResponse(wavelength);
    
    return SRGBToLinear(vec3(R,G,B)); 

}
    
    
    

    
    vec3 sampleSpectrum(inout float wavelength, inout uint state){
        
        float percent=RandomFloat01(state);
        
        float min=380.;
        float max=650.;
        float spread=max-min;
 
        wavelength=spread*percent+min;
        
        return WaveLengthColor(wavelength);
        
    }
    




vec3 sampleRed(inout float wavelength, inout uint state){
    
    wavelength=RandomNormal(600.,25.,state);
    
    return WaveLengthColor(wavelength);
}



vec3 sampleGreen(inout float wavelength,inout uint state){
    
    wavelength=RandomNormal(550.,25.,state);
    
    
    return WaveLengthColor(wavelength);
}


vec3 sampleBlue(inout float wavelength, inout uint state){
    
    wavelength=RandomNormal(450.,25.,state);
    
    return WaveLengthColor(wavelength);
}



