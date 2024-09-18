# 🎮 Réalisation d'une Console de Jeu sous Basys3 🎮

## Overview 👀:
Le but de ce projet était de créer la partie hardware (électronique) d'une console de jeu sous Basys3, à l'aide de Vivado, du langage VHDL et Verilog. Le projet inclut également la partie software en C pour le jeu vidéo Pong 👾.

## Organisation des fichiers 📖:

- Les images `.coe` sont dans le dossier `/jeu_img/ img_coe` (pour la balle/raquette) et le dossier `/jeu_img` (contenant `PONG.coe` et `gameover2.coe`).

- `jeu.c` : code du jeu en C.
- `test.bin` : exécutable du jeu.
- `.bit` : bitstream.
- `makefile` : fichier permettant la compilation avec la commande `make` sur Cygwin.
- `.coe` : fichier permettant l'affichage des images utilisées.

---

## Dimensions des Sprites 📏:

- **sprite_balle**:  
  Port A width = 12  
  Port A depth = 900 (30 x 30)

- **sprite_raquette**:  
  Port A width = 12  
  Port A depth = 3000 (30 x 100)

- **sprite_accueil**:  
  Port A width = 12  
  Port A depth = 38400 (240 x 160)

- **sprite_gameover**:  
  Port A width = 12  
  Port A depth = 38400 (240 x 160)

---

Le fichier `readme.md` indique les dimensions des sprites utilisés.
