function [] = robot()

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%        SIMULATEUR         %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%réinitialisation de la figure 1
clc;
close all
clear
figure(1)
clf
hold on
%choix des coordonnées max:
axis([0 50 0 50])
axis square

%Affichage d'obstacles
obstacle=obs();
%choix du point de départ
Dep= ginput(1);
plot(Dep(1), Dep(2), 'go');
%choix angle de départ: 
b = ginput(1);
c = b-Dep;
theta=atan2(c(2),c(1));
%Choix de l'arrivée
arrivee = ginput(1);
plot(arrivee(1),arrivee(2),'ro');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%              FIN SIMULATEUR                             %%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%_________________________________________________________________________
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%              ROBOT                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%initialisation de Etat:
%Etat = [X;Y;angle;wd;wg]
Etat = [Dep(1);Dep(2);theta;0;0];
Rob= initrobot();
%initiaisation de la vitesse de roues (via commande)
commande=[Rob.wmax;Rob.wmax]; %[wd;wg]
%%défintition de cible:
%c'est la même chose que arr mais il nous faut un angle d'arrivée (définit
%à pi/2 )
%Il nous faut définir un angle d'arrivé
Cible = [arrivee(1);arrivee(2);pi/2];
%tracé du robot sur fig 1
%trois points dans le repère du robot
Rob.a=[1;0;1]; Rob.b=[0;-0.5;1]; Rob.c=[0;0.5;1];
%maintenant il faut passer dans le repère absolue:
%définition de la matrice de passage
mat_passage = [cos(theta) -sin(theta) Dep(1) ; sin(theta) cos(theta) Dep(2) ; 0 0 1];
A=mat_passage*Rob.a;
B=mat_passage*Rob.b;
C=mat_passage*Rob.c;
%On trace le robot
rob_points=[A B C]';
faces=[1 2 3];
Rob.ptr=patch('vertices',rob_points,'faces',faces,'facecolor','r');
%définition des capteurs:
capteurs = def_capteur(Etat, Rob);
%matrice de détection 

detection_capteur = [Rob.Dmax Rob.theta1;
                     Rob.Dmax   Rob.theta2;
                     Rob.Dmax  Rob.theta3];
while commande(1)~=0 && commande(2)~=0
    %tant que la vitesse du robot n'est pas nulle...
    %intégration de l'état actuel
    [T,X]= ode45(@(t, Etat)modele(Etat,commande,Rob)', [0 0.1], Etat);
    L45 = length(T);  %il n'y a que la dernière ligne qui nous interressent
    Etat = X(L45, :);
    %mide à jour de la figure 1:
    capteurs= mise_a_jour(Etat, Rob, capteurs);
    %detection d'obstacles
    for i=1:3 %pour chaque capteurs
        [dist_capteur,pt_inter] = intersect(obstacle,capteurs.extrem(i,:),Etat,Rob);
        if dist_capteur>0 && dist_capteur<Rob.Dmax
            %cas ou le laser ne permet pas de détecter d'obstacle
            capteurs.extrem(i,1)=pt_inter(1);
            capteurs.extrem(i,2)=pt_inter(2);
        end
        detection_capteur(i,1)=dist_capteur;
    end
    %controle des commandes en fonction de la cible, l'état et les obstacles
    commande = controle(Etat,Cible,detection_capteur);
    
end
end