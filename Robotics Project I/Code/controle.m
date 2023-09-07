function commande = controle(Etat,Cible,capteurs)

%param�tre d'erreur
position_err = 0.05;
angle_err = 0.03;
%d�finition des param�tres du cahier des charges
Robwmax = 10;
dmax = 3;
%vitesse roues pour tourner
w_roues_virr = 0.000001; 
%param�tre de sensibilit� des capteurs
sensibilite = 0.98*dmax; 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DETERMINATION DES DISTANCES PAR LES CAPTEURS                      %%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%on fait un test sur tout les capteurs: y a t'il un obstacle?
% on va alors stocker les distance dans une matrice distance
%cette matrice poss�dera 3 infos: distance obs/capteurs num�ro i
%ou i est l'indice du capteur allant de 1 � 3
%%cas le plus �vident: pas d'obstacle
if (capteurs(1,1) >= dmax || capteurs(1,1) <= 0) 
    distance(1) = dmax;

%sinon il y a un obstacle
else
    distance(1) = capteurs(1,1); % renvoie la distance � l'obstacle
end

%cas capteur 2:
if (capteurs(2,1) >= dmax || capteurs(2,1) <= 0)
    distance(2) = dmax;
else
    distance(2) = capteurs(2,1);
end

%cas capteur 3
if (capteurs(3,1) >= dmax || capteurs(3,1) <= 0) 
    distance(3) = dmax;
else
    distance(3) = capteurs(3,1);
end
%ensuite il nous faut la distance cible/robot: on utilise pythagore
distance_cible = sqrt((Cible(1)-Etat(1))^2+(Cible(2)-Etat(2))^2); 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% r�glage vitesse/ sensibilit� suivant l'approche de la cible %%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% cas 1: cible tr�s proche: la cible est dans le rayon du capteur
if distance_cible < dmax 
    wmax = 0.8*Robwmax; %on ralentit    
    if capteurs(3,1) >= distance_cible*1.5 || distance(2)>=distance_cible*1.5 || distance(1) >= distance_cible*1.5 
    %si la cible est proche d'un obstacle
        %il faut r�duire la sensibilit� des capteurs
        sensibilite = 0.2*sensibilite; 
    end
else
    %pas de changement au niveau de la vitesse ni de la sensibilit�
    wmax = Robwmax;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%               Rotation pour angle point d'arriv�e               %%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% test: a t'on atteint la cible (prise en compte de l'erreur de position) 
if (Etat(1) > Cible(1)-position_err && Etat(1) < Cible(1)+position_err) && (Etat(2) > Cible(2)-position_err && Etat(2) < Cible(2) + position_err)
    % delta_angle est l'angle au quel le robot doit tourner
    delta_angle = Etat(3)-Cible(3);
    %cas 1: delta_angle proche de 0
    if abs(delta_angle) < angle_err 
        % on arrete nos deux moteurs
        wd = 0;
        wg = 0;
    % sinon il faut tourner pour l'atteindre
    elseif delta_angle > 0 
        wd = -0.5*wmax;
        wg = 0.5*wmax;   
    else
        wd = 0.5*wmax;    
        wg = -0.5*wmax;
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%    PROCEDURE D'EVITEMENT D'OBSTACLES                %%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% sinon on a pas encore atteint la cible...
else 
    % cas  de detection d'obstacle:
    if distance(2) <= sensibilite %obstacle devant
        if distance(3) <= sensibilite %obstacle � gauche et devant
            if distance(1) <= sensibilite %obstacle � gauche et � droite et devant
                wd = w_roues_virr*wmax;
                wg = 0.5*wmax;
            else %obstacle en face et � gauche mais pas � droite
                wd = w_roues_virr*wmax;
                wg = 0.6*wmax;
            end
        else %obstacle en face-pas � gauche
            if distance(1) <= sensibilite %obstacle en face-pas � gauche-� droite
                wd = 0.5*wmax;
                wg = w_roues_virr*wmax;
            else %obstacle en face-pas � gauche-pas � droite, on choisit de tourner � droite
                wd = w_roues_virr*wmax;
                wg = wmax;
            end
        end
     else %cas pas d'obstacle devant
        if distance(3) <= sensibilite %pas d'obstacle � gauche
            if distance(1) <= sensibilite %pas d'obstacle en face ni � gauche ou � droite
                if distance(3) >= distance(1) %pas d'obstacle en face-� gauche-� droite-G > D
                    wd = 0.5*wmax;
                    wg = 0.2*wmax;
                else %pas d'obstacle en face-� gauche-� droite-G < D
                    wd = 0.2*wmax;
                    wg = 0.5*wmax;
                end
            else %pas d'obstacle en face-� gauche-pas � droite
                wd = w_roues_virr*wmax;
                wg = 0.5*wmax;
            end
        else %pas d'obstacle en face-pas � gauche
            if distance(1)<=sensibilite %pas d'obstacle en face-pas � gauche-� droite
                wd = 0.5*wmax;
                wg = w_roues_virr*wmax;
 
            else %pas d'obstacle detect�
             %on cherche l'arriv�e :
             %calcul de l'angle entre abcisse et vecteur robot-position
                 pt_fin = [Cible(1) Cible(2)];
                 pt_actuel = [Etat(1) Etat(2)];
                 W = pt_fin - pt_actuel;
                 teta_dir = atan2(W(2),W(1)); % si valeure positive : 2 possiblit�s, pareil si c'est n�gatif
                 teta_act = teta_dir-Etat(3);

                 if teta_act > 0
                     wd = wmax;
                     wg = 0.75*wmax;
                 else
                     wd = 0.75*wmax;
                     wg = wmax;
                 end
                 %code 2
            end
        end
    end
end

commande = [wd;wg];

end