#include "retard.h"

double lookup_table( long int  retard)
{
    if ((retard > 200000) && (retard < 400000) )
    {
        return 1.00353;
    }
    else if ((retard > 400000) && (retard < 600000) )
    {
        return 1.00091;
    }
    else if ((retard > 600000) && (retard < 800000) )
    {
        return 1.00023;
    }
    else
    {
        return 1.00015;
    }
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

int main(int nba, char *arg[]){

    srand(time(NULL));
    // définition des variables:
    struct msg message_speed;
    struct mesg_r message_pos;
    struct mesg_r message_pos_client;
    struct mesg_r message_backup;

    FILE * fp;

    // définition de l'acknowledge: 
    int Ack = 1;
    int a = 1;
    // on va prendre un retard aléatoire constant, entre 0 et 1s:
    // puisque on envoie une commande toutes les 2s, donc avec ce retard , on ne
    // pourra pas déborder sur le prochain envoi!
    
    // Pour Akram: c'est des micro sec
    int retard = 200000; // retard initial de 200 milli sec 
    int T = 1000000; // 1s  retard constant max
    
    int result, nsend;
    struct sockaddr_in sockAddr1, sockAddr2 , sock;
    int serveur1, serveur2, client1, err, nConnect, addr1, addr2;
    int n , i, results, results2, resultr, resultr2 ;
    long int  Te;
    double  Un,  Sn,  Snp;
    double K = lookup_table(retard);
    double tau, dt, A, B;
    int Rt;  
    int timeout = 0;
    // INITIALISATION CLIENT/SERVEUR:
    // serveur retard
    serveur1 = socket(PF_INET,SOCK_DGRAM,IPPROTO_UDP);
    sockAddr1.sin_family=PF_INET;
    sockAddr1.sin_port=htons(2000); 
    sockAddr1.sin_addr.s_addr=0;
    addr1=sizeof(sockAddr1);

    err=bind(serveur1,(struct sockaddr*)&sockAddr1,addr1);
    if(err==ERROR) {
        printf("\n erreur de bind du serveur1 UDP!! \n");
    }
   
    // client retard : 
    serveur2 =  socket(PF_INET,SOCK_DGRAM,IPPROTO_UDP);
    sockAddr2.sin_family=PF_INET;
    sockAddr2.sin_port=htons(2001); 
    sockAddr2.sin_addr.s_addr= inet_addr(arg[1]);
    addr2=sizeof(sockAddr2);


    // initialisation de structure: 
    for (int i = 0; i< 6; i++)
    {
        message_pos_client.q[i] = 0.0;
        message_pos.q[i] = 0.0;
        message_speed.q_p[i] = 0.0;
    }

    Te=100000; // Te=1s, c'est le retard max
    
    results  = ERROR;
    resultr  = ERROR;
    resultr2 = ERROR;
    results2 = ERROR;

    // démarrage des serveurs: 
    fcntl(serveur1,F_SETFL,fcntl(serveur1,F_GETFL) | O_NONBLOCK); 
    fcntl(serveur2,F_SETFL,fcntl(serveur2,F_GETFL) | O_NONBLOCK);
    
    fp = fopen("retard_envoie.txt","w");
    fprintf(fp,"%s %s","retard", "K\n");

    // fermuture du fichier texte:
    fclose(fp);
    printf("file: retard.c:\n");
    message_backup = message_pos_client;
    while(a)
    {       
        
        for (int n = 0; n<= T / Te; n++)
        {          
            // étape 1: je reçois mon message:
            resultr=recvfrom(serveur1,&message_pos_client,sizeof(message_pos_client), 0,(struct sockaddr*)&sockAddr1,&addr1);
            if (resultr != -1)
            {
                // J'ai reçu un message:
                message_backup = message_pos_client;
                if (n == T/Te && retard < 1000000)
                {
                    retard += rand()%100000; 
                }  
                else if (retard >=1000000) 
                {
                    retard = 1000000;
                }
                printf("injected delay = %f\t Kc = %f \n",((float)retard)/1000000, K);
            
                // retard: 
                usleep(retard);

                // On a reçu un message: il faut l'envoyé:
                
                for (int i = 0; i< 6; i ++)
                {   
                    // correcteur:
                    K = lookup_table(retard);
                    message_speed.q_p[i] = (message_pos_client.q[i] - message_pos.q[i]) * K;
                    message_speed.id = message_pos_client.id;
                    message_speed.time = message_pos_client.time;
                }
                fp = fopen("retard_envoie.txt","a");
                fprintf(fp,"%f \t%f\n",((float)retard)/1000000 ,K, "\n");
                // fermuture du fichier texte:
                fclose(fp);
                
                results2 =  sendto(serveur2,&message_speed,sizeof(message_speed),0,(struct sockaddr*)&sockAddr2,sizeof(sockAddr2));
                timeout = 0;
                do 
                {
                    // commande envoyé par coppélia: 
                    resultr2 = recvfrom(serveur2,&message_pos,sizeof(message_pos), 0,(struct sockaddr*)&sockAddr2,&addr2); 
                    if (resultr2 == -1)
                    {
                        timeout += 1;
                        usleep(50000);
                    }
                }
                while ((resultr2 == -1) && (timeout < 20));            
                
                // On envoie le message retardé: 
                results = sendto(serveur1,&message_pos,sizeof(message_pos),0,(struct sockaddr*)&sockAddr1,sizeof(sockAddr1));
            }              
        }
        if (press())
        {
            char c = getchar();
            if (c = 'c')
            {
                close(serveur1);
                close(serveur2);
                a = 0;
            }
            
        }
        
    }
    close(serveur1);
    close(serveur2);
    return 0; 
}
