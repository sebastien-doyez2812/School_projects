function cap = def_capteur(Etat, Rob)
% on va définir les extremités des capteurs
%on va donc aditionner la projection de l'extremité sur l'axe des absice ou
%ordonnée à l'absice et à l'ordonnée du point central du robot
    cap.extrem = [Etat(1)+Rob.Dmax*cos(Etat(3)+Rob.theta1)  Etat(2)+Rob.Dmax*sin(Etat(3)+Rob.theta1);
                  Etat(1)+Rob.Dmax*cos(Etat(3))  Etat(2)+Rob.Dmax*sin(Etat(3));
                  Etat(1)+Rob.Dmax*cos(Etat(3)+Rob.theta3)  Etat(2)+Rob.Dmax*sin(Etat(3)+Rob.theta3)];
    cap.ptr1 = line([2 0], [0 0]); 
    cap.ptr2 = line([2 0], [0 0]);
    cap.ptr3 = line([2 0], [0 0]);



end