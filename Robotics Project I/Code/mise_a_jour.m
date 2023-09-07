function cap = mise_a_jour(Etat, Rob, cap)
% calcul des nouvelles coordonn�es des extremit�s des capteurs
    cap.extrem = [Etat(1) + Rob.Dmax*cos(Etat(3)+Rob.theta1) , Etat(2) + Rob.Dmax*sin(Etat(3)+Rob.theta1);
                  Etat(1) + Rob.Dmax*cos(Etat(3)) , Etat(2) + Rob.Dmax*sin(Etat(3));
                  Etat(1) + Rob.Dmax*cos(Etat(3)+Rob.theta3) , Etat(2) + Rob.Dmax*sin(Etat(3)+Rob.theta3)];
    %recalcul des coordonn�es des points A,B et C dans le rep�re abs
    mat_de_passage = [cos(Etat(3)) (-sin(Etat(3))) Etat(1) ; sin(Etat(3)) cos(Etat(3)) Etat(2) ; 0 0 1];
    A=mat_de_passage*Rob.a;
    B=mat_de_passage*Rob.b;
    C=mat_de_passage*Rob.c;
    sommets=[A B C]';
    %on retrace le robot
    set(Rob.ptr,'vertices',sommets);
    
    %on va remettre � jour nos capteurs:
    abs_capteurg = [Etat(1) Etat(1) + Rob.Dmax*cos(Etat(3)+Rob.theta1)];
    abs_capteurd = [Etat(1) Etat(1) + Rob.Dmax*cos(Etat(3)+Rob.theta3)];
    abs_capteur = [Etat(1) Etat(1) + Rob.Dmax*cos(Etat(3))];
    ord_capteurg = [Etat(2)  Etat(2) + Rob.Dmax*sin(Etat(3)+Rob.theta1)];
    ord_capteurd = [Etat(2)  Etat(2) + Rob.Dmax*sin(Etat(3)+Rob.theta3)];
    ord_capteur = [Etat(2)  Etat(2) + Rob.Dmax*sin(Etat(3))];
    %renvoi des nouvelles coordonn�es au robot pour l'interface graphique
    %et pour la d�tection d'obstacles
    set(cap.ptr1, 'xdata', abs_capteurg, 'ydata', ord_capteurg);
    set(cap.ptr2, 'xdata', abs_capteurd, 'ydata', ord_capteurd);
    set(cap.ptr3, 'xdata', abs_capteur, 'ydata', ord_capteur);
    
    drawnow
end