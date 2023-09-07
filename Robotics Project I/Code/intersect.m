function [distance_capteur_obs, point_intersec] = intersect(obstacles,capteur,Etat,Rob)
% on initialise la distance par defaut à 10
distance_capteur_obs = 10; point_intersec=[0 0];

% boucle pour de 1 à 10 pour chaque obstacle
for i=1:10
    %on cherche ici à écrire M = A + t x (B -A)
    %matriciellement cela s'écrit
    %[P ? R A ? B]x [s ; t] = A ? R
    %P et R désignent les extremités de l'obstacle 
    %A et B c'est les extremité du capteur
    % le but ici est de connaitre les coordonnées du point d'intersection
    % entre le laser et l'obstacle
    P = obstacles(i).B;
    R = obstacles(i).A;
    A = [Etat(1) Etat(2)];
    B = capteur;
    Mobstacle = [P(1)-R(1) ; P(2)-R(2)];
    Mcapteur = [A(1)-B(1) ; A(2)-B(2)];
    M = [Mobstacle Mcapteur];
    %tout d'abord il faut vérifier l'inversibiité de M (via le déterminant)
    if abs(det(M)) < 0.0001
        %si on est dans ce cas, matrice M non inversible => pas d'intersection
    else
        %cas d'existence d'intersection 
        % il faut résoudre U = inverse(M) x (A -R)
        u = M\[A(1)-R(1);A(2)-R(2)]; 
        % on a s = u(1) et t = u(2)
        %il faut vérifier que s et t sont dans [0 1]
        if (u(1)>0 && u(1)<1) && (u(2)>0 && u(2)<1)
            %cas OK
            s = u(1);
            t = u(2);
            distance_capteur_obs = Rob.Dmax*t;
            %les coordonnées du point d'intersec sont donnée par R+s(P-R)
            point_intersec = [R(1)+s*(P(1)-R(1)) R(2)+s*(P(2)-R(2))];
        end
    end
end

