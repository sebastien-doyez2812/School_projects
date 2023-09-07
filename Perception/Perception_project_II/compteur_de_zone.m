function [ nombre_de_zone1, nombre_de_zone2 , dilated, erode] = compteur_de_zone(  )
%% 1) passage en noir et blanc: 
mat = imread('blood_cells.jpg'); 
BW = im2bw(mat, 0.5);

%% 2) dilatation et erosion :

% On doit ici déterminer de combien de pixels doit on dilater et éroder
% pour avoir le meilleur rendu: 


se = strel('disk',1,8);
dilated = imdilate(BW,se);
se = strel('disk',2,0);
erode = imerode(dilated,se);

b = bwconncomp(erode);
nombre_de_zone1 = b.NumObjects;

% méthode 2 : 
% Après quelques tests, on peut alors choisir une dilatation / erosion de 3
% puis 4 pixels
% autour d'un pixels central
se = strel('square',3);

dilated = imdilate(BW,se);
erode = imerode(dilated,se);

se = strel('square',4);

dilated = imdilate(erode,se);
erode = imerode(dilated,se);
%% 4) on compte les zones : 

%méthode 2:

%je vais compter le nombre de pixels noir dans mon image et je diviserais
%par la suite par l'aire d'un globule: 

% méthode 2.1 : combien a t'on de pixel noir dans cette image: 
count = 0; 

% combien y a t'il de pixel pour un globule: 
% la zone x: 291 -> 315 et y: 89 -> 110 contient un seul globule,
% grace à lui je vais avoir le nombre de pixels d'un globule

counter = 0; 
for i=291:315
    for j = 89:110
        if erode(i,j) == 0
            counter = counter + 1;
        end;
    end;
end;

[n,m] = size(erode); 
for i=1:n
    for j = 1:m
        if erode(i,j) == 0 
            count = count +1;
        end;
    end
end
nombre_de_zone2 =  count/counter;



end

