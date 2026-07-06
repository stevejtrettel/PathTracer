

float sdf_octahedron(vec3 p) {
    if(length(p)>1.){
        return length(p)-.9;
    }

    float s =0.5;
        p = abs(p);
        float m = p.x+p.y+p.z-s;
        vec3 q;
        if( 3.0*p.x < m ) q = p.xyz;
        else if( 3.0*p.y < m ) q = p.yzx;
        else if( 3.0*p.z < m ) q = p.zxy;
        else return m*0.57735027;

        float k = clamp(0.5*(q.z-q.y+s),0.0,s);
        return length(vec3(q.x,q.y-s+k,q.z-k));
    }


//-------------------------------------------------
//The OCTAHEDRON sdf
//-------------------------------------------------

struct Octahedron{
    vec3 center;
    float size;
    Material mat;
};


//the point-level sdf
float sdf( vec3 p, Octahedron obj ){
    //normalize position
    vec3 pos = p - obj.center;
    pos /= obj.size;
    return sdf_octahedron(pos);
}

//the standard interface: at, inside, sdf, normalVec, setData
OBJECT_API(Octahedron)
