%% TD 2: Perception :

%% exercice 1 :

[nombre_de_zone1, nombre_de_zone2 , dilated, erode] = compteur_de_zone();
% Nous allons travaill� sur l'image ci dessous: 
 

figure(1)
title('Image d origine: ');
imshow('blood_cells.jpg');

% Nous avons donc au cours de ce programme dilat� l'image d'origine: 

figure(2)
imshow(dilated);
title('Image dilat�e');

% Nous avons ensuite �rod� cette image : 

figure(3)
imshow(erode) ;
title ('Image �rod�');
% Nous appliquons le programme: 

disp('Premi�re m�thode: ');

disp(' Avec un comptage rapide, il y en a :');
disp(nombre_de_zone1);

disp('Avec la seconde m�thode (nombre de pixels noirs divis� par l aire en pixel d un globule, il y a ');
disp (floor(nombre_de_zone2));
disp('globules')


%% exercice 2:

% On doit ici �tre capable de selectionner un point sur une premi�re image
% et le retrouver sur l'image 2 :


coordonnee_image_2('im0.png', 'im1.png');