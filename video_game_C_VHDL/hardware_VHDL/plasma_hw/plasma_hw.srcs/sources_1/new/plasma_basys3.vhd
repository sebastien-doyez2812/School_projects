library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity plasma_basys3 is
   port(clk          : in std_logic;
       -- reset        : in std_logic;

        -- ajout: 
        RsRx: in std_logic;
        RsTx: out std_logic;
        led: out std_logic_vector(7 downto 0);
        btnR, btnL, btnU, btnD, btnC: in std_logic;
        sw: in std_logic_vector(11 downto 0 );
        Vsync, Hsync: out std_logic;
        vgaRed, vgaGreen, vgaBlue: out std_logic_vector (3 downto 0);
        seg: out std_logic_vector(6 downto 0);
        an:out std_logic_vector(3 downto 0);
        dp: out std_logic
        );
end; --entity plasma

architecture Behavioral of plasma_basys3 is
component plasma is
   generic(memory_type : string := "XILINX_16X"; --"DUAL_PORT_" "ALTERA_LPM";
           log_file    : string := "UNUSED";
           ethernet    : std_logic := '0';
           use_cache   : std_logic := '0');
   port(clk          : in std_logic;
        reset        : in std_logic;
                
        uart_write   : out std_logic;
        uart_read    : in std_logic;

        address      : out std_logic_vector(31 downto 2);
        byte_we      : out std_logic_vector(3 downto 0); 
        data_write   : out std_logic_vector(31 downto 0);
        data_read    : in std_logic_vector(31 downto 0);
        mem_pause_in : in std_logic;
        no_ddr_start : out std_logic;
        no_ddr_stop  : out std_logic;
        
        gpio0_out    : out std_logic_vector(31 downto 0);
        gpio1_out    : out std_logic_vector(31 downto 0);
        gpio2_out    : out std_logic_vector(31 downto 0);
        gpio3_out    : out std_logic_vector(31 downto 0);
        gpio4_out    :out std_logic_vector(31 downto 0);
        gpioA_in     : in std_logic_vector(31 downto 0));
end component; --entity plasma

component clk25 is
    Port ( rst : in STD_LOGIC;
           mclk : in STD_LOGIC;
           clk50 : out STD_LOGIC);
end component;

component top_7seg is
    Port ( rst : in STD_LOGIC;
           clk : in STD_LOGIC;
           e1 : in STD_LOGIC_VECTOR (3 downto 0);
           e2 : in STD_LOGIC_VECTOR (3 downto 0);
           e3 : in STD_LOGIC_VECTOR (3 downto 0);
           e4 : in STD_LOGIC_VECTOR (3 downto 0);
           seg : out STD_LOGIC_VECTOR (6 downto 0);
           an : out STD_LOGIC_VECTOR (3 downto 0);
           dp : out STD_LOGIC);
end component;

component VGA_PROM_3 is
    Port ( hc, vc : in std_logic_vector (9 downto 0);
        vidon : in std_logic;
        red, green, blue : out std_logic_vector (3 downto 0);
        rom_addr16, rom_addr16_raquette, rom_addr16_raquette2,rom_addr16_accueil, rom_addr16_gameover: out std_logic_vector(15 downto 0);
        m1,m2,m3,m4,m5 : in std_logic_vector(11 downto 0);
        R1,R2,R3,R4,R5 : in STD_LOGIC_VECTOR (9 downto 0);
        C1,C2,C3,C4,C5 : in STD_LOGIC_VECTOR (9 downto 0));
end component;

component RAM_PROGRAM
    Port(
        addra: in std_logic_vector(11 downto 0);
        clka: in std_logic;
        clkb: in std_logic;
        dina: in std_logic_vector(31 downto 0);
        wea : in std_logic_vector(3 downto 0 );
        addrb: in std_logic_vector (11 downto 0);
        doutb: out std_logic_vector(31 downto 0)
        );
end component;

component VGA_640x480
  Port ( clk25M, rst : in std_logic;
            hsync, vsync : out std_logic;  -- signaux de synchronisations
            hc : out std_logic_vector( 9 downto 0); -- renvoie le numéro de pixel sur la ligne courante
            vc : out std_logic_vector( 9 downto 0); -- renvoie le numéro de la ligne courante
            vidon : out std_logic);
end component;


component vga_color is
    Port (vgaRed: out std_logic_vector(3 downto 0 );
    vgaGreen: out std_logic_vector(3 downto 0 );
    vgaBlue: out std_logic_vector(3 downto 0 );
    vidon : in std_logic;
    gpio0_out: in std_logic_vector(11 downto 0));
end component;

component sprite_balle is
Port (    clka : in std_logic;
            addra : in STD_LOGIC_VECTOR (9 downto 0); -- adresse sur 12 bits
            douta : out STD_LOGIC_VECTOR (11 downto 0));    -- mots de 12 bits
end component;

component sprite_raquette is
Port (    clka : in std_logic;
            addra : in STD_LOGIC_VECTOR (11 downto 0); -- adresse sur 12 bits
            douta : out STD_LOGIC_VECTOR (11 downto 0));    -- mots de 12 bits
end component;

