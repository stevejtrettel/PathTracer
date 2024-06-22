//----------------------------------------------------------------------------------------------------------------------
// The Schwarzschild Null Geodesic Equation
//----------------------------------------------------------------------------------------------------------------------



//vec3 acceleration(Vector tv){
//  //  return vec3(0);
//    vec3 p=tv.pos;
//    vec3 n=normalize(p);
//    float dist=length(p);
//
//    //lightRad is a uniform controlling the size of the disturbance
//    float mag=1.-smoothstep(0.,1.,dist);
//    vec3 vField= -mag*n;
//    return vField;
//}


//this ficticious force whose trajectories have the same paths in space as the projection of schwarzchild geodesics.
vec3 acceleration(Vector tv){
//return vec3(0);
    float m = 1.;
    vec3 r=tv.pos;
    vec3 v=tv.dir;
    float R=length(r);

    vec3 l=cross(r,v);
    float L=length(l);

    float mag=  1.5*L*L/(R*R*R*R*R*R);
    vec3 acc=-m*mag*r;
    return acc;
}


bool stopODE(Vector tv){
    //return false;
    return length(tv.pos)<0.3;
}

float setDT(Vector tv, float dt){

//    float R = length(tv.pos)-1.;
//    return min(R/2.+0.005,1.);

    float mag = length(acceleration(tv));
    if(mag>0.1){
        return dt/mag;
    }
    return 1.;
}






////----------------------------------------------------------------------------------------------------------------------
//// EULER
////----------------------------------------------------------------------------------------------------------------------

void euler(inout Vector tv, float dt){
//    tv.dir = normalize(tv.dir);
    vec3 acc = acceleration(tv);
    tv.dir += dt*acc;
    tv.dir = normalize(tv.dir);
    tv.pos += dt*tv.dir;
}







////----------------------------------------------------------------------------------------------------------------------
//// Runge Kutta
////----------------------------------------------------------------------------------------------------------------------


//structure for the derivative of a tangent vector.
struct dVector{
    vec3 vel;
    vec3 acc;
};

dVector add(dVector s1,dVector s2){
    vec3 vel=s1.vel+s2.vel;
    vec3 acc=s1.acc+s2.acc;
    dVector dVec;
    dVec.vel=vel;
    dVec.acc=acc;
    return dVec;
}

dVector scale(dVector dVec, float k){
    dVec.vel*=k;
    dVec.acc*=k;
    return dVec;
}

Vector nudge(Vector tv, dVector dVec, float step){
    tv.pos += dVec.vel*step;
    tv.dir += dVec.acc*step;
    return tv;
}


dVector differentiate(Vector tv){

    vec3 pos=tv.pos;
    vec3 vel=tv.dir;

    dVector dVec;
    dVec.vel=vel;
    dVec.acc = acceleration(tv);
    return dVec;
}




//one iteration of rk4
//gets a dVector that should be added to the vector
void rk4(inout Vector tv, float dt){

    //constants computed during the process
    Vector temp;
    dVector k1,k2,k3,k4,total;

    //get the derivative
    k1=differentiate(tv);
    k1=scale(k1,dt);

    //move a little, get k2 there
    temp=nudge(tv,k1,0.5);
    k2=differentiate(temp);
    k2=scale(k2,dt);

    //move a little, get k3
    temp=nudge(tv,k2,0.5);
    k3=differentiate(temp);
    k3=scale(k3,dt);

    //move a little, get k4
    temp=nudge(tv,k3,1.);
    k4=differentiate(temp);
    k4=scale(k4,dt);

    //add up results:
    total=scale(k1,1.);
    total=add(total,scale(k2,2.));
    total=add(total,scale(k3,2.));
    total=add(total,k4);
    total=scale(total,1./6.);

    tv=nudge(tv,total,1.);

    //this is the total amount moved in the step
    //return length(total.vel);

}















////----------------------------------------------------------------------------------------------------------------------
//// CHOOSING STEP METHOD
////----------------------------------------------------------------------------------------------------------------------


//choose the numerical scheme:
void odeStep(inout Vector tv, float dt){
    rk4(tv, dt);
}
