function [ x2, y2 ] = coordonnee_image_2( image1 , image2 )

% d�claration des variables: 

point=20;
intervalle = 40;

% Nous allons avoir besoin de nos deux matrices associ� aux images: 

mat = imread(image1);
mat2 = imread(image2);

figure(1)
imshow(mat) 

% j'obtiens donc les coordornn�es du points cjoisi sur ma premi�re image: 

[x,y] = ginput(1);
% ces valeurs �tant des nombres � virgules, je vais utiliser floor() afin
% d'avoir des entiers: 

x = floor(x);
y = floor(y);


% normalement sur une vision robotique, les deux cam�ra sont assez proches:
% donc cela ce servirait � rien d'explorer toute l'image pour trouver le 1
% er points:

% Apr�s avoir pris les coordonn�es d'un points facilement rep�rable, on
% remarque qu'un intervale de 40 pixels semble �tre un bon compromis: 

% Nous avons �galement besoin de passer la seconde image en niveau de
% gris: 
BW2 = rgb2gray(mat2);

% Pour la suite, sur matlab, il existe une fonction normxcorr2 qui va nous
% servir � faire une corr�lation : 
% On a besoin d'une image r�duite autour de notre point o� l'on a cliqu�:

Image_reduite = mat(y-intervalle:y+intervalle , x-intervalle:x+intervalle, :);
imred_gray= rgb2gray(Image_reduite);

% maintenant on r�alise la corr�lation: 

% On d�termine les coordonn�es o� on a un max de corr�lation:
c = normxcorr2(imred_gray, BW2);
[y2, x2] = find(c==max(c(:)));

% pour l'image d'origine :
% on va faire un point rouge :
for i = 0:point
    for j= 0:point
    mat(y-point/2+i,x-point/2+j,1)=255;
    mat(y-point/2+i,x-point/2+j,2)=0;
    mat(y-point/2+i,x-point/2+j,3)=0;

    end

end

% il ne faut pas oublier de retirer l'intervalle dans les x et y de la
% matrice: 

% pour l'image 2: 
for i = 0:point
    for j= 0:point
    mat2(y2-point/2+i-intervalle,x2-point/2+j-intervalle,1)=255;
    mat2(y2-point/2+i-intervalle,x2-point/2+j-intervalle,2)=0;
    mat2(y2-point/2+i-intervalle,x2-point/2+j-intervalle,3)=0;

    end

end

% on affiche les 2 images o� on a un point rouge:
figure(1)
title('Image 1:');
imshow(mat);
figure(2)
title('Image 2:');
imshow(mat2);
end

