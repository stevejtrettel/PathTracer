



//-------------------------------------------------
//The SCENE
//-------------------------------------------------



float sceneSDF(Path path){

    float dist=maxDist;

    //top orange light
    //dist=min(dist,sphereSDF(tv,light2,dat));

    // dist=min(dist,sphereSDF(tv,light3,dat));

    //dist=min(dist,sphereSDF(tv,light4,dat));


    //------BALLS

    dist=min(dist,sphereSDF(path,ball1));

     dist=min(dist,sphereSDF(path,ball2));

     dist=min(dist,sphereSDF(path, ball3));



    //------WALLS

   // dist=min(dist,planeSDF(path,wall1));

  //  dist=min(dist,planeSDF(path,wall2));

   // dist=min(dist,planeSDF(path,wall3));


    return dist;
}




