



//-------------------------------------------------
//The WALLS
//-------------------------------------------------



float wallsSDF(inout Path path){

    float dist=maxDist;

        dist=min(dist,planeSDF(path,wall1));

//        dist=min(dist,planeSDF(path,wall2));
//
//        dist=min(dist,planeSDF(path,wall3));

        return dist;

}



//-------------------------------------------------
//The SCENE
//-------------------------------------------------



float sceneSDF(inout Path path){

    float dist=maxDist;

    dist=min(dist,sphereSDF(path,light2));

    dist=min(dist,sphereSDF(path,light3));

    dist=min(dist,sphereSDF(path,light4));


    //------BALLS

     dist=min(dist,sphereSDF(path,ball1));

     dist=min(dist,sphereSDF(path,ball2));

     dist=min(dist,sphereSDF(path, ball3));


    return dist;
}




