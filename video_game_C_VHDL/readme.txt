Organisation des fichiers:

les images .coe sont dans le dossier /jeu_img/ img_coe { pour la balle/ raquette}
et le dossier /jeu_img {PONG.coe / gameover2.coe }


jeu.c 		: code du jeu codé en C
test.bin	: éxécutable du jeu
.bit		: bitstream
makefile	: fichier permettant la compilation avec la commande make sur cygwin
.coe		: fichier permettant l'affichage des images utilisées.
___________________________________________________________________________

readme.txt pour indiquer les dimensions des sprites:
sprite_balle: 
Port A width = 12 
Port A depth = 900   = 30 x 30 

sprite_raquette: 
Port A width = 12 
Port A depth = 3000   = 30 x 100 

sprite_accueil: 
Port A width = 12 
Port A depth = 38400   = 240 x 160

sprite_gameover: 
Port A width = 12 
Port A depth = 38400   = 240 x 160 



