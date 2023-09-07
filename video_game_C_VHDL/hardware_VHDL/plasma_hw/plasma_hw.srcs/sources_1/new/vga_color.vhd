----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 18.04.2023 09:34:01
-- Design Name: 
-- Module Name: vga_color - Behavioral
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

entity vga_color is
    Port (vgaRed: out std_logic_vector(3 downto 0 );
    vgaGreen: out std_logic_vector(3 downto 0 );
    vgaBlue: out std_logic_vector(3 downto 0 );
    vidon : in std_logic;
    gpio0_out: in std_logic_vector(11 downto 0));
end vga_color;

architecture Behavioral of vga_color is
begin
process(gpio0_out,vidon)
begin 
    if vidon ='1' then
        vgaRed <= gpio0_out(3 downto 0);
        vgaGreen <= gpio0_out(7 downto 4);
        vgaBlue <= gpio0_out(11 downto 8);
    else 
        vgaRed <= (others=>'0');
        vgaGreen <= (others=>'0');
        vgaBlue <= (others=>'0');
    end if;
end process;


end Behavioral;
