library IEEE;
use IEEE.STD_LOGIC_1164.ALL;use IEEE.STD_LOGIC_unsigned.ALL;


entity VGA_640x480 is 
     Port ( clk25M, rst : in std_logic;
            hsync, vsync : out std_logic;  -- signaux de synchronisations
            hc : out std_logic_vector( 9 downto 0); -- renvoie le numéro de pixel sur la ligne courante
            vc : out std_logic_vector( 9 downto 0); -- renvoie le numéro de la ligne courante
            vidon : out std_logic);
end VGA_640x480;

architecture Behavioral of VGA_640x480 is
 
constant hbp     : std_logic_vector(9 downto 0)  := "0010010000" ; -- 144
constant hfp     : std_logic_vector(9 downto 0)  := "1100010000" ; -- 784
constant hpixels : std_logic_vector(9 downto 0)  := "1100100000" ; -- 800
constant vbp     : std_logic_vector(9 downto 0)  := "0000011111" ; -- 31
constant vfp     : std_logic_vector(9 downto 0)  := "0111111111" ; -- 511
constant vlines  : std_logic_vector(9 downto 0)  := "1000001001" ; -- 521

signal hc_sig : std_logic_vector (9 downto 0);
signal vc_sig : std_logic_vector (9 downto 0);
signal vsenable : std_logic;
    
begin
-----------------------------------------------------------
comptage_horizontal : process (rst, clk25M)
begin
    if rst='1' then
        hc_sig <= (others=>'0');
    elsif clk25M'event and clk25M='1' then
        if hc_sig = hpixels - 1 then
            hc_sig <= (others=>'0');
            else
                hc_sig <= hc_sig + 1; 
        end  if;
    end if;          
end process;
------------------------------------------------------
process(hc_sig)
begin
if hc_sig = hpixels - 1 then
               
                     vsenable <= '1';
                else
                    vsenable <= '0';
end if;
end process;
--------------------------------------------------------------
comptage_vertical : process(clk25M, rst, vsenable)
begin
if rst='1' then vc_sig <= (others => '0');
    elsif clk25M'event and clk25M='1' then
        if vsenable = '1' then
            if vc_sig = vlines -1 then
                vc_sig <= (others => '0');
            else
                vc_sig <= vc_sig + 1;
            end if;
        end if;
end if;
end process;

----------------------------------------------------------
hsync <= '0' when hc_sig < 96 else '1';
vsync <= '0' when vc_sig < 2 else '1';

vidon <= '1' when ( ((hc_sig < hfp) and (hc_sig >= hbp) ) and ((vc_sig < vfp) and vc_sig >= vbp))  else '0';

hc <= hc_sig; 
vc <= vc_sig;

end Behavioral;