



//-------------------------------------------------
//The SCENE
//-------------------------------------------------



float sceneSDF(Vector tv, inout localData dat){

    float dist=maxDist;

    //top orange light
    dist=min(dist,sphereSDF(tv,light2,dat));

     dist=min(dist,sphereSDF(tv,light3,dat));

    dist=min(dist,sphereSDF(tv,light4,dat));


    //------BALLS

    //dist=min(dist,sphereSDF(tv,ball1,dat));

     //dist=min(dist,sphereSDF(tv,ball2,dat));

     dist=min(dist,sphereSDF(tv,ball3,dat));



    //------WALLS

   // dist=min(dist,planeSDF(tv,wall1,dat));

    //dist=min(dist,planeSDF(tv,wall2,dat));

    //dist=min(dist,planeSDF(tv,wall3,dat));



    return dist;
}




