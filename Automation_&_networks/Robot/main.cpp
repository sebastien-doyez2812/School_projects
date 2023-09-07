#include "main.h"


/*
Get Join Pos: utiliser pour le message de retour: 
En effet, nous avons un systeme client- serveur en UDP,
mais nous voulons envoyer un acknowledge avec la position actuelle du moteur 
que l'on bouge
*/

void getJoinPos(int clientID, float* qr)
{
    // Il faut d'abord mettre en pause la communication : 
    simxPauseCommunication(clientID, 1);
    
    // On peut alors récupérer les composantes angulaires des moteurs: 
    for (int i = 0; i<6; i++)
    {
        simxGetJointPosition(clientID, handles[i], &(qr[i]), simx_opmode_oneshot);
    }
    
    // Il faut redemarrer :
    simxPauseCommunication(clientID, 0);
}


int press() { 
    // Déclaration de deux structures termios pour gérer les attributs du terminal
    struct termios oldt, newt; 
    // Déclaration d'un entier pour stocker la valeur de la touche pressée
    int ch; 
    // Déclaration d'un entier pour stocker les attributs de fichier du terminal

    int oldf; 
    // Récupération des attributs du terminal dans la structure oldt
    tcgetattr(STDIN_FILENO, &oldt); 
    // Copie des attributs du terminal dans la structure newt
    newt = oldt; 
    newt.c_lflag &= ~(ICANON | ECHO); // Désactivation du mode canonique et de l'écho des caractères
    tcsetattr(STDIN_FILENO, TCSANOW, &newt); // Appliquer les nouveaux attributs du terminal

    oldf = fcntl(STDIN_FILENO, F_GETFL, 0); // Récupération des attributs de fichier du terminal
    fcntl(STDIN_FILENO, F_SETFL, oldf | O_NONBLOCK); // Activation du mode non-bloquant pour la lecture des caractères

    ch = getchar(); // Lecture d'un caractère depuis l'entrée standard

    tcsetattr(STDIN_FILENO, TCSANOW, &oldt); // Rétablir les attributs du terminal d'origine
    fcntl(STDIN_FILENO, F_SETFL, oldf); // Rétablir les attributs de fichier du terminal d'origine

    if(ch != EOF) // Si un caractère a été lu avec succès
    {
        ungetc(ch, stdin); // Remettre le caractère dans le flux d'entrée
        return 1; // Renvoyer 1 pour indiquer que la touche a été pressée
    }
    return 0; // Renvoyer 0 pour indiquer que aucune touche n'a été pressée
}

void GetHandles(int clientID){
	simxChar objectName[100];
	char str[10];
    for (int i=0; i < 6; i++) {
        strcpy(objectName, "joint");
        sprintf(str, "%d", i+1);
        strcat(objectName,str);
        error=simxGetObjectHandle(clientID, objectName, &handle, simx_opmode_oneshot_wait);
        if (error == simx_return_ok)
            handles[i]=handle;
        else {
            printf("Error in Object Handle - joint number %d\n", i);
            all_ok=0;
        }
    }
}
/////////////////////////////////////////////////////////
// Set the join position
//
// Inputs:
//  clientID
//  q : array of the joint values
// Return: 0 if an error occurs in object handling, 1 otherwise
/////////////////////////////////////////////////////////

/*
Nous avons besoin d'une fonction qui va set ma position désiré:
*/

int SetJointPos(int clientID,  float *q)
{    
    if (all_ok) {
        for (int i=0; i < 6; i++)
        {
            // asservissement en psoition : 
            simxSetJointTargetPosition(clientID, handles[i], q[i], simx_opmode_oneshot);               
        } 
        return 1;
    }
    else
        return 0;
}

/*
dans ce sujet de ce projet, nous ne devons pas utiliser un asservissements en positions, mais en vitesse
Nous avons donc besoin d'une fonction SetJointSpeed
*/

int SetJointSpeed(int clientID,  float *qv)
{         
    if (all_ok) {
        // On envoie alors la vitesse désirée:
        simxPauseCommunication(clientID, 1);
        for (int i=0; i < 6; i++)
        {
            // Asservissements vitesse:
            simxSetJointTargetVelocity(clientID, handles[i], qv[i], simx_opmode_oneshot);        
        }
        simxPauseCommunication(clientID,0);       
        
        return 1;
    }

    else
        return 0;
}
/// @brief 
/// @param argc 
/// @param argv 
/// @return 


