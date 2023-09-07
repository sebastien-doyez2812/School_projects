----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 15.03.2020 18:04:36
-- Design Name: 
-- Module Name: gestion_an - Behavioral
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

entity gestion_an is
    Port ( cpt_in : in STD_LOGIC_VECTOR (1 downto 0);
           rst : in STD_LOGIC;
           an : out STD_LOGIC_VECTOR (3 downto 0));
end gestion_an;

architecture Behavioral of gestion_an is
signal an_s: std_logic_vector(3 downto 0);
begin

    gen_an: process(cpt_in, rst)
    begin
        if rst='1' then an_s <= "1111";
        else
            case cpt_in is
                when "00" =>
                an_s <= "1110";
                when "01" =>
                an_s <= "1101";
                when "10" =>
                an_s <= "1011";
                when others =>
                an_s <= "0111";
            end case;   
        end if;
    end process;
    
    an <= an_s;

end Behavioral;
