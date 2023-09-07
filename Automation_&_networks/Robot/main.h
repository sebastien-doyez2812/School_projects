#include <iostream>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <fcntl.h>
#include <sys/time.h>
#include <time.h>
#include <termios.h>
#include <unistd.h>

#define ERROR (-1)

using namespace std;

extern "C" {
    //#include "/opt/V-REP_PRO_EDU_V3_5_0_Linux/programming/remoteApi/extApi.h"
    #include "/home/sebastien/CoppeliaSim_Edu_V4_1_0_Ubuntu16_04/programming/remoteApi/extApi.h"
}

// Définitions des différentes fonctions utilisées 
// dans le main:

int handles[6],all_ok=1;
simxInt handle, error;

// structures:

// On a besoin d'une structure d'envoie de message:
struct speed_send{
    float q_p[6];
    struct timeval time;
    int id;
};

// On a aussi besoin d'une structure de reception:
struct pos_receive{
    // ATTENTION ici ce sont des positions et NON des vitesses comme dans la
    // struct précédente:
    float q[6];   
    struct timeval time;
    int id;
};

// prototypes:

void getJoinPos(int clientID, float* qr);
void GetHandles(int clientID);
int SetJointPos(int clientID,  float *q);
int SetJointSpeed(int clientID,  float *qv);

