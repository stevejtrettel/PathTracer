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

    vec3 r=tv.pos;
    vec3 v=tv.dir;
    float R=length(r);

    vec3 l=cross(r,v);
    float L=length(l);

    float mag=  1.5*L*L/(R*R*R*R*R);
    vec3 acc=-mag*r;
    return acc;
}


void euler(inout Vector tv, float dt){
//    tv.dir = normalize(tv.dir);
    vec3 acc = acceleration(tv);
    tv.dir += dt*acc;
    tv.dir = normalize(tv.dir);
    tv.pos += dt*tv.dir;
}


//
////structure for the derivative of a tangent vector.
//struct dVector{
//    vec3 vel;
//    vec3 acc;
//};
//
//dVector add(dVector s1,dVector s2){
//    vec3 vel=s1.vel+s2.vel;
//    vec3 acc=s1.acc+s2.acc;
//    dVector dVec;
//    dVec.vel=vel;
//    dVec.acc=acc;
//    return dVec;
//}
//
//dVector scale(dVector dVec, float k){
//    dVec.vel*=k;
//    dVec.acc*=k;
//    return dVec;
//}
//
//Vector nudge(Vector tv, dVector dVec, float step){
//    tv.pos += dVec.vel*step;
//    tv.dir += dVec.acc*step;
//    return tv;
//}
//
//
//dVector differentiate(Vector tv){
//
//    vec3 pos=tv.pos;
//    vec3 vel=tv.dir;
//
//    dVector dVec;
//    dVec.vel=vel;
//    dVec.acc = schwarzschildAcc(tv);
//    return dVec;
//}
//
//
////----------------------------------------------------------------------------------------------------------------------
//// Schwarzschild Flow
////----------------------------------------------------------------------------------------------------------------------
//
//
////one iteration of rk4
////gets a dVector that should be added to the vector
//float rk4(inout Vector tv, float dt){
//
//    //constants computed during the process
//    Vector temp;
//    dVector k1,k2,k3,k4,total;
//
//    //get the derivative
//    k1=differentiate(tv);
//    k1=scale(k1,dt);
//
//    //move a little, get k2 there
//    temp=nudge(tv,k1,0.5);
//    k2=differentiate(temp);
//    k2=scale(k2,dt);
//
//    //move a little, get k3
//    temp=nudge(tv,k2,0.5);
//    k3=differentiate(temp);
//    k3=scale(k3,dt);
//
//    //move a little, get k4
//    temp=nudge(tv,k3,1.);
//    k4=differentiate(temp);
//    k4=scale(k4,dt);
//
//    //add up results:
//    total=scale(k1,1.);
//    total=add(total,scale(k2,2.));
//    total=add(total,scale(k3,2.));
//    total=add(total,k4);
//    total=scale(total,1./6.);
//
//    tv=nudge(tv,total,1.);
//
//    //this is the total amount moved in the step
//    return length(total.vel);
//
//}
//
//




//float rk4(inout Vector tv, float dt){
//
//    tv.pos += tv.dir*dt;
//    return dt;
//
//}




//void odeFlow(inout Vector tv, float t){
//
//    float dist=0.;
//    float dt;
//
//    for(int i=0; i<100; i++){
//        dt = max(t/100.,0.1);
//        dist += dt;
//        if(t<dist){ break;}
//        else {
//            euler(tv, dt);
//        }
//    }
//}


void flowODE(inout Vector tv, float t){

    float dt=0.1, dist = 0.;
    for(int i=0; i<100; i++){
        if(dist+dt>t){
            euler(tv,t-dist);
            return;
        }
       // if(length(tv.pos)<1.){return;}
        euler(tv,dt);
        dist+=dt;
    }
}

