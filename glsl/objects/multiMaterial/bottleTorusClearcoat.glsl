


//-------------------------------------------------
// The LAYEERDONUT sdf
//-------------------------------------------------

struct BottleTorusClearcoat{
    BottleTorus inner;
    BottleTorus outer;
//Sphere outer;
};



//overload of sdf for the cocktail struct
float sdf( Vector tv, BottleTorusClearcoat donut){

    float innerDist = sdf(tv, donut.inner);
    float outerDist = sdf(tv, donut.outer);

    //make the total distance:
    float dist = min( abs(innerDist), abs(outerDist));

    return dist;
}


bool inside(Vector tv, BottleTorusClearcoat layerdonut){
    return inside(tv,layerdonut.inner);
}



//overload of set data
void setData(inout Path path, BottleTorusClearcoat donut){

    Vector normal;

    float innerDist = sdf(path.tv, donut.inner);
    float outerDist = sdf(path.tv, donut.outer);

    if(abs(outerDist)<abs(innerDist)) {
        //----if we hit the outer shell

        //get outward pointing normal to this shell
        normal = normalVec(path.tv, donut.outer);

        //figure out if we are incoming or outgoing:
        bool inside = dot(path.tv.dir,normal.dir)>0.;

        //if we are outgoing: we are leaving the glass material and going into the air
        if (inside) {
            setObjectInAir(path.dat, true, normal, donut.outer.mat);
        }

        else {
            //if we are ingoing: we are leaving the air and going into the glass
            setObjectInAir(path.dat, false, normal, donut.outer.mat);
        }

    }

    else {
        //----if we hit the inner shell

        //get outward pointing normal to this shell
        normal = normalVec(path.tv, donut.inner);

        //figure out if we are incoming or outgoing:
        bool inside = dot(path.tv.dir,normal.dir)>0.;

        //if we are outgoing: we are leaving the colored material and going into the clear
        if (inside) {
            setMaterialInterface(path.dat, donut.inner.mat, donut.outer.mat, donut.inner.mat);
        }

        else {
            //if we are ingoing: we are leaving the clear material and going into the colored
            setMaterialInterface(path.dat, donut.outer.mat, donut.inner.mat, donut.inner.mat);
        }

    }

}


