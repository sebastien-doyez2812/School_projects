----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 03.03.2023 13:50:40
-- Design Name: 
-- Module Name: VGA_PROM_coe - Behavioral
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

entity VGA_PROM_coe is
  Port ( hc, vc : in std_logic_vector (9 downto 0);
        sw : in std_logic_vector (7 downto 0);
        vidon : in std_logic;
        red, green, blue : out std_logic_vector (3 downto 0);
        rom_addr16 : out std_logic_vector(15 downto 0);
        m : in std_logic_vector(11 downto 0));
end VGA_PROM_coe;

architecture Behavioral of VGA_PROM_coe is

--porch
constant hbp     : std_logic_vector(9 downto 0)  := "0010010000" ; -- 144
constant vbp     : std_logic_vector(9 downto 0)  := "0000011111" ; -- 31
--sprite dimensions
constant h       : std_logic_vector(9 downto 0)  := "0010100000" ; -- 160  -- hauteur du Sprite
constant w       : std_logic_vector(9 downto 0)  := "0011110000" ; -- 240  -- largeur du sprite

-- signal rom_addr  : std_logic_vector(9 downto 0); -- adresse horizontale du sprite
-- signal rom_pix   : std_logic_vector(9 downto 0); -- verticale
signal spriteon  : std_logic;
-- signal R,G,B     : std_logic; --en fonction de data dans la prom

constant addr_c  : std_logic_vector(3 downto 0) := sw(3 downto 0) ; -- 80; -- adresse horizontale du sprite
constant pix_c   : std_logic_vector(3 downto 0) := sw(7 downto 4); -- 80; -- verticale

signal  xpix     : std_logic_vector(15 downto 0) ;  -- adresse horizontale du sprite
signal  ypix     : std_logic_vector(15 downto 0) ;  -- verticale

signal tmp1,tmp2, tmp3, tmp4 : std_logic_vector(15 downto 0) ; --utilisé pour la multiplication 

begin
-----------------------------------------------------------------------------------------------------
process(hc,vc,sw)
begin
    ypix <= "000000" & (vc - (vbp + addr_c)) ; 
    
    xpix <= "000000" & (hc - (hbp + pix_c));
    


if (((hc >=hbp+pix_c) and (hc<=hbp+pix_c+w)) and ((vc>= vbp+addr_c) and(vc<=vbp+addr_c+h))) then 
spriteon <= '1';
else spriteon <= '0';
end if;

end process;
-----------------------------------------------------------------------------------------------------

process(xpix,ypix)
begin

-- rom_addr16 <= ypix*240 + xpix;
-- rom_addr16 <= ypix*(128+64+32+16) + xpix;

--tmp1 <= ypix;
--rom_addr16 <= ypix(8 downto 0)&"0000000" + ypix(9 downto 0)&"000000" + ypix(10 downto 0)&"00000" + ypix(11 downto 0)&"0000" + xpix;

tmp1 <= ypix(8 downto 0)&"0000000";
tmp2 <= tmp1 + (ypix(9 downto 0)&"000000");
tmp3 <= tmp2 + (ypix(10 downto 0)&"00000");
tmp4 <= tmp3 + (ypix(11 downto 0)&"0000" );
rom_addr16 <= tmp4 + xpix;

end process;
-----------------------------------------------------------------------------------------------------
process(hc, vc,sw)
--variable j: integer;
begin
if ((spriteon = '1') and (vidon = '1')) then
    -- on determine notre position
    -- j :=conv_integer(rom_pix);
    -- on affecte les bonnes couleurs
--    R <= M(j); -- 1 ou 0 selon le dessin
--    G <= M(j);
--    B <= M(j);
    red   <= M(11 downto 8);
    green <= M(7 downto 4);
    blue  <= M(3 downto 0);
 else
    red   <= "0000";
    green <= "0000";
    blue  <= "0000";
end if;
end process;

end Behavioral;
