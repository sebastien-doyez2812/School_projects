---------------------------------------------------------------------
-- TITLE: Random Access Memory for Xilinx
-- AUTHOR: Steve Rhoads (rhoadss@yahoo.com)
-- DATE CREATED: 11/06/05
-- FILENAME: ram_xilinx.vhd
-- PROJECT: Plasma CPU core
-- COPYRIGHT: Software placed into the public domain by the author.
--    Software 'as is' without warranty.  Author liable for nothing.
-- DESCRIPTION:
--    Implements the RAM for Spartan 3 Xilinx FPGA
--
--    Compile the MIPS C and assembly code into "test.axf".
--    Run convert.exe to change "test.axf" to "code.txt" which
--    will contain the hex values of the opcodes.
--    Next run "ram_image ram_xilinx.vhd code.txt ram_image.vhd",
--    to create the "ram_image.vhd" file that will have the opcodes
--    correctly placed inside the INIT_00 => strings.
--    Then include ram_image.vhd in the simulation/synthesis.
---------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
use work.mlite_pack.all;
library UNISIM;
use UNISIM.vcomponents.all;

entity ram is
   generic(memory_type : string := "DEFAULT");
   port(clk               : in std_logic;
        enable            : in std_logic;
        write_byte_enable : in std_logic_vector(3 downto 0);
        address           : in std_logic_vector(31 downto 2);
        data_write        : in std_logic_vector(31 downto 0);
        data_read         : out std_logic_vector(31 downto 0));
end; --entity ram

