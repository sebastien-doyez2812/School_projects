#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <fcntl.h>
#include <sys/time.h>
#include <termios.h>
#include <unistd.h>
#include <time.h>

// structures:

struct msg_ack
{
    /* c'est l'acknowledge qui revient de coppélia*/
    float q[6];
    //temps :
    struct timeval time;
    // id:
    int id;
};

struct msg_pos
{
    // On envoit une position, celle ci sera transformé par retard.c en vitesse:
    float q[6];
    
    // temps: quand a t on emit le msg:
    struct timeval time;
    
    int id;
};

#define ERROR (-1)

// prototype:
struct msg_pos position_desire(char c, struct msg_pos pos);
int press();
int main (int nba, char *arg[]) ;