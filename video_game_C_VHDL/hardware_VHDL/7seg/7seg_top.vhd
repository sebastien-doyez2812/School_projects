----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 15.03.2020 18:47:31
-- Design Name: 
-- Module Name: 7seg_top - Behavioral
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


library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity top_7seg is
    Port ( rst : in STD_LOGIC;
           clk : in STD_LOGIC;
           e1 : in STD_LOGIC_VECTOR (3 downto 0);
           e2 : in STD_LOGIC_VECTOR (3 downto 0);
           e3 : in STD_LOGIC_VECTOR (3 downto 0);
           e4 : in STD_LOGIC_VECTOR (3 downto 0);
           seg : out STD_LOGIC_VECTOR (6 downto 0);
           an : out STD_LOGIC_VECTOR (3 downto 0);
           dp : out STD_LOGIC);
end top_7seg;

architecture Behavioral of top_7seg is

component clk50
    Port ( rst : in STD_LOGIC;
           mclk : in STD_LOGIC;
           clk50 : out STD_LOGIC);
end component;

component clk190
    Port ( rst : in STD_LOGIC;
           clk50 : in STD_LOGIC;
           clk190 : out STD_LOGIC);
end component;

component cpt
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           output : out STD_LOGIC_VECTOR (1 downto 0));
end component;

component gestion_an
    Port ( cpt_in : in STD_LOGIC_VECTOR (1 downto 0);
           rst : in STD_LOGIC;
           an : out STD_LOGIC_VECTOR (3 downto 0));
end component;

component mux_7
    Port ( E1 : in STD_LOGIC_VECTOR (3 downto 0);
           E2 : in STD_LOGIC_VECTOR (3 downto 0);
           E3 : in STD_LOGIC_VECTOR (3 downto 0);
           E4 : in STD_LOGIC_VECTOR (3 downto 0);
           cmd : in STD_LOGIC_VECTOR (1 downto 0);
           Eout : out STD_LOGIC_VECTOR (3 downto 0));
end component;

component hex7seg
    port(
      hex: in std_logic_vector(3 downto 0);
      a_to_g: out std_logic_vector(6 downto 0));
end component;

signal CLK50_s          : std_logic;
signal CLK190_s         : std_logic;
signal OUTPUT_s         : std_logic_vector (1 downto 0);
signal E_s              : std_logic_vector (3 downto 0);

begin

    clk_div1: clk50
    port map (
        rst     =>  rst,
        mclk    =>  clk, 
        clk50   =>  CLK50_s
    );

    clk_div2: clk190
    port map (
        rst     =>  rst,
        clk50    =>  CLK50_s, 
        clk190   =>  CLK190_s
    );

    compteur: cpt
    port map (
        clk     =>  CLK190_s,
        rst     =>  rst, 
        output   =>  OUTPUT_s
    );

    gestion: gestion_an
    port map (
        cpt_in      =>  OUTPUT_s,
        rst         =>  rst, 
        an          =>  an
    );

    mux: mux_7
    port map (
        E1      =>  e1,
        E2      =>  e2,
        E3      =>  e3,
        E4      =>  e4,
        cmd     =>  OUTPUT_s, 
        Eout    =>  E_s
    );

    hex7: hex7seg
    port map (
        hex      =>  E_s, 
        a_to_g   =>  seg
    );

    dp <= '1';

end Behavioral;
