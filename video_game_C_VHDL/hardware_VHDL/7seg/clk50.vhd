----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 27.02.2020 17:08:36
-- Design Name: 
-- Module Name: clk50 - Behavioral
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

entity clk50 is
    Port ( rst : in STD_LOGIC;
           mclk : in STD_LOGIC;
           clk50 : out STD_LOGIC);
end clk50;

architecture Behavioral of clk50 is
signal count: std_logic_vector(1 downto 0);
begin

gen_clk50: process(mclk, rst)
begin
    if rst='1' then count <= "00";
    elsif rising_edge(mclk) then 
        count <= count + 1;
    end if;
end process;

clk50 <= count(0);

end Behavioral;
