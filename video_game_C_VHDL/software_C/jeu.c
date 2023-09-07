#include "plasma.h"

#define MemoryRead(A) (*(volatile unsigned int*)(A))
#define MemoryWrite(A,V) *(volatile unsigned int*)(A)=(V)

#define sprite_ball_w 30
#define sprite_ball_h 30
#define sprite_raquette1_w 30
#define sprite_raquette1_h 100
#define out 800
#define scoremax 4
#define scoremax_d 1
#define mask_btnD 4096 
#define mask_btnU 8192
#define mask_btnD_m 0x00001000
#define mask_btnU_m 0x00002000
#define mask_btnL_m 0x00004000
#define mask_btnR_m 0x00008000

char *itoa10(unsigned long num)
{
   static char buf[12];
   int i;
   buf[10] = 0;
   for (i = 9; i >= 0; --i)
   {
      buf[i] = (char)((num % 10) + '0');
      num /= 10;
   }
   return buf;
}

void VGA_color(int value)
{
	//Alignement de la variable value par decalage a gauche de X bits
	value = value << 16 ;
	MemoryWrite(GPIO0_CLEAR, (~value) & 0xFFF0000); //clear
	MemoryWrite(GPIO0_OUT, value); //set	
}

void SEG7(char E4, char E3, char E2, char E1) {
	//ALIGNEMENT DES PARAMETRES PAR DECALAGE A GAUCHE DE X BITS
	int tmp=E4<<28 | E3<<24 | E2<<20 | E1<<16 ;
	MemoryWrite(GPIO0_CLEAR, (~tmp) & 0xFFFF0000); //clear
	MemoryWrite(GPIO0_OUT, tmp); //set
}
void VGA_SPRITE(int x, int y) 
{
	int value = x | (y << 10);
	MemoryWrite(GPIO1_CLEAR, (~value) & 0xfffff); //clear
	MemoryWrite(GPIO1_OUT, value); 
}

void VGA_SPRITE2(int x, int y) 
{
	int value = x | (y << 10);
	MemoryWrite(GPIO2_CLEAR, (~value) & 0xfffff); //clear
	MemoryWrite(GPIO2_OUT, value); 
}

void VGA_SPRITE3(int x, int y) 
{
	int value = x | (y << 10);
	MemoryWrite(GPIO3_CLEAR, (~value) & 0xfffff); //clear
	MemoryWrite(GPIO3_OUT, value); 
}
void VGA_SPRITE4(int x, int y) 
{// c'est la page de démarrage
	int value = x | (y << 10);
	MemoryWrite(GPIO4_CLEAR, (~value) & 0xfffff); //clear
	MemoryWrite(GPIO4_OUT, value); 
}


void VGA_SPRITE5(int x, int y) 
{// c'est la page de démarrage
	int value = x << 20 ;
	int value2 = y << 20;
	MemoryWrite(GPIO1_CLEAR, (~value) & 0xfff00000); //clear
	MemoryWrite(GPIO2_CLEAR, (~value) & 0xfff00000); //clear
	MemoryWrite(GPIO1_OUT, value); 
	MemoryWrite(GPIO2_OUT, value2); 
}

int VGA_sw()
{
	int mask = 0xFFF; // car les sw sont sur le 16 bits de GPIOA(15,0)
	return ( mask & MemoryRead(GPIOA_IN));
}

int VGA_btn()
{
	int mask = 0xF000; // car les sw sont sur le 16 bits de GPIOA(15,0)
	return ( mask & MemoryRead(GPIOA_IN));
}
void delay(long int temp)
{
	int i;
	for (i = 0; i < temp; i++);
}

void screen_saver(int* x, int* y, int* dx, int* dy, int* a, int difficulte){	
	// Limit x
	if(*x == 0) *dx = 1;
	if(*x == 480-sprite_ball_w) *dx = -1;
	// Limit y
	if(*y == 0) *dy = 1;
	if(*y == 640-sprite_ball_h) *dy = -1;
	// Move x,y
	*a = *a + 1;
	// mise en place des niveaux:
	// a <5 => niveau facile
	// a < 3 => intermédiaire
	// a < 1 => difficile
	if (*a == difficulte)
	{
		*x = (*x + *dx);
		*y = (*y + *dy);
		*a = 0;
	}
}

int nostradamus(int x, int y, int dx, int dy, int score, int score_d){	
	
	int pos_cible;
	if ((score >= scoremax) && (score_d == scoremax_d))
	{
		if((y >= 300)&& (dy == 1))
		{
			pos_cible = x + 160;
		}
		else pos_cible = 200;
	}
	else
	{
		if((y >= 300)&& (dy == 1))
		{
			pos_cible = x;
		}
		else pos_cible = 200;
	}
	return pos_cible;
}

int raquette2(int cible, int act_pos)
{
	if (act_pos != cible)
	{
		if ((cible - act_pos) > 0)
		{
			return act_pos + 2; 
		}
		else 
		{
			return act_pos - 2;
		}
	}
	return act_pos;
}

int main(void)
{
	// les valeurs de positionnements: 
	int value = 122;
	int value2 = 0;
	int value3 = 610;
	int pos = 200;
	int x = 122;
	int y = 122;
	int dx = 1;
	int dy = 1;
	int a = 0;
	int pos_cible;
	int pos_raquette2 = 200;//100;
	int temp = 10000;
	// initialisation variable jeu:
	int game = 1;
	int mask = 0x00000000;
	int difficulte = 5;
	int multiplayer = 0;
	int OK = 0;
	// indice : 
	int score_d = 0;
	int score = 0;
	// pour multi joueur:
	int scorep1 = 0;
	int scorep2 = 0;
	int indice = 0;
	
	// initialisation:
	VGA_SPRITE(out,out);
	VGA_SPRITE3(out, out);
	VGA_SPRITE2(out, out);
	VGA_SPRITE4 (150,200);
	VGA_SPRITE5 (out,out);
	VGA_color(0x000011110000);
	SEG7(0,0,0,0);
	// choix de la difficulté:
	while (OK != 1 )
	{
		switch (VGA_sw())
		{
			case 0x000000001:
				difficulte = 5;
				multiplayer = 0;
				OK = 1;
				break;
			case 0x000000002:
				difficulte = 3;
				multiplayer = 0;
				OK = 1;
				break;
			case 0x000000004:
				difficulte = 1;
				multiplayer = 0;
				OK = 1;
				break;
			case 0x000000008:
				difficulte = 1;
				multiplayer = 1;
				OK = 1;
				break;
			case 0x000000010:
				difficulte = 3;
				multiplayer = 2;
				OK = 1;
				break;
			default:
				OK = 0;
		}
	}
	// initialisation:
	VGA_SPRITE(value,value);
	VGA_SPRITE3(pos_raquette2, value3);
	VGA_SPRITE2(300, value2);
	VGA_SPRITE4(out, out);

	// On rentre dans le jeu:
	while(game == 1)
	{
		// choix du joueur: 
		switch (multiplayer)
		{
			case 0:
				/*
					PARTIE I: Déplacement du joueur:
				*/
				mask = VGA_btn();
				if (mask == mask_btnD)
				{
					pos ++;
					delay(temp);
				}
				else if (mask == mask_btnU )
				{
					pos --;
					delay(temp);
				}
				// les limites de l'écrans: 
				if (pos > 400)
				{
					pos = 400;
				}
				else if (pos < 0)
				{
					pos = 0;
				}
				VGA_SPRITE2(pos, value2);
				/*
					Partie II: la balle:
				*/
				if (mask == 0)
				{
					delay(temp);
				}
				screen_saver(&x,&y,&dx,&dy,&a, difficulte);
				if (( y <= sprite_raquette1_w) && (y > 0))
				{
					if ((x >= pos- sprite_ball_h/2) &&(x <= pos + sprite_raquette1_h + sprite_ball_h/2)) 
					{
						// si on arrive ici , on a bien tapé sur la balle
						dy = 1;
						indice ++;
					}
				}
				else if (y == 0)// cas y ==0
				{
					game = 0;
					score = score_d = 0;
				}
				
				if (( y >= value3 - sprite_raquette1_w) && (y < value3))
				{
					if ((x >= pos_raquette2- sprite_ball_h/2) &&(x <= pos_raquette2 + sprite_raquette1_h + sprite_ball_h/2)) 
					{
						// si on arrive ici , on a bien tapé sur la balle
						dy = -1;
					}
				}
				else if (y == value3)// cas y ==0
				{
					game = 2;
					SEG7(0,0,score_d,score);
					// score = score_d = 0;
				}
				
				VGA_SPRITE(x,y);
				
				/*
					PARTIE III: la raquette 2
				*/
				pos_cible = nostradamus(x,y,dx,dy,score, score_d);
				// pos_raquette2= raquette2(pos_cible,pos_raquette2);
				if (pos_cible != pos_raquette2)
				{
					if (pos_cible - pos_raquette2 > 0 )
					{
						pos_raquette2 ++;
					}
					else{
						pos_raquette2 --;
					}
				}
				if ( pos_raquette2 > 400)
				{
					pos_raquette2 = 400;
				}
				else if (pos_raquette2 < 0)
				{
					pos_raquette2 = 0;
				}
				// réglage du score
				if (difficulte == 3)
				{
					if (indice == 3)
					{
						score ++;
						indice = 0;
					}
				}
				else if (difficulte == 5)
				{
					if (indice == 5)
					{
						score ++;
						indice = 0;
					}
				}
				else if (difficulte == 1)
				{
					if (indice == 1)
					{
						score = score + 1;
						indice = 0;
					}
				}
				// affichage du score:
				if(score < 10)
				{
					SEG7(0,0,score_d,score);
				}
				else if(score >= 10)
				{
					score_d ++;
					score = score - 10;
					SEG7(0,0,score_d,score);
				}
				VGA_SPRITE3(pos_raquette2, value3);
				break;
			case 1:
				/*
				PARTIE I: Déplacement du joueur:
				*/
				mask = VGA_btn();
				// partie 1: raquette1 :
				if ( ((mask & mask_btnU_m)>>13) == 1)
				{
					// U a été pressé: 
					pos --;
					delay(temp);
				}
				else if ( ((mask & mask_btnR_m)>>15) == 1)
				{
					// R pressé
					pos ++;
					delay(temp);
				}
				// blocage de la raquetteà la limite
				if (pos > 400)
				{
					pos = 400;
				}
				else if (pos < 0)
				{
					pos = 0;
				}
				VGA_SPRITE2(pos, value2);
				
				// partie 2: raquette 2:
				if ( ((mask & mask_btnL_m)>>14) == 1)
				{
					// U a été pressé: 
					pos_raquette2 --;
					delay(temp);
				}
				else if ( ((mask & mask_btnD_m)>>12) == 1)
				{
					// R pressé
					pos_raquette2 ++;
					delay(temp);
				}
				if (pos_raquette2 > 400)
				{
					pos_raquette2 = 400;
				}
				else if (pos_raquette2 < 0)
				{
					pos_raquette2 = 0;
				}
				VGA_SPRITE3(pos_raquette2, value3);
				
				/*
					Partie II: la balle:
				*/
				if (mask == 0)
				{
					delay(temp);
				}
				screen_saver(&x,&y,&dx,&dy,&a, difficulte);
				if (( y <= sprite_raquette1_w) && (y > 0))
				{
					if ((x >= pos- sprite_ball_h/2) &&(x <= pos + sprite_raquette1_h + sprite_ball_h/2)) 
					{
						// si on arrive ici , on a bien tapé sur la balle
						dy = 1;
						indice ++;
					}
				}
				else if (y == 0)// cas y ==0
				{
					SEG7(2,2,2,2);
					game = 0;
					score = score_d = 0;
				}
				if (( y >= value3 - sprite_raquette1_w)&& (y < value3))
				{
					if ((x >= pos_raquette2- sprite_ball_h/2) &&(x <= pos_raquette2 + sprite_raquette1_h + sprite_ball_h/2)) 
					{
						// si on arrive ici , on a bien tapé sur la balle
						dy = -1;
					}
				}
				else if (y >= value3)
				{
					SEG7(1,1,1,1);
					game = 0;
					score = score_d = 0;
				}
				if (difficulte == 3)
				{
					if (indice == 3)
					{
						score ++;
						indice = 0;
					}
				}
				else if (difficulte == 5)
				{
					if (indice == 5)
					{
						score ++;
						indice = 0;
					}
				}
				else if (difficulte == 1)
				{
					if (indice == 1)
					{
						score = score + 1;
						indice = 0;
					}
				}
				
				if(score < 10)
				{
					SEG7(0,0,score_d,score);
				}
				else if(score >= 10)
				{
					score_d ++;
					score = score - 10;
					SEG7(0,0,1,score);
				}
				
				VGA_SPRITE(x,y);
				break;
			case 2: 
				while ((scorep1 < 10)&&(scorep2 < 10) )
				{
					/*
						PARTIE I: Déplacement du joueur:
					*/
					mask = VGA_btn();
					// partie 1: raquette1 :
					if ( ((mask & mask_btnU_m)>>13) == 1)
					{
						// U a été pressé: 
						pos --;
						delay(temp);
					}
					else if ( ((mask & mask_btnR_m)>>15) == 1)
					{
						// R pressé
						pos ++;
						delay(temp);
					}
					if (pos > 400)
					{
						pos = 400;
					}
					else if (pos < 0)
					{
						pos = 0;
					}
					VGA_SPRITE2(pos, value2);
					
					// partie 2: raquette 2:
					if ( ((mask & mask_btnL_m)>>14) == 1)
					{
						// U a été pressé: 
						pos_raquette2 --;
						delay(temp);
					}
					else if ( ((mask & mask_btnD_m)>>12) == 1)
					{
						// R pressé
						pos_raquette2 ++;
						delay(temp);
					}
					if (pos_raquette2 > 400)
					{
						pos_raquette2 = 400;
					}
					else if (pos_raquette2 < 0)
					{
						pos_raquette2 = 0;
					}
					VGA_SPRITE3(pos_raquette2, value3);
					
					/*
						Partie II: la balle:
					*/
					if (mask == 0)
					{
						delay(temp);
					}
					screen_saver(&x,&y,&dx,&dy,&a, difficulte);
					if (( y <= sprite_raquette1_w) && (y > 0))
					{
						if ((x >= pos- sprite_ball_h/2) &&(x <= pos + sprite_raquette1_h + sprite_ball_h/2)) 
						{
							// si on arrive ici , on a bien tapé sur la balle
							dy = 1;
						}
					}
					else if (y == 0)// cas y ==0
					{
						delay(100000);
						scorep2 ++;
						x = 220;
						y = 220;
					}
					if (( y >= value3 - sprite_raquette1_w)&& (y < value3))
					{
						if ((x >= pos_raquette2- sprite_ball_h/2) &&(x <= pos_raquette2 + sprite_raquette1_h + sprite_ball_h/2)) 
						{
							// si on arrive ici , on a bien tapé sur la balle
							dy = -1;
						}
					}
					else if (y >= value3)
					{
						delay(100000);
						scorep1 ++;
						x = 220;
						y = 220;
					}
								
					if((scorep1 < 10) && (scorep2 < 10))
					{
						SEG7(0,scorep2,0,scorep1);
					}
					else if(scorep1 == 10)
					{
						SEG7(1,0,0,0);
					}
					else if(scorep2 == 10)
					{
						SEG7(2,0,0,0);
					}
					
					VGA_SPRITE(x,y);
					// premiere balle lente pour s'échauffer
					if ((scorep1 > 0 ) || (scorep2 > 0))
					{
						difficulte = 1;
					}
				}
				game = 3;
				scorep1 = scorep2 = 0;

				break;
			default:
				//nothing;
		}
	}
	
	if (game == 0)
	{
		VGA_SPRITE5 (150,200);
		VGA_SPRITE(out,out);
		VGA_SPRITE3(out, out);
		VGA_SPRITE2(out, out);
		VGA_SPRITE4 (out,out);		
	}
	else if (game == 2)
	{
		VGA_SPRITE5 (150,200);
		VGA_SPRITE(out,out);
		VGA_SPRITE3(out, out);
		VGA_SPRITE2(out, out);
		VGA_SPRITE4 (out,out);
	}
	else if (game == 3)
	{
		VGA_SPRITE5 (150,200);
		VGA_SPRITE(out,out);
		VGA_SPRITE3(out, out);
		VGA_SPRITE2(out, out);
		VGA_SPRITE4 (out,out);
	}
}