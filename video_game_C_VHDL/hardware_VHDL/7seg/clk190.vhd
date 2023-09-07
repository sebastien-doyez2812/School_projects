----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 27.02.2020 17:08:36
-- Design Name: 
-- Module Name: clk190 - Behavioral
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

entity clk190 is
    Port ( rst : in STD_LOGIC;
           clk50 : in STD_LOGIC;
           clk190 : out STD_LOGIC);
end clk190;

architecture Behavioral of clk190 is
signal count: std_logic_vector(17 downto 0);
begin

gen_clk190: process(clk50, rst)
begin
    if rst='1' then count <= "000000000000000000";
    elsif rising_edge(clk50) then 
        count <= count + 1;
    end if;
end process;

clk190 <= count(17);

end Behavioral;
