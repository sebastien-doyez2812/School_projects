#include <stdio.h>
#include <stdlib.h>
#include <string.h>
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

// structures:

// structure venant du premier client:
struct msg{
    float q_p[6];
    struct timeval time;
    int id;
};

// Structure des messages reçu:
struct mesg_r{
    // puisque l'on va recevoir des positions angulaire via acknowledge
    float q[6];
    struct timeval time;
    int id;
};

// prototypes: 

double lookup_table( long int  retard);
int main(int nba, char *arg[]);