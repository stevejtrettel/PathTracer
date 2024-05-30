


//-------------------------------------------------
// The GLASS VARIETY sdf
//-------------------------------------------------

struct GlassVariety{
    Variety surf;
    Variety glass;
};

GlassVariety createGlassVariety(Variety surf, Material glassMat, float thickness){

    GlassVariety obj;
    obj.surf = surf;
    obj.glass.center=surf.center;
    obj.glass.size=surf.size;
    obj.glass.boundingSphere = surf.boundingSphere+2.*thickness;
    obj.glass.inside=surf.inside+thickness;
    obj.glass.outside = surf.outside+thickness;
    obj.glass.smoothing = surf.smoothing;
    obj.glass.mat = glassMat;

    return obj;
}



//overload of sdf for the cocktail struct
float sdf( Vector tv, GlassVariety var){

    float innerDist = sdf(tv, var.surf);
    float outerDist = sdf(tv, var.glass);

    //make the total distance:
    float dist = min( abs(innerDist), abs(outerDist));

    return dist;
}



//overload of set data
void setData(inout Path path, GlassVariety var){

    Vector normal;

    float innerDist = sdf(path.tv, var.surf);
    float outerDist = sdf(path.tv, var.glass);

    if(abs(outerDist)<abs(innerDist)) {
        //----if we hit the outer shell

        //get outward pointing normal to this shell
        normal = normalVec(path.tv, var.glass);

        //figure out if we are incoming or outgoing:
        bool inside = dot(path.tv.dir,normal.dir)>0.;

        //if we are outgoing: we are leaving the glass material and going into the air
        if (inside) {
            setObjectInAir(path.dat, true, normal, var.glass.mat);
        }

        else {
            //if we are ingoing: we are leaving the air and going into the glass
            setObjectInAir(path.dat, false, normal, var.glass.mat);
        }

    }

    else {
        //----if we hit the inner shell

        //get outward pointing normal to this shell
        normal = normalVec(path.tv, var.surf);

        //figure out if we are incoming or outgoing:
        bool inside = dot(path.tv.dir,normal.dir)>0.;

        //if we are outgoing: we are leaving the colored material and going into the clear
        if (inside) {
            path.dat.normal=negate(normal);
            setMaterialInterface(path.dat, var.surf.mat, var.glass.mat, var.surf.mat);
        }

        else {
            path.dat.normal=normal;
            //if we are ingoing: we are leaving the clear material and going into the colored
            setMaterialInterface(path.dat, var.glass.mat, var.surf.mat, var.surf.mat);
        }

    }

}

