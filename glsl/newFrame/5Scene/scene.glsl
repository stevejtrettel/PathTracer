



//-------------------------------------------------
//The SCENE
//-------------------------------------------------



float sceneSDF(inout Path path){

    float dist=maxDist;

    //top orange light
    dist=min(dist,sphereSDF(path,light2));
    if(dist<EPSILON){return dist;}

    dist=min(dist,sphereSDF(path,light3));
    if(dist<EPSILON){return dist;}


    dist=min(dist,sphereSDF(path,light4));
    if(dist<EPSILON){return dist;}



    //------BALLS

    //dist=min(dist,sphereSDF(path,ball1));

     //dist=min(dist,sphereSDF(path,ball2));

    dist=min(dist,sphereSDF(path,ball3));
    if(dist<EPSILON){return dist;}

    //------WALLS

   // dist=min(dist,planeSDF(path,wall1));

    //dist=min(dist,planeSDF(path,wall2));

    //dist=min(dist,planeSDF(path,wall3));

    return dist;
}