int main(int argc,char* argv[])
{
    int portNb=5555;            // the port number where to connect
    int timeOutInMs=5000;       // connection time-out in milliseconds (for the first connection)
    int commThreadCycleInMs=5;  // indicate how often data packets are sent back and forth - a default value of 5 is recommended
    
    FILE * fp2;

    // Partie SERVEUR:
    
    //définition des variables et structure:
    struct speed_send message_vitesse;
    struct pos_receive message_pos;
    struct timeval dep_time;
    struct timeval actual_time;
    int result, nsend;
    struct sockaddr_in sockAddr, sock;
    int serveur, client, err, nConnect;
    socklen_t longaddr;
    int n , i, results, resultr ;
    long int  Te;
    double  Un,  Sn,  Snp , K;
    double tau, dt, A, B;
    int Rt;  
    int a = 1;

    for (int i = 0; i<6; i++)
    {
        message_vitesse.q_p[i] = 0.0;
        message_pos.q[i] = 0.0;
    }
    
    serveur=socket(PF_INET,SOCK_DGRAM,IPPROTO_UDP);
    sockAddr.sin_family=PF_INET;
    sockAddr.sin_port=htons(2001); 
    sockAddr.sin_addr.s_addr=0;
 	longaddr=sizeof(sockAddr);

    err=bind(serveur,(struct sockaddr*)&sockAddr,longaddr);
 	if(err==ERROR) {
        printf("\n erreur de bind du serveur UDP!! \n");
	}

    Te=200000; // Te=100ms

    results=ERROR;
    resultr=ERROR;

    // Lancement du serveur, on veut des transmissions non bloquante: 
    fcntl(serveur,F_SETFL,fcntl(serveur,F_GETFL) | O_NONBLOCK); 
 
    // Connection to the server
    int clientID=simxStart((simxChar*)"127.0.0.1",portNb,true,true,timeOutInMs,commThreadCycleInMs);

    GetHandles(clientID);
    
    if (clientID!=-1)
    {
       int nbloop=100;
       simxSynchronous(clientID,true);       // Enable the synchronous mode (Blocking function call)
       simxStartSimulation(clientID, simx_opmode_oneshot);

       float t=0.0;
       float tfinal=5;
       float dt=0.01;
       float q0m = 0.1;
       float q1m =0.2;
       float q2m = 0.2;
       float w=2*M_PI/2.5;
       int timeout = 0;
       int offsetTime=simxGetLastCmdTime(clientID)/1000;

        // On va recevoir nos messages reçu par le clients: 
        // on va donc utiliser la variable resultr:
        // cette fonction renvoie le nombre d'octets du message recu:
        // donc tant que on a un nombre d'octet < 1: on a rien recu...

        fp2 = fopen("position&vitesse.txt","w");
        fprintf(fp2,"%s","");
        // fermuture du fichier texte:
        fclose(fp2);
        
        printf("file: main.cpp: \n");
        gettimeofday(&dep_time,NULL);
       while (a) 
       {
            resultr=recvfrom(serveur,&message_vitesse,sizeof(message_vitesse), 0,(struct sockaddr*)&sockAddr,&longaddr);
            // si on reçoit on modifie le comportement de Coppélia:
            if (resultr != -1)
            {
            
                // mise en place de l'ackonwledge :           
                SetJointSpeed(clientID,message_vitesse.q_p);
                getJoinPos(clientID,message_pos.q);
                message_pos.time = message_vitesse.time;
                message_pos.id = message_vitesse.id;
                results = sendto(serveur,&message_pos, sizeof(message_pos),0, (struct sockaddr*)&sockAddr, sizeof(sockAddr));
                
                // impression en console : 
                printf("Current position: q0 = %4.5f , q1 = %4.1f, q2 = %4.1f, q3 = %4.1f, q4 = %4.1f, q5 = %4.1f\n", message_pos.q[0], message_pos.q[1], message_pos.q[2], message_pos.q[3], message_pos.q[4], message_pos.q[5]);
                
                //ouverture du fichier texte:
                fp2 = fopen("position&vitesse.txt","a");
                // vérification de l'ouverture:
                if (fp2 == NULL)
                {
                    printf("ERROR: file position&vitesse.txt is busy");
                    return 0;
                }
                gettimeofday(&actual_time,NULL);
                float temps = float((actual_time.tv_sec-dep_time.tv_sec + 1e-6 * (actual_time.tv_usec-dep_time.tv_usec)));
                fprintf(fp2,"%f\t%f\t%f\n",temps, message_pos.q[0], message_vitesse.q_p[0]);
                // fermuture du fichier texte:
                fclose(fp2);

                if (press())
                {
                    char c = getchar();
                    if (c = 'c')
                    {
                        simxStopSimulation(clientID, simx_opmode_oneshot);
                        // Close the connection to the server
                        simxFinish(clientID);
                        close(serveur);
                        a = 0;
                    }
                
                }
            }

        }

        simxStopSimulation(clientID, simx_opmode_oneshot);

        // Close the connection to the server
        simxFinish(clientID);
    }
    else
        printf("Connection to the server not possible\n");

    return(0);
}
