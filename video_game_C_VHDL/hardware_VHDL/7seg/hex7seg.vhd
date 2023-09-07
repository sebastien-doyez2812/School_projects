----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 15.03.2020 18:37:48
-- Design Name: 
-- Module Name: hex7seg - Behavioral
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

entity hex7seg is
  port(
    hex: in std_logic_vector(3 downto 0);
    a_to_g: out std_logic_vector(6 downto 0));
end hex7seg;

architecture archi of hex7seg is
begin
  process (hex)
    begin
      case hex is
      when x"0" => a_to_g <="1000000"; -- 0 -- NB: O = ON , 1 = OFF
      when x"1" => a_to_g <="1111001"; -- 1
      when x"2" => a_to_g <="0100100"; -- 2
      when x"3" => a_to_g <="0110000"; -- 3 
      when x"4" => a_to_g <="0011001";-- 4
      when x"5" => a_to_g <="0010010"; -- 5
      when x"6" => a_to_g <="0000010"; -- 6 
      when x"7" => a_to_g <="1011000"; -- 7
      when x"8" => a_to_g <="0000000"; -- 8
      when x"9" => a_to_g <="0010000"; -- 9
      when x"A" => a_to_g <="0001000"; -- A
      when x"B" => a_to_g <="0000011"; -- b
      when x"C" => a_to_g <="1000110"; -- C
      when x"D" => a_to_g <="0100001"; -- d
      when x"E" => a_to_g <="0000110"; -- E
      when others => a_to_g <="0001110"; -- F
    end case;    
  end process;

end archi;  
