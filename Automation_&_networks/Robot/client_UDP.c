#include "client_UDP.h"

struct msg_pos position_desire(char c, struct msg_pos pos)
{
    struct msg_pos pos_des;
    if (c == 'q')
    {
        pos_des.q[0] = pos.q[0]+ 3.14/9;
        pos_des.q[1] = 0.0;
        pos_des.q[2] = 0.0;
        pos_des.q[3] = 0.0;
        pos_des.q[4] = 0.0;
        pos_des.q[5] = 0.0;
    }
    else if (c == 'd')
    {
        pos_des.q[0] = pos.q[0] - 3.14/9;
        pos_des.q[1] = 0.0;
        pos_des.q[2] = 0.0;
        pos_des.q[3] = 0.0;
        pos_des.q[4] = 0.0;
        pos_des.q[5] = 0.0;
    }
    return pos_des;
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

int main (int nba, char *arg[]) 
{
    // déclaration pour les fichiers textes:
    FILE * fp;
    
    int result;
    int nsend;
    int nconnect;
    int i = 0;
    char c;
    // on va envoyé une position:
    struct msg_pos pos;
    int id_msg;
    float retard_mesure;
    int addr;
    long int Te, T;
    int ACK;
    struct msg_ack ACK2;
    struct sockaddr_in sockAddr, sock;
    int serveur, client, err, nConnect, longaddr , results, resultr, resultr2;
    struct timeval end_time;
    double cpu_time_used;
    int a = 1;
    int timeout = 0;
    serveur=socket(PF_INET,SOCK_DGRAM,IPPROTO_UDP);
    sockAddr.sin_family=PF_INET;
    sockAddr.sin_port=htons(2000); 
    sockAddr.sin_addr.s_addr=inet_addr(arg[1]);
    addr=sizeof(sockAddr);

    Te=1000000; 
    /*
    La fréquence d'envoie est faible ici car le retard peut atteindre 1s max,
    pour éviter tout dépassement de capcité du buffer de retard.c, on diminue cette fréquence.
    */


    fcntl(serveur,F_SETFL,fcntl(serveur,F_GETFL) | O_NONBLOCK); 

    // initialisation:
    // données en position:

    pos.q[0] = 3.14/2;
    pos.q[1] = 0.0;
    pos.q[2] = 0.0;
    pos.q[3] = 0.0;
    pos.q[4] = 0.0;
    pos.q[5] = 0.0;
    pos.id = 0;

    // remise à zéro du document retard_msg.txt
    fp = fopen("retard_msg.txt","w");
    fprintf(fp,"%s","");
    // fermuture du fichier texte:
    fclose(fp);

    printf("file: client_UDP.c:\n");
    do{  
        usleep(Te);
        
        // MAJ de la consigne: 
        id_msg = pos.id;
        gettimeofday(&pos.time, NULL);
        
        results = sendto(serveur,&pos,sizeof(pos),0,(struct sockaddr*)&sockAddr,sizeof(sockAddr));
        
        // test d'envoie de la commande:
        if (results == -1)
        {
            printf("\n ERROR: Command not send\n");
        }

        // ajout de l'akcnowledge :
        timeout = 0;
        do{
        resultr2 = recvfrom(serveur,&ACK2,sizeof(ACK2), 0,(struct sockaddr*)&sockAddr,&addr);
        if (resultr2 ==-1)
        {
            usleep(50000);
            timeout +=1;
        }
        // l'UDP est non bloquant, ici on attend de recevoir pendant un temps donnée, si 
        // on dépasse ce temps on sort de la boucle.            
        }
        while ((resultr2 == -1) && (timeout < 20));
        // un message vient d'être reçu, ou dépassement du timeout
        if (ACK2.id == pos.id)
        {

        // Une fois ici, on arrete le chrono.
        gettimeofday(&end_time, NULL);
        cpu_time_used = (end_time.tv_sec - ACK2.time.tv_sec) + (end_time.tv_usec - ACK2.time.tv_usec) / 1000000.0;
        
        //ouverture du fichier texte:
        fp = fopen("retard_msg.txt","a");
        // vérification de l'ouverture:
        if (fp == NULL)
        {
            printf("ERROR: file retard_msg.txt is busy");
            return 0;
        }
        fprintf(fp,"%f\n",cpu_time_used);
        // fermuture du fichier texte:
        fclose(fp);
        }        
        // A t'on eu un changement de consigne?
        if (press())
        {
            c = getchar();
            // l'utilisateur veut il stopper la simulation?
            if (c == 'c')
            {          
                close(serveur);
                a = 0;
            }        
            pos = position_desire(c, pos);
            printf(" \tclient:\n COMMAND HAS BEEN CHANGED\nCommand on q[0] = %f\n", pos.q[0]);
        
        }
        else
        {
            printf("\tCLIENT\n Command on q[0] = %f\n",pos.q[0]);
        }
    
        //On incrémente l'identifiant:
        pos.id = pos.id + 1;
    }
    while(a);

    close(serveur);

    return 0;

}



