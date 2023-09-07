

----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 28.02.2023 14:18:34
-- Design Name: 
-- Module Name: TOP_VGA_PROM_switches - Behavioral
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
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity TOP_VGA_PROM_2_COE is
  Port ( clk : in std_logic;
        sw : in std_logic_vector(7 downto 0);
        btnR : in std_logic;
        vgaRed, vgaBlue, vgaGreen : out std_logic_vector (3 downto 0);
        Hsync, Vsync : out std_logic );
end TOP_VGA_PROM_2_COE;

architecture Behavioral of TOP_VGA_PROM_2_COE is

component clk25 is
    Port ( rst : in STD_LOGIC;
           mclk : in STD_LOGIC;
           clk50 : out STD_LOGIC);
end component;

signal clk25_s : std_logic;

component VGA_640x480
     Port ( clk25M, rst : in std_logic;
            hsync, vsync : out std_logic;
            hc : out std_logic_vector( 9 downto 0); -- renvoie le numéro de pixel sur la ligne courante
            vc : out std_logic_vector( 9 downto 0); -- renvoie le numéro de la ligne courante
            vidon : out std_logic);
end component;

signal vcs, hcs : std_logic_vector(9 downto 0);
signal vidons : std_logic;

component VGA_PROM_coe
  Port ( hc, vc : in std_logic_vector (9 downto 0);
        sw : in std_logic_vector (7 downto 0);
        vidon : in std_logic;
        red, green, blue : out std_logic_vector (3 downto 0);
        rom_addr16 : out std_logic_vector(15 downto 0);
        m : in std_logic_vector(11 downto 0));
end component;

signal rom_addr16 : std_logic_vector(15 downto 0);
signal m : std_logic_vector(11 downto 0);

component sprite_rom
  Port (    clka : in std_logic;
            addra : in STD_LOGIC_VECTOR (15 downto 0); -- adresse sur 16 bits
            douta : out STD_LOGIC_VECTOR (11 downto 0));    -- mots de 12 bits
end component;

begin

div : clk25 port map (rst => btnR, mclk => clk, clk50 => clk25_s);
VGA : VGA_640x480 port map (clk25M => clk25_s, rst=>btnR, hsync => Hsync, vsync => Vsync, hc => hcs , vc => vcs , vidon => vidons);
vgaa_Prom : VGA_PROM_coe port map ( hc => hcs, vc=>vcs , vidon=>vidons, red=>vgaRed, green=>vgaGreen, blue=>vgaBlue, rom_addr16 =>rom_addr16, M => m, sw => sw);
coe : sprite_rom port map (clka => clk ,addra =>rom_addr16, douta => m);



end Behavioral;