architecture logic of ram is
begin

   RAMB16_S9_inst0 : RAMB16_S9
   generic map (
INIT_00 => X"afafafafafafafafafafafafafafafaf2308000c241400ac273c243c243c273c",
INIT_01 => X"8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f8f230c008c8c3caf00af00af2340afaf",
INIT_02 => X"acacacac0003373cac038cac8cac8cac8c243c40034040033423038f038f8f8f",
INIT_03 => X"000300ac0300000034038c8c8c8c8c8c8c8c8c8c8c8c3403acacacacacacacac",
INIT_04 => X"30008c241430008c24ac0094ac2400183c000003241ca424248cac1824003c00",
INIT_05 => X"2410001028300024a0243c0003001030008cac24ac24003c000003001c240010",
INIT_06 => X"1026102c260214002c3a2c3a00000c240200afafafafaf2724033c000424a024",
INIT_07 => X"00142a0000260c0010240c26240c240c001a001600261000102c261026102c00",
INIT_08 => X"240c3c240c3c240c3caf0cafafafafafafafaf2727038f8f8f028f8f240c240c",
INIT_09 => X"3c3c003c3c0c003c240c3c3c1430248c3c1030008c343cac243c240c3c240c3c",
INIT_0A => X"240c3c240c3c240c3c240c3c240c3c240c3c240c3c240c3c240c3c240c3c3c3c",
INIT_0B => X"0c000c020c240c3c00000c240c3c020c26102c2600000c240c3c240c3c240c3c",
INIT_0C => X"000c000c923c10ae000c020c00000c260c02108e0000008c0000243c102c2626",
INIT_0D => X"1402260c90023c1200000c260c3c100002a210000c020c00000c260c3c10260c",
INIT_0E => X"0202269002021200000c260c00103c140226a002000c3c1200000c260c3c1002",
INIT_0F => X"321402240c000c260c8c02260c0214321200000c260c3c10240c000c020c0214",
INIT_10 => X"2a14000c00a002363c003c3c103c0c003c000c0014343c000c240c3c3c10260c",
INIT_11 => X"3c1030008c343c3c1430008c343c3c1000003c02100200260c00100000142a26",
INIT_12 => X"af272703008f8f8f00140092260c92240c00140024100092afaf00af270003ac",
INIT_13 => X"8c343c2703008f240caf2727038f8f8f0206260c24341000102c30022400afaf",
INIT_14 => X"04242424142c24240424ac00248c243c3c00002703008f8c3c10000caf273003",
INIT_15 => X"616d20423a0030312030324d656c62747267650a0000000000000000038c3c24",
INIT_16 => X"330a7769796532006f61796531006e706e724f303030206e6569612020740a00",
INIT_17 => X"3900736838006979656137617965613673647475350a62697965340079617965",
INIT_18 => X"660a0d786e6e0a786e750a0a3d6541206820720a3e00616f446f42316f460075",
INIT_19 => X"0000000000000000000000000000000000000000000000000000000037336820",
INIT_1A => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_1B => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_1C => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_1D => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_1E => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_1F => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_20 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_21 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_22 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_23 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_24 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_25 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_26 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_27 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_28 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_29 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_2A => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_2B => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_2C => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_2D => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_2E => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_2F => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_30 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_31 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_32 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_33 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_34 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_35 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_36 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_37 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_38 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_39 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_3A => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_3B => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_3C => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_3D => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_3E => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_3F => X"0000000000000000000000000000000000000000000000000000000000000000")
   port map (
      DO   => data_read(31 downto 24),
      DOP  => open, 
      ADDR => address(12 downto 2),
      CLK  => clk, 
      DI   => data_write(31 downto 24),
      DIP  => ZERO(0 downto 0),
      EN   => enable,
      SSR  => ZERO(0),
      WE   => write_byte_enable(3));

   RAMB16_S9_inst1 : RAMB16_S9
   generic map (
INIT_00 => X"b8afaeadacabaaa9a8a7a6a5a4a3a2a1bd000000a560a4a0bd1d8404a5059c1c",
INIT_01 => X"b9b8afaeadacabaaa9a8a7a6a5a4a3a2a1a50086c6c406bb00bb00ba5a1abfb9",
INIT_02 => X"9392919000405a1a06e0a606a606a606a6a50584e0029b401bbd60bb60bbbabf",
INIT_03 => X"00e000c4e0000085a2e09f9d9c9e979695949392919002e09f9d9c9e97969594",
INIT_04 => X"4200a284404200a2a5a20082a303a2c0020500e084c082c6a5a2a2c002a20205",
INIT_05 => X"6200a7406283400540420200e000404200828202820282020400e000c0c60040",
INIT_06 => X"000240620300606242026303400000134000b0b1b2b3bfbd42e00204a1a5c262",
INIT_07 => X"0040225012310012000400310400040000200013001000004042100002404260",
INIT_08 => X"840004840004840004b000b1b2b3b4b5b6b7bfbdbde0b0b1b240b3bf04000400",
INIT_09 => X"1415200106000004840004144342036215404200424202620203840004840004",
INIT_0A => X"8400048400048400048400048400048400048400048400048400048400041716",
INIT_0B => X"0040006000840004400000840004000003404202400000840004840004840004",
INIT_0C => X"400000006404007040000000400000e4000000700040006262034202406203a4",
INIT_0D => X"4032310044710440400000840004000060700040000000400000e4000400a400",
INIT_0E => X"3202314271004040000084000000044032316271000004404000008400040071",
INIT_0F => X"2240320400400031004471c40071402240400000840004000400400000007140",
INIT_10 => X"024000000050715212001304000600000400000043630300008400040400c400",
INIT_11 => X"0240420062630302404200424202040000200171405140310000400000400210",
INIT_12 => X"bfbdbde000b0b1bf00400002100004040000510011400002b1bf80b0bd00e044",
INIT_13 => X"424202bde000bf0400bfbdbde0b0b1bf1101100084840000408244111080b0b1",
INIT_14 => X"616303a540c2c6846163404703a24502078000bde000bf4202400000bfbd42e0",
INIT_15 => X"7320666f0a003a3000323361726f6f686f7374470000000000000082e0420284",
INIT_16 => X"2e006f74206d2e007264206d2e007374752074303078616b206d726266695700",
INIT_17 => X"2e0075652e0074206d772e64206d772e73646f6d2e007974206d2e007464206d",
INIT_18 => X"69430a3e2074433e20655600207364006569654120007320526d2032702e006d",
INIT_19 => X"2400800000000000000000000000000000000000000000000000000038342077",
INIT_1A => X"0000000000000000000000000000000000000000000000000000000004000080",
INIT_1B => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_1C => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_1D => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_1E => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_1F => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_20 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_21 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_22 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_23 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_24 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_25 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_26 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_27 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_28 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_29 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_2A => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_2B => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_2C => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_2D => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_2E => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_2F => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_30 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_31 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_32 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_33 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_34 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_35 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_36 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_37 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_38 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_39 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_3A => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_3B => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_3C => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_3D => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_3E => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_3F => X"0000000000000000000000000000000000000000000000000000000000000000")
   port map (
      DO   => data_read(23 downto 16),
      DOP  => open, 
      ADDR => address(12 downto 2),
      CLK  => clk, 
      DI   => data_write(23 downto 16),
      DIP  => ZERO(0 downto 0),
      EN   => enable,
      SSR  => ZERO(0),
      WE   => write_byte_enable(2));

   RAMB16_S9_inst2 : RAMB16_S9
   generic map (
INIT_00 => X"00000000000000000000000000000000ff00000100ff18000f000f000d008d00",
INIT_01 => X"000000000000000000000000000000000000022000002000d800d800ff700000",
INIT_02 => X"0000000000000010000000000000000000010060006060000000000000000000",
INIT_03 => X"0000000000201000000000000000000000000000000000000000000000000000",
INIT_04 => X"000000000000000000000000000028003028000000ff00ff0000000000283028",
INIT_05 => X"0000300000003800000d00000000ff00000000000000203020000000ffff00ff",
INIT_06 => X"00ff0000ff200018000000008000020088900000000000ff0d000021ffff0000",
INIT_07 => X"00ff009011000291000002ff000200020000000000ff00000000ff00ff000080",
INIT_08 => X"0a02000a02000a020000020000000000000000ff000000000010000000020002",
INIT_09 => X"0000f810000028100a02000000ff3c00000000000000200000300a02000a0200",
INIT_0A => X"0b02000b02000b02000b02000b02000b02000b02000b02000b02000b02000000",
INIT_0B => X"02200220000c02009800000c02002002ff0000ff8098020c02000c02000b0200",
INIT_0C => X"200200000000ff00200220008000000c022000000000000018180c00ff00ff0c",
INIT_0D => X"ff100002001000ff9088000c0200ff00f800ff200220008000000c0200ff0c02",
INIT_0E => X"108000001088009080000c0200ff00ff10000018000200ff9088000c0200ff10",
INIT_0F => X"00ff1000022002000000100c02100000009088000c0200ff00022002200010ff",
INIT_10 => X"27000002800010ff00881000ff00002810200000ff561200000c020000ff0c02",
INIT_11 => X"20ff00000000202000000000002000ff00f81010ff1080000200000000ff2700",
INIT_12 => X"00ff00001000000000ff000000020000020000000000000000008000ff100000",
INIT_13 => X"00002000000000000200ff000000000010ffff02000000000000001000880000",
INIT_14 => X"ffff0000ff000000ffff001000000c00103020000000000020ff000200ff0000",
INIT_15 => X"6866726f0000333a0033207920616f656d206972000000000000001000001000",
INIT_16 => X"20007265776f20006420726f20003a69204d680a303174656c6179696f6e6100",
INIT_17 => X"20006d63200065776f20200a726f20200a72207020007465776f20006520726f",
INIT_18 => X"726f002068206f206820610000736400786e7364000068662020663879200070",
INIT_19 => X"202800000805050505050505050508050507070706060606060600003e353169",
INIT_1A => X"0000000000000000000000000000000000000000000000000000000020000000",
INIT_1B => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_1C => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_1D => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_1E => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_1F => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_20 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_21 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_22 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_23 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_24 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_25 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_26 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_27 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_28 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_29 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_2A => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_2B => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_2C => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_2D => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_2E => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_2F => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_30 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_31 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_32 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_33 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_34 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_35 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_36 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_37 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_38 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_39 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_3A => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_3B => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_3C => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_3D => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_3E => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_3F => X"0000000000000000000000000000000000000000000000000000000000000000")
   port map (
      DO   => data_read(15 downto 8),
      DOP  => open, 
      ADDR => address(12 downto 2),
      CLK  => clk, 
      DI   => data_write(15 downto 8),
      DIP  => ZERO(0 downto 0),
      EN   => enable,
      SSR  => ZERO(0),
      WE   => write_byte_enable(1));

   RAMB16_S9_inst3 : RAMB16_S9
   generic map (
INIT_00 => X"4c4844403c3834302c2824201c181410980e000c04fd2a000800200010000001",
INIT_01 => X"504c4844403c3834302c2824201c18141000752410200060125c1058fc005450",
INIT_02 => X"0c08040000083c0048080c440840043c006000000800000801681360115c5854",
INIT_03 => X"00080c000810121900082c2824201c1814100c08040000082c2824201c181410",
INIT_04 => X"800000020680000004000000004021140040000802fb00fe04000007ff210040",
INIT_05 => X"300221030a0f2507081000000800fc80000000d00020210040000800effe00fc",
INIT_06 => X"19bf030ad0252625010d010a2500820825251014181c20d810080002f6ff0037",
INIT_07 => X"00d2102100013202050832ff203208320008000c00a90f00031ac9149f031a25",
INIT_08 => X"dc4300d04300b04300108d14181c2024282c30c82808101418251c200a320d32",
INIT_09 => X"0000090002802500f04300000cff1c000010010000700000ff00ec4300e04300",
INIT_0A => X"ec4300d44300c04300ac43009443007c43006443004c43003443000443000000",
INIT_0B => X"43254325b54443002500c83043002532cf130ad02525822c4300084300fc4300",
INIT_0C => X"254300b50000a900254325b52500c85443250e000008000021809800be16cf50",
INIT_0D => X"fb2b01320021008a2525c86443009100090094254325b52500c8544300a05043",
INIT_0E => X"2b2101002125082525c86443007000f92b0100210082007a2525c86443008121",
INIT_0F => X"0ff22b2032254304b50021744321040f102525c86443005a0a32254325b521fb",
INIT_10 => X"1005007d250021ff0f2500002f028e250025a70036783400c878430000407443",
INIT_11 => X"00fc020000200000080200002000001200090021ee2a25018200070000f91001",
INIT_12 => X"18e020082510141800f500000132000d320003000a0d000014182510e0250800",
INIT_13 => X"00200018080010493210e8200810141806f6fc3257300200030a0f061c251014",
INIT_14 => X"feff6304f6080101feff00210300f000002525180800100000fd007d10e80108",
INIT_15 => X"0a6c6f7400003032000032200064742020666e65000000000000002108000001",
INIT_16 => X"4d00642072724d000a7765724d000a6f4f656500303020646967206e72676900",
INIT_17 => X"44000a6b43000a72726d520065726d52006561204a00652072724d000a626572",
INIT_18 => X"6d6e00006569750065696c00002072003e20736400000a6c7444724b2043000a",
INIT_19 => X"0000207010080808080808080808540808a8500cccbc906c3c30000020363274",
INIT_1A => X"0000000000000000000000000000000000000000000000000000000000101020",
INIT_1B => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_1C => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_1D => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_1E => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_1F => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_20 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_21 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_22 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_23 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_24 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_25 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_26 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_27 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_28 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_29 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_2A => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_2B => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_2C => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_2D => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_2E => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_2F => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_30 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_31 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_32 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_33 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_34 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_35 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_36 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_37 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_38 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_39 => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_3A => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_3B => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_3C => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_3D => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_3E => X"0000000000000000000000000000000000000000000000000000000000000000",
INIT_3F => X"0000000000000000000000000000000000000000000000000000000000000000")
   port map (
      DO   => data_read(7 downto 0),
      DOP  => open, 
      ADDR => address(12 downto 2),
      CLK  => clk, 
      DI   => data_write(7 downto 0),
      DIP  => ZERO(0 downto 0),
      EN   => enable,
      SSR  => ZERO(0),
      WE   => write_byte_enable(0));

end; --architecture logic