component sprite_accueil is
Port (    clka : in std_logic;
            addra : in STD_LOGIC_VECTOR (15 downto 0); -- adresse sur 12 bits
            douta : out STD_LOGIC_VECTOR (11 downto 0));    -- mots de 12 bits
end component;

component sprite_gameover is
Port (    clka : in std_logic;
            addra : in STD_LOGIC_VECTOR (15 downto 0); -- adresse sur 12 bits
            douta : out STD_LOGIC_VECTOR (11 downto 0));    -- mots de 12 bits
end component;


signal clk_50: std_logic;
signal uart_w_s, uart_r_s : std_logic;
signal address_s : std_logic_vector(31 downto 2);
signal byte_we_s: std_logic_vector(3 downto 0); 
signal data_write_s:  std_logic_vector(31 downto 0);
signal data_read_s:  std_logic_vector(31 downto 0);
signal mem_pause_in :  std_logic;
signal no_ddr_start :  std_logic;
signal no_ddr_stop  :  std_logic;
signal gpio0_out_s: std_logic_vector(31 downto 0);
signal gpio1_out_s: std_logic_vector(31 downto 0);
signal gpio2_out_s: std_logic_vector(31 downto 0);
signal gpio3_out_s: std_logic_vector(31 downto 0);
signal gpio4_out_s: std_logic_vector(31 downto 0);
signal HC_s, VC_s : std_logic_vector( 9 downto 0);
signal vidon_s : std_logic ;
signal m1:  std_logic_vector(11 downto 0);
signal m2, m3,m4, m5:  std_logic_vector(11 downto 0);
signal addr:  std_logic_vector(15 downto 0);
signal addr2:  std_logic_vector(15 downto 0);
signal addr3:  std_logic_vector(15 downto 0);
signal addr4:  std_logic_vector(15 downto 0);
signal addr5:  std_logic_vector(15 downto 0);
begin
  


inst1: plasma port map( clk => clk_50 , reset => btnC ,uart_write =>  RsTx, uart_read => RsRx, gpio0_out => gpio0_out_s, gpio1_out => gpio1_out_s, gpio2_out => gpio2_out_s,gpio3_out => gpio3_out_s,gpio4_out => gpio4_out_s,gpioA_in(15) => btnR ,  gpioA_in(14) => btnL, gpioA_in(13) => btnU,  gpioA_in(12) =>btnD,  gpioA_in(11 downto 0) =>  sw(11 downto 0), gpioA_in(31 downto 16)=> (others => '0'), address => address_s, byte_we=> byte_we_s, data_write=> data_write_s, data_read=> data_read_s, mem_pause_in => mem_pause_in, no_ddr_start=> no_ddr_start, no_ddr_stop=> no_ddr_stop );
inst2 : clk25 port map (mclk => clk, clk50 => clk_50, rst=> btnC);
ints3: RAM_PROGRAM port map( addra => address_s(13 downto 2), addrb => address_s(13 downto 2), clka => clk, clkb => clk, dina => data_write_s, doutb => data_read_s, wea => byte_we_s);
inst4 : VGA_640x480 port map (clk25M => clk_50, rst => btnC, hsync => Hsync, vsync => Vsync , hc => HC_s,vc=> VC_s, vidon=> vidon_s);
inst6: VGA_PROM_3 port map(hc => HC_s, vc=> VC_s,vidon => vidon_s, red=> vgaRed,  green => vgaGreen, blue => vgaBlue,rom_addr16(15 downto 0)=>addr,rom_addr16_raquette(15 downto 0) =>addr2,rom_addr16_raquette2(15 downto 0) => addr3, rom_addr16_accueil(15 downto 0) => addr4,rom_addr16_gameover(15 downto 0) =>addr5,m1=> m1,m2 =>m2,m3=> m3, m4=> m4, m5 => m5, R1=>gpio1_out_s(9 downto 0), C1=> gpio1_out_s(19 downto 10), R2=>gpio2_out_s(9 downto 0), C2=> gpio2_out_s(19 downto 10), R3=>gpio3_out_s(9 downto 0), C3=> gpio3_out_s(19 downto 10), R4=>gpio4_out_s(9 downto 0), C4=> gpio4_out_s(19 downto 10), R5=>gpio1_out_s(29 downto 20), C5=> gpio2_out_s(29 downto 20));
-- les sprites:
inst7: sprite_balle port map(clka => clk, addra => addr(9 downto 0), douta => m1);
inst8: sprite_raquette port map(clka => clk, addra => addr2(11 downto 0), douta => m2);
inst9: sprite_raquette port map(clka => clk, addra => addr3(11 downto 0), douta => m3);
inst10: sprite_accueil port map(clka => clk, addra => addr4(15 downto 0), douta => m4);
inst11: top_7seg port map (rst => btnC, clk => clk, e1=> gpio0_out_s(19 downto 16), e2 => gpio0_out_s(23 downto 20), e3 => gpio0_out_s(27 downto 24),e4 => gpio0_out_s(31 downto 28), seg => seg,an =>an,dp=> dp);
inst12: sprite_gameover port map(clka => clk, addra => addr5(15 downto 0), douta => m5);

led <= gpio0_out_s(7 downto 0 );

end Behavioral;
