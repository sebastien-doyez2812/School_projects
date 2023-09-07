function robot = initrobot()
%roues
robot.R = 0.05;
%longueur 
robot.L = 0.4;
% paramètre pour les capteurs
robot.theta1= -pi/6;
robot.theta2= 0;
robot.theta3= pi/6;
%taille du capteur
robot.Dmax = 3;
% vitesse maximale des roues
robot.wmax = 10;
robot.tau_moteur = 0.2;
end