%% TD 2: Perception :

%% exercice 1 :

[nombre_de_zone1, nombre_de_zone2 , dilated, erode] = compteur_de_zone();
% Nous allons travaillé sur l'image ci dessous: 
 

figure(1)
title('Image d origine: ');
imshow('blood_cells.jpg');

% Nous avons donc au cours de ce programme dilaté l'image d'origine: 

figure(2)
imshow(dilated);
title('Image dilatée');

% Nous avons ensuite érodé cette image : 

figure(3)
imshow(erode) ;
title ('Image érodé');
% Nous appliquons le programme: 

disp('Première méthode: ');

disp(' Avec un comptage rapide, il y en a :');
disp(nombre_de_zone1);

disp('Avec la seconde méthode (nombre de pixels noirs divisé par l aire en pixel d un globule, il y a ');
disp (floor(nombre_de_zone2));
disp('globules')


%% exercice 2:

% On doit ici être capable de selectionner un point sur une première image
% et le retrouver sur l'image 2 :


coordonnee_image_2('im0.png', 'im1.png');