//-------------------------------------------------
// OBJECTS — THE PRESET CHART (3Materials/presets.glsl)
// one sphere per preset, the permanent tuning reference. Rows front -> back:
//   row 0 (front): OPAQUE   — terracotta, tile(blue), plastic(cherry),
//                             rubber(green), carPaint(red)
//   row 1:         METAL    — gold, copper, silver, iron, mirror
//   row 2:         GLASS    — clear glass, liquid(teal), honey, diamond,
//                             neon(cyan)
//   row 3 (back):  SUBSURF  — jade(green), porcelain, wax(amber), milk,
//                             marble(grey)
//-------------------------------------------------

const int NUM = 20;
Sphere ball[NUM];


void buildObjects(){

    //grid: 5 columns x 4 rows
    for(int i = 0; i < NUM; i++){
        float x = -5.4 + 2.7*float(i - 5*(i/5));
        float z =  4.2 - 2.8*float(i/5);
        ball[i].frame  = makeFrame(vec3(x, 1.2, z));
        ball[i].radius = 1.2;
    }

    //row 0: opaque
    ball[0].mat  = makeTerracotta();
    ball[1].mat  = makeTile(vec3(0.12, 0.32, 0.55));
    ball[2].mat  = makePlastic(vec3(0.55, 0.08, 0.10), 0.05);
    ball[3].mat  = makeRubber(vec3(0.06, 0.25, 0.09));
    ball[4].mat  = makeCarPaint(vec3(0.55, 0.05, 0.08));

    //row 1: metal
    ball[5].mat  = makeGold(0.15);
    ball[6].mat  = makeCopper(0.25);
    ball[7].mat  = makeSilver(0.05);
    ball[8].mat  = makeIron(0.35);
    ball[9].mat  = makeMirror();

    //row 2: transmissive
    ball[10].mat = makeGlass(vec3(0.), 1.5);
    ball[11].mat = makeLiquid(vec3(0.25, 0.65, 0.7));
    ball[12].mat = makeHoney();
    ball[13].mat = makeDiamond();
    ball[14].mat = makeNeon(vec3(0.2, 0.9, 1.), neonPower);

    //row 3: subsurface
    ball[15].mat = makeJade(vec3(0.15, 0.5, 0.25));
    ball[16].mat = makePorcelain();
    ball[17].mat = makeWax(vec3(0.85, 0.55, 0.25));
    ball[18].mat = makeMilk();
    ball[19].mat = makeMarble(vec3(0.8, 0.78, 0.75));

}


//-------------------------------------------------
// Finding the Objects  (spheres are analytic: traced, not marched)
//-------------------------------------------------

float trace_Objects( Vector tv ){
    float dist=maxDist;
    for(int i = 0; i < NUM; i++){
        dist = min(dist, trace(tv, ball[i]));
    }
    return dist;
}

float sdf_Objects( Vector tv ){
    return maxDist;
}


//used by the medium walk: keep scattering while inside any of these
bool inside_Object( Vector tv ){
    for(int i = 0; i < NUM; i++){
        if(inside(tv, ball[i])){ return true; }
    }
    return false;
}


//-------------------------------------------------
// Setting the Objects Data
//-------------------------------------------------

void setData_Objects(inout Path path){
    for(int i = 0; i < NUM; i++){
        setData(path, ball[i]);
    }
}
