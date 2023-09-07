----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 15.03.2020 18:24:32
-- Design Name: 
-- Module Name: mux_7 - Behavioral
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

entity mux_7 is
    Port ( E1 : in STD_LOGIC_VECTOR (3 downto 0);
           E2 : in STD_LOGIC_VECTOR (3 downto 0);
           E3 : in STD_LOGIC_VECTOR (3 downto 0);
           E4 : in STD_LOGIC_VECTOR (3 downto 0);
           cmd : in STD_LOGIC_VECTOR (1 downto 0);
           Eout : out STD_LOGIC_VECTOR (3 downto 0));
end mux_7;

architecture Behavioral of mux_7 is
signal Eout_s: std_logic_vector(3 downto 0);
begin

    gen_mux: process(cmd)
    begin
        case cmd is
            when "00" =>
            Eout_s <= E1;
            when "01" =>
            Eout_s <= E2;
            when "10" =>
            Eout_s <= E3;
            when others =>
            Eout_s <= E4;
        end case;   
    end process;
    
    Eout <= Eout_s;

end Behavioral;
