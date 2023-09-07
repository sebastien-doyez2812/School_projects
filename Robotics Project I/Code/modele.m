function etatdot = modele(Etat,commande,Rob)
% d'après le cours, la fonction modele doit nous renvoyer etatdot:
%etatdot doit etre une matrice contenant les variable x,y,theta,wd,wg
%répondant à la commande
%  etatdot(1) = diamètre des roues/2*(wd + wg)*cos(theta));
%  etatdot(2) = diamètre des roues/2*(wd + wg)*sin(theta);
%  etatdot(3) = diamètre des roues/longueurdu robot*(wd - wg);
%  etatdot(4) = (-1/tau)*wd + (1/tau)*commande de wd;
%  etatdot(5) = (-1/tau)*Etat(5) + (1/tau)*commande de wg;
    etatdot(1) = Rob.R/2*(Etat(4) + Etat(5))*cos(Etat(3));
    etatdot(2) = Rob.R/2*(Etat(4) + Etat(5))*sin(Etat(3));
    etatdot(3) = Rob.R/Rob.L*(Etat(4) - Etat(5));
    etatdot(4) = (-1/Rob.tau_moteur)*Etat(4) + (1/Rob.tau_moteur)*commande(1);
    etatdot(5) = (-1/Rob.tau_moteur)*Etat(5) + (1/Rob.tau_moteur)*commande(2);
 
end