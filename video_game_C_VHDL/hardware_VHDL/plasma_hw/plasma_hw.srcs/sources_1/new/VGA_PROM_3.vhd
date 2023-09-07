----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 17.03.2023 17:09:41
-- Design Name: 
-- Module Name: VGA_PROM_3 - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;use IEEE.STD_LOGIC_unsigned.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity VGA_PROM_3 is
  Port ( hc, vc : in std_logic_vector (9 downto 0);
        vidon : in std_logic;
        red, green, blue : out std_logic_vector (3 downto 0);
        rom_addr16, rom_addr16_raquette, rom_addr16_raquette2,rom_addr16_accueil, rom_addr16_gameover: out std_logic_vector(15 downto 0);
        m1,m2,m3,m4,m5 : in std_logic_vector(11 downto 0);
        R1,R2,R3,R4,R5 : in STD_LOGIC_VECTOR (9 downto 0);
        C1,C2,C3,C4,C5 : in STD_LOGIC_VECTOR (9 downto 0));
end VGA_PROM_3;

architecture Behavioral of VGA_PROM_3 is

--porch
constant hbp     : std_logic_vector(9 downto 0)  := "0010010000" ; -- 144
constant vbp     : std_logic_vector(9 downto 0)  := "0000011111" ; -- 31
--sprite dimensions
constant h       : std_logic_vector(9 downto 0)  := "0000011110";  -- hauteur du Sprite
constant w       : std_logic_vector(9 downto 0)  := "0000011110";  -- largeur du sprite

constant h2      :std_logic_vector(9 downto 0)   := "0001100100"; 
constant w2      :std_logic_vector(9 downto 0)   := "0000011110"; 

constant h3      :std_logic_vector(9 downto 0)   := "0001100100"; 
constant w3      :std_logic_vector(9 downto 0)   := "0000011110"; 

constant h4      :std_logic_vector(9 downto 0)   := "0010100000"; --160
constant w4      :std_logic_vector(9 downto 0)   := "0011110000"; --240

constant h5      :std_logic_vector(9 downto 0)   := "0010100000"; --160
constant w5      :std_logic_vector(9 downto 0)   := "0011110000"; --240
-- signal rom_addr  : std_logic_vector(9 downto 0); -- adresse horizontale du sprite
-- signal rom_pix   : std_logic_vector(9 downto 0); -- verticale
signal spriteon  : std_logic;
signal spriteon_raquette : std_logic;
signal spriteon_raquette2 : std_logic;
signal spriteon_accueil : std_logic;
signal spriteon_gameover : std_logic;
-- signal R,G,B     : std_logic; --en fonction de data dans la prom

constant addr_c  : std_logic_vector(9 downto 0) := R1 ; -- 80; -- adresse horizontale du sprite
constant pix_c   : std_logic_vector(9 downto 0) := C1; -- 80; -- verticale

signal  xpix     : std_logic_vector(15 downto 0) ;  -- adresse horizontale du sprite
signal  ypix     : std_logic_vector(15 downto 0) ;  -- verticale

constant addr_c2  : std_logic_vector(9 downto 0) := R2 ; -- 80; -- adresse horizontale du sprite
constant pix_c2   : std_logic_vector(9 downto 0) := C2; -- 80; -- verticale

signal  xpix_raquette     : std_logic_vector(15 downto 0) ;  -- adresse horizontale du sprite
signal  ypix_raquette     : std_logic_vector(15 downto 0) ;  -- verticale

constant addr_c3  : std_logic_vector(9 downto 0) := R3 ; -- 80; -- adresse horizontale du sprite
constant pix_c3   : std_logic_vector(9 downto 0) := C3; -- 80; -- verticale

signal  xpix_raquette2     : std_logic_vector(15 downto 0) ;  -- adresse horizontale du sprite
signal  ypix_raquette2     : std_logic_vector(15 downto 0) ;  -- verticale

constant addr_c4  : std_logic_vector(9 downto 0) := R4 ; -- 80; -- adresse horizontale du sprite
constant pix_c4   : std_logic_vector(9 downto 0) := C4; -- 80; -- verticale

signal  xpix_accueil     : std_logic_vector(15 downto 0) ;  -- adresse horizontale du sprite
signal  ypix_accueil     : std_logic_vector(15 downto 0) ;  -- verticale

constant addr_c5  : std_logic_vector(9 downto 0) := R5 ; -- 80; -- adresse horizontale du sprite
constant pix_c5   : std_logic_vector(9 downto 0) := C5; -- 80; -- verticale

signal  xpix_gameover     : std_logic_vector(15 downto 0) ;  -- adresse horizontale du sprite
signal  ypix_gameover     : std_logic_vector(15 downto 0) ;  -- verticale

signal tmp1,tmp2, tmp3, tmp4 : std_logic_vector(15 downto 0) ; --utilisé pour la multiplication 
signal rom_addr16sig: std_logic_vector(25 downto 0);
signal rom_addr16sig_raquette: std_logic_vector(25 downto 0);
signal rom_addr16sig_raquette2: std_logic_vector(25 downto 0);
signal rom_addr16sig_accueil: std_logic_vector(25 downto 0);
signal rom_addr16sig_gameover: std_logic_vector(25 downto 0);
begin
-----------------------------------------------------------------------------------------------------
process(hc,vc,R1,C1)
begin
    ypix <= "000000" & (vc - (vbp + addr_c)) ; 
    
    xpix <= "000000" & (hc - (hbp + pix_c));
    
if (((hc >=hbp+pix_c) and (hc<=hbp+pix_c+w)) and ((vc>= vbp+addr_c) and(vc<=vbp+addr_c+h))) then 
spriteon <= '1';
else spriteon <= '0';
end if;

end process;
-----------------------------------------------------------------------------------------------------
process(hc,vc,R2,C2)
begin
    ypix_raquette <= "000000" & (vc - (vbp + addr_c2)) ; 
    
    xpix_raquette <= "000000" & (hc - (hbp + pix_c2));
    
if (((hc >=hbp+pix_c2) and (hc<=hbp+pix_c2+w2)) and ((vc>= vbp+addr_c2) and(vc<=vbp+addr_c2+h2))) then 
spriteon_raquette <= '1';
else spriteon_raquette <= '0';
end if;

end process;

process(hc,vc,R3,C3)
begin
    ypix_raquette2 <= "000000" & (vc - (vbp + addr_c3)) ; 
    
    xpix_raquette2 <= "000000" & (hc - (hbp + pix_c3));
    
if (((hc >=hbp+pix_c3) and (hc<=hbp+pix_c3+w3)) and ((vc>= vbp+addr_c3) and(vc<=vbp+addr_c3+h3))) then 
spriteon_raquette2 <= '1';
else spriteon_raquette2 <= '0';
end if;

end process;

process(hc,vc,R4,C4)
begin
    ypix_accueil <= "000000" & (vc - (vbp + addr_c4)) ; 
    
    xpix_accueil <= "000000" & (hc - (hbp + pix_c4));
    
if (((hc >=hbp+pix_c4) and (hc<=hbp+pix_c4+w4)) and ((vc>= vbp+addr_c4) and(vc<=vbp+addr_c4+h4))) then 
spriteon_accueil <= '1';
else spriteon_accueil <= '0';
end if;

end process;

process(hc,vc,R5,C5)
begin
    ypix_gameover <= "000000" & (vc - (vbp + addr_c5)) ; 
    
    xpix_gameover <= "000000" & (hc - (hbp + pix_c5));
    
if (((hc >=hbp+pix_c5) and (hc<=hbp+pix_c5+w5)) and ((vc>= vbp+addr_c5) and(vc<=vbp+addr_c5+h5))) then 
spriteon_gameover <= '1';
else spriteon_gameover <= '0';
end if;

end process;

process(xpix,ypix)
begin

rom_addr16sig <= ypix*w+xpix;
end process;
rom_addr16 <= rom_addr16sig(15 downto 0);

process(xpix_raquette,ypix_raquette)
begin

rom_addr16sig_raquette <= ypix_raquette*w2+xpix_raquette;
end process;
rom_addr16_raquette <= rom_addr16sig_raquette(15 downto 0);


process(xpix_raquette2,ypix_raquette2)
begin

rom_addr16sig_raquette2 <= ypix_raquette2*w3+xpix_raquette2;
end process;
rom_addr16_raquette2 <= rom_addr16sig_raquette2(15 downto 0);
-----------------------------------------------------------------------------------------------------


process(xpix_accueil,ypix_accueil)
begin

rom_addr16sig_accueil <= ypix_accueil*w4 + xpix_accueil;
end process;
rom_addr16_accueil <= rom_addr16sig_accueil(15 downto 0);


process(xpix_gameover,ypix_gameover)
begin

rom_addr16sig_gameover <= ypix_gameover*w5 + xpix_gameover;
end process;
rom_addr16_gameover <= rom_addr16sig_gameover(15 downto 0);



process(hc, vc,R1,C1,R2,C2,C3,R3,C4,R4,C5, R5)
--variable j: integer;
begin
if ((spriteon = '1') and (vidon = '1')) then

    if ((M1(11 downto 8) = "1111") and (M1(7 downto 4) = "1111" )and (M1(3 downto 0) = "1111" )) then
        red   <= "0000";
        green <= "0000";
        blue  <= "0000";
    else
        red   <= M1(11 downto 8);
        green <= M1(7 downto 4);
        blue  <= M1(3 downto 0);
    end if;
elsif ((spriteon_raquette = '1') and (vidon = '1')) then
   
    red   <= M2(11 downto 8);
    green <= M2(7 downto 4);
    blue  <= M2(3 downto 0);
elsif ((spriteon_raquette2 = '1') and (vidon = '1')) then
   
    red   <= M3(11 downto 8);
    green <= M3(7 downto 4);
    blue  <= M3(3 downto 0);
elsif ((spriteon_accueil = '1') and (vidon = '1')) then
   
    red   <= M4(11 downto 8);
    green <= M4(7 downto 4);
    blue  <= M4(3 downto 0);
elsif ((spriteon_gameover = '1') and (vidon = '1')) then
   
    red   <= M5(11 downto 8);
    green <= M5(7 downto 4);
    blue  <= M5(3 downto 0);
 else
    red   <= "0000";
    green <= "0000";
    blue  <= "0000";
end if;
end process;

end Behavioral;
