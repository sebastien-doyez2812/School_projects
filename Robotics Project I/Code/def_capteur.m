function cap = def_capteur(Etat, Rob)
% on va d�finir les extremit�s des capteurs
%on va donc aditionner la projection de l'extremit� sur l'axe des absice ou
%ordonn�e � l'absice et � l'ordonn�e du point central du robot
    cap.extrem = [Etat(1)+Rob.Dmax*cos(Etat(3)+Rob.theta1)  Etat(2)+Rob.Dmax*sin(Etat(3)+Rob.theta1);
                  Etat(1)+Rob.Dmax*cos(Etat(3))  Etat(2)+Rob.Dmax*sin(Etat(3));
                  Etat(1)+Rob.Dmax*cos(Etat(3)+Rob.theta3)  Etat(2)+Rob.Dmax*sin(Etat(3)+Rob.theta3)];
    cap.ptr1 = line([2 0], [0 0]); 
    cap.ptr2 = line([2 0], [0 0]);
    cap.ptr3 = line([2 0], [0 0]);



end