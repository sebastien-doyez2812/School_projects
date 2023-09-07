----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 15.03.2020 17:44:19
-- Design Name: 
-- Module Name: cpt - Behavioral
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

entity cpt is
    Port ( clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           output : out STD_LOGIC_VECTOR (1 downto 0));
end cpt;

architecture Behavioral of cpt is
signal count: std_logic_vector(1 downto 0);
begin

    gen_count: process(clk, rst)
    begin
        if rst='1' then count <= "00";
        elsif rising_edge(clk) then 
            count <= count + 1;
        end if;
    end process;
    
    output <= count;

end Behavioral;
