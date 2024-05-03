--
-------------------------------------------------------------------------------------------
-- Copyright © 2010-2013, Xilinx, Inc.
-- This file contains confidential and proprietary information of Xilinx, Inc. and is
-- protected under U.S. and international copyright and other intellectual property laws.
-------------------------------------------------------------------------------------------
--
-- Disclaimer:
-- This disclaimer is not a license and does not grant any rights to the materials
-- distributed herewith. Except as otherwise provided in a valid license issued to
-- you by Xilinx, and to the maximum extent permitted by applicable law: (1) THESE
-- MATERIALS ARE MADE AVAILABLE "AS IS" AND WITH ALL FAULTS, AND XILINX HEREBY
-- DISCLAIMS ALL WARRANTIES AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY,
-- INCLUDING BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-INFRINGEMENT,
-- OR FITNESS FOR ANY PARTICULAR PURPOSE; and (2) Xilinx shall not be liable
-- (whether in contract or tort, including negligence, or under any other theory
-- of liability) for any loss or damage of any kind or nature related to, arising
-- under or in connection with these materials, including for any direct, or any
-- indirect, special, incidental, or consequential loss or damage (including loss
-- of data, profits, goodwill, or any type of loss or damage suffered as a result
-- of any action brought by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the possibility of the same.
--
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-safe, or for use in any
-- application requiring fail-safe performance, such as life-support or safety
-- devices or systems, Class III medical devices, nuclear facilities, applications
-- related to the deployment of airbags, or any other applications that could lead
-- to death, personal injury, or severe property or environmental damage
-- (individually and collectively, "Critical Applications"). Customer assumes the
-- sole risk and liability of any use of Xilinx products in Critical Applications,
-- subject only to applicable laws and regulations governing limitations on product
-- liability.
--
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS PART OF THIS FILE AT ALL TIMES.
--
-------------------------------------------------------------------------------------------
--
--
-- Definition of a program memory for KCPSM6 including generic parameters for the 
-- convenient selection of device family, program memory size and the ability to include 
-- the JTAG Loader hardware for rapid software development.
--
-- This file is primarily for use during code development and it is recommended that the 
-- appropriate simplified program memory definition be used in a final production design. 
--
--    Generic                  Values             Comments
--    Parameter                Supported
--  
--    C_FAMILY                 "S6"               Spartan-6 device
--                             "V6"               Virtex-6 device
--                             "7S"               7-Series device 
--                                                  (Artix-7, Kintex-7, Virtex-7 or Zynq)
--
--    C_RAM_SIZE_KWORDS        1, 2 or 4          Size of program memory in K-instructions
--
--    C_JTAG_LOADER_ENABLE     0 or 1             Set to '1' to include JTAG Loader
--
-- Notes
--
-- If your design contains MULTIPLE KCPSM6 instances then only one should have the 
-- JTAG Loader enabled at a time (i.e. make sure that C_JTAG_LOADER_ENABLE is only set to 
-- '1' on one instance of the program memory). Advanced users may be interested to know 
-- that it is possible to connect JTAG Loader to multiple memories and then to use the 
-- JTAG Loader utility to specify which memory contents are to be modified. However, 
-- this scheme does require some effort to set up and the additional connectivity of the 
-- multiple BRAMs can impact the placement, routing and performance of the complete 
-- design. Please contact the author at Xilinx for more detailed information. 
--
-- Regardless of the size of program memory specified by C_RAM_SIZE_KWORDS, the complete 
-- 12-bit address bus is connected to KCPSM6. This enables the generic to be modified 
-- without requiring changes to the fundamental hardware definition. However, when the 
-- program memory is 1K then only the lower 10-bits of the address are actually used and 
-- the valid address range is 000 to 3FF hex. Likewise, for a 2K program only the lower 
-- 11-bits of the address are actually used and the valid address range is 000 to 7FF hex.
--
-- Programs are stored in Block Memory (BRAM) and the number of BRAM used depends on the 
-- size of the program and the device family. 
--
-- In a Spartan-6 device a BRAM is capable of holding 1K instructions. Hence a 2K program 
-- will require 2 BRAMs to be used and a 4K program will require 4 BRAMs to be used. It 
-- should be noted that a 4K program is not such a natural fit in a Spartan-6 device and 
-- the implementation also requires a small amount of logic resulting in slightly lower 
-- performance. A Spartan-6 BRAM can also be split into two 9k-bit memories suggesting 
-- that a program containing up to 512 instructions could be implemented. However, there 
-- is a silicon errata which makes this unsuitable and therefore it is not supported by 
-- this file.
--
-- In a Virtex-6 or any 7-Series device a BRAM is capable of holding 2K instructions so 
-- obviously a 2K program requires only a single BRAM. Each BRAM can also be divided into 
-- 2 smaller memories supporting programs of 1K in half of a 36k-bit BRAM (generally 
-- reported as being an 18k-bit BRAM). For a program of 4K instructions, 2 BRAMs are used.
--
--
-- Program defined by 'C:\Users\equack\Documents\Xilinx\DVI-1080p\dvid_test_hd\PicoBlaze\quackterm.psm'.
--
-- Generated by KCPSM6 Assembler: 22 May 2017 - 16:13:31. 
--
-- Assembler used ROM_form template: ROM_form_JTAGLoader_14March13.vhd
--
-- Standard IEEE libraries
--
--
package jtag_loader_pkg is
 function addr_width_calc (size_in_k: integer) return integer;
end jtag_loader_pkg;
--
package body jtag_loader_pkg is
  function addr_width_calc (size_in_k: integer) return integer is
   begin
    if (size_in_k = 1) then return 10;
      elsif (size_in_k = 2) then return 11;
      elsif (size_in_k = 4) then return 12;
      else report "Invalid BlockRAM size. Please set to 1, 2 or 4 K words." severity FAILURE;
    end if;
    return 0;
  end function addr_width_calc;
end package body;
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.jtag_loader_pkg.ALL;
--
-- The Unisim Library is used to define Xilinx primitives. It is also used during
-- simulation. The source can be viewed at %XILINX%\vhdl\src\unisims\unisim_VCOMP.vhd
--  
library unisim;
use unisim.vcomponents.all;
--
--
entity quackterm is
  generic(             C_FAMILY : string := "S6"; 
              C_RAM_SIZE_KWORDS : integer := 1;
           C_JTAG_LOADER_ENABLE : integer := 0);
  Port (      address : in std_logic_vector(11 downto 0);
          instruction : out std_logic_vector(17 downto 0);
               enable : in std_logic;
                  rdl : out std_logic;                    
                  clk : in std_logic);
  end quackterm;
--
architecture low_level_definition of quackterm is
--
signal       address_a : std_logic_vector(15 downto 0);
signal        pipe_a11 : std_logic;
signal       data_in_a : std_logic_vector(35 downto 0);
signal      data_out_a : std_logic_vector(35 downto 0);
signal    data_out_a_l : std_logic_vector(35 downto 0);
signal    data_out_a_h : std_logic_vector(35 downto 0);
signal   data_out_a_ll : std_logic_vector(35 downto 0);
signal   data_out_a_lh : std_logic_vector(35 downto 0);
signal   data_out_a_hl : std_logic_vector(35 downto 0);
signal   data_out_a_hh : std_logic_vector(35 downto 0);
signal       address_b : std_logic_vector(15 downto 0);
signal       data_in_b : std_logic_vector(35 downto 0);
signal     data_in_b_l : std_logic_vector(35 downto 0);
signal    data_in_b_ll : std_logic_vector(35 downto 0);
signal    data_in_b_hl : std_logic_vector(35 downto 0);
signal      data_out_b : std_logic_vector(35 downto 0);
signal    data_out_b_l : std_logic_vector(35 downto 0);
signal   data_out_b_ll : std_logic_vector(35 downto 0);
signal   data_out_b_hl : std_logic_vector(35 downto 0);
signal     data_in_b_h : std_logic_vector(35 downto 0);
signal    data_in_b_lh : std_logic_vector(35 downto 0);
signal    data_in_b_hh : std_logic_vector(35 downto 0);
signal    data_out_b_h : std_logic_vector(35 downto 0);
signal   data_out_b_lh : std_logic_vector(35 downto 0);
signal   data_out_b_hh : std_logic_vector(35 downto 0);
signal        enable_b : std_logic;
signal           clk_b : std_logic;
signal            we_b : std_logic_vector(7 downto 0);
signal          we_b_l : std_logic_vector(3 downto 0);
signal          we_b_h : std_logic_vector(3 downto 0);
-- 
signal       jtag_addr : std_logic_vector(11 downto 0);
signal         jtag_we : std_logic;
signal       jtag_we_l : std_logic;
signal       jtag_we_h : std_logic;
signal        jtag_clk : std_logic;
signal        jtag_din : std_logic_vector(17 downto 0);
signal       jtag_dout : std_logic_vector(17 downto 0);
signal     jtag_dout_1 : std_logic_vector(17 downto 0);
signal         jtag_en : std_logic_vector(0 downto 0);
-- 
signal picoblaze_reset : std_logic_vector(0 downto 0);
signal         rdl_bus : std_logic_vector(0 downto 0);
--
constant BRAM_ADDRESS_WIDTH  : integer := addr_width_calc(C_RAM_SIZE_KWORDS);
--
--
component jtag_loader_6
generic(                C_JTAG_LOADER_ENABLE : integer := 1;
                                    C_FAMILY : string  := "V6";
                             C_NUM_PICOBLAZE : integer := 1;
                       C_BRAM_MAX_ADDR_WIDTH : integer := 10;
          C_PICOBLAZE_INSTRUCTION_DATA_WIDTH : integer := 18;
                                C_JTAG_CHAIN : integer := 2;
                              C_ADDR_WIDTH_0 : integer := 10;
                              C_ADDR_WIDTH_1 : integer := 10;
                              C_ADDR_WIDTH_2 : integer := 10;
                              C_ADDR_WIDTH_3 : integer := 10;
                              C_ADDR_WIDTH_4 : integer := 10;
                              C_ADDR_WIDTH_5 : integer := 10;
                              C_ADDR_WIDTH_6 : integer := 10;
                              C_ADDR_WIDTH_7 : integer := 10);
port(              picoblaze_reset : out std_logic_vector(C_NUM_PICOBLAZE-1 downto 0);
                           jtag_en : out std_logic_vector(C_NUM_PICOBLAZE-1 downto 0);
                          jtag_din : out STD_LOGIC_VECTOR(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
                         jtag_addr : out STD_LOGIC_VECTOR(C_BRAM_MAX_ADDR_WIDTH-1 downto 0);
                          jtag_clk : out std_logic;
                           jtag_we : out std_logic;
                       jtag_dout_0 : in STD_LOGIC_VECTOR(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
                       jtag_dout_1 : in STD_LOGIC_VECTOR(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
                       jtag_dout_2 : in STD_LOGIC_VECTOR(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
                       jtag_dout_3 : in STD_LOGIC_VECTOR(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
                       jtag_dout_4 : in STD_LOGIC_VECTOR(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
                       jtag_dout_5 : in STD_LOGIC_VECTOR(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
                       jtag_dout_6 : in STD_LOGIC_VECTOR(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
                       jtag_dout_7 : in STD_LOGIC_VECTOR(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0));
end component;
--
begin
  --
  --  
  ram_1k_generate : if (C_RAM_SIZE_KWORDS = 1) generate
 
    s6: if (C_FAMILY = "S6") generate 
      --
      address_a(13 downto 0) <= address(9 downto 0) & "0000";
      instruction <= data_out_a(33 downto 32) & data_out_a(15 downto 0);
      data_in_a <= "0000000000000000000000000000000000" & address(11 downto 10);
      jtag_dout <= data_out_b(33 downto 32) & data_out_b(15 downto 0);
      --
      no_loader : if (C_JTAG_LOADER_ENABLE = 0) generate
        data_in_b <= "00" & data_out_b(33 downto 32) & "0000000000000000" & data_out_b(15 downto 0);
        address_b(13 downto 0) <= "00000000000000";
        we_b(3 downto 0) <= "0000";
        enable_b <= '0';
        rdl <= '0';
        clk_b <= '0';
      end generate no_loader;
      --
      loader : if (C_JTAG_LOADER_ENABLE = 1) generate
        data_in_b <= "00" & jtag_din(17 downto 16) & "0000000000000000" & jtag_din(15 downto 0);
        address_b(13 downto 0) <= jtag_addr(9 downto 0) & "0000";
        we_b(3 downto 0) <= jtag_we & jtag_we & jtag_we & jtag_we;
        enable_b <= jtag_en(0);
        rdl <= rdl_bus(0);
        clk_b <= jtag_clk;
      end generate loader;
      --
      kcpsm6_rom: RAMB16BWER
      generic map ( DATA_WIDTH_A => 18,
                    DOA_REG => 0,
                    EN_RSTRAM_A => FALSE,
                    INIT_A => X"000000000",
                    RST_PRIORITY_A => "CE",
                    SRVAL_A => X"000000000",
                    WRITE_MODE_A => "WRITE_FIRST",
                    DATA_WIDTH_B => 18,
                    DOB_REG => 0,
                    EN_RSTRAM_B => FALSE,
                    INIT_B => X"000000000",
                    RST_PRIORITY_B => "CE",
                    SRVAL_B => X"000000000",
                    WRITE_MODE_B => "WRITE_FIRST",
                    RSTTYPE => "SYNC",
                    INIT_FILE => "NONE",
                    SIM_COLLISION_CHECK => "ALL",
                    SIM_DEVICE => "SPARTAN6",
                    INIT_00 => X"F030F031D00ED00FF01FF01EF033F0321000D00BF02F100017431D7820420002",
                    INIT_01 => X"152800B8152006031300B22F056819A8180504BB0038F6341670FC351C000632",
                    INIT_02 => X"00B800B8F03B1010152000B8152906031300027000B815780603130002D000B8",
                    INIT_03 => X"F422B30084D0F321F42005E5097008D0500004E41670602DD0009001B03B1601",
                    INIT_04 => X"100091012051D001900C11A7204200B82042004A006040B3D010B02F5000F323",
                    INIT_05 => X"5000100110009540205610009101205CD001904111A7500010011000950D204B",
                    INIT_06 => X"2002D5A420A6D59EF03030BF5000F030504060A6D59E606AD040B03010000055",
                    INIT_07 => X"D00BF02F30071001B02F50007C205000D5135000F03070806077D553207BD5F3",
                    INIT_08 => X"D00320071D501743608FD00220071D781721608AD00120071D7817436085D000",
                    INIT_09 => X"60A3D00620071D781719609ED00520071D7817326099D00420071D5017216094",
                    INIT_0A => X"3A001B015000BA009B01500060B8D080B030063520071D50171920071D501732",
                    INIT_0B => X"60DCDC90F53160BEDC0320BED51B00B05000D002B021D003B0205000DB03DA02",
                    INIT_0C => X"2476D5092472D57F246AD50820F9D51B60DCDC2060FBDC026154DC011000D500",
                    INIT_0D => X"152020E0DC08F03D2538D5072467D50524BBD50C24A3D50B24A3D50A24E6D50D",
                    INIT_0E => X"D051B0303CEF20ED956020ED151F60EBD56020EDA0EDD55FE0EDD57F20EDDC40",
                    INIT_0F => X"500001495C016100D55B50005C0224F004CF00B000AB5000054E00AED609D504",
                    INIT_10 => X"B030214700B0BC35B634BA33BB32610FD5382147FC35F634FA33FB326107D537",
                    INIT_11 => X"5020B0306122D5282147611CD53E21475C106119D54E20026115D5636122D020",
                    INIT_12 => X"30FE6133D5422147F03030FE5C40612DD530F03030DF2147D020B0305000F030",
                    INIT_13 => X"D56921475C40F0305001613FD53221473CBFF03050016139D53121473CBFF030",
                    INIT_14 => X"E100110010085000F011F007100050003CFD207E00509561E147C4501460E147",
                    INIT_15 => X"5000F1111101E5000010B11110122160A160D52FE160D53A5000614FD0101001",
                    INIT_16 => X"B03704F0F0371001616DD000B0086174D55350006167D53F50006164D53B043F",
                    INIT_17 => X"D568243C617AD0009001050C1001617AD000B008617FD554243C616DD0009001",
                    INIT_18 => X"243CD00BF02F5008B02F243C00B0F02F30EFB02F643CD019218BD00CB0096190",
                    INIT_19 => X"D00BF02F30F7B02F243C00B3F02F5010B02F643CD019219CD00CB00961A1D56C",
                    INIT_1A => X"09D00800100161AED000B008243C04F261AA055704CFFA01FB0061D4D54D243C",
                    INIT_1B => X"950A940592500000DF02DE03F237B121B0202F300E400FA00EB0F33EF43D05E5",
                    INIT_1C => X"B33EB43DBA21BB20B23761BAEF10CE003F001E013A001B01D509D404D25100B0",
                    INIT_1D => X"B008FA3CFB3B243C04FA61DD055704CFFA01FB006210D54C243C04FCAA308B40",
                    INIT_1E => X"BE20F33EF43D05E509D00800243C61E69001050E61EAFA00DB00100161E3D000",
                    INIT_1F => X"950A9405985000B023500240B33CB23B0530AA308B400AF00BE0BF009E01BF21",
                    INIT_20 => X"243C0528B13EB03D61FCEF30CE20BF009E0100ABD509D404D8510000DF02DE03",
                    INIT_21 => X"6219D000900100AED609D504D55110016219D0001500B008FA01FB006224D558",
                    INIT_22 => X"900180E000D005BFFA01FB001101622AD100B108624BD540243C00B0BA01BB00",
                    INIT_23 => X"D000900100B0BA009B02D509D404D25100AE950A94059250100100B03A000B00",
                    INIT_24 => X"6251D100B1086271D550243C622AD1009101D609D404D251B200142000AE6234",
                    INIT_25 => X"1B01D509D404D25100B000AB950A9405925000AE80E000D005BFFA01FB001101",
                    INIT_26 => X"6251D100910100B0BA01BB00D609D404D4511420B25000B06256D00090013A00",
                    INIT_27 => X"6322D56D243C04BD243C04A9627CD001243C04BB6278D002B008627ED54A243C",
                    INIT_28 => X"DC046295D401231EF43034FDB4303CF73CFB1670628DD400A41000101108B007",
                    INIT_29 => X"5608445ADC0462A3D405231EF4305402B430629BD404231E445ADC045680445A",
                    INIT_2A => X"62B5D40A231E5C0862AED408231E5C04045A631EDC0462AAD407231E445ADC04",
                    INIT_2B => X"B4303CBF62C3D40C231EF43034FEB4305C4062BCD40B231EF43034FEB4303CBF",
                    INIT_2C => X"62D6D416231E3CF762CED41C231EF4305401B4305C4062CAD40D231EF4305401",
                    INIT_2D => X"445ADC0462E4D419231EF43034FDB43062DCD418231E445ADC04367F445ADC04",
                    INIT_2E => X"360F445ADC0462F4D427231E3CFB045A231EDC0462EBD41B231E445ADC0436F7",
                    INIT_2F => X"C540151DE30FD426231E445ADC0436F0445ADC0462FCD431231E445ADC045670",
                    INIT_30 => X"D430231EB43D445ADC0406404406440644064406368F941EF43D445ADC04E30F",
                    INIT_31 => X"C1001101231EB43D445ADC04064036F89428F43D445ADC04E31EC5401527E31E",
                    INIT_32 => X"91012330D100A1001008F0091000232BD002B0076346D5662326D548243C6283",
                    INIT_33 => X"A342C1D09101233ED100A10010010B400A3005E509D0081091010170A334C170",
                    INIT_34 => X"90010070A350C0709001234CD000B008635CD564243C00B03A000B10910101D0",
                    INIT_35 => X"D000B0086372D547243C00B03A000BE00B400A3005E509D00800B03D05C4F03D",
                    INIT_36 => X"3A000B00B03D0B400A3005E509D0082005C4F03D900100D0A366C0D090012362",
                    INIT_37 => X"9001B03600DCF036B5311001637BD000B008F5373CFE3CFD6384D562243C00B0",
                    INIT_38 => X"8BE09E012395D401239FD400B40805BFFA01FB0063B2D54B5000B537637BD000",
                    INIT_39 => X"04D023AE6396DE009E0100B000ABD609D404D451140023A714000ED000B0BA00",
                    INIT_3A => X"BA01BB0063A7DE009E0100AED609D404D4510ED063A7DE0014000E4084E01401",
                    INIT_3B => X"D100B10863C6D542243C63B891010496110163B8D100B10863BCD541243C00B0",
                    INIT_3C => X"9001B0080490F008100163CDD000B00863D4D543243C63C29101049D110163C2",
                    INIT_3D => X"D000F0089001B008048AF008100163DBD000B00863E2D544243C63CDD000F008",
                    INIT_3E => X"D549243C63E8D1009101B13D047DF13D110163E8D100B10863EFD55A243C63DB",
                    INIT_3F => X"D006B008641CD56E243C63F5D1009101B13D0476F13D110163F5D100B10863FC",
                   INITP_00 => X"A12368DDDD8A370E90B70242DC0AEB0A96A0A351A822088222082A22AAAA280A",
                   INITP_01 => X"A362ABAA82637DDC32DDDDDDDDDDCCCDCB36A22A596C2820D8360D8360D8360D",
                   INITP_02 => X"6D674DB529D36DB6A643DDB582A221D3623623623683630A0DB636DC28036AAD",
                   INITP_03 => X"025014142A0B6D5D2ABAADA5003555AA00A8142A074AEAB6A0A8374DA82A0DD3",
                   INITP_04 => X"DAADAD36D60A82D56AA024A9D36D6A0B596A806552A74DA0D6A9D0ADA0D56A8A",
                   INITP_05 => X"4DB0CDB03362CDB0CDA0DB0CD8DA03680DA03680D8D8B36C336836C336800D10",
                   INITP_06 => X"4A1D20DA5020A4D74DA5080A4D74DA54D744204D74234DDB58C46CD3631551B3",
                   INITP_07 => X"4DB529D36D4A74DB64A74DB64A74DB674DB674DA0D6A8D052D6AA2095DD2AD8D")
      port map(  ADDRA => address_a(13 downto 0),
                   ENA => enable,
                  CLKA => clk,
                   DOA => data_out_a(31 downto 0),
                  DOPA => data_out_a(35 downto 32), 
                   DIA => data_in_a(31 downto 0),
                  DIPA => data_in_a(35 downto 32), 
                   WEA => "0000",
                REGCEA => '0',
                  RSTA => '0',
                 ADDRB => address_b(13 downto 0),
                   ENB => enable_b,
                  CLKB => clk_b,
                   DOB => data_out_b(31 downto 0),
                  DOPB => data_out_b(35 downto 32), 
                   DIB => data_in_b(31 downto 0),
                  DIPB => data_in_b(35 downto 32), 
                   WEB => we_b(3 downto 0),
                REGCEB => '0',
                  RSTB => '0');
    --               
    end generate s6;
    --
    --
    v6 : if (C_FAMILY = "V6") generate
      --
      address_a(13 downto 0) <= address(9 downto 0) & "1111";
      instruction <= data_out_a(17 downto 0);
      data_in_a(17 downto 0) <= "0000000000000000" & address(11 downto 10);
      jtag_dout <= data_out_b(17 downto 0);
      --
      no_loader : if (C_JTAG_LOADER_ENABLE = 0) generate
        data_in_b(17 downto 0) <= data_out_b(17 downto 0);
        address_b(13 downto 0) <= "11111111111111";
        we_b(3 downto 0) <= "0000";
        enable_b <= '0';
        rdl <= '0';
        clk_b <= '0';
      end generate no_loader;
      --
      loader : if (C_JTAG_LOADER_ENABLE = 1) generate
        data_in_b(17 downto 0) <= jtag_din(17 downto 0);
        address_b(13 downto 0) <= jtag_addr(9 downto 0) & "1111";
        we_b(3 downto 0) <= jtag_we & jtag_we & jtag_we & jtag_we;
        enable_b <= jtag_en(0);
        rdl <= rdl_bus(0);
        clk_b <= jtag_clk;
      end generate loader;
      -- 
      kcpsm6_rom: RAMB18E1
      generic map ( READ_WIDTH_A => 18,
                    WRITE_WIDTH_A => 18,
                    DOA_REG => 0,
                    INIT_A => "000000000000000000",
                    RSTREG_PRIORITY_A => "REGCE",
                    SRVAL_A => X"000000000000000000",
                    WRITE_MODE_A => "WRITE_FIRST",
                    READ_WIDTH_B => 18,
                    WRITE_WIDTH_B => 18,
                    DOB_REG => 0,
                    INIT_B => X"000000000000000000",
                    RSTREG_PRIORITY_B => "REGCE",
                    SRVAL_B => X"000000000000000000",
                    WRITE_MODE_B => "WRITE_FIRST",
                    INIT_FILE => "NONE",
                    SIM_COLLISION_CHECK => "ALL",
                    RAM_MODE => "TDP",
                    RDADDR_COLLISION_HWCONFIG => "DELAYED_WRITE",
                    SIM_DEVICE => "VIRTEX6",
                    INIT_00 => X"F030F031D00ED00FF01FF01EF033F0321000D00BF02F100017431D7820420002",
                    INIT_01 => X"152800B8152006031300B22F056819A8180504BB0038F6341670FC351C000632",
                    INIT_02 => X"00B800B8F03B1010152000B8152906031300027000B815780603130002D000B8",
                    INIT_03 => X"F422B30084D0F321F42005E5097008D0500004E41670602DD0009001B03B1601",
                    INIT_04 => X"100091012051D001900C11A7204200B82042004A006040B3D010B02F5000F323",
                    INIT_05 => X"5000100110009540205610009101205CD001904111A7500010011000950D204B",
                    INIT_06 => X"2002D5A420A6D59EF03030BF5000F030504060A6D59E606AD040B03010000055",
                    INIT_07 => X"D00BF02F30071001B02F50007C205000D5135000F03070806077D553207BD5F3",
                    INIT_08 => X"D00320071D501743608FD00220071D781721608AD00120071D7817436085D000",
                    INIT_09 => X"60A3D00620071D781719609ED00520071D7817326099D00420071D5017216094",
                    INIT_0A => X"3A001B015000BA009B01500060B8D080B030063520071D50171920071D501732",
                    INIT_0B => X"60DCDC90F53160BEDC0320BED51B00B05000D002B021D003B0205000DB03DA02",
                    INIT_0C => X"2476D5092472D57F246AD50820F9D51B60DCDC2060FBDC026154DC011000D500",
                    INIT_0D => X"152020E0DC08F03D2538D5072467D50524BBD50C24A3D50B24A3D50A24E6D50D",
                    INIT_0E => X"D051B0303CEF20ED956020ED151F60EBD56020EDA0EDD55FE0EDD57F20EDDC40",
                    INIT_0F => X"500001495C016100D55B50005C0224F004CF00B000AB5000054E00AED609D504",
                    INIT_10 => X"B030214700B0BC35B634BA33BB32610FD5382147FC35F634FA33FB326107D537",
                    INIT_11 => X"5020B0306122D5282147611CD53E21475C106119D54E20026115D5636122D020",
                    INIT_12 => X"30FE6133D5422147F03030FE5C40612DD530F03030DF2147D020B0305000F030",
                    INIT_13 => X"D56921475C40F0305001613FD53221473CBFF03050016139D53121473CBFF030",
                    INIT_14 => X"E100110010085000F011F007100050003CFD207E00509561E147C4501460E147",
                    INIT_15 => X"5000F1111101E5000010B11110122160A160D52FE160D53A5000614FD0101001",
                    INIT_16 => X"B03704F0F0371001616DD000B0086174D55350006167D53F50006164D53B043F",
                    INIT_17 => X"D568243C617AD0009001050C1001617AD000B008617FD554243C616DD0009001",
                    INIT_18 => X"243CD00BF02F5008B02F243C00B0F02F30EFB02F643CD019218BD00CB0096190",
                    INIT_19 => X"D00BF02F30F7B02F243C00B3F02F5010B02F643CD019219CD00CB00961A1D56C",
                    INIT_1A => X"09D00800100161AED000B008243C04F261AA055704CFFA01FB0061D4D54D243C",
                    INIT_1B => X"950A940592500000DF02DE03F237B121B0202F300E400FA00EB0F33EF43D05E5",
                    INIT_1C => X"B33EB43DBA21BB20B23761BAEF10CE003F001E013A001B01D509D404D25100B0",
                    INIT_1D => X"B008FA3CFB3B243C04FA61DD055704CFFA01FB006210D54C243C04FCAA308B40",
                    INIT_1E => X"BE20F33EF43D05E509D00800243C61E69001050E61EAFA00DB00100161E3D000",
                    INIT_1F => X"950A9405985000B023500240B33CB23B0530AA308B400AF00BE0BF009E01BF21",
                    INIT_20 => X"243C0528B13EB03D61FCEF30CE20BF009E0100ABD509D404D8510000DF02DE03",
                    INIT_21 => X"6219D000900100AED609D504D55110016219D0001500B008FA01FB006224D558",
                    INIT_22 => X"900180E000D005BFFA01FB001101622AD100B108624BD540243C00B0BA01BB00",
                    INIT_23 => X"D000900100B0BA009B02D509D404D25100AE950A94059250100100B03A000B00",
                    INIT_24 => X"6251D100B1086271D550243C622AD1009101D609D404D251B200142000AE6234",
                    INIT_25 => X"1B01D509D404D25100B000AB950A9405925000AE80E000D005BFFA01FB001101",
                    INIT_26 => X"6251D100910100B0BA01BB00D609D404D4511420B25000B06256D00090013A00",
                    INIT_27 => X"6322D56D243C04BD243C04A9627CD001243C04BB6278D002B008627ED54A243C",
                    INIT_28 => X"DC046295D401231EF43034FDB4303CF73CFB1670628DD400A41000101108B007",
                    INIT_29 => X"5608445ADC0462A3D405231EF4305402B430629BD404231E445ADC045680445A",
                    INIT_2A => X"62B5D40A231E5C0862AED408231E5C04045A631EDC0462AAD407231E445ADC04",
                    INIT_2B => X"B4303CBF62C3D40C231EF43034FEB4305C4062BCD40B231EF43034FEB4303CBF",
                    INIT_2C => X"62D6D416231E3CF762CED41C231EF4305401B4305C4062CAD40D231EF4305401",
                    INIT_2D => X"445ADC0462E4D419231EF43034FDB43062DCD418231E445ADC04367F445ADC04",
                    INIT_2E => X"360F445ADC0462F4D427231E3CFB045A231EDC0462EBD41B231E445ADC0436F7",
                    INIT_2F => X"C540151DE30FD426231E445ADC0436F0445ADC0462FCD431231E445ADC045670",
                    INIT_30 => X"D430231EB43D445ADC0406404406440644064406368F941EF43D445ADC04E30F",
                    INIT_31 => X"C1001101231EB43D445ADC04064036F89428F43D445ADC04E31EC5401527E31E",
                    INIT_32 => X"91012330D100A1001008F0091000232BD002B0076346D5662326D548243C6283",
                    INIT_33 => X"A342C1D09101233ED100A10010010B400A3005E509D0081091010170A334C170",
                    INIT_34 => X"90010070A350C0709001234CD000B008635CD564243C00B03A000B10910101D0",
                    INIT_35 => X"D000B0086372D547243C00B03A000BE00B400A3005E509D00800B03D05C4F03D",
                    INIT_36 => X"3A000B00B03D0B400A3005E509D0082005C4F03D900100D0A366C0D090012362",
                    INIT_37 => X"9001B03600DCF036B5311001637BD000B008F5373CFE3CFD6384D562243C00B0",
                    INIT_38 => X"8BE09E012395D401239FD400B40805BFFA01FB0063B2D54B5000B537637BD000",
                    INIT_39 => X"04D023AE6396DE009E0100B000ABD609D404D451140023A714000ED000B0BA00",
                    INIT_3A => X"BA01BB0063A7DE009E0100AED609D404D4510ED063A7DE0014000E4084E01401",
                    INIT_3B => X"D100B10863C6D542243C63B891010496110163B8D100B10863BCD541243C00B0",
                    INIT_3C => X"9001B0080490F008100163CDD000B00863D4D543243C63C29101049D110163C2",
                    INIT_3D => X"D000F0089001B008048AF008100163DBD000B00863E2D544243C63CDD000F008",
                    INIT_3E => X"D549243C63E8D1009101B13D047DF13D110163E8D100B10863EFD55A243C63DB",
                    INIT_3F => X"D006B008641CD56E243C63F5D1009101B13D0476F13D110163F5D100B10863FC",
                   INITP_00 => X"A12368DDDD8A370E90B70242DC0AEB0A96A0A351A822088222082A22AAAA280A",
                   INITP_01 => X"A362ABAA82637DDC32DDDDDDDDDDCCCDCB36A22A596C2820D8360D8360D8360D",
                   INITP_02 => X"6D674DB529D36DB6A643DDB582A221D3623623623683630A0DB636DC28036AAD",
                   INITP_03 => X"025014142A0B6D5D2ABAADA5003555AA00A8142A074AEAB6A0A8374DA82A0DD3",
                   INITP_04 => X"DAADAD36D60A82D56AA024A9D36D6A0B596A806552A74DA0D6A9D0ADA0D56A8A",
                   INITP_05 => X"4DB0CDB03362CDB0CDA0DB0CD8DA03680DA03680D8D8B36C336836C336800D10",
                   INITP_06 => X"4A1D20DA5020A4D74DA5080A4D74DA54D744204D74234DDB58C46CD3631551B3",
                   INITP_07 => X"4DB529D36D4A74DB64A74DB64A74DB674DB674DA0D6A8D052D6AA2095DD2AD8D")
      port map(   ADDRARDADDR => address_a(13 downto 0),
                      ENARDEN => enable,
                    CLKARDCLK => clk,
                        DOADO => data_out_a(15 downto 0),
                      DOPADOP => data_out_a(17 downto 16), 
                        DIADI => data_in_a(15 downto 0),
                      DIPADIP => data_in_a(17 downto 16), 
                          WEA => "00",
                  REGCEAREGCE => '0',
                RSTRAMARSTRAM => '0',
                RSTREGARSTREG => '0',
                  ADDRBWRADDR => address_b(13 downto 0),
                      ENBWREN => enable_b,
                    CLKBWRCLK => clk_b,
                        DOBDO => data_out_b(15 downto 0),
                      DOPBDOP => data_out_b(17 downto 16), 
                        DIBDI => data_in_b(15 downto 0),
                      DIPBDIP => data_in_b(17 downto 16), 
                        WEBWE => we_b(3 downto 0),
                       REGCEB => '0',
                      RSTRAMB => '0',
                      RSTREGB => '0');
      --
    end generate v6;
    --
    --
    akv7 : if (C_FAMILY = "7S") generate
      --
      address_a(13 downto 0) <= address(9 downto 0) & "1111";
      instruction <= data_out_a(17 downto 0);
      data_in_a(17 downto 0) <= "0000000000000000" & address(11 downto 10);
      jtag_dout <= data_out_b(17 downto 0);
      --
      no_loader : if (C_JTAG_LOADER_ENABLE = 0) generate
        data_in_b(17 downto 0) <= data_out_b(17 downto 0);
        address_b(13 downto 0) <= "11111111111111";
        we_b(3 downto 0) <= "0000";
        enable_b <= '0';
        rdl <= '0';
        clk_b <= '0';
      end generate no_loader;
      --
      loader : if (C_JTAG_LOADER_ENABLE = 1) generate
        data_in_b(17 downto 0) <= jtag_din(17 downto 0);
        address_b(13 downto 0) <= jtag_addr(9 downto 0) & "1111";
        we_b(3 downto 0) <= jtag_we & jtag_we & jtag_we & jtag_we;
        enable_b <= jtag_en(0);
        rdl <= rdl_bus(0);
        clk_b <= jtag_clk;
      end generate loader;
      -- 
      kcpsm6_rom: RAMB18E1
      generic map ( READ_WIDTH_A => 18,
                    WRITE_WIDTH_A => 18,
                    DOA_REG => 0,
                    INIT_A => "000000000000000000",
                    RSTREG_PRIORITY_A => "REGCE",
                    SRVAL_A => X"000000000000000000",
                    WRITE_MODE_A => "WRITE_FIRST",
                    READ_WIDTH_B => 18,
                    WRITE_WIDTH_B => 18,
                    DOB_REG => 0,
                    INIT_B => X"000000000000000000",
                    RSTREG_PRIORITY_B => "REGCE",
                    SRVAL_B => X"000000000000000000",
                    WRITE_MODE_B => "WRITE_FIRST",
                    INIT_FILE => "NONE",
                    SIM_COLLISION_CHECK => "ALL",
                    RAM_MODE => "TDP",
                    RDADDR_COLLISION_HWCONFIG => "DELAYED_WRITE",
                    SIM_DEVICE => "7SERIES",
                    INIT_00 => X"F030F031D00ED00FF01FF01EF033F0321000D00BF02F100017431D7820420002",
                    INIT_01 => X"152800B8152006031300B22F056819A8180504BB0038F6341670FC351C000632",
                    INIT_02 => X"00B800B8F03B1010152000B8152906031300027000B815780603130002D000B8",
                    INIT_03 => X"F422B30084D0F321F42005E5097008D0500004E41670602DD0009001B03B1601",
                    INIT_04 => X"100091012051D001900C11A7204200B82042004A006040B3D010B02F5000F323",
                    INIT_05 => X"5000100110009540205610009101205CD001904111A7500010011000950D204B",
                    INIT_06 => X"2002D5A420A6D59EF03030BF5000F030504060A6D59E606AD040B03010000055",
                    INIT_07 => X"D00BF02F30071001B02F50007C205000D5135000F03070806077D553207BD5F3",
                    INIT_08 => X"D00320071D501743608FD00220071D781721608AD00120071D7817436085D000",
                    INIT_09 => X"60A3D00620071D781719609ED00520071D7817326099D00420071D5017216094",
                    INIT_0A => X"3A001B015000BA009B01500060B8D080B030063520071D50171920071D501732",
                    INIT_0B => X"60DCDC90F53160BEDC0320BED51B00B05000D002B021D003B0205000DB03DA02",
                    INIT_0C => X"2476D5092472D57F246AD50820F9D51B60DCDC2060FBDC026154DC011000D500",
                    INIT_0D => X"152020E0DC08F03D2538D5072467D50524BBD50C24A3D50B24A3D50A24E6D50D",
                    INIT_0E => X"D051B0303CEF20ED956020ED151F60EBD56020EDA0EDD55FE0EDD57F20EDDC40",
                    INIT_0F => X"500001495C016100D55B50005C0224F004CF00B000AB5000054E00AED609D504",
                    INIT_10 => X"B030214700B0BC35B634BA33BB32610FD5382147FC35F634FA33FB326107D537",
                    INIT_11 => X"5020B0306122D5282147611CD53E21475C106119D54E20026115D5636122D020",
                    INIT_12 => X"30FE6133D5422147F03030FE5C40612DD530F03030DF2147D020B0305000F030",
                    INIT_13 => X"D56921475C40F0305001613FD53221473CBFF03050016139D53121473CBFF030",
                    INIT_14 => X"E100110010085000F011F007100050003CFD207E00509561E147C4501460E147",
                    INIT_15 => X"5000F1111101E5000010B11110122160A160D52FE160D53A5000614FD0101001",
                    INIT_16 => X"B03704F0F0371001616DD000B0086174D55350006167D53F50006164D53B043F",
                    INIT_17 => X"D568243C617AD0009001050C1001617AD000B008617FD554243C616DD0009001",
                    INIT_18 => X"243CD00BF02F5008B02F243C00B0F02F30EFB02F643CD019218BD00CB0096190",
                    INIT_19 => X"D00BF02F30F7B02F243C00B3F02F5010B02F643CD019219CD00CB00961A1D56C",
                    INIT_1A => X"09D00800100161AED000B008243C04F261AA055704CFFA01FB0061D4D54D243C",
                    INIT_1B => X"950A940592500000DF02DE03F237B121B0202F300E400FA00EB0F33EF43D05E5",
                    INIT_1C => X"B33EB43DBA21BB20B23761BAEF10CE003F001E013A001B01D509D404D25100B0",
                    INIT_1D => X"B008FA3CFB3B243C04FA61DD055704CFFA01FB006210D54C243C04FCAA308B40",
                    INIT_1E => X"BE20F33EF43D05E509D00800243C61E69001050E61EAFA00DB00100161E3D000",
                    INIT_1F => X"950A9405985000B023500240B33CB23B0530AA308B400AF00BE0BF009E01BF21",
                    INIT_20 => X"243C0528B13EB03D61FCEF30CE20BF009E0100ABD509D404D8510000DF02DE03",
                    INIT_21 => X"6219D000900100AED609D504D55110016219D0001500B008FA01FB006224D558",
                    INIT_22 => X"900180E000D005BFFA01FB001101622AD100B108624BD540243C00B0BA01BB00",
                    INIT_23 => X"D000900100B0BA009B02D509D404D25100AE950A94059250100100B03A000B00",
                    INIT_24 => X"6251D100B1086271D550243C622AD1009101D609D404D251B200142000AE6234",
                    INIT_25 => X"1B01D509D404D25100B000AB950A9405925000AE80E000D005BFFA01FB001101",
                    INIT_26 => X"6251D100910100B0BA01BB00D609D404D4511420B25000B06256D00090013A00",
                    INIT_27 => X"6322D56D243C04BD243C04A9627CD001243C04BB6278D002B008627ED54A243C",
                    INIT_28 => X"DC046295D401231EF43034FDB4303CF73CFB1670628DD400A41000101108B007",
                    INIT_29 => X"5608445ADC0462A3D405231EF4305402B430629BD404231E445ADC045680445A",
                    INIT_2A => X"62B5D40A231E5C0862AED408231E5C04045A631EDC0462AAD407231E445ADC04",
                    INIT_2B => X"B4303CBF62C3D40C231EF43034FEB4305C4062BCD40B231EF43034FEB4303CBF",
                    INIT_2C => X"62D6D416231E3CF762CED41C231EF4305401B4305C4062CAD40D231EF4305401",
                    INIT_2D => X"445ADC0462E4D419231EF43034FDB43062DCD418231E445ADC04367F445ADC04",
                    INIT_2E => X"360F445ADC0462F4D427231E3CFB045A231EDC0462EBD41B231E445ADC0436F7",
                    INIT_2F => X"C540151DE30FD426231E445ADC0436F0445ADC0462FCD431231E445ADC045670",
                    INIT_30 => X"D430231EB43D445ADC0406404406440644064406368F941EF43D445ADC04E30F",
                    INIT_31 => X"C1001101231EB43D445ADC04064036F89428F43D445ADC04E31EC5401527E31E",
                    INIT_32 => X"91012330D100A1001008F0091000232BD002B0076346D5662326D548243C6283",
                    INIT_33 => X"A342C1D09101233ED100A10010010B400A3005E509D0081091010170A334C170",
                    INIT_34 => X"90010070A350C0709001234CD000B008635CD564243C00B03A000B10910101D0",
                    INIT_35 => X"D000B0086372D547243C00B03A000BE00B400A3005E509D00800B03D05C4F03D",
                    INIT_36 => X"3A000B00B03D0B400A3005E509D0082005C4F03D900100D0A366C0D090012362",
                    INIT_37 => X"9001B03600DCF036B5311001637BD000B008F5373CFE3CFD6384D562243C00B0",
                    INIT_38 => X"8BE09E012395D401239FD400B40805BFFA01FB0063B2D54B5000B537637BD000",
                    INIT_39 => X"04D023AE6396DE009E0100B000ABD609D404D451140023A714000ED000B0BA00",
                    INIT_3A => X"BA01BB0063A7DE009E0100AED609D404D4510ED063A7DE0014000E4084E01401",
                    INIT_3B => X"D100B10863C6D542243C63B891010496110163B8D100B10863BCD541243C00B0",
                    INIT_3C => X"9001B0080490F008100163CDD000B00863D4D543243C63C29101049D110163C2",
                    INIT_3D => X"D000F0089001B008048AF008100163DBD000B00863E2D544243C63CDD000F008",
                    INIT_3E => X"D549243C63E8D1009101B13D047DF13D110163E8D100B10863EFD55A243C63DB",
                    INIT_3F => X"D006B008641CD56E243C63F5D1009101B13D0476F13D110163F5D100B10863FC",
                   INITP_00 => X"A12368DDDD8A370E90B70242DC0AEB0A96A0A351A822088222082A22AAAA280A",
                   INITP_01 => X"A362ABAA82637DDC32DDDDDDDDDDCCCDCB36A22A596C2820D8360D8360D8360D",
                   INITP_02 => X"6D674DB529D36DB6A643DDB582A221D3623623623683630A0DB636DC28036AAD",
                   INITP_03 => X"025014142A0B6D5D2ABAADA5003555AA00A8142A074AEAB6A0A8374DA82A0DD3",
                   INITP_04 => X"DAADAD36D60A82D56AA024A9D36D6A0B596A806552A74DA0D6A9D0ADA0D56A8A",
                   INITP_05 => X"4DB0CDB03362CDB0CDA0DB0CD8DA03680DA03680D8D8B36C336836C336800D10",
                   INITP_06 => X"4A1D20DA5020A4D74DA5080A4D74DA54D744204D74234DDB58C46CD3631551B3",
                   INITP_07 => X"4DB529D36D4A74DB64A74DB64A74DB674DB674DA0D6A8D052D6AA2095DD2AD8D")
      port map(   ADDRARDADDR => address_a(13 downto 0),
                      ENARDEN => enable,
                    CLKARDCLK => clk,
                        DOADO => data_out_a(15 downto 0),
                      DOPADOP => data_out_a(17 downto 16), 
                        DIADI => data_in_a(15 downto 0),
                      DIPADIP => data_in_a(17 downto 16), 
                          WEA => "00",
                  REGCEAREGCE => '0',
                RSTRAMARSTRAM => '0',
                RSTREGARSTREG => '0',
                  ADDRBWRADDR => address_b(13 downto 0),
                      ENBWREN => enable_b,
                    CLKBWRCLK => clk_b,
                        DOBDO => data_out_b(15 downto 0),
                      DOPBDOP => data_out_b(17 downto 16), 
                        DIBDI => data_in_b(15 downto 0),
                      DIPBDIP => data_in_b(17 downto 16), 
                        WEBWE => we_b(3 downto 0),
                       REGCEB => '0',
                      RSTRAMB => '0',
                      RSTREGB => '0');
      --
    end generate akv7;
    --
  end generate ram_1k_generate;
  --
  --
  --
  ram_2k_generate : if (C_RAM_SIZE_KWORDS = 2) generate
    --
    --
    s6: if (C_FAMILY = "S6") generate
      --
      address_a(13 downto 0) <= address(10 downto 0) & "000";
      instruction <= data_out_a_h(32) & data_out_a_h(7 downto 0) & data_out_a_l(32) & data_out_a_l(7 downto 0);
      data_in_a <= "00000000000000000000000000000000000" & address(11);
      jtag_dout <= data_out_b_h(32) & data_out_b_h(7 downto 0) & data_out_b_l(32) & data_out_b_l(7 downto 0);
      --
      no_loader : if (C_JTAG_LOADER_ENABLE = 0) generate
        data_in_b_l <= "000" & data_out_b_l(32) & "000000000000000000000000" & data_out_b_l(7 downto 0);
        data_in_b_h <= "000" & data_out_b_h(32) & "000000000000000000000000" & data_out_b_h(7 downto 0);
        address_b(13 downto 0) <= "00000000000000";
        we_b(3 downto 0) <= "0000";
        enable_b <= '0';
        rdl <= '0';
        clk_b <= '0';
      end generate no_loader;
      --
      loader : if (C_JTAG_LOADER_ENABLE = 1) generate
        data_in_b_h <= "000" & jtag_din(17) & "000000000000000000000000" & jtag_din(16 downto 9);
        data_in_b_l <= "000" & jtag_din(8) & "000000000000000000000000" & jtag_din(7 downto 0);
        address_b(13 downto 0) <= jtag_addr(10 downto 0) & "000";
        we_b(3 downto 0) <= jtag_we & jtag_we & jtag_we & jtag_we;
        enable_b <= jtag_en(0);
        rdl <= rdl_bus(0);
        clk_b <= jtag_clk;
      end generate loader;
      --
      kcpsm6_rom_l: RAMB16BWER
      generic map ( DATA_WIDTH_A => 9,
                    DOA_REG => 0,
                    EN_RSTRAM_A => FALSE,
                    INIT_A => X"000000000",
                    RST_PRIORITY_A => "CE",
                    SRVAL_A => X"000000000",
                    WRITE_MODE_A => "WRITE_FIRST",
                    DATA_WIDTH_B => 9,
                    DOB_REG => 0,
                    EN_RSTRAM_B => FALSE,
                    INIT_B => X"000000000",
                    RST_PRIORITY_B => "CE",
                    SRVAL_B => X"000000000",
                    WRITE_MODE_B => "WRITE_FIRST",
                    RSTTYPE => "SYNC",
                    INIT_FILE => "NONE",
                    SIM_COLLISION_CHECK => "ALL",
                    SIM_DEVICE => "SPARTAN6",
                    INIT_00 => X"28B82003002F68A805BB38347035003230310E0F1F1E3332000B2F0043784202",
                    INIT_01 => X"2200D02120E570D000E4702D00013B01B8B83B1020B829030070B8780300D0B8",
                    INIT_02 => X"000100405600015C0141A70001000D4B000151010CA742B8424A60B3102F0023",
                    INIT_03 => X"0B2F07012F0020001300308077537BF302A4A69E30BF003040A69E6A40300055",
                    INIT_04 => X"A3060778199E05077832990407502194030750438F020778218A010778438500",
                    INIT_05 => X"DC9031BE03BE1BB00002210320000302000100000100B8803035075019075032",
                    INIT_06 => X"20E0083D38076705BB0CA30BA30AE60D7609727F6A08F91BDC20FB0254010000",
                    INIT_07 => X"004901005B0002F0CFB0AB004EAE09045130EFED60ED1FEB60EDED5FED7FED40",
                    INIT_08 => X"20302228471C3E4710194E02156322203047B0353433320F3847353433320737",
                    INIT_09 => X"69474030013F3247BF3001393147BF30FE33424730FE402D3030DF4720300030",
                    INIT_0A => X"0011010010111260602F603A004F10010000080011070000FD7E506147506047",
                    INIT_0B => X"683C7A00010C017A00087F543C6D000137F037016D0008745300673F00643B3F",
                    INIT_0C => X"0B2FF72F3CB32F102F3C199C0C09A16C3C0B2F082F3CB02FEF2F3C198B0C0990",
                    INIT_0D => X"0A05500002033721203040A0B03E3DE5D00001AE00083CF2AA57CF0100D44D3C",
                    INIT_0E => X"083C3B3CFADD57CF0100104C3CFC30403E3D212037BA100000010001090451B0",
                    INIT_0F => X"0A0550B050403C3B303040F0E0000121203E3DE5D0003CE6010EEA000001E300",
                    INIT_10 => X"190001AE0904510119000008010024583C283E3DFC30200001AB090451000203",
                    INIT_11 => X"0001B00002090451AE0A055001B0000001E0D0BF0100012A00084B403CB00100",
                    INIT_12 => X"01090451B0AB0A0550AEE0D0BF01000151000871503C2A00010904510020AE34",
                    INIT_13 => X"226D3CBD3CA97C013CBB7802087E4A3C510001B001000904512050B056000100",
                    INIT_14 => X"085A04A3051E3002309B041E5A04805A0495011E30FD30F7FB708D0010100807",
                    INIT_15 => X"30BFC30C1E30FE3040BC0B1E30FE30BFB50A1E08AE081E045A1E04AA071E5A04",
                    INIT_16 => X"5A04E4191E30FD30DC181E5A047F5A04D6161EF7CE1C1E30013040CA0D1E3001",
                    INIT_17 => X"401D0F261E5A04F05A04FC311E5A04700F5A04F4271EFB5A1E04EB1B1E5A04F7",
                    INIT_18 => X"00011E3D5A0440F8283D5A041E40271E301E3D5A0440060606068F1E3D5A040F",
                    INIT_19 => X"42D0013E0000014030E5D01001703470013000000809002B0207466626483C83",
                    INIT_1A => X"000872473CB000E04030E5D0003DC43D01705070014C00085C643CB0001001D0",
                    INIT_1B => X"0136DC3631017B000837FEFD84623CB000003D4030E5D020C43D01D066D00162",
                    INIT_1C => X"D0AE960001B0AB09045100A700D0B000E00195019F0008BF0100B24B00377B00",
                    INIT_1D => X"0008C6423CB8019601B80008BC413CB00100A70001AE090451D0A7000040E001",
                    INIT_1E => X"000801088A0801DB0008E2443CCD00080108900801CD0008D4433CC2019D01C2",
                    INIT_1F => X"06081C6E3CF500013D763D01F50008FC493CE800013D7D3D01E80008EF5A3CDB",
                    INIT_20 => X"7E3C1F723C3E3D01003552F00001003F353BF000013FC4355B351B3E3D01001B",
                    INIT_21 => X"0000FEFD3CDA3C063CD638053CDE34043C510130033C2A012B023CCF2601083C",
                    INIT_22 => X"0E0E0E0E603E000701110000100708E04440E50AE00150000140300012500011",
                    INIT_23 => X"0000C4B00010000807B08AB8208A8A00B00001000000003506003E4006060606",
                    INIT_24 => X"D0005700B000D00000D000AE00D001C400B0AB0000C4B00008B00000870007E0",
                    INIT_25 => X"000100000000B00100090451ACB00000AB09045100010000B000D0F05700B000",
                    INIT_26 => X"ABCF00B0232200B0000000B000E00000C400B00100C210000001090451B02120",
                    INIT_27 => X"B021200023220E0F1F1E00D01F1E0100232200B0EE4E00D000CFE8E600B000D0",
                    INIT_28 => X"D00001090451B00000000E0F1F1E00D01F1E010000B00100FF10000001090451",
                    INIT_29 => X"010043DC433D010000B0010029000000010001090451B00000D000B001001900",
                    INIT_2A => X"003A39100023223A39003A39100021203A3900454E0001095A0AB0000000B03D",
                    INIT_2B => X"7B0035910F4035910E0E0E0E406800010100B801000000906100000136DC3600",
                    INIT_2C => X"DC3EDC40007F0800DC3C003A07940A00DC910F40DC910E0E0E0E4000DC7D85DC",
                    INIT_2D => X"B0002065646F4D202032302E3156206D7265546B6361755100DC7DDC40DC7B00",
                    INIT_2E => X"E0688909CE0001080E00069080D607D390800900003020C900D0A0B0C60001A0",
                    INIT_2F => X"F60100023530FC0050E000061600000000E806080880EB2000000100E0000001",
                    INIT_30 => X"00302017010006401D0200B83009010002B8300F0050E0000616130000003530",
                    INIT_31 => X"0000000000000001350400000131240001080E000690802C072990800D00A000",
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
                    INIT_3F => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_00 => X"58090A948D5555092202481B18C6318C008550201222440156000A94AB00000C",
                   INITP_01 => X"8AAD596A26519698895590CE00130009A53409B675F4C019C71C71903F6E43C7",
                   INITP_02 => X"E8080488082022040810224404101002C0026400C20B69800C4116D106256D22",
                   INITP_03 => X"17BFBDFD013404DBF6FC60206010A9760A4C568931B224C7FD6FF13CE00F4001",
                   INITP_04 => X"56A945010444894228810228A241049027082480018431830000210094BA72B2",
                   INITP_05 => X"87E24F4AA8D5956D7FFFFF2A545E77E69DFD92BB4D269A08791D2D86AD6A912B",
                   INITP_06 => X"0000000000000000000000000000000000000000000000000100342340082F11",
                   INITP_07 => X"0000000000000000000000000000000000000000000000000000000000000000")
      port map(  ADDRA => address_a(13 downto 0),
                   ENA => enable,
                  CLKA => clk,
                   DOA => data_out_a_l(31 downto 0),
                  DOPA => data_out_a_l(35 downto 32), 
                   DIA => data_in_a(31 downto 0),
                  DIPA => data_in_a(35 downto 32), 
                   WEA => "0000",
                REGCEA => '0',
                  RSTA => '0',
                 ADDRB => address_b(13 downto 0),
                   ENB => enable_b,
                  CLKB => clk_b,
                   DOB => data_out_b_l(31 downto 0),
                  DOPB => data_out_b_l(35 downto 32), 
                   DIB => data_in_b_l(31 downto 0),
                  DIPB => data_in_b_l(35 downto 32), 
                   WEB => we_b(3 downto 0),
                REGCEB => '0',
                  RSTB => '0');
      -- 
      kcpsm6_rom_h: RAMB16BWER
      generic map ( DATA_WIDTH_A => 9,
                    DOA_REG => 0,
                    EN_RSTRAM_A => FALSE,
                    INIT_A => X"000000000",
                    RST_PRIORITY_A => "CE",
                    SRVAL_A => X"000000000",
                    WRITE_MODE_A => "WRITE_FIRST",
                    DATA_WIDTH_B => 9,
                    DOB_REG => 0,
                    EN_RSTRAM_B => FALSE,
                    INIT_B => X"000000000",
                    RST_PRIORITY_B => "CE",
                    SRVAL_B => X"000000000",
                    WRITE_MODE_B => "WRITE_FIRST",
                    RSTTYPE => "SYNC",
                    INIT_FILE => "NONE",
                    SIM_COLLISION_CHECK => "ALL",
                    SIM_DEVICE => "SPARTAN6",
                    INIT_00 => X"0A000A030959020C0C02007B0B7E0E037878686878787878086878080B0E1000",
                    INIT_01 => X"7AD9C2797A02040428020BB0E8C8588B000078080A000A030901000A03090100",
                    INIT_02 => X"2888084A1088C8906848082888084A1088C8906848081000900000A068582879",
                    INIT_03 => X"6878188858283EA8EA287838B0EA90EA90EA90EA7818287828B0EAB068588800",
                    INIT_04 => X"B0E8100E0BB0E8100E0BB0E8100E0BB0E8100E0BB0E8100E0BB0E8100E0BB0E8",
                    INIT_05 => X"B06E7AB06E90EA002868586858286D6D9D8D28DDCD28B0685803100E0B100E0B",
                    INIT_06 => X"0A906E7892EA92EA92EA92EA92EA92EA92EA92EA92EA90EAB06EB06EB06E88EA",
                    INIT_07 => X"28002EB0EA282E12020000A802006B6A68581E10CA100AB0EA90D0EAF0EA906E",
                    INIT_08 => X"2858B0EA10B0EA102EB0EA10B0EAB0685810005E5B5D5DB0EA107E7B7D7DB0EA",
                    INIT_09 => X"EA102E7828B0EA101E7828B0EA101E7818B0EA1078182EB0EA78189068582878",
                    INIT_0A => X"2878887280580890D0EAF0EA28B0E88870080828787808281E1000CAF0E20AF0",
                    INIT_0B => X"EA12B0E8C80288B0E858B0EA12B0E8C858027888B0E858B0EA28B0EA28B0EA02",
                    INIT_0C => X"687818581200782858B2E890E858B0EA12687828581200781858B2E890E858B0",
                    INIT_0D => X"4A4A49006F6F79585897870707797A02040488B0E8581202B002027D7DB0EA12",
                    INIT_0E => X"587D7D1202B002027D7DB1EA1202D5C5595A5D5D59B0F7E79F8F9D8D6A6A6900",
                    INIT_0F => X"4A4A4C009181595902D5C50505DFCF5F5F797A02040412B0C802B0FDED88B0E8",
                    INIT_10 => X"B1E8C8006B6A6A88B1E80A587D7DB1EA12025858B0F7E7DFCF006A6A6C006F6F",
                    INIT_11 => X"E8C800DDCD6A6A69004A4A4988009D85C8C000027D7D88B1E858B1EA12005D5D",
                    INIT_12 => X"8D6A6A6900004A4A4900C000027D7D88B1E858B1EA12B1E8C86B6A69590A00B1",
                    INIT_13 => X"B1EA12021202B1E81202B1E858B1EA12B1E8C8005D5D6B6A6A0A5900B1E8C89D",
                    INIT_14 => X"2BA26EB1EA117A2A5AB1EA11A26E2BA26EB1EA117A1A5A1E1E0BB1EA52800858",
                    INIT_15 => X"5A1EB1EA117A1A5A2EB1EA117A1A5A1EB1EA112EB1EA112E02B16EB1EA11A26E",
                    INIT_16 => X"A26EB1EA117A1A5AB1EA11A26E1BA26EB1EA111EB1EA117A2A5A2EB1EA117A2A",
                    INIT_17 => X"E20AF1EA11A26E1BA26EB1EA11A26E2B1BA26EB1EA111E02916EB1EA11A26E1B",
                    INIT_18 => X"E088115AA26E831BCA7AA26EF1E20AF1EA115AA26E83A2A2A2A21BCA7AA26EF1",
                    INIT_19 => X"D1E0C891E850880505020404C800D1E0C891E85008780891E858B1EA91EA12B1",
                    INIT_1A => X"E858B1EA12009D850505020404580278C800D1E0C891E858B1EA12009D85C800",
                    INIT_1B => X"C85800785A88B1E8587A1E1EB1EA12009D855805050204040278C800D1E0C891",
                    INIT_1C => X"0211B1EFCF00006B6A6A0A110A0700DDC5CF91EA91EA5A027D7DB1EA285AB1E8",
                    INIT_1D => X"E858B1EA12B1C80288B1E858B1EA12005D5DB1EFCF006B6A6A07B1EF0A07C28A",
                    INIT_1E => X"E878C858027888B1E858B1EA12B1E878C858027888B1E858B1EA12B1C80288B1",
                    INIT_1F => X"E858B2EA12B1E8C858027888B1E858B1EA12B1E8C858027888B1E858B1EA12B1",
                    INIT_20 => X"EA12B2EA125A5A5D5D030A0299890959030A0299897F02030A030A7A7A7D7DB2",
                    INIT_21 => X"0F281E1E1202B2E81202B2E81202B2E8120108B2E8120108B2E81202B2E858B2",
                    INIT_22 => X"A3A3A3A3027A287888780877805808021207020C048892E8C887CA520892E858",
                    INIT_23 => X"88EF02109D85C008180012000A02122800DDCD88FDED28030A285A23A2A2A2A2",
                    INIT_24 => X"85E8022800DDC5C8FDE5280088E78F0228000088EF0210DDCD10DDC592E81800",
                    INIT_25 => X"0A7D7D0D0D28005D5D6B6A69B200FDED006B6A6A0A7D7D28009D85F20228009D",
                    INIT_26 => X"000228005D5D28000D0D2800DDC588EF0228005D5DB2F5E59D8D6B6A6A005858",
                    INIT_27 => X"0058580A5D5D6F6F7F7F9F875F5F7D7D5D5D280092029D852802120228009D85",
                    INIT_28 => X"E59D8D6B6A6A000A0D0D6F6F7F7FDFC75F5F7D7D28005D5DB2F5E59D8D6B6A6A",
                    INIT_29 => X"5D5D0202027B7D7D28005D5DB2F8E8D8C89D8D6B6A6A000A080028005D5DB2FD",
                    INIT_2A => X"285858F5E558587878285858F5E55858787828B2029D8D6B024B000D0D28005B",
                    INIT_2B => X"0A2803021A020302A2A2A2A202129C8C5C5C007C7C88EA241288EA8A5A007A0A",
                    INIT_2C => X"000A00025A025A7A000A288A8AD2CA2800021A020002A2A2A2A20228000A0200",
                    INIT_2D => X"010A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A28000A0002000A28",
                    INIT_2E => X"120808091288C8A4A4A1A1978712A1D2D7C70809090707120C04010112998901",
                    INIT_2F => X"12CF88EF038A92EF87520F0F0393F9E928B2A1A2A18192640A090928B2D9D8C8",
                    INIT_30 => X"090707138A88EA77030A28000A13CF88EF008A93EF87520F0F0393F9E928030A",
                    INIT_31 => X"000000000000286AB368482858581388C8A4A4A1A1978713A1D3D7C7080C0C09",
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
                    INIT_3F => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_00 => X"D5FF956A5AAAAAAAB5D72664A5294A52C56AAB538D11A3F39CD0E5295275FF63",
                   INITP_01 => X"100073627FEC040F0E0713FDCE52E729652C696DD1AC9D49555559532D5A617E",
                   INITP_02 => X"2CAC55ACACB2AB162C58AAD656595820BEE593987C4E967327841D2C9E8EC87B",
                   INITP_03 => X"2C69634B4D2D34B52D4B27A067D229EA324B04C92C2324B09042452B2869500D",
                   INITP_04 => X"83C33CFCF332E43C667CF79E7939F648B03793400750A2044EEED6B96850A75F",
                   INITP_05 => X"AA0CC2188C0501087FFFFFD5A5A5CC1B73043DC681C0F9A63FC81E321E3C3C87",
                   INITP_06 => X"000000000000000000000000000000000000000000000000039F014015B55066",
                   INITP_07 => X"0000000000000000000000000000000000000000000000000000000000000000")
      port map(  ADDRA => address_a(13 downto 0),
                   ENA => enable,
                  CLKA => clk,
                   DOA => data_out_a_h(31 downto 0),
                  DOPA => data_out_a_h(35 downto 32), 
                   DIA => data_in_a(31 downto 0),
                  DIPA => data_in_a(35 downto 32), 
                   WEA => "0000",
                REGCEA => '0',
                  RSTA => '0',
                 ADDRB => address_b(13 downto 0),
                   ENB => enable_b,
                  CLKB => clk_b,
                   DOB => data_out_b_h(31 downto 0),
                  DOPB => data_out_b_h(35 downto 32), 
                   DIB => data_in_b_h(31 downto 0),
                  DIPB => data_in_b_h(35 downto 32), 
                   WEB => we_b(3 downto 0),
                REGCEB => '0',
                  RSTB => '0');
    --
    end generate s6;
    --
    --
    v6 : if (C_FAMILY = "V6") generate
      --
      address_a <= '1' & address(10 downto 0) & "1111";
      instruction <= data_out_a(33 downto 32) & data_out_a(15 downto 0);
      data_in_a <= "00000000000000000000000000000000000" & address(11);
      jtag_dout <= data_out_b(33 downto 32) & data_out_b(15 downto 0);
      --
      no_loader : if (C_JTAG_LOADER_ENABLE = 0) generate
        data_in_b <= "00" & data_out_b(33 downto 32) & "0000000000000000" & data_out_b(15 downto 0);
        address_b <= "1111111111111111";
        we_b <= "00000000";
        enable_b <= '0';
        rdl <= '0';
        clk_b <= '0';
      end generate no_loader;
      --
      loader : if (C_JTAG_LOADER_ENABLE = 1) generate
        data_in_b <= "00" & jtag_din(17 downto 16) & "0000000000000000" & jtag_din(15 downto 0);
        address_b <= '1' & jtag_addr(10 downto 0) & "1111";
        we_b <= jtag_we & jtag_we & jtag_we & jtag_we & jtag_we & jtag_we & jtag_we & jtag_we;
        enable_b <= jtag_en(0);
        rdl <= rdl_bus(0);
        clk_b <= jtag_clk;
      end generate loader;
      --
      kcpsm6_rom: RAMB36E1
      generic map ( READ_WIDTH_A => 18,
                    WRITE_WIDTH_A => 18,
                    DOA_REG => 0,
                    INIT_A => X"000000000",
                    RSTREG_PRIORITY_A => "REGCE",
                    SRVAL_A => X"000000000",
                    WRITE_MODE_A => "WRITE_FIRST",
                    READ_WIDTH_B => 18,
                    WRITE_WIDTH_B => 18,
                    DOB_REG => 0,
                    INIT_B => X"000000000",
                    RSTREG_PRIORITY_B => "REGCE",
                    SRVAL_B => X"000000000",
                    WRITE_MODE_B => "WRITE_FIRST",
                    INIT_FILE => "NONE",
                    SIM_COLLISION_CHECK => "ALL",
                    RAM_MODE => "TDP",
                    RDADDR_COLLISION_HWCONFIG => "DELAYED_WRITE",
                    EN_ECC_READ => FALSE,
                    EN_ECC_WRITE => FALSE,
                    RAM_EXTENSION_A => "NONE",
                    RAM_EXTENSION_B => "NONE",
                    SIM_DEVICE => "VIRTEX6",
                    INIT_00 => X"F030F031D00ED00FF01FF01EF033F0321000D00BF02F100017431D7820420002",
                    INIT_01 => X"152800B8152006031300B22F056819A8180504BB0038F6341670FC351C000632",
                    INIT_02 => X"00B800B8F03B1010152000B8152906031300027000B815780603130002D000B8",
                    INIT_03 => X"F422B30084D0F321F42005E5097008D0500004E41670602DD0009001B03B1601",
                    INIT_04 => X"100091012051D001900C11A7204200B82042004A006040B3D010B02F5000F323",
                    INIT_05 => X"5000100110009540205610009101205CD001904111A7500010011000950D204B",
                    INIT_06 => X"2002D5A420A6D59EF03030BF5000F030504060A6D59E606AD040B03010000055",
                    INIT_07 => X"D00BF02F30071001B02F50007C205000D5135000F03070806077D553207BD5F3",
                    INIT_08 => X"D00320071D501743608FD00220071D781721608AD00120071D7817436085D000",
                    INIT_09 => X"60A3D00620071D781719609ED00520071D7817326099D00420071D5017216094",
                    INIT_0A => X"3A001B015000BA009B01500060B8D080B030063520071D50171920071D501732",
                    INIT_0B => X"60DCDC90F53160BEDC0320BED51B00B05000D002B021D003B0205000DB03DA02",
                    INIT_0C => X"2476D5092472D57F246AD50820F9D51B60DCDC2060FBDC026154DC011000D500",
                    INIT_0D => X"152020E0DC08F03D2538D5072467D50524BBD50C24A3D50B24A3D50A24E6D50D",
                    INIT_0E => X"D051B0303CEF20ED956020ED151F60EBD56020EDA0EDD55FE0EDD57F20EDDC40",
                    INIT_0F => X"500001495C016100D55B50005C0224F004CF00B000AB5000054E00AED609D504",
                    INIT_10 => X"B030214700B0BC35B634BA33BB32610FD5382147FC35F634FA33FB326107D537",
                    INIT_11 => X"5020B0306122D5282147611CD53E21475C106119D54E20026115D5636122D020",
                    INIT_12 => X"30FE6133D5422147F03030FE5C40612DD530F03030DF2147D020B0305000F030",
                    INIT_13 => X"D56921475C40F0305001613FD53221473CBFF03050016139D53121473CBFF030",
                    INIT_14 => X"E100110010085000F011F007100050003CFD207E00509561E147C4501460E147",
                    INIT_15 => X"5000F1111101E5000010B11110122160A160D52FE160D53A5000614FD0101001",
                    INIT_16 => X"B03704F0F0371001616DD000B0086174D55350006167D53F50006164D53B043F",
                    INIT_17 => X"D568243C617AD0009001050C1001617AD000B008617FD554243C616DD0009001",
                    INIT_18 => X"243CD00BF02F5008B02F243C00B0F02F30EFB02F643CD019218BD00CB0096190",
                    INIT_19 => X"D00BF02F30F7B02F243C00B3F02F5010B02F643CD019219CD00CB00961A1D56C",
                    INIT_1A => X"09D00800100161AED000B008243C04F261AA055704CFFA01FB0061D4D54D243C",
                    INIT_1B => X"950A940592500000DF02DE03F237B121B0202F300E400FA00EB0F33EF43D05E5",
                    INIT_1C => X"B33EB43DBA21BB20B23761BAEF10CE003F001E013A001B01D509D404D25100B0",
                    INIT_1D => X"B008FA3CFB3B243C04FA61DD055704CFFA01FB006210D54C243C04FCAA308B40",
                    INIT_1E => X"BE20F33EF43D05E509D00800243C61E69001050E61EAFA00DB00100161E3D000",
                    INIT_1F => X"950A9405985000B023500240B33CB23B0530AA308B400AF00BE0BF009E01BF21",
                    INIT_20 => X"243C0528B13EB03D61FCEF30CE20BF009E0100ABD509D404D8510000DF02DE03",
                    INIT_21 => X"6219D000900100AED609D504D55110016219D0001500B008FA01FB006224D558",
                    INIT_22 => X"900180E000D005BFFA01FB001101622AD100B108624BD540243C00B0BA01BB00",
                    INIT_23 => X"D000900100B0BA009B02D509D404D25100AE950A94059250100100B03A000B00",
                    INIT_24 => X"6251D100B1086271D550243C622AD1009101D609D404D251B200142000AE6234",
                    INIT_25 => X"1B01D509D404D25100B000AB950A9405925000AE80E000D005BFFA01FB001101",
                    INIT_26 => X"6251D100910100B0BA01BB00D609D404D4511420B25000B06256D00090013A00",
                    INIT_27 => X"6322D56D243C04BD243C04A9627CD001243C04BB6278D002B008627ED54A243C",
                    INIT_28 => X"DC046295D401231EF43034FDB4303CF73CFB1670628DD400A41000101108B007",
                    INIT_29 => X"5608445ADC0462A3D405231EF4305402B430629BD404231E445ADC045680445A",
                    INIT_2A => X"62B5D40A231E5C0862AED408231E5C04045A631EDC0462AAD407231E445ADC04",
                    INIT_2B => X"B4303CBF62C3D40C231EF43034FEB4305C4062BCD40B231EF43034FEB4303CBF",
                    INIT_2C => X"62D6D416231E3CF762CED41C231EF4305401B4305C4062CAD40D231EF4305401",
                    INIT_2D => X"445ADC0462E4D419231EF43034FDB43062DCD418231E445ADC04367F445ADC04",
                    INIT_2E => X"360F445ADC0462F4D427231E3CFB045A231EDC0462EBD41B231E445ADC0436F7",
                    INIT_2F => X"C540151DE30FD426231E445ADC0436F0445ADC0462FCD431231E445ADC045670",
                    INIT_30 => X"D430231EB43D445ADC0406404406440644064406368F941EF43D445ADC04E30F",
                    INIT_31 => X"C1001101231EB43D445ADC04064036F89428F43D445ADC04E31EC5401527E31E",
                    INIT_32 => X"91012330D100A1001008F0091000232BD002B0076346D5662326D548243C6283",
                    INIT_33 => X"A342C1D09101233ED100A10010010B400A3005E509D0081091010170A334C170",
                    INIT_34 => X"90010070A350C0709001234CD000B008635CD564243C00B03A000B10910101D0",
                    INIT_35 => X"D000B0086372D547243C00B03A000BE00B400A3005E509D00800B03D05C4F03D",
                    INIT_36 => X"3A000B00B03D0B400A3005E509D0082005C4F03D900100D0A366C0D090012362",
                    INIT_37 => X"9001B03600DCF036B5311001637BD000B008F5373CFE3CFD6384D562243C00B0",
                    INIT_38 => X"8BE09E012395D401239FD400B40805BFFA01FB0063B2D54B5000B537637BD000",
                    INIT_39 => X"04D023AE6396DE009E0100B000ABD609D404D451140023A714000ED000B0BA00",
                    INIT_3A => X"BA01BB0063A7DE009E0100AED609D404D4510ED063A7DE0014000E4084E01401",
                    INIT_3B => X"D100B10863C6D542243C63B891010496110163B8D100B10863BCD541243C00B0",
                    INIT_3C => X"9001B0080490F008100163CDD000B00863D4D543243C63C29101049D110163C2",
                    INIT_3D => X"D000F0089001B008048AF008100163DBD000B00863E2D544243C63CDD000F008",
                    INIT_3E => X"D549243C63E8D1009101B13D047DF13D110163E8D100B10863EFD55A243C63DB",
                    INIT_3F => X"D006B008641CD56E243C63F5D1009101B13D0476F13D110163F5D100B10863FC",
                    INIT_40 => X"0635153B05F033001201FE3F05C40635155B0635151BF53EF43DFA01FB00641B",
                    INIT_41 => X"D57E243C641FD572243CB53EB43DBA01BB000635155205F0330012011300B23F",
                    INIT_42 => X"243C025111016430D003243C022A1101642BD002243C04CF6426D001B008643C",
                    INIT_43 => X"1E0050003CFE3CFD243C04DA643CD006243C04D66438D005243C04DE6434D004",
                    INIT_44 => X"24440E4005E5190A08E010012450D10091010E409430A40010122450D100B111",
                    INIT_45 => X"460E460E460E460E0460F43E5000F1071101F0111000EE000010B107100804E0",
                    INIT_46 => X"00B0BA009B011000FA00DB005000063515065000B43E46404406440644064406",
                    INIT_47 => X"1000DE0005C420B03A000B1081001108300700B0248A00B81520048A248A5000",
                    INIT_48 => X"500000B000AB1000DE0005C420B0BA009B0820B0BA008B002487D000300700E0",
                    INIT_49 => X"0BD0D0000557500000B0BA008BD09000FA00CBD0500000AE1000CED01E0105C4",
                    INIT_4A => X"00ABD609D404D4511400FA01FB00500000B03A000BD0E4F00557500000B03A00",
                    INIT_4B => X"1400FA01FB001A001B00500000B0BA01BB00D609D404D25164AC00B0FA00DB00",
                    INIT_4C => X"05C4500000B0BA01BB0064C2EA10CB003A001B01D609D404D45100B0B121B020",
                    INIT_4D => X"00AB04CF500000B0BA23BB22500000B01A001B00500000B0BA008BE01000DE00",
                    INIT_4E => X"BA23BB22500000B024EE054E3A000BD0500004CF24E804E6500000B03A000BD0",
                    INIT_4F => X"00B0B121B0201500BA23BB22DF0EDE0FFF1FFE1E3F000ED0BF1FBE1EFA01FB00",
                    INIT_50 => X"BF1FBE1EFA01FB00500000B0BA01BB0064FFEA10CB003A001B01D609D504D551",
                    INIT_51 => X"CBD03A001B01D609D504D55100B015001A001B00DF0EDE0FFF1FFE1EBF008ED0",
                    INIT_52 => X"90013A001B01D609D504D55100B01500110000D0500000B0BA01BB006519FA00",
                    INIT_53 => X"BA01BB00054305DC0543F63DFA01FB00500000B0BA01BB006529F100D000B100",
                    INIT_54 => X"F13AF03950006545054E3A001B01D609045A960A00B01A001B00500000B0B63D",
                    INIT_55 => X"5000B13AB039EA10CB00B123B022F13AF0395000B13AB039EA10CB00B121B020",
                    INIT_56 => X"B901B80000B8F901F8001000D500489025611000D5001501B53600DCF5361500",
                    INIT_57 => X"157B500006350591350F054006350591450E450E450E450E0540256838001901",
                    INIT_58 => X"00DC0591350F054000DC0591450E450E450E450E0540500000DC157D058500DC",
                    INIT_59 => X"00DC153E00DC0540B400057FB408F40000DC153C5000153A1507A594950A5000",
                    INIT_5A => X"157215651554156B1563156115751551500000DC157D00DC054000DC157B5000",
                    INIT_5B => X"02B01500152015651564156F154D1520152015321530152E153115561520156D",
                    INIT_5C => X"AF908E801009130012000F300E2025C9180009D003A002B025C63300120103A0",
                    INIT_5D => X"25E010681189120925CE100090014808490E430042062F900E8025D64207A5D3",
                    INIT_5E => X"500065E8420644084308038025EBC920140013001201500065E0B200B1009001",
                    INIT_5F => X"25F69E011000DE020635153025FCDF000F50A5E01F001E0606162600F300D200",
                    INIT_60 => X"DE0200B81530260FDF000F50A5E01F001E0606162613F300D200500006351530",
                    INIT_61 => X"12000F300E20261714011000D406EE40061D1402500000B8153026099E011000",
                    INIT_62 => X"90014808490E430042062F900E80262C4207A629AF908E80100D180019A01300",
                    INIT_63 => X"0000000000000000000000005000D5016635D00490005000B001B03126241000",
                    INIT_64 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_65 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_66 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_67 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_68 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_69 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_70 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_71 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_72 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_73 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_74 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_75 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_76 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_77 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_78 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_79 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7F => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_00 => X"A12368DDDD8A370E90B70242DC0AEB0A96A0A351A822088222082A22AAAA280A",
                   INITP_01 => X"A362ABAA82637DDC32DDDDDDDDDDCCCDCB36A22A596C2820D8360D8360D8360D",
                   INITP_02 => X"6D674DB529D36DB6A643DDB582A221D3623623623683630A0DB636DC28036AAD",
                   INITP_03 => X"025014142A0B6D5D2ABAADA5003555AA00A8142A074AEAB6A0A8374DA82A0DD3",
                   INITP_04 => X"DAADAD36D60A82D56AA024A9D36D6A0B596A806552A74DA0D6A9D0ADA0D56A8A",
                   INITP_05 => X"4DB0CDB03362CDB0CDA0DB0CD8DA03680DA03680D8D8B36C336836C336800D10",
                   INITP_06 => X"4A1D20DA5020A4D74DA5080A4D74DA54D744204D74234DDB58C46CD3631551B3",
                   INITP_07 => X"4DB529D36D4A74DB64A74DB64A74DB674DB674DA0D6A8D052D6AA2095DD2AD8D",
                   INITP_08 => X"DA540A2A975A2055552A6240881D543420ADADADA368DAD36D802250896A22AB",
                   INITP_09 => X"800AA50A0AE5AAA5AA0A0A5DA8355AA028282AE5AA2A97A97A975AD6AB6965D0",
                   INITP_0A => X"2A0A55250AB6B5288142A050AB9688280AAAA0D556A80A0D56A80AA50AA0D56A",
                   INITP_0B => X"9D9D40B5B55C02D580B55567500200942AAAAAAAAAAAA22288228976A0A5528A",
                   INITP_0C => X"00000000000000000000000000000000000AC2AB5556750002768A2767502D68",
                   INITP_0D => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0E => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0F => X"0000000000000000000000000000000000000000000000000000000000000000")
      port map(   ADDRARDADDR => address_a,
                      ENARDEN => enable,
                    CLKARDCLK => clk,
                        DOADO => data_out_a(31 downto 0),
                      DOPADOP => data_out_a(35 downto 32), 
                        DIADI => data_in_a(31 downto 0),
                      DIPADIP => data_in_a(35 downto 32), 
                          WEA => "0000",
                  REGCEAREGCE => '0',
                RSTRAMARSTRAM => '0',
                RSTREGARSTREG => '0',
                  ADDRBWRADDR => address_b,
                      ENBWREN => enable_b,
                    CLKBWRCLK => clk_b,
                        DOBDO => data_out_b(31 downto 0),
                      DOPBDOP => data_out_b(35 downto 32), 
                        DIBDI => data_in_b(31 downto 0),
                      DIPBDIP => data_in_b(35 downto 32), 
                        WEBWE => we_b,
                       REGCEB => '0',
                      RSTRAMB => '0',
                      RSTREGB => '0',
                   CASCADEINA => '0',
                   CASCADEINB => '0',
                INJECTDBITERR => '0',
                INJECTSBITERR => '0');
      --
    end generate v6;
    --
    --
    akv7 : if (C_FAMILY = "7S") generate
      --
      address_a <= '1' & address(10 downto 0) & "1111";
      instruction <= data_out_a(33 downto 32) & data_out_a(15 downto 0);
      data_in_a <= "00000000000000000000000000000000000" & address(11);
      jtag_dout <= data_out_b(33 downto 32) & data_out_b(15 downto 0);
      --
      no_loader : if (C_JTAG_LOADER_ENABLE = 0) generate
        data_in_b <= "00" & data_out_b(33 downto 32) & "0000000000000000" & data_out_b(15 downto 0);
        address_b <= "1111111111111111";
        we_b <= "00000000";
        enable_b <= '0';
        rdl <= '0';
        clk_b <= '0';
      end generate no_loader;
      --
      loader : if (C_JTAG_LOADER_ENABLE = 1) generate
        data_in_b <= "00" & jtag_din(17 downto 16) & "0000000000000000" & jtag_din(15 downto 0);
        address_b <= '1' & jtag_addr(10 downto 0) & "1111";
        we_b <= jtag_we & jtag_we & jtag_we & jtag_we & jtag_we & jtag_we & jtag_we & jtag_we;
        enable_b <= jtag_en(0);
        rdl <= rdl_bus(0);
        clk_b <= jtag_clk;
      end generate loader;
      --
      kcpsm6_rom: RAMB36E1
      generic map ( READ_WIDTH_A => 18,
                    WRITE_WIDTH_A => 18,
                    DOA_REG => 0,
                    INIT_A => X"000000000",
                    RSTREG_PRIORITY_A => "REGCE",
                    SRVAL_A => X"000000000",
                    WRITE_MODE_A => "WRITE_FIRST",
                    READ_WIDTH_B => 18,
                    WRITE_WIDTH_B => 18,
                    DOB_REG => 0,
                    INIT_B => X"000000000",
                    RSTREG_PRIORITY_B => "REGCE",
                    SRVAL_B => X"000000000",
                    WRITE_MODE_B => "WRITE_FIRST",
                    INIT_FILE => "NONE",
                    SIM_COLLISION_CHECK => "ALL",
                    RAM_MODE => "TDP",
                    RDADDR_COLLISION_HWCONFIG => "DELAYED_WRITE",
                    EN_ECC_READ => FALSE,
                    EN_ECC_WRITE => FALSE,
                    RAM_EXTENSION_A => "NONE",
                    RAM_EXTENSION_B => "NONE",
                    SIM_DEVICE => "7SERIES",
                    INIT_00 => X"F030F031D00ED00FF01FF01EF033F0321000D00BF02F100017431D7820420002",
                    INIT_01 => X"152800B8152006031300B22F056819A8180504BB0038F6341670FC351C000632",
                    INIT_02 => X"00B800B8F03B1010152000B8152906031300027000B815780603130002D000B8",
                    INIT_03 => X"F422B30084D0F321F42005E5097008D0500004E41670602DD0009001B03B1601",
                    INIT_04 => X"100091012051D001900C11A7204200B82042004A006040B3D010B02F5000F323",
                    INIT_05 => X"5000100110009540205610009101205CD001904111A7500010011000950D204B",
                    INIT_06 => X"2002D5A420A6D59EF03030BF5000F030504060A6D59E606AD040B03010000055",
                    INIT_07 => X"D00BF02F30071001B02F50007C205000D5135000F03070806077D553207BD5F3",
                    INIT_08 => X"D00320071D501743608FD00220071D781721608AD00120071D7817436085D000",
                    INIT_09 => X"60A3D00620071D781719609ED00520071D7817326099D00420071D5017216094",
                    INIT_0A => X"3A001B015000BA009B01500060B8D080B030063520071D50171920071D501732",
                    INIT_0B => X"60DCDC90F53160BEDC0320BED51B00B05000D002B021D003B0205000DB03DA02",
                    INIT_0C => X"2476D5092472D57F246AD50820F9D51B60DCDC2060FBDC026154DC011000D500",
                    INIT_0D => X"152020E0DC08F03D2538D5072467D50524BBD50C24A3D50B24A3D50A24E6D50D",
                    INIT_0E => X"D051B0303CEF20ED956020ED151F60EBD56020EDA0EDD55FE0EDD57F20EDDC40",
                    INIT_0F => X"500001495C016100D55B50005C0224F004CF00B000AB5000054E00AED609D504",
                    INIT_10 => X"B030214700B0BC35B634BA33BB32610FD5382147FC35F634FA33FB326107D537",
                    INIT_11 => X"5020B0306122D5282147611CD53E21475C106119D54E20026115D5636122D020",
                    INIT_12 => X"30FE6133D5422147F03030FE5C40612DD530F03030DF2147D020B0305000F030",
                    INIT_13 => X"D56921475C40F0305001613FD53221473CBFF03050016139D53121473CBFF030",
                    INIT_14 => X"E100110010085000F011F007100050003CFD207E00509561E147C4501460E147",
                    INIT_15 => X"5000F1111101E5000010B11110122160A160D52FE160D53A5000614FD0101001",
                    INIT_16 => X"B03704F0F0371001616DD000B0086174D55350006167D53F50006164D53B043F",
                    INIT_17 => X"D568243C617AD0009001050C1001617AD000B008617FD554243C616DD0009001",
                    INIT_18 => X"243CD00BF02F5008B02F243C00B0F02F30EFB02F643CD019218BD00CB0096190",
                    INIT_19 => X"D00BF02F30F7B02F243C00B3F02F5010B02F643CD019219CD00CB00961A1D56C",
                    INIT_1A => X"09D00800100161AED000B008243C04F261AA055704CFFA01FB0061D4D54D243C",
                    INIT_1B => X"950A940592500000DF02DE03F237B121B0202F300E400FA00EB0F33EF43D05E5",
                    INIT_1C => X"B33EB43DBA21BB20B23761BAEF10CE003F001E013A001B01D509D404D25100B0",
                    INIT_1D => X"B008FA3CFB3B243C04FA61DD055704CFFA01FB006210D54C243C04FCAA308B40",
                    INIT_1E => X"BE20F33EF43D05E509D00800243C61E69001050E61EAFA00DB00100161E3D000",
                    INIT_1F => X"950A9405985000B023500240B33CB23B0530AA308B400AF00BE0BF009E01BF21",
                    INIT_20 => X"243C0528B13EB03D61FCEF30CE20BF009E0100ABD509D404D8510000DF02DE03",
                    INIT_21 => X"6219D000900100AED609D504D55110016219D0001500B008FA01FB006224D558",
                    INIT_22 => X"900180E000D005BFFA01FB001101622AD100B108624BD540243C00B0BA01BB00",
                    INIT_23 => X"D000900100B0BA009B02D509D404D25100AE950A94059250100100B03A000B00",
                    INIT_24 => X"6251D100B1086271D550243C622AD1009101D609D404D251B200142000AE6234",
                    INIT_25 => X"1B01D509D404D25100B000AB950A9405925000AE80E000D005BFFA01FB001101",
                    INIT_26 => X"6251D100910100B0BA01BB00D609D404D4511420B25000B06256D00090013A00",
                    INIT_27 => X"6322D56D243C04BD243C04A9627CD001243C04BB6278D002B008627ED54A243C",
                    INIT_28 => X"DC046295D401231EF43034FDB4303CF73CFB1670628DD400A41000101108B007",
                    INIT_29 => X"5608445ADC0462A3D405231EF4305402B430629BD404231E445ADC045680445A",
                    INIT_2A => X"62B5D40A231E5C0862AED408231E5C04045A631EDC0462AAD407231E445ADC04",
                    INIT_2B => X"B4303CBF62C3D40C231EF43034FEB4305C4062BCD40B231EF43034FEB4303CBF",
                    INIT_2C => X"62D6D416231E3CF762CED41C231EF4305401B4305C4062CAD40D231EF4305401",
                    INIT_2D => X"445ADC0462E4D419231EF43034FDB43062DCD418231E445ADC04367F445ADC04",
                    INIT_2E => X"360F445ADC0462F4D427231E3CFB045A231EDC0462EBD41B231E445ADC0436F7",
                    INIT_2F => X"C540151DE30FD426231E445ADC0436F0445ADC0462FCD431231E445ADC045670",
                    INIT_30 => X"D430231EB43D445ADC0406404406440644064406368F941EF43D445ADC04E30F",
                    INIT_31 => X"C1001101231EB43D445ADC04064036F89428F43D445ADC04E31EC5401527E31E",
                    INIT_32 => X"91012330D100A1001008F0091000232BD002B0076346D5662326D548243C6283",
                    INIT_33 => X"A342C1D09101233ED100A10010010B400A3005E509D0081091010170A334C170",
                    INIT_34 => X"90010070A350C0709001234CD000B008635CD564243C00B03A000B10910101D0",
                    INIT_35 => X"D000B0086372D547243C00B03A000BE00B400A3005E509D00800B03D05C4F03D",
                    INIT_36 => X"3A000B00B03D0B400A3005E509D0082005C4F03D900100D0A366C0D090012362",
                    INIT_37 => X"9001B03600DCF036B5311001637BD000B008F5373CFE3CFD6384D562243C00B0",
                    INIT_38 => X"8BE09E012395D401239FD400B40805BFFA01FB0063B2D54B5000B537637BD000",
                    INIT_39 => X"04D023AE6396DE009E0100B000ABD609D404D451140023A714000ED000B0BA00",
                    INIT_3A => X"BA01BB0063A7DE009E0100AED609D404D4510ED063A7DE0014000E4084E01401",
                    INIT_3B => X"D100B10863C6D542243C63B891010496110163B8D100B10863BCD541243C00B0",
                    INIT_3C => X"9001B0080490F008100163CDD000B00863D4D543243C63C29101049D110163C2",
                    INIT_3D => X"D000F0089001B008048AF008100163DBD000B00863E2D544243C63CDD000F008",
                    INIT_3E => X"D549243C63E8D1009101B13D047DF13D110163E8D100B10863EFD55A243C63DB",
                    INIT_3F => X"D006B008641CD56E243C63F5D1009101B13D0476F13D110163F5D100B10863FC",
                    INIT_40 => X"0635153B05F033001201FE3F05C40635155B0635151BF53EF43DFA01FB00641B",
                    INIT_41 => X"D57E243C641FD572243CB53EB43DBA01BB000635155205F0330012011300B23F",
                    INIT_42 => X"243C025111016430D003243C022A1101642BD002243C04CF6426D001B008643C",
                    INIT_43 => X"1E0050003CFE3CFD243C04DA643CD006243C04D66438D005243C04DE6434D004",
                    INIT_44 => X"24440E4005E5190A08E010012450D10091010E409430A40010122450D100B111",
                    INIT_45 => X"460E460E460E460E0460F43E5000F1071101F0111000EE000010B107100804E0",
                    INIT_46 => X"00B0BA009B011000FA00DB005000063515065000B43E46404406440644064406",
                    INIT_47 => X"1000DE0005C420B03A000B1081001108300700B0248A00B81520048A248A5000",
                    INIT_48 => X"500000B000AB1000DE0005C420B0BA009B0820B0BA008B002487D000300700E0",
                    INIT_49 => X"0BD0D0000557500000B0BA008BD09000FA00CBD0500000AE1000CED01E0105C4",
                    INIT_4A => X"00ABD609D404D4511400FA01FB00500000B03A000BD0E4F00557500000B03A00",
                    INIT_4B => X"1400FA01FB001A001B00500000B0BA01BB00D609D404D25164AC00B0FA00DB00",
                    INIT_4C => X"05C4500000B0BA01BB0064C2EA10CB003A001B01D609D404D45100B0B121B020",
                    INIT_4D => X"00AB04CF500000B0BA23BB22500000B01A001B00500000B0BA008BE01000DE00",
                    INIT_4E => X"BA23BB22500000B024EE054E3A000BD0500004CF24E804E6500000B03A000BD0",
                    INIT_4F => X"00B0B121B0201500BA23BB22DF0EDE0FFF1FFE1E3F000ED0BF1FBE1EFA01FB00",
                    INIT_50 => X"BF1FBE1EFA01FB00500000B0BA01BB0064FFEA10CB003A001B01D609D504D551",
                    INIT_51 => X"CBD03A001B01D609D504D55100B015001A001B00DF0EDE0FFF1FFE1EBF008ED0",
                    INIT_52 => X"90013A001B01D609D504D55100B01500110000D0500000B0BA01BB006519FA00",
                    INIT_53 => X"BA01BB00054305DC0543F63DFA01FB00500000B0BA01BB006529F100D000B100",
                    INIT_54 => X"F13AF03950006545054E3A001B01D609045A960A00B01A001B00500000B0B63D",
                    INIT_55 => X"5000B13AB039EA10CB00B123B022F13AF0395000B13AB039EA10CB00B121B020",
                    INIT_56 => X"B901B80000B8F901F8001000D500489025611000D5001501B53600DCF5361500",
                    INIT_57 => X"157B500006350591350F054006350591450E450E450E450E0540256838001901",
                    INIT_58 => X"00DC0591350F054000DC0591450E450E450E450E0540500000DC157D058500DC",
                    INIT_59 => X"00DC153E00DC0540B400057FB408F40000DC153C5000153A1507A594950A5000",
                    INIT_5A => X"157215651554156B1563156115751551500000DC157D00DC054000DC157B5000",
                    INIT_5B => X"02B01500152015651564156F154D1520152015321530152E153115561520156D",
                    INIT_5C => X"AF908E801009130012000F300E2025C9180009D003A002B025C63300120103A0",
                    INIT_5D => X"25E010681189120925CE100090014808490E430042062F900E8025D64207A5D3",
                    INIT_5E => X"500065E8420644084308038025EBC920140013001201500065E0B200B1009001",
                    INIT_5F => X"25F69E011000DE020635153025FCDF000F50A5E01F001E0606162600F300D200",
                    INIT_60 => X"DE0200B81530260FDF000F50A5E01F001E0606162613F300D200500006351530",
                    INIT_61 => X"12000F300E20261714011000D406EE40061D1402500000B8153026099E011000",
                    INIT_62 => X"90014808490E430042062F900E80262C4207A629AF908E80100D180019A01300",
                    INIT_63 => X"0000000000000000000000005000D5016635D00490005000B001B03126241000",
                    INIT_64 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_65 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_66 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_67 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_68 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_69 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_70 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_71 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_72 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_73 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_74 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_75 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_76 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_77 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_78 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_79 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7F => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_00 => X"A12368DDDD8A370E90B70242DC0AEB0A96A0A351A822088222082A22AAAA280A",
                   INITP_01 => X"A362ABAA82637DDC32DDDDDDDDDDCCCDCB36A22A596C2820D8360D8360D8360D",
                   INITP_02 => X"6D674DB529D36DB6A643DDB582A221D3623623623683630A0DB636DC28036AAD",
                   INITP_03 => X"025014142A0B6D5D2ABAADA5003555AA00A8142A074AEAB6A0A8374DA82A0DD3",
                   INITP_04 => X"DAADAD36D60A82D56AA024A9D36D6A0B596A806552A74DA0D6A9D0ADA0D56A8A",
                   INITP_05 => X"4DB0CDB03362CDB0CDA0DB0CD8DA03680DA03680D8D8B36C336836C336800D10",
                   INITP_06 => X"4A1D20DA5020A4D74DA5080A4D74DA54D744204D74234DDB58C46CD3631551B3",
                   INITP_07 => X"4DB529D36D4A74DB64A74DB64A74DB674DB674DA0D6A8D052D6AA2095DD2AD8D",
                   INITP_08 => X"DA540A2A975A2055552A6240881D543420ADADADA368DAD36D802250896A22AB",
                   INITP_09 => X"800AA50A0AE5AAA5AA0A0A5DA8355AA028282AE5AA2A97A97A975AD6AB6965D0",
                   INITP_0A => X"2A0A55250AB6B5288142A050AB9688280AAAA0D556A80A0D56A80AA50AA0D56A",
                   INITP_0B => X"9D9D40B5B55C02D580B55567500200942AAAAAAAAAAAA22288228976A0A5528A",
                   INITP_0C => X"00000000000000000000000000000000000AC2AB5556750002768A2767502D68",
                   INITP_0D => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0E => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0F => X"0000000000000000000000000000000000000000000000000000000000000000")
      port map(   ADDRARDADDR => address_a,
                      ENARDEN => enable,
                    CLKARDCLK => clk,
                        DOADO => data_out_a(31 downto 0),
                      DOPADOP => data_out_a(35 downto 32), 
                        DIADI => data_in_a(31 downto 0),
                      DIPADIP => data_in_a(35 downto 32), 
                          WEA => "0000",
                  REGCEAREGCE => '0',
                RSTRAMARSTRAM => '0',
                RSTREGARSTREG => '0',
                  ADDRBWRADDR => address_b,
                      ENBWREN => enable_b,
                    CLKBWRCLK => clk_b,
                        DOBDO => data_out_b(31 downto 0),
                      DOPBDOP => data_out_b(35 downto 32), 
                        DIBDI => data_in_b(31 downto 0),
                      DIPBDIP => data_in_b(35 downto 32), 
                        WEBWE => we_b,
                       REGCEB => '0',
                      RSTRAMB => '0',
                      RSTREGB => '0',
                   CASCADEINA => '0',
                   CASCADEINB => '0',
                INJECTDBITERR => '0',
                INJECTSBITERR => '0');
      --
    end generate akv7;
    --
  end generate ram_2k_generate;
  --
  --	
  ram_4k_generate : if (C_RAM_SIZE_KWORDS = 4) generate
    s6: if (C_FAMILY = "S6") generate
      --
      address_a(13 downto 0) <= address(10 downto 0) & "000";
      data_in_a <= "000000000000000000000000000000000000";
      --
      s6_a11_flop: FD
      port map (  D => address(11),
                  Q => pipe_a11,
                  C => clk);
      --
      s6_4k_mux0_lut: LUT6_2
      generic map (INIT => X"FF00F0F0CCCCAAAA")
      port map( I0 => data_out_a_ll(0),
                I1 => data_out_a_hl(0),
                I2 => data_out_a_ll(1),
                I3 => data_out_a_hl(1),
                I4 => pipe_a11,
                I5 => '1',
                O5 => instruction(0),
                O6 => instruction(1));
      --
      s6_4k_mux2_lut: LUT6_2
      generic map (INIT => X"FF00F0F0CCCCAAAA")
      port map( I0 => data_out_a_ll(2),
                I1 => data_out_a_hl(2),
                I2 => data_out_a_ll(3),
                I3 => data_out_a_hl(3),
                I4 => pipe_a11,
                I5 => '1',
                O5 => instruction(2),
                O6 => instruction(3));
      --
      s6_4k_mux4_lut: LUT6_2
      generic map (INIT => X"FF00F0F0CCCCAAAA")
      port map( I0 => data_out_a_ll(4),
                I1 => data_out_a_hl(4),
                I2 => data_out_a_ll(5),
                I3 => data_out_a_hl(5),
                I4 => pipe_a11,
                I5 => '1',
                O5 => instruction(4),
                O6 => instruction(5));
      --
      s6_4k_mux6_lut: LUT6_2
      generic map (INIT => X"FF00F0F0CCCCAAAA")
      port map( I0 => data_out_a_ll(6),
                I1 => data_out_a_hl(6),
                I2 => data_out_a_ll(7),
                I3 => data_out_a_hl(7),
                I4 => pipe_a11,
                I5 => '1',
                O5 => instruction(6),
                O6 => instruction(7));
      --
      s6_4k_mux8_lut: LUT6_2
      generic map (INIT => X"FF00F0F0CCCCAAAA")
      port map( I0 => data_out_a_ll(32),
                I1 => data_out_a_hl(32),
                I2 => data_out_a_lh(0),
                I3 => data_out_a_hh(0),
                I4 => pipe_a11,
                I5 => '1',
                O5 => instruction(8),
                O6 => instruction(9));
      --
      s6_4k_mux10_lut: LUT6_2
      generic map (INIT => X"FF00F0F0CCCCAAAA")
      port map( I0 => data_out_a_lh(1),
                I1 => data_out_a_hh(1),
                I2 => data_out_a_lh(2),
                I3 => data_out_a_hh(2),
                I4 => pipe_a11,
                I5 => '1',
                O5 => instruction(10),
                O6 => instruction(11));
      --
      s6_4k_mux12_lut: LUT6_2
      generic map (INIT => X"FF00F0F0CCCCAAAA")
      port map( I0 => data_out_a_lh(3),
                I1 => data_out_a_hh(3),
                I2 => data_out_a_lh(4),
                I3 => data_out_a_hh(4),
                I4 => pipe_a11,
                I5 => '1',
                O5 => instruction(12),
                O6 => instruction(13));
      --
      s6_4k_mux14_lut: LUT6_2
      generic map (INIT => X"FF00F0F0CCCCAAAA")
      port map( I0 => data_out_a_lh(5),
                I1 => data_out_a_hh(5),
                I2 => data_out_a_lh(6),
                I3 => data_out_a_hh(6),
                I4 => pipe_a11,
                I5 => '1',
                O5 => instruction(14),
                O6 => instruction(15));
      --
      s6_4k_mux16_lut: LUT6_2
      generic map (INIT => X"FF00F0F0CCCCAAAA")
      port map( I0 => data_out_a_lh(7),
                I1 => data_out_a_hh(7),
                I2 => data_out_a_lh(32),
                I3 => data_out_a_hh(32),
                I4 => pipe_a11,
                I5 => '1',
                O5 => instruction(16),
                O6 => instruction(17));
      --
      no_loader : if (C_JTAG_LOADER_ENABLE = 0) generate
        data_in_b_ll <= "000" & data_out_b_ll(32) & "000000000000000000000000" & data_out_b_ll(7 downto 0);
        data_in_b_lh <= "000" & data_out_b_lh(32) & "000000000000000000000000" & data_out_b_lh(7 downto 0);
        data_in_b_hl <= "000" & data_out_b_hl(32) & "000000000000000000000000" & data_out_b_hl(7 downto 0);
        data_in_b_hh <= "000" & data_out_b_hh(32) & "000000000000000000000000" & data_out_b_hh(7 downto 0);
        address_b(13 downto 0) <= "00000000000000";
        we_b_l(3 downto 0) <= "0000";
        we_b_h(3 downto 0) <= "0000";
        enable_b <= '0';
        rdl <= '0';
        clk_b <= '0';
        jtag_dout <= data_out_b_lh(32) & data_out_b_lh(7 downto 0) & data_out_b_ll(32) & data_out_b_ll(7 downto 0);
      end generate no_loader;
      --
      loader : if (C_JTAG_LOADER_ENABLE = 1) generate
        data_in_b_lh <= "000" & jtag_din(17) & "000000000000000000000000" & jtag_din(16 downto 9);
        data_in_b_ll <= "000" & jtag_din(8) & "000000000000000000000000" & jtag_din(7 downto 0);
        data_in_b_hh <= "000" & jtag_din(17) & "000000000000000000000000" & jtag_din(16 downto 9);
        data_in_b_hl <= "000" & jtag_din(8) & "000000000000000000000000" & jtag_din(7 downto 0);
        address_b(13 downto 0) <= jtag_addr(10 downto 0) & "000";
        --
        s6_4k_jtag_we_lut: LUT6_2
        generic map (INIT => X"8000000020000000")
        port map( I0 => jtag_we,
                  I1 => jtag_addr(11),
                  I2 => '1',
                  I3 => '1',
                  I4 => '1',
                  I5 => '1',
                  O5 => jtag_we_l,
                  O6 => jtag_we_h);
        --
        we_b_l(3 downto 0) <= jtag_we_l & jtag_we_l & jtag_we_l & jtag_we_l;
        we_b_h(3 downto 0) <= jtag_we_h & jtag_we_h & jtag_we_h & jtag_we_h;
        --
        enable_b <= jtag_en(0);
        rdl <= rdl_bus(0);
        clk_b <= jtag_clk;
        --
        s6_4k_jtag_mux0_lut: LUT6_2
        generic map (INIT => X"FF00F0F0CCCCAAAA")
        port map( I0 => data_out_b_ll(0),
                  I1 => data_out_b_hl(0),
                  I2 => data_out_b_ll(1),
                  I3 => data_out_b_hl(1),
                  I4 => jtag_addr(11),
                  I5 => '1',
                  O5 => jtag_dout(0),
                  O6 => jtag_dout(1));
        --
        s6_4k_jtag_mux2_lut: LUT6_2
        generic map (INIT => X"FF00F0F0CCCCAAAA")
        port map( I0 => data_out_b_ll(2),
                  I1 => data_out_b_hl(2),
                  I2 => data_out_b_ll(3),
                  I3 => data_out_b_hl(3),
                  I4 => jtag_addr(11),
                  I5 => '1',
                  O5 => jtag_dout(2),
                  O6 => jtag_dout(3));
        --
        s6_4k_jtag_mux4_lut: LUT6_2
        generic map (INIT => X"FF00F0F0CCCCAAAA")
        port map( I0 => data_out_b_ll(4),
                  I1 => data_out_b_hl(4),
                  I2 => data_out_b_ll(5),
                  I3 => data_out_b_hl(5),
                  I4 => jtag_addr(11),
                  I5 => '1',
                  O5 => jtag_dout(4),
                  O6 => jtag_dout(5));
        --
        s6_4k_jtag_mux6_lut: LUT6_2
        generic map (INIT => X"FF00F0F0CCCCAAAA")
        port map( I0 => data_out_b_ll(6),
                  I1 => data_out_b_hl(6),
                  I2 => data_out_b_ll(7),
                  I3 => data_out_b_hl(7),
                  I4 => jtag_addr(11),
                  I5 => '1',
                  O5 => jtag_dout(6),
                  O6 => jtag_dout(7));
        --
        s6_4k_jtag_mux8_lut: LUT6_2
        generic map (INIT => X"FF00F0F0CCCCAAAA")
        port map( I0 => data_out_b_ll(32),
                  I1 => data_out_b_hl(32),
                  I2 => data_out_b_lh(0),
                  I3 => data_out_b_hh(0),
                  I4 => jtag_addr(11),
                  I5 => '1',
                  O5 => jtag_dout(8),
                  O6 => jtag_dout(9));
        --
        s6_4k_jtag_mux10_lut: LUT6_2
        generic map (INIT => X"FF00F0F0CCCCAAAA")
        port map( I0 => data_out_b_lh(1),
                  I1 => data_out_b_hh(1),
                  I2 => data_out_b_lh(2),
                  I3 => data_out_b_hh(2),
                  I4 => jtag_addr(11),
                  I5 => '1',
                  O5 => jtag_dout(10),
                  O6 => jtag_dout(11));
        --
        s6_4k_jtag_mux12_lut: LUT6_2
        generic map (INIT => X"FF00F0F0CCCCAAAA")
        port map( I0 => data_out_b_lh(3),
                  I1 => data_out_b_hh(3),
                  I2 => data_out_b_lh(4),
                  I3 => data_out_b_hh(4),
                  I4 => jtag_addr(11),
                  I5 => '1',
                  O5 => jtag_dout(12),
                  O6 => jtag_dout(13));
        --
        s6_4k_jtag_mux14_lut: LUT6_2
        generic map (INIT => X"FF00F0F0CCCCAAAA")
        port map( I0 => data_out_b_lh(5),
                  I1 => data_out_b_hh(5),
                  I2 => data_out_b_lh(6),
                  I3 => data_out_b_hh(6),
                  I4 => jtag_addr(11),
                  I5 => '1',
                  O5 => jtag_dout(14),
                  O6 => jtag_dout(15));
        --
        s6_4k_jtag_mux16_lut: LUT6_2
        generic map (INIT => X"FF00F0F0CCCCAAAA")
        port map( I0 => data_out_b_lh(7),
                  I1 => data_out_b_hh(7),
                  I2 => data_out_b_lh(32),
                  I3 => data_out_b_hh(32),
                  I4 => jtag_addr(11),
                  I5 => '1',
                  O5 => jtag_dout(16),
                  O6 => jtag_dout(17));
      --
      end generate loader;
      --
      kcpsm6_rom_ll: RAMB16BWER
      generic map ( DATA_WIDTH_A => 9,
                    DOA_REG => 0,
                    EN_RSTRAM_A => FALSE,
                    INIT_A => X"000000000",
                    RST_PRIORITY_A => "CE",
                    SRVAL_A => X"000000000",
                    WRITE_MODE_A => "WRITE_FIRST",
                    DATA_WIDTH_B => 9,
                    DOB_REG => 0,
                    EN_RSTRAM_B => FALSE,
                    INIT_B => X"000000000",
                    RST_PRIORITY_B => "CE",
                    SRVAL_B => X"000000000",
                    WRITE_MODE_B => "WRITE_FIRST",
                    RSTTYPE => "SYNC",
                    INIT_FILE => "NONE",
                    SIM_COLLISION_CHECK => "ALL",
                    SIM_DEVICE => "SPARTAN6",
                    INIT_00 => X"28B82003002F68A805BB38347035003230310E0F1F1E3332000B2F0043784202",
                    INIT_01 => X"2200D02120E570D000E4702D00013B01B8B83B1020B829030070B8780300D0B8",
                    INIT_02 => X"000100405600015C0141A70001000D4B000151010CA742B8424A60B3102F0023",
                    INIT_03 => X"0B2F07012F0020001300308077537BF302A4A69E30BF003040A69E6A40300055",
                    INIT_04 => X"A3060778199E05077832990407502194030750438F020778218A010778438500",
                    INIT_05 => X"DC9031BE03BE1BB00002210320000302000100000100B8803035075019075032",
                    INIT_06 => X"20E0083D38076705BB0CA30BA30AE60D7609727F6A08F91BDC20FB0254010000",
                    INIT_07 => X"004901005B0002F0CFB0AB004EAE09045130EFED60ED1FEB60EDED5FED7FED40",
                    INIT_08 => X"20302228471C3E4710194E02156322203047B0353433320F3847353433320737",
                    INIT_09 => X"69474030013F3247BF3001393147BF30FE33424730FE402D3030DF4720300030",
                    INIT_0A => X"0011010010111260602F603A004F10010000080011070000FD7E506147506047",
                    INIT_0B => X"683C7A00010C017A00087F543C6D000137F037016D0008745300673F00643B3F",
                    INIT_0C => X"0B2FF72F3CB32F102F3C199C0C09A16C3C0B2F082F3CB02FEF2F3C198B0C0990",
                    INIT_0D => X"0A05500002033721203040A0B03E3DE5D00001AE00083CF2AA57CF0100D44D3C",
                    INIT_0E => X"083C3B3CFADD57CF0100104C3CFC30403E3D212037BA100000010001090451B0",
                    INIT_0F => X"0A0550B050403C3B303040F0E0000121203E3DE5D0003CE6010EEA000001E300",
                    INIT_10 => X"190001AE0904510119000008010024583C283E3DFC30200001AB090451000203",
                    INIT_11 => X"0001B00002090451AE0A055001B0000001E0D0BF0100012A00084B403CB00100",
                    INIT_12 => X"01090451B0AB0A0550AEE0D0BF01000151000871503C2A00010904510020AE34",
                    INIT_13 => X"226D3CBD3CA97C013CBB7802087E4A3C510001B001000904512050B056000100",
                    INIT_14 => X"085A04A3051E3002309B041E5A04805A0495011E30FD30F7FB708D0010100807",
                    INIT_15 => X"30BFC30C1E30FE3040BC0B1E30FE30BFB50A1E08AE081E045A1E04AA071E5A04",
                    INIT_16 => X"5A04E4191E30FD30DC181E5A047F5A04D6161EF7CE1C1E30013040CA0D1E3001",
                    INIT_17 => X"401D0F261E5A04F05A04FC311E5A04700F5A04F4271EFB5A1E04EB1B1E5A04F7",
                    INIT_18 => X"00011E3D5A0440F8283D5A041E40271E301E3D5A0440060606068F1E3D5A040F",
                    INIT_19 => X"42D0013E0000014030E5D01001703470013000000809002B0207466626483C83",
                    INIT_1A => X"000872473CB000E04030E5D0003DC43D01705070014C00085C643CB0001001D0",
                    INIT_1B => X"0136DC3631017B000837FEFD84623CB000003D4030E5D020C43D01D066D00162",
                    INIT_1C => X"D0AE960001B0AB09045100A700D0B000E00195019F0008BF0100B24B00377B00",
                    INIT_1D => X"0008C6423CB8019601B80008BC413CB00100A70001AE090451D0A7000040E001",
                    INIT_1E => X"000801088A0801DB0008E2443CCD00080108900801CD0008D4433CC2019D01C2",
                    INIT_1F => X"06081C6E3CF500013D763D01F50008FC493CE800013D7D3D01E80008EF5A3CDB",
                    INIT_20 => X"7E3C1F723C3E3D01003552F00001003F353BF000013FC4355B351B3E3D01001B",
                    INIT_21 => X"0000FEFD3CDA3C063CD638053CDE34043C510130033C2A012B023CCF2601083C",
                    INIT_22 => X"0E0E0E0E603E000701110000100708E04440E50AE00150000140300012500011",
                    INIT_23 => X"0000C4B00010000807B08AB8208A8A00B00001000000003506003E4006060606",
                    INIT_24 => X"D0005700B000D00000D000AE00D001C400B0AB0000C4B00008B00000870007E0",
                    INIT_25 => X"000100000000B00100090451ACB00000AB09045100010000B000D0F05700B000",
                    INIT_26 => X"ABCF00B0232200B0000000B000E00000C400B00100C210000001090451B02120",
                    INIT_27 => X"B021200023220E0F1F1E00D01F1E0100232200B0EE4E00D000CFE8E600B000D0",
                    INIT_28 => X"D00001090451B00000000E0F1F1E00D01F1E010000B00100FF10000001090451",
                    INIT_29 => X"010043DC433D010000B0010029000000010001090451B00000D000B001001900",
                    INIT_2A => X"003A39100023223A39003A39100021203A3900454E0001095A0AB0000000B03D",
                    INIT_2B => X"7B0035910F4035910E0E0E0E406800010100B801000000906100000136DC3600",
                    INIT_2C => X"DC3EDC40007F0800DC3C003A07940A00DC910F40DC910E0E0E0E4000DC7D85DC",
                    INIT_2D => X"B0002065646F4D202032302E3156206D7265546B6361755100DC7DDC40DC7B00",
                    INIT_2E => X"E0688909CE0001080E00069080D607D390800900003020C900D0A0B0C60001A0",
                    INIT_2F => X"F60100023530FC0050E000061600000000E806080880EB2000000100E0000001",
                    INIT_30 => X"00302017010006401D0200B83009010002B8300F0050E0000616130000003530",
                    INIT_31 => X"0000000000000001350400000131240001080E000690802C072990800D00A000",
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
                    INIT_3F => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_00 => X"58090A948D5555092202481B18C6318C008550201222440156000A94AB00000C",
                   INITP_01 => X"8AAD596A26519698895590CE00130009A53409B675F4C019C71C71903F6E43C7",
                   INITP_02 => X"E8080488082022040810224404101002C0026400C20B69800C4116D106256D22",
                   INITP_03 => X"17BFBDFD013404DBF6FC60206010A9760A4C568931B224C7FD6FF13CE00F4001",
                   INITP_04 => X"56A945010444894228810228A241049027082480018431830000210094BA72B2",
                   INITP_05 => X"87E24F4AA8D5956D7FFFFF2A545E77E69DFD92BB4D269A08791D2D86AD6A912B",
                   INITP_06 => X"0000000000000000000000000000000000000000000000000100342340082F11",
                   INITP_07 => X"0000000000000000000000000000000000000000000000000000000000000000")
      port map(  ADDRA => address_a(13 downto 0),
                   ENA => enable,
                  CLKA => clk,
                   DOA => data_out_a_ll(31 downto 0),
                  DOPA => data_out_a_ll(35 downto 32), 
                   DIA => data_in_a(31 downto 0),
                  DIPA => data_in_a(35 downto 32), 
                   WEA => "0000",
                REGCEA => '0',
                  RSTA => '0',
                 ADDRB => address_b(13 downto 0),
                   ENB => enable_b,
                  CLKB => clk_b,
                   DOB => data_out_b_ll(31 downto 0),
                  DOPB => data_out_b_ll(35 downto 32), 
                   DIB => data_in_b_ll(31 downto 0),
                  DIPB => data_in_b_ll(35 downto 32), 
                   WEB => we_b_l(3 downto 0),
                REGCEB => '0',
                  RSTB => '0');
      -- 
      kcpsm6_rom_lh: RAMB16BWER
      generic map ( DATA_WIDTH_A => 9,
                    DOA_REG => 0,
                    EN_RSTRAM_A => FALSE,
                    INIT_A => X"000000000",
                    RST_PRIORITY_A => "CE",
                    SRVAL_A => X"000000000",
                    WRITE_MODE_A => "WRITE_FIRST",
                    DATA_WIDTH_B => 9,
                    DOB_REG => 0,
                    EN_RSTRAM_B => FALSE,
                    INIT_B => X"000000000",
                    RST_PRIORITY_B => "CE",
                    SRVAL_B => X"000000000",
                    WRITE_MODE_B => "WRITE_FIRST",
                    RSTTYPE => "SYNC",
                    INIT_FILE => "NONE",
                    SIM_COLLISION_CHECK => "ALL",
                    SIM_DEVICE => "SPARTAN6",
                    INIT_00 => X"0A000A030959020C0C02007B0B7E0E037878686878787878086878080B0E1000",
                    INIT_01 => X"7AD9C2797A02040428020BB0E8C8588B000078080A000A030901000A03090100",
                    INIT_02 => X"2888084A1088C8906848082888084A1088C8906848081000900000A068582879",
                    INIT_03 => X"6878188858283EA8EA287838B0EA90EA90EA90EA7818287828B0EAB068588800",
                    INIT_04 => X"B0E8100E0BB0E8100E0BB0E8100E0BB0E8100E0BB0E8100E0BB0E8100E0BB0E8",
                    INIT_05 => X"B06E7AB06E90EA002868586858286D6D9D8D28DDCD28B0685803100E0B100E0B",
                    INIT_06 => X"0A906E7892EA92EA92EA92EA92EA92EA92EA92EA92EA90EAB06EB06EB06E88EA",
                    INIT_07 => X"28002EB0EA282E12020000A802006B6A68581E10CA100AB0EA90D0EAF0EA906E",
                    INIT_08 => X"2858B0EA10B0EA102EB0EA10B0EAB0685810005E5B5D5DB0EA107E7B7D7DB0EA",
                    INIT_09 => X"EA102E7828B0EA101E7828B0EA101E7818B0EA1078182EB0EA78189068582878",
                    INIT_0A => X"2878887280580890D0EAF0EA28B0E88870080828787808281E1000CAF0E20AF0",
                    INIT_0B => X"EA12B0E8C80288B0E858B0EA12B0E8C858027888B0E858B0EA28B0EA28B0EA02",
                    INIT_0C => X"687818581200782858B2E890E858B0EA12687828581200781858B2E890E858B0",
                    INIT_0D => X"4A4A49006F6F79585897870707797A02040488B0E8581202B002027D7DB0EA12",
                    INIT_0E => X"587D7D1202B002027D7DB1EA1202D5C5595A5D5D59B0F7E79F8F9D8D6A6A6900",
                    INIT_0F => X"4A4A4C009181595902D5C50505DFCF5F5F797A02040412B0C802B0FDED88B0E8",
                    INIT_10 => X"B1E8C8006B6A6A88B1E80A587D7DB1EA12025858B0F7E7DFCF006A6A6C006F6F",
                    INIT_11 => X"E8C800DDCD6A6A69004A4A4988009D85C8C000027D7D88B1E858B1EA12005D5D",
                    INIT_12 => X"8D6A6A6900004A4A4900C000027D7D88B1E858B1EA12B1E8C86B6A69590A00B1",
                    INIT_13 => X"B1EA12021202B1E81202B1E858B1EA12B1E8C8005D5D6B6A6A0A5900B1E8C89D",
                    INIT_14 => X"2BA26EB1EA117A2A5AB1EA11A26E2BA26EB1EA117A1A5A1E1E0BB1EA52800858",
                    INIT_15 => X"5A1EB1EA117A1A5A2EB1EA117A1A5A1EB1EA112EB1EA112E02B16EB1EA11A26E",
                    INIT_16 => X"A26EB1EA117A1A5AB1EA11A26E1BA26EB1EA111EB1EA117A2A5A2EB1EA117A2A",
                    INIT_17 => X"E20AF1EA11A26E1BA26EB1EA11A26E2B1BA26EB1EA111E02916EB1EA11A26E1B",
                    INIT_18 => X"E088115AA26E831BCA7AA26EF1E20AF1EA115AA26E83A2A2A2A21BCA7AA26EF1",
                    INIT_19 => X"D1E0C891E850880505020404C800D1E0C891E85008780891E858B1EA91EA12B1",
                    INIT_1A => X"E858B1EA12009D850505020404580278C800D1E0C891E858B1EA12009D85C800",
                    INIT_1B => X"C85800785A88B1E8587A1E1EB1EA12009D855805050204040278C800D1E0C891",
                    INIT_1C => X"0211B1EFCF00006B6A6A0A110A0700DDC5CF91EA91EA5A027D7DB1EA285AB1E8",
                    INIT_1D => X"E858B1EA12B1C80288B1E858B1EA12005D5DB1EFCF006B6A6A07B1EF0A07C28A",
                    INIT_1E => X"E878C858027888B1E858B1EA12B1E878C858027888B1E858B1EA12B1C80288B1",
                    INIT_1F => X"E858B2EA12B1E8C858027888B1E858B1EA12B1E8C858027888B1E858B1EA12B1",
                    INIT_20 => X"EA12B2EA125A5A5D5D030A0299890959030A0299897F02030A030A7A7A7D7DB2",
                    INIT_21 => X"0F281E1E1202B2E81202B2E81202B2E8120108B2E8120108B2E81202B2E858B2",
                    INIT_22 => X"A3A3A3A3027A287888780877805808021207020C048892E8C887CA520892E858",
                    INIT_23 => X"88EF02109D85C008180012000A02122800DDCD88FDED28030A285A23A2A2A2A2",
                    INIT_24 => X"85E8022800DDC5C8FDE5280088E78F0228000088EF0210DDCD10DDC592E81800",
                    INIT_25 => X"0A7D7D0D0D28005D5D6B6A69B200FDED006B6A6A0A7D7D28009D85F20228009D",
                    INIT_26 => X"000228005D5D28000D0D2800DDC588EF0228005D5DB2F5E59D8D6B6A6A005858",
                    INIT_27 => X"0058580A5D5D6F6F7F7F9F875F5F7D7D5D5D280092029D852802120228009D85",
                    INIT_28 => X"E59D8D6B6A6A000A0D0D6F6F7F7FDFC75F5F7D7D28005D5DB2F5E59D8D6B6A6A",
                    INIT_29 => X"5D5D0202027B7D7D28005D5DB2F8E8D8C89D8D6B6A6A000A080028005D5DB2FD",
                    INIT_2A => X"285858F5E558587878285858F5E55858787828B2029D8D6B024B000D0D28005B",
                    INIT_2B => X"0A2803021A020302A2A2A2A202129C8C5C5C007C7C88EA241288EA8A5A007A0A",
                    INIT_2C => X"000A00025A025A7A000A288A8AD2CA2800021A020002A2A2A2A20228000A0200",
                    INIT_2D => X"010A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A28000A0002000A28",
                    INIT_2E => X"120808091288C8A4A4A1A1978712A1D2D7C70809090707120C04010112998901",
                    INIT_2F => X"12CF88EF038A92EF87520F0F0393F9E928B2A1A2A18192640A090928B2D9D8C8",
                    INIT_30 => X"090707138A88EA77030A28000A13CF88EF008A93EF87520F0F0393F9E928030A",
                    INIT_31 => X"000000000000286AB368482858581388C8A4A4A1A1978713A1D3D7C7080C0C09",
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
                    INIT_3F => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_00 => X"D5FF956A5AAAAAAAB5D72664A5294A52C56AAB538D11A3F39CD0E5295275FF63",
                   INITP_01 => X"100073627FEC040F0E0713FDCE52E729652C696DD1AC9D49555559532D5A617E",
                   INITP_02 => X"2CAC55ACACB2AB162C58AAD656595820BEE593987C4E967327841D2C9E8EC87B",
                   INITP_03 => X"2C69634B4D2D34B52D4B27A067D229EA324B04C92C2324B09042452B2869500D",
                   INITP_04 => X"83C33CFCF332E43C667CF79E7939F648B03793400750A2044EEED6B96850A75F",
                   INITP_05 => X"AA0CC2188C0501087FFFFFD5A5A5CC1B73043DC681C0F9A63FC81E321E3C3C87",
                   INITP_06 => X"000000000000000000000000000000000000000000000000039F014015B55066",
                   INITP_07 => X"0000000000000000000000000000000000000000000000000000000000000000")
      port map(  ADDRA => address_a(13 downto 0),
                   ENA => enable,
                  CLKA => clk,
                   DOA => data_out_a_lh(31 downto 0),
                  DOPA => data_out_a_lh(35 downto 32), 
                   DIA => data_in_a(31 downto 0),
                  DIPA => data_in_a(35 downto 32), 
                   WEA => "0000",
                REGCEA => '0',
                  RSTA => '0',
                 ADDRB => address_b(13 downto 0),
                   ENB => enable_b,
                  CLKB => clk_b,
                   DOB => data_out_b_lh(31 downto 0),
                  DOPB => data_out_b_lh(35 downto 32), 
                   DIB => data_in_b_lh(31 downto 0),
                  DIPB => data_in_b_lh(35 downto 32), 
                   WEB => we_b_l(3 downto 0),
                REGCEB => '0',
                  RSTB => '0');
      --
      kcpsm6_rom_hl: RAMB16BWER
      generic map ( DATA_WIDTH_A => 9,
                    DOA_REG => 0,
                    EN_RSTRAM_A => FALSE,
                    INIT_A => X"000000000",
                    RST_PRIORITY_A => "CE",
                    SRVAL_A => X"000000000",
                    WRITE_MODE_A => "WRITE_FIRST",
                    DATA_WIDTH_B => 9,
                    DOB_REG => 0,
                    EN_RSTRAM_B => FALSE,
                    INIT_B => X"000000000",
                    RST_PRIORITY_B => "CE",
                    SRVAL_B => X"000000000",
                    WRITE_MODE_B => "WRITE_FIRST",
                    RSTTYPE => "SYNC",
                    INIT_FILE => "NONE",
                    SIM_COLLISION_CHECK => "ALL",
                    SIM_DEVICE => "SPARTAN6",
                    INIT_00 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_01 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_02 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_03 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_04 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_05 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_06 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_07 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_08 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_09 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_0A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_0B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_0C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_0D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_0E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_0F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_10 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_11 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_12 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_13 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_14 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_15 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_16 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_17 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_18 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_19 => X"0000000000000000000000000000000000000000000000000000000000000000",
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
                    INIT_3F => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_00 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_01 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_02 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_03 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_04 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_05 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_06 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_07 => X"0000000000000000000000000000000000000000000000000000000000000000")
      port map(  ADDRA => address_a(13 downto 0),
                   ENA => enable,
                  CLKA => clk,
                   DOA => data_out_a_hl(31 downto 0),
                  DOPA => data_out_a_hl(35 downto 32), 
                   DIA => data_in_a(31 downto 0),
                  DIPA => data_in_a(35 downto 32), 
                   WEA => "0000",
                REGCEA => '0',
                  RSTA => '0',
                 ADDRB => address_b(13 downto 0),
                   ENB => enable_b,
                  CLKB => clk_b,
                   DOB => data_out_b_hl(31 downto 0),
                  DOPB => data_out_b_hl(35 downto 32), 
                   DIB => data_in_b_hl(31 downto 0),
                  DIPB => data_in_b_hl(35 downto 32), 
                   WEB => we_b_h(3 downto 0),
                REGCEB => '0',
                  RSTB => '0');
      -- 
      kcpsm6_rom_hh: RAMB16BWER
      generic map ( DATA_WIDTH_A => 9,
                    DOA_REG => 0,
                    EN_RSTRAM_A => FALSE,
                    INIT_A => X"000000000",
                    RST_PRIORITY_A => "CE",
                    SRVAL_A => X"000000000",
                    WRITE_MODE_A => "WRITE_FIRST",
                    DATA_WIDTH_B => 9,
                    DOB_REG => 0,
                    EN_RSTRAM_B => FALSE,
                    INIT_B => X"000000000",
                    RST_PRIORITY_B => "CE",
                    SRVAL_B => X"000000000",
                    WRITE_MODE_B => "WRITE_FIRST",
                    RSTTYPE => "SYNC",
                    INIT_FILE => "NONE",
                    SIM_COLLISION_CHECK => "ALL",
                    SIM_DEVICE => "SPARTAN6",
                    INIT_00 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_01 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_02 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_03 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_04 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_05 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_06 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_07 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_08 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_09 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_0A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_0B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_0C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_0D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_0E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_0F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_10 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_11 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_12 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_13 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_14 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_15 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_16 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_17 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_18 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_19 => X"0000000000000000000000000000000000000000000000000000000000000000",
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
                    INIT_3F => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_00 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_01 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_02 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_03 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_04 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_05 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_06 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_07 => X"0000000000000000000000000000000000000000000000000000000000000000")
      port map(  ADDRA => address_a(13 downto 0),
                   ENA => enable,
                  CLKA => clk,
                   DOA => data_out_a_hh(31 downto 0),
                  DOPA => data_out_a_hh(35 downto 32), 
                   DIA => data_in_a(31 downto 0),
                  DIPA => data_in_a(35 downto 32), 
                   WEA => "0000",
                REGCEA => '0',
                  RSTA => '0',
                 ADDRB => address_b(13 downto 0),
                   ENB => enable_b,
                  CLKB => clk_b,
                   DOB => data_out_b_hh(31 downto 0),
                  DOPB => data_out_b_hh(35 downto 32), 
                   DIB => data_in_b_hh(31 downto 0),
                  DIPB => data_in_b_hh(35 downto 32), 
                   WEB => we_b_h(3 downto 0),
                REGCEB => '0',
                  RSTB => '0');
    --
    end generate s6;
    --
    --
    v6 : if (C_FAMILY = "V6") generate
      --
      address_a <= '1' & address(11 downto 0) & "111";
      instruction <= data_out_a_h(32) & data_out_a_h(7 downto 0) & data_out_a_l(32) & data_out_a_l(7 downto 0);
      data_in_a <= "000000000000000000000000000000000000";
      jtag_dout <= data_out_b_h(32) & data_out_b_h(7 downto 0) & data_out_b_l(32) & data_out_b_l(7 downto 0);
      --
      no_loader : if (C_JTAG_LOADER_ENABLE = 0) generate
        data_in_b_l <= "000" & data_out_b_l(32) & "000000000000000000000000" & data_out_b_l(7 downto 0);
        data_in_b_h <= "000" & data_out_b_h(32) & "000000000000000000000000" & data_out_b_h(7 downto 0);
        address_b <= "1111111111111111";
        we_b <= "00000000";
        enable_b <= '0';
        rdl <= '0';
        clk_b <= '0';
      end generate no_loader;
      --
      loader : if (C_JTAG_LOADER_ENABLE = 1) generate
        data_in_b_h <= "000" & jtag_din(17) & "000000000000000000000000" & jtag_din(16 downto 9);
        data_in_b_l <= "000" & jtag_din(8) & "000000000000000000000000" & jtag_din(7 downto 0);
        address_b <= '1' & jtag_addr(11 downto 0) & "111";
        we_b <= jtag_we & jtag_we & jtag_we & jtag_we & jtag_we & jtag_we & jtag_we & jtag_we;
        enable_b <= jtag_en(0);
        rdl <= rdl_bus(0);
        clk_b <= jtag_clk;
      end generate loader;
      --
      kcpsm6_rom_l: RAMB36E1
      generic map ( READ_WIDTH_A => 9,
                    WRITE_WIDTH_A => 9,
                    DOA_REG => 0,
                    INIT_A => X"000000000",
                    RSTREG_PRIORITY_A => "REGCE",
                    SRVAL_A => X"000000000",
                    WRITE_MODE_A => "WRITE_FIRST",
                    READ_WIDTH_B => 9,
                    WRITE_WIDTH_B => 9,
                    DOB_REG => 0,
                    INIT_B => X"000000000",
                    RSTREG_PRIORITY_B => "REGCE",
                    SRVAL_B => X"000000000",
                    WRITE_MODE_B => "WRITE_FIRST",
                    INIT_FILE => "NONE",
                    SIM_COLLISION_CHECK => "ALL",
                    RAM_MODE => "TDP",
                    RDADDR_COLLISION_HWCONFIG => "DELAYED_WRITE",
                    EN_ECC_READ => FALSE,
                    EN_ECC_WRITE => FALSE,
                    RAM_EXTENSION_A => "NONE",
                    RAM_EXTENSION_B => "NONE",
                    SIM_DEVICE => "VIRTEX6",
                    INIT_00 => X"28B82003002F68A805BB38347035003230310E0F1F1E3332000B2F0043784202",
                    INIT_01 => X"2200D02120E570D000E4702D00013B01B8B83B1020B829030070B8780300D0B8",
                    INIT_02 => X"000100405600015C0141A70001000D4B000151010CA742B8424A60B3102F0023",
                    INIT_03 => X"0B2F07012F0020001300308077537BF302A4A69E30BF003040A69E6A40300055",
                    INIT_04 => X"A3060778199E05077832990407502194030750438F020778218A010778438500",
                    INIT_05 => X"DC9031BE03BE1BB00002210320000302000100000100B8803035075019075032",
                    INIT_06 => X"20E0083D38076705BB0CA30BA30AE60D7609727F6A08F91BDC20FB0254010000",
                    INIT_07 => X"004901005B0002F0CFB0AB004EAE09045130EFED60ED1FEB60EDED5FED7FED40",
                    INIT_08 => X"20302228471C3E4710194E02156322203047B0353433320F3847353433320737",
                    INIT_09 => X"69474030013F3247BF3001393147BF30FE33424730FE402D3030DF4720300030",
                    INIT_0A => X"0011010010111260602F603A004F10010000080011070000FD7E506147506047",
                    INIT_0B => X"683C7A00010C017A00087F543C6D000137F037016D0008745300673F00643B3F",
                    INIT_0C => X"0B2FF72F3CB32F102F3C199C0C09A16C3C0B2F082F3CB02FEF2F3C198B0C0990",
                    INIT_0D => X"0A05500002033721203040A0B03E3DE5D00001AE00083CF2AA57CF0100D44D3C",
                    INIT_0E => X"083C3B3CFADD57CF0100104C3CFC30403E3D212037BA100000010001090451B0",
                    INIT_0F => X"0A0550B050403C3B303040F0E0000121203E3DE5D0003CE6010EEA000001E300",
                    INIT_10 => X"190001AE0904510119000008010024583C283E3DFC30200001AB090451000203",
                    INIT_11 => X"0001B00002090451AE0A055001B0000001E0D0BF0100012A00084B403CB00100",
                    INIT_12 => X"01090451B0AB0A0550AEE0D0BF01000151000871503C2A00010904510020AE34",
                    INIT_13 => X"226D3CBD3CA97C013CBB7802087E4A3C510001B001000904512050B056000100",
                    INIT_14 => X"085A04A3051E3002309B041E5A04805A0495011E30FD30F7FB708D0010100807",
                    INIT_15 => X"30BFC30C1E30FE3040BC0B1E30FE30BFB50A1E08AE081E045A1E04AA071E5A04",
                    INIT_16 => X"5A04E4191E30FD30DC181E5A047F5A04D6161EF7CE1C1E30013040CA0D1E3001",
                    INIT_17 => X"401D0F261E5A04F05A04FC311E5A04700F5A04F4271EFB5A1E04EB1B1E5A04F7",
                    INIT_18 => X"00011E3D5A0440F8283D5A041E40271E301E3D5A0440060606068F1E3D5A040F",
                    INIT_19 => X"42D0013E0000014030E5D01001703470013000000809002B0207466626483C83",
                    INIT_1A => X"000872473CB000E04030E5D0003DC43D01705070014C00085C643CB0001001D0",
                    INIT_1B => X"0136DC3631017B000837FEFD84623CB000003D4030E5D020C43D01D066D00162",
                    INIT_1C => X"D0AE960001B0AB09045100A700D0B000E00195019F0008BF0100B24B00377B00",
                    INIT_1D => X"0008C6423CB8019601B80008BC413CB00100A70001AE090451D0A7000040E001",
                    INIT_1E => X"000801088A0801DB0008E2443CCD00080108900801CD0008D4433CC2019D01C2",
                    INIT_1F => X"06081C6E3CF500013D763D01F50008FC493CE800013D7D3D01E80008EF5A3CDB",
                    INIT_20 => X"7E3C1F723C3E3D01003552F00001003F353BF000013FC4355B351B3E3D01001B",
                    INIT_21 => X"0000FEFD3CDA3C063CD638053CDE34043C510130033C2A012B023CCF2601083C",
                    INIT_22 => X"0E0E0E0E603E000701110000100708E04440E50AE00150000140300012500011",
                    INIT_23 => X"0000C4B00010000807B08AB8208A8A00B00001000000003506003E4006060606",
                    INIT_24 => X"D0005700B000D00000D000AE00D001C400B0AB0000C4B00008B00000870007E0",
                    INIT_25 => X"000100000000B00100090451ACB00000AB09045100010000B000D0F05700B000",
                    INIT_26 => X"ABCF00B0232200B0000000B000E00000C400B00100C210000001090451B02120",
                    INIT_27 => X"B021200023220E0F1F1E00D01F1E0100232200B0EE4E00D000CFE8E600B000D0",
                    INIT_28 => X"D00001090451B00000000E0F1F1E00D01F1E010000B00100FF10000001090451",
                    INIT_29 => X"010043DC433D010000B0010029000000010001090451B00000D000B001001900",
                    INIT_2A => X"003A39100023223A39003A39100021203A3900454E0001095A0AB0000000B03D",
                    INIT_2B => X"7B0035910F4035910E0E0E0E406800010100B801000000906100000136DC3600",
                    INIT_2C => X"DC3EDC40007F0800DC3C003A07940A00DC910F40DC910E0E0E0E4000DC7D85DC",
                    INIT_2D => X"B0002065646F4D202032302E3156206D7265546B6361755100DC7DDC40DC7B00",
                    INIT_2E => X"E0688909CE0001080E00069080D607D390800900003020C900D0A0B0C60001A0",
                    INIT_2F => X"F60100023530FC0050E000061600000000E806080880EB2000000100E0000001",
                    INIT_30 => X"00302017010006401D0200B83009010002B8300F0050E0000616130000003530",
                    INIT_31 => X"0000000000000001350400000131240001080E000690802C072990800D00A000",
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
                    INIT_3F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_40 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_41 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_42 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_43 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_44 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_45 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_46 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_47 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_48 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_49 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_50 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_51 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_52 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_53 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_54 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_55 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_56 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_57 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_58 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_59 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_60 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_61 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_62 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_63 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_64 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_65 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_66 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_67 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_68 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_69 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_70 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_71 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_72 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_73 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_74 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_75 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_76 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_77 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_78 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_79 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7F => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_00 => X"58090A948D5555092202481B18C6318C008550201222440156000A94AB00000C",
                   INITP_01 => X"8AAD596A26519698895590CE00130009A53409B675F4C019C71C71903F6E43C7",
                   INITP_02 => X"E8080488082022040810224404101002C0026400C20B69800C4116D106256D22",
                   INITP_03 => X"17BFBDFD013404DBF6FC60206010A9760A4C568931B224C7FD6FF13CE00F4001",
                   INITP_04 => X"56A945010444894228810228A241049027082480018431830000210094BA72B2",
                   INITP_05 => X"87E24F4AA8D5956D7FFFFF2A545E77E69DFD92BB4D269A08791D2D86AD6A912B",
                   INITP_06 => X"0000000000000000000000000000000000000000000000000100342340082F11",
                   INITP_07 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_08 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_09 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0A => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0B => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0C => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0D => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0E => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0F => X"0000000000000000000000000000000000000000000000000000000000000000")
      port map(   ADDRARDADDR => address_a,
                      ENARDEN => enable,
                    CLKARDCLK => clk,
                        DOADO => data_out_a_l(31 downto 0),
                      DOPADOP => data_out_a_l(35 downto 32), 
                        DIADI => data_in_a(31 downto 0),
                      DIPADIP => data_in_a(35 downto 32), 
                          WEA => "0000",
                  REGCEAREGCE => '0',
                RSTRAMARSTRAM => '0',
                RSTREGARSTREG => '0',
                  ADDRBWRADDR => address_b,
                      ENBWREN => enable_b,
                    CLKBWRCLK => clk_b,
                        DOBDO => data_out_b_l(31 downto 0),
                      DOPBDOP => data_out_b_l(35 downto 32), 
                        DIBDI => data_in_b_l(31 downto 0),
                      DIPBDIP => data_in_b_l(35 downto 32), 
                        WEBWE => we_b,
                       REGCEB => '0',
                      RSTRAMB => '0',
                      RSTREGB => '0',
                   CASCADEINA => '0',
                   CASCADEINB => '0',
                INJECTDBITERR => '0',
                INJECTSBITERR => '0');
      --
      kcpsm6_rom_h: RAMB36E1
      generic map ( READ_WIDTH_A => 9,
                    WRITE_WIDTH_A => 9,
                    DOA_REG => 0,
                    INIT_A => X"000000000",
                    RSTREG_PRIORITY_A => "REGCE",
                    SRVAL_A => X"000000000",
                    WRITE_MODE_A => "WRITE_FIRST",
                    READ_WIDTH_B => 9,
                    WRITE_WIDTH_B => 9,
                    DOB_REG => 0,
                    INIT_B => X"000000000",
                    RSTREG_PRIORITY_B => "REGCE",
                    SRVAL_B => X"000000000",
                    WRITE_MODE_B => "WRITE_FIRST",
                    INIT_FILE => "NONE",
                    SIM_COLLISION_CHECK => "ALL",
                    RAM_MODE => "TDP",
                    RDADDR_COLLISION_HWCONFIG => "DELAYED_WRITE",
                    EN_ECC_READ => FALSE,
                    EN_ECC_WRITE => FALSE,
                    RAM_EXTENSION_A => "NONE",
                    RAM_EXTENSION_B => "NONE",
                    SIM_DEVICE => "VIRTEX6",
                    INIT_00 => X"0A000A030959020C0C02007B0B7E0E037878686878787878086878080B0E1000",
                    INIT_01 => X"7AD9C2797A02040428020BB0E8C8588B000078080A000A030901000A03090100",
                    INIT_02 => X"2888084A1088C8906848082888084A1088C8906848081000900000A068582879",
                    INIT_03 => X"6878188858283EA8EA287838B0EA90EA90EA90EA7818287828B0EAB068588800",
                    INIT_04 => X"B0E8100E0BB0E8100E0BB0E8100E0BB0E8100E0BB0E8100E0BB0E8100E0BB0E8",
                    INIT_05 => X"B06E7AB06E90EA002868586858286D6D9D8D28DDCD28B0685803100E0B100E0B",
                    INIT_06 => X"0A906E7892EA92EA92EA92EA92EA92EA92EA92EA92EA90EAB06EB06EB06E88EA",
                    INIT_07 => X"28002EB0EA282E12020000A802006B6A68581E10CA100AB0EA90D0EAF0EA906E",
                    INIT_08 => X"2858B0EA10B0EA102EB0EA10B0EAB0685810005E5B5D5DB0EA107E7B7D7DB0EA",
                    INIT_09 => X"EA102E7828B0EA101E7828B0EA101E7818B0EA1078182EB0EA78189068582878",
                    INIT_0A => X"2878887280580890D0EAF0EA28B0E88870080828787808281E1000CAF0E20AF0",
                    INIT_0B => X"EA12B0E8C80288B0E858B0EA12B0E8C858027888B0E858B0EA28B0EA28B0EA02",
                    INIT_0C => X"687818581200782858B2E890E858B0EA12687828581200781858B2E890E858B0",
                    INIT_0D => X"4A4A49006F6F79585897870707797A02040488B0E8581202B002027D7DB0EA12",
                    INIT_0E => X"587D7D1202B002027D7DB1EA1202D5C5595A5D5D59B0F7E79F8F9D8D6A6A6900",
                    INIT_0F => X"4A4A4C009181595902D5C50505DFCF5F5F797A02040412B0C802B0FDED88B0E8",
                    INIT_10 => X"B1E8C8006B6A6A88B1E80A587D7DB1EA12025858B0F7E7DFCF006A6A6C006F6F",
                    INIT_11 => X"E8C800DDCD6A6A69004A4A4988009D85C8C000027D7D88B1E858B1EA12005D5D",
                    INIT_12 => X"8D6A6A6900004A4A4900C000027D7D88B1E858B1EA12B1E8C86B6A69590A00B1",
                    INIT_13 => X"B1EA12021202B1E81202B1E858B1EA12B1E8C8005D5D6B6A6A0A5900B1E8C89D",
                    INIT_14 => X"2BA26EB1EA117A2A5AB1EA11A26E2BA26EB1EA117A1A5A1E1E0BB1EA52800858",
                    INIT_15 => X"5A1EB1EA117A1A5A2EB1EA117A1A5A1EB1EA112EB1EA112E02B16EB1EA11A26E",
                    INIT_16 => X"A26EB1EA117A1A5AB1EA11A26E1BA26EB1EA111EB1EA117A2A5A2EB1EA117A2A",
                    INIT_17 => X"E20AF1EA11A26E1BA26EB1EA11A26E2B1BA26EB1EA111E02916EB1EA11A26E1B",
                    INIT_18 => X"E088115AA26E831BCA7AA26EF1E20AF1EA115AA26E83A2A2A2A21BCA7AA26EF1",
                    INIT_19 => X"D1E0C891E850880505020404C800D1E0C891E85008780891E858B1EA91EA12B1",
                    INIT_1A => X"E858B1EA12009D850505020404580278C800D1E0C891E858B1EA12009D85C800",
                    INIT_1B => X"C85800785A88B1E8587A1E1EB1EA12009D855805050204040278C800D1E0C891",
                    INIT_1C => X"0211B1EFCF00006B6A6A0A110A0700DDC5CF91EA91EA5A027D7DB1EA285AB1E8",
                    INIT_1D => X"E858B1EA12B1C80288B1E858B1EA12005D5DB1EFCF006B6A6A07B1EF0A07C28A",
                    INIT_1E => X"E878C858027888B1E858B1EA12B1E878C858027888B1E858B1EA12B1C80288B1",
                    INIT_1F => X"E858B2EA12B1E8C858027888B1E858B1EA12B1E8C858027888B1E858B1EA12B1",
                    INIT_20 => X"EA12B2EA125A5A5D5D030A0299890959030A0299897F02030A030A7A7A7D7DB2",
                    INIT_21 => X"0F281E1E1202B2E81202B2E81202B2E8120108B2E8120108B2E81202B2E858B2",
                    INIT_22 => X"A3A3A3A3027A287888780877805808021207020C048892E8C887CA520892E858",
                    INIT_23 => X"88EF02109D85C008180012000A02122800DDCD88FDED28030A285A23A2A2A2A2",
                    INIT_24 => X"85E8022800DDC5C8FDE5280088E78F0228000088EF0210DDCD10DDC592E81800",
                    INIT_25 => X"0A7D7D0D0D28005D5D6B6A69B200FDED006B6A6A0A7D7D28009D85F20228009D",
                    INIT_26 => X"000228005D5D28000D0D2800DDC588EF0228005D5DB2F5E59D8D6B6A6A005858",
                    INIT_27 => X"0058580A5D5D6F6F7F7F9F875F5F7D7D5D5D280092029D852802120228009D85",
                    INIT_28 => X"E59D8D6B6A6A000A0D0D6F6F7F7FDFC75F5F7D7D28005D5DB2F5E59D8D6B6A6A",
                    INIT_29 => X"5D5D0202027B7D7D28005D5DB2F8E8D8C89D8D6B6A6A000A080028005D5DB2FD",
                    INIT_2A => X"285858F5E558587878285858F5E55858787828B2029D8D6B024B000D0D28005B",
                    INIT_2B => X"0A2803021A020302A2A2A2A202129C8C5C5C007C7C88EA241288EA8A5A007A0A",
                    INIT_2C => X"000A00025A025A7A000A288A8AD2CA2800021A020002A2A2A2A20228000A0200",
                    INIT_2D => X"010A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A28000A0002000A28",
                    INIT_2E => X"120808091288C8A4A4A1A1978712A1D2D7C70809090707120C04010112998901",
                    INIT_2F => X"12CF88EF038A92EF87520F0F0393F9E928B2A1A2A18192640A090928B2D9D8C8",
                    INIT_30 => X"090707138A88EA77030A28000A13CF88EF008A93EF87520F0F0393F9E928030A",
                    INIT_31 => X"000000000000286AB368482858581388C8A4A4A1A1978713A1D3D7C7080C0C09",
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
                    INIT_3F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_40 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_41 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_42 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_43 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_44 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_45 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_46 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_47 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_48 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_49 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_50 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_51 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_52 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_53 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_54 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_55 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_56 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_57 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_58 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_59 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_60 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_61 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_62 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_63 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_64 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_65 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_66 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_67 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_68 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_69 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_70 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_71 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_72 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_73 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_74 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_75 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_76 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_77 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_78 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_79 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7F => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_00 => X"D5FF956A5AAAAAAAB5D72664A5294A52C56AAB538D11A3F39CD0E5295275FF63",
                   INITP_01 => X"100073627FEC040F0E0713FDCE52E729652C696DD1AC9D49555559532D5A617E",
                   INITP_02 => X"2CAC55ACACB2AB162C58AAD656595820BEE593987C4E967327841D2C9E8EC87B",
                   INITP_03 => X"2C69634B4D2D34B52D4B27A067D229EA324B04C92C2324B09042452B2869500D",
                   INITP_04 => X"83C33CFCF332E43C667CF79E7939F648B03793400750A2044EEED6B96850A75F",
                   INITP_05 => X"AA0CC2188C0501087FFFFFD5A5A5CC1B73043DC681C0F9A63FC81E321E3C3C87",
                   INITP_06 => X"000000000000000000000000000000000000000000000000039F014015B55066",
                   INITP_07 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_08 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_09 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0A => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0B => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0C => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0D => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0E => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0F => X"0000000000000000000000000000000000000000000000000000000000000000")
      port map(   ADDRARDADDR => address_a,
                      ENARDEN => enable,
                    CLKARDCLK => clk,
                        DOADO => data_out_a_h(31 downto 0),
                      DOPADOP => data_out_a_h(35 downto 32), 
                        DIADI => data_in_a(31 downto 0),
                      DIPADIP => data_in_a(35 downto 32), 
                          WEA => "0000",
                  REGCEAREGCE => '0',
                RSTRAMARSTRAM => '0',
                RSTREGARSTREG => '0',
                  ADDRBWRADDR => address_b,
                      ENBWREN => enable_b,
                    CLKBWRCLK => clk_b,
                        DOBDO => data_out_b_h(31 downto 0),
                      DOPBDOP => data_out_b_h(35 downto 32), 
                        DIBDI => data_in_b_h(31 downto 0),
                      DIPBDIP => data_in_b_h(35 downto 32), 
                        WEBWE => we_b,
                       REGCEB => '0',
                      RSTRAMB => '0',
                      RSTREGB => '0',
                   CASCADEINA => '0',
                   CASCADEINB => '0',
                INJECTDBITERR => '0',
                INJECTSBITERR => '0');
      --
    end generate v6;
    --
    --
    akv7 : if (C_FAMILY = "7S") generate
      --
      address_a <= '1' & address(11 downto 0) & "111";
      instruction <= data_out_a_h(32) & data_out_a_h(7 downto 0) & data_out_a_l(32) & data_out_a_l(7 downto 0);
      data_in_a <= "000000000000000000000000000000000000";
      jtag_dout <= data_out_b_h(32) & data_out_b_h(7 downto 0) & data_out_b_l(32) & data_out_b_l(7 downto 0);
      --
      no_loader : if (C_JTAG_LOADER_ENABLE = 0) generate
        data_in_b_l <= "000" & data_out_b_l(32) & "000000000000000000000000" & data_out_b_l(7 downto 0);
        data_in_b_h <= "000" & data_out_b_h(32) & "000000000000000000000000" & data_out_b_h(7 downto 0);
        address_b <= "1111111111111111";
        we_b <= "00000000";
        enable_b <= '0';
        rdl <= '0';
        clk_b <= '0';
      end generate no_loader;
      --
      loader : if (C_JTAG_LOADER_ENABLE = 1) generate
        data_in_b_h <= "000" & jtag_din(17) & "000000000000000000000000" & jtag_din(16 downto 9);
        data_in_b_l <= "000" & jtag_din(8) & "000000000000000000000000" & jtag_din(7 downto 0);
        address_b <= '1' & jtag_addr(11 downto 0) & "111";
        we_b <= jtag_we & jtag_we & jtag_we & jtag_we & jtag_we & jtag_we & jtag_we & jtag_we;
        enable_b <= jtag_en(0);
        rdl <= rdl_bus(0);
        clk_b <= jtag_clk;
      end generate loader;
      --
      kcpsm6_rom_l: RAMB36E1
      generic map ( READ_WIDTH_A => 9,
                    WRITE_WIDTH_A => 9,
                    DOA_REG => 0,
                    INIT_A => X"000000000",
                    RSTREG_PRIORITY_A => "REGCE",
                    SRVAL_A => X"000000000",
                    WRITE_MODE_A => "WRITE_FIRST",
                    READ_WIDTH_B => 9,
                    WRITE_WIDTH_B => 9,
                    DOB_REG => 0,
                    INIT_B => X"000000000",
                    RSTREG_PRIORITY_B => "REGCE",
                    SRVAL_B => X"000000000",
                    WRITE_MODE_B => "WRITE_FIRST",
                    INIT_FILE => "NONE",
                    SIM_COLLISION_CHECK => "ALL",
                    RAM_MODE => "TDP",
                    RDADDR_COLLISION_HWCONFIG => "DELAYED_WRITE",
                    EN_ECC_READ => FALSE,
                    EN_ECC_WRITE => FALSE,
                    RAM_EXTENSION_A => "NONE",
                    RAM_EXTENSION_B => "NONE",
                    SIM_DEVICE => "7SERIES",
                    INIT_00 => X"28B82003002F68A805BB38347035003230310E0F1F1E3332000B2F0043784202",
                    INIT_01 => X"2200D02120E570D000E4702D00013B01B8B83B1020B829030070B8780300D0B8",
                    INIT_02 => X"000100405600015C0141A70001000D4B000151010CA742B8424A60B3102F0023",
                    INIT_03 => X"0B2F07012F0020001300308077537BF302A4A69E30BF003040A69E6A40300055",
                    INIT_04 => X"A3060778199E05077832990407502194030750438F020778218A010778438500",
                    INIT_05 => X"DC9031BE03BE1BB00002210320000302000100000100B8803035075019075032",
                    INIT_06 => X"20E0083D38076705BB0CA30BA30AE60D7609727F6A08F91BDC20FB0254010000",
                    INIT_07 => X"004901005B0002F0CFB0AB004EAE09045130EFED60ED1FEB60EDED5FED7FED40",
                    INIT_08 => X"20302228471C3E4710194E02156322203047B0353433320F3847353433320737",
                    INIT_09 => X"69474030013F3247BF3001393147BF30FE33424730FE402D3030DF4720300030",
                    INIT_0A => X"0011010010111260602F603A004F10010000080011070000FD7E506147506047",
                    INIT_0B => X"683C7A00010C017A00087F543C6D000137F037016D0008745300673F00643B3F",
                    INIT_0C => X"0B2FF72F3CB32F102F3C199C0C09A16C3C0B2F082F3CB02FEF2F3C198B0C0990",
                    INIT_0D => X"0A05500002033721203040A0B03E3DE5D00001AE00083CF2AA57CF0100D44D3C",
                    INIT_0E => X"083C3B3CFADD57CF0100104C3CFC30403E3D212037BA100000010001090451B0",
                    INIT_0F => X"0A0550B050403C3B303040F0E0000121203E3DE5D0003CE6010EEA000001E300",
                    INIT_10 => X"190001AE0904510119000008010024583C283E3DFC30200001AB090451000203",
                    INIT_11 => X"0001B00002090451AE0A055001B0000001E0D0BF0100012A00084B403CB00100",
                    INIT_12 => X"01090451B0AB0A0550AEE0D0BF01000151000871503C2A00010904510020AE34",
                    INIT_13 => X"226D3CBD3CA97C013CBB7802087E4A3C510001B001000904512050B056000100",
                    INIT_14 => X"085A04A3051E3002309B041E5A04805A0495011E30FD30F7FB708D0010100807",
                    INIT_15 => X"30BFC30C1E30FE3040BC0B1E30FE30BFB50A1E08AE081E045A1E04AA071E5A04",
                    INIT_16 => X"5A04E4191E30FD30DC181E5A047F5A04D6161EF7CE1C1E30013040CA0D1E3001",
                    INIT_17 => X"401D0F261E5A04F05A04FC311E5A04700F5A04F4271EFB5A1E04EB1B1E5A04F7",
                    INIT_18 => X"00011E3D5A0440F8283D5A041E40271E301E3D5A0440060606068F1E3D5A040F",
                    INIT_19 => X"42D0013E0000014030E5D01001703470013000000809002B0207466626483C83",
                    INIT_1A => X"000872473CB000E04030E5D0003DC43D01705070014C00085C643CB0001001D0",
                    INIT_1B => X"0136DC3631017B000837FEFD84623CB000003D4030E5D020C43D01D066D00162",
                    INIT_1C => X"D0AE960001B0AB09045100A700D0B000E00195019F0008BF0100B24B00377B00",
                    INIT_1D => X"0008C6423CB8019601B80008BC413CB00100A70001AE090451D0A7000040E001",
                    INIT_1E => X"000801088A0801DB0008E2443CCD00080108900801CD0008D4433CC2019D01C2",
                    INIT_1F => X"06081C6E3CF500013D763D01F50008FC493CE800013D7D3D01E80008EF5A3CDB",
                    INIT_20 => X"7E3C1F723C3E3D01003552F00001003F353BF000013FC4355B351B3E3D01001B",
                    INIT_21 => X"0000FEFD3CDA3C063CD638053CDE34043C510130033C2A012B023CCF2601083C",
                    INIT_22 => X"0E0E0E0E603E000701110000100708E04440E50AE00150000140300012500011",
                    INIT_23 => X"0000C4B00010000807B08AB8208A8A00B00001000000003506003E4006060606",
                    INIT_24 => X"D0005700B000D00000D000AE00D001C400B0AB0000C4B00008B00000870007E0",
                    INIT_25 => X"000100000000B00100090451ACB00000AB09045100010000B000D0F05700B000",
                    INIT_26 => X"ABCF00B0232200B0000000B000E00000C400B00100C210000001090451B02120",
                    INIT_27 => X"B021200023220E0F1F1E00D01F1E0100232200B0EE4E00D000CFE8E600B000D0",
                    INIT_28 => X"D00001090451B00000000E0F1F1E00D01F1E010000B00100FF10000001090451",
                    INIT_29 => X"010043DC433D010000B0010029000000010001090451B00000D000B001001900",
                    INIT_2A => X"003A39100023223A39003A39100021203A3900454E0001095A0AB0000000B03D",
                    INIT_2B => X"7B0035910F4035910E0E0E0E406800010100B801000000906100000136DC3600",
                    INIT_2C => X"DC3EDC40007F0800DC3C003A07940A00DC910F40DC910E0E0E0E4000DC7D85DC",
                    INIT_2D => X"B0002065646F4D202032302E3156206D7265546B6361755100DC7DDC40DC7B00",
                    INIT_2E => X"E0688909CE0001080E00069080D607D390800900003020C900D0A0B0C60001A0",
                    INIT_2F => X"F60100023530FC0050E000061600000000E806080880EB2000000100E0000001",
                    INIT_30 => X"00302017010006401D0200B83009010002B8300F0050E0000616130000003530",
                    INIT_31 => X"0000000000000001350400000131240001080E000690802C072990800D00A000",
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
                    INIT_3F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_40 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_41 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_42 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_43 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_44 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_45 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_46 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_47 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_48 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_49 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_50 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_51 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_52 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_53 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_54 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_55 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_56 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_57 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_58 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_59 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_60 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_61 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_62 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_63 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_64 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_65 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_66 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_67 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_68 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_69 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_70 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_71 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_72 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_73 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_74 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_75 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_76 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_77 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_78 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_79 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7F => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_00 => X"58090A948D5555092202481B18C6318C008550201222440156000A94AB00000C",
                   INITP_01 => X"8AAD596A26519698895590CE00130009A53409B675F4C019C71C71903F6E43C7",
                   INITP_02 => X"E8080488082022040810224404101002C0026400C20B69800C4116D106256D22",
                   INITP_03 => X"17BFBDFD013404DBF6FC60206010A9760A4C568931B224C7FD6FF13CE00F4001",
                   INITP_04 => X"56A945010444894228810228A241049027082480018431830000210094BA72B2",
                   INITP_05 => X"87E24F4AA8D5956D7FFFFF2A545E77E69DFD92BB4D269A08791D2D86AD6A912B",
                   INITP_06 => X"0000000000000000000000000000000000000000000000000100342340082F11",
                   INITP_07 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_08 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_09 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0A => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0B => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0C => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0D => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0E => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0F => X"0000000000000000000000000000000000000000000000000000000000000000")
      port map(   ADDRARDADDR => address_a,
                      ENARDEN => enable,
                    CLKARDCLK => clk,
                        DOADO => data_out_a_l(31 downto 0),
                      DOPADOP => data_out_a_l(35 downto 32), 
                        DIADI => data_in_a(31 downto 0),
                      DIPADIP => data_in_a(35 downto 32), 
                          WEA => "0000",
                  REGCEAREGCE => '0',
                RSTRAMARSTRAM => '0',
                RSTREGARSTREG => '0',
                  ADDRBWRADDR => address_b,
                      ENBWREN => enable_b,
                    CLKBWRCLK => clk_b,
                        DOBDO => data_out_b_l(31 downto 0),
                      DOPBDOP => data_out_b_l(35 downto 32), 
                        DIBDI => data_in_b_l(31 downto 0),
                      DIPBDIP => data_in_b_l(35 downto 32), 
                        WEBWE => we_b,
                       REGCEB => '0',
                      RSTRAMB => '0',
                      RSTREGB => '0',
                   CASCADEINA => '0',
                   CASCADEINB => '0',
                INJECTDBITERR => '0',
                INJECTSBITERR => '0');
      --
      kcpsm6_rom_h: RAMB36E1
      generic map ( READ_WIDTH_A => 9,
                    WRITE_WIDTH_A => 9,
                    DOA_REG => 0,
                    INIT_A => X"000000000",
                    RSTREG_PRIORITY_A => "REGCE",
                    SRVAL_A => X"000000000",
                    WRITE_MODE_A => "WRITE_FIRST",
                    READ_WIDTH_B => 9,
                    WRITE_WIDTH_B => 9,
                    DOB_REG => 0,
                    INIT_B => X"000000000",
                    RSTREG_PRIORITY_B => "REGCE",
                    SRVAL_B => X"000000000",
                    WRITE_MODE_B => "WRITE_FIRST",
                    INIT_FILE => "NONE",
                    SIM_COLLISION_CHECK => "ALL",
                    RAM_MODE => "TDP",
                    RDADDR_COLLISION_HWCONFIG => "DELAYED_WRITE",
                    EN_ECC_READ => FALSE,
                    EN_ECC_WRITE => FALSE,
                    RAM_EXTENSION_A => "NONE",
                    RAM_EXTENSION_B => "NONE",
                    SIM_DEVICE => "7SERIES",
                    INIT_00 => X"0A000A030959020C0C02007B0B7E0E037878686878787878086878080B0E1000",
                    INIT_01 => X"7AD9C2797A02040428020BB0E8C8588B000078080A000A030901000A03090100",
                    INIT_02 => X"2888084A1088C8906848082888084A1088C8906848081000900000A068582879",
                    INIT_03 => X"6878188858283EA8EA287838B0EA90EA90EA90EA7818287828B0EAB068588800",
                    INIT_04 => X"B0E8100E0BB0E8100E0BB0E8100E0BB0E8100E0BB0E8100E0BB0E8100E0BB0E8",
                    INIT_05 => X"B06E7AB06E90EA002868586858286D6D9D8D28DDCD28B0685803100E0B100E0B",
                    INIT_06 => X"0A906E7892EA92EA92EA92EA92EA92EA92EA92EA92EA90EAB06EB06EB06E88EA",
                    INIT_07 => X"28002EB0EA282E12020000A802006B6A68581E10CA100AB0EA90D0EAF0EA906E",
                    INIT_08 => X"2858B0EA10B0EA102EB0EA10B0EAB0685810005E5B5D5DB0EA107E7B7D7DB0EA",
                    INIT_09 => X"EA102E7828B0EA101E7828B0EA101E7818B0EA1078182EB0EA78189068582878",
                    INIT_0A => X"2878887280580890D0EAF0EA28B0E88870080828787808281E1000CAF0E20AF0",
                    INIT_0B => X"EA12B0E8C80288B0E858B0EA12B0E8C858027888B0E858B0EA28B0EA28B0EA02",
                    INIT_0C => X"687818581200782858B2E890E858B0EA12687828581200781858B2E890E858B0",
                    INIT_0D => X"4A4A49006F6F79585897870707797A02040488B0E8581202B002027D7DB0EA12",
                    INIT_0E => X"587D7D1202B002027D7DB1EA1202D5C5595A5D5D59B0F7E79F8F9D8D6A6A6900",
                    INIT_0F => X"4A4A4C009181595902D5C50505DFCF5F5F797A02040412B0C802B0FDED88B0E8",
                    INIT_10 => X"B1E8C8006B6A6A88B1E80A587D7DB1EA12025858B0F7E7DFCF006A6A6C006F6F",
                    INIT_11 => X"E8C800DDCD6A6A69004A4A4988009D85C8C000027D7D88B1E858B1EA12005D5D",
                    INIT_12 => X"8D6A6A6900004A4A4900C000027D7D88B1E858B1EA12B1E8C86B6A69590A00B1",
                    INIT_13 => X"B1EA12021202B1E81202B1E858B1EA12B1E8C8005D5D6B6A6A0A5900B1E8C89D",
                    INIT_14 => X"2BA26EB1EA117A2A5AB1EA11A26E2BA26EB1EA117A1A5A1E1E0BB1EA52800858",
                    INIT_15 => X"5A1EB1EA117A1A5A2EB1EA117A1A5A1EB1EA112EB1EA112E02B16EB1EA11A26E",
                    INIT_16 => X"A26EB1EA117A1A5AB1EA11A26E1BA26EB1EA111EB1EA117A2A5A2EB1EA117A2A",
                    INIT_17 => X"E20AF1EA11A26E1BA26EB1EA11A26E2B1BA26EB1EA111E02916EB1EA11A26E1B",
                    INIT_18 => X"E088115AA26E831BCA7AA26EF1E20AF1EA115AA26E83A2A2A2A21BCA7AA26EF1",
                    INIT_19 => X"D1E0C891E850880505020404C800D1E0C891E85008780891E858B1EA91EA12B1",
                    INIT_1A => X"E858B1EA12009D850505020404580278C800D1E0C891E858B1EA12009D85C800",
                    INIT_1B => X"C85800785A88B1E8587A1E1EB1EA12009D855805050204040278C800D1E0C891",
                    INIT_1C => X"0211B1EFCF00006B6A6A0A110A0700DDC5CF91EA91EA5A027D7DB1EA285AB1E8",
                    INIT_1D => X"E858B1EA12B1C80288B1E858B1EA12005D5DB1EFCF006B6A6A07B1EF0A07C28A",
                    INIT_1E => X"E878C858027888B1E858B1EA12B1E878C858027888B1E858B1EA12B1C80288B1",
                    INIT_1F => X"E858B2EA12B1E8C858027888B1E858B1EA12B1E8C858027888B1E858B1EA12B1",
                    INIT_20 => X"EA12B2EA125A5A5D5D030A0299890959030A0299897F02030A030A7A7A7D7DB2",
                    INIT_21 => X"0F281E1E1202B2E81202B2E81202B2E8120108B2E8120108B2E81202B2E858B2",
                    INIT_22 => X"A3A3A3A3027A287888780877805808021207020C048892E8C887CA520892E858",
                    INIT_23 => X"88EF02109D85C008180012000A02122800DDCD88FDED28030A285A23A2A2A2A2",
                    INIT_24 => X"85E8022800DDC5C8FDE5280088E78F0228000088EF0210DDCD10DDC592E81800",
                    INIT_25 => X"0A7D7D0D0D28005D5D6B6A69B200FDED006B6A6A0A7D7D28009D85F20228009D",
                    INIT_26 => X"000228005D5D28000D0D2800DDC588EF0228005D5DB2F5E59D8D6B6A6A005858",
                    INIT_27 => X"0058580A5D5D6F6F7F7F9F875F5F7D7D5D5D280092029D852802120228009D85",
                    INIT_28 => X"E59D8D6B6A6A000A0D0D6F6F7F7FDFC75F5F7D7D28005D5DB2F5E59D8D6B6A6A",
                    INIT_29 => X"5D5D0202027B7D7D28005D5DB2F8E8D8C89D8D6B6A6A000A080028005D5DB2FD",
                    INIT_2A => X"285858F5E558587878285858F5E55858787828B2029D8D6B024B000D0D28005B",
                    INIT_2B => X"0A2803021A020302A2A2A2A202129C8C5C5C007C7C88EA241288EA8A5A007A0A",
                    INIT_2C => X"000A00025A025A7A000A288A8AD2CA2800021A020002A2A2A2A20228000A0200",
                    INIT_2D => X"010A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A28000A0002000A28",
                    INIT_2E => X"120808091288C8A4A4A1A1978712A1D2D7C70809090707120C04010112998901",
                    INIT_2F => X"12CF88EF038A92EF87520F0F0393F9E928B2A1A2A18192640A090928B2D9D8C8",
                    INIT_30 => X"090707138A88EA77030A28000A13CF88EF008A93EF87520F0F0393F9E928030A",
                    INIT_31 => X"000000000000286AB368482858581388C8A4A4A1A1978713A1D3D7C7080C0C09",
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
                    INIT_3F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_40 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_41 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_42 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_43 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_44 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_45 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_46 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_47 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_48 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_49 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_4F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_50 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_51 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_52 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_53 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_54 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_55 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_56 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_57 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_58 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_59 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_5F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_60 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_61 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_62 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_63 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_64 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_65 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_66 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_67 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_68 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_69 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_6F => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_70 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_71 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_72 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_73 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_74 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_75 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_76 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_77 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_78 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_79 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7F => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_00 => X"D5FF956A5AAAAAAAB5D72664A5294A52C56AAB538D11A3F39CD0E5295275FF63",
                   INITP_01 => X"100073627FEC040F0E0713FDCE52E729652C696DD1AC9D49555559532D5A617E",
                   INITP_02 => X"2CAC55ACACB2AB162C58AAD656595820BEE593987C4E967327841D2C9E8EC87B",
                   INITP_03 => X"2C69634B4D2D34B52D4B27A067D229EA324B04C92C2324B09042452B2869500D",
                   INITP_04 => X"83C33CFCF332E43C667CF79E7939F648B03793400750A2044EEED6B96850A75F",
                   INITP_05 => X"AA0CC2188C0501087FFFFFD5A5A5CC1B73043DC681C0F9A63FC81E321E3C3C87",
                   INITP_06 => X"000000000000000000000000000000000000000000000000039F014015B55066",
                   INITP_07 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_08 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_09 => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0A => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0B => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0C => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0D => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0E => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_0F => X"0000000000000000000000000000000000000000000000000000000000000000")
      port map(   ADDRARDADDR => address_a,
                      ENARDEN => enable,
                    CLKARDCLK => clk,
                        DOADO => data_out_a_h(31 downto 0),
                      DOPADOP => data_out_a_h(35 downto 32), 
                        DIADI => data_in_a(31 downto 0),
                      DIPADIP => data_in_a(35 downto 32), 
                          WEA => "0000",
                  REGCEAREGCE => '0',
                RSTRAMARSTRAM => '0',
                RSTREGARSTREG => '0',
                  ADDRBWRADDR => address_b,
                      ENBWREN => enable_b,
                    CLKBWRCLK => clk_b,
                        DOBDO => data_out_b_h(31 downto 0),
                      DOPBDOP => data_out_b_h(35 downto 32), 
                        DIBDI => data_in_b_h(31 downto 0),
                      DIPBDIP => data_in_b_h(35 downto 32), 
                        WEBWE => we_b,
                       REGCEB => '0',
                      RSTRAMB => '0',
                      RSTREGB => '0',
                   CASCADEINA => '0',
                   CASCADEINB => '0',
                INJECTDBITERR => '0',
                INJECTSBITERR => '0');
      --
    end generate akv7;
    --
  end generate ram_4k_generate;	              
  --
  --
  --
  --
  -- JTAG Loader
  --
  instantiate_loader : if (C_JTAG_LOADER_ENABLE = 1) generate
  --
    jtag_loader_6_inst : jtag_loader_6
    generic map(              C_FAMILY => C_FAMILY,
                       C_NUM_PICOBLAZE => 1,
                  C_JTAG_LOADER_ENABLE => C_JTAG_LOADER_ENABLE,
                 C_BRAM_MAX_ADDR_WIDTH => BRAM_ADDRESS_WIDTH,
	                  C_ADDR_WIDTH_0 => BRAM_ADDRESS_WIDTH)
    port map( picoblaze_reset => rdl_bus,
                      jtag_en => jtag_en,
                     jtag_din => jtag_din,
                    jtag_addr => jtag_addr(BRAM_ADDRESS_WIDTH-1 downto 0),
                     jtag_clk => jtag_clk,
                      jtag_we => jtag_we,
                  jtag_dout_0 => jtag_dout,
                  jtag_dout_1 => jtag_dout, -- ports 1-7 are not used
                  jtag_dout_2 => jtag_dout, -- in a 1 device debug 
                  jtag_dout_3 => jtag_dout, -- session.  However, Synplify
                  jtag_dout_4 => jtag_dout, -- etc require all ports to
                  jtag_dout_5 => jtag_dout, -- be connected
                  jtag_dout_6 => jtag_dout,
                  jtag_dout_7 => jtag_dout);
    --  
  end generate instantiate_loader;
  --
end low_level_definition;
--
--
-------------------------------------------------------------------------------------------
--
-- JTAG Loader 
--
-------------------------------------------------------------------------------------------
--
--
-- JTAG Loader 6 - Version 6.00
-- Kris Chaplin 4 February 2010
-- Ken Chapman 15 August 2011 - Revised coding style
--
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--
library unisim;
use unisim.vcomponents.all;
--
entity jtag_loader_6 is
generic(              C_JTAG_LOADER_ENABLE : integer := 1;
                                  C_FAMILY : string := "V6";
                           C_NUM_PICOBLAZE : integer := 1;
                     C_BRAM_MAX_ADDR_WIDTH : integer := 10;
        C_PICOBLAZE_INSTRUCTION_DATA_WIDTH : integer := 18;
                              C_JTAG_CHAIN : integer := 2;
                            C_ADDR_WIDTH_0 : integer := 10;
                            C_ADDR_WIDTH_1 : integer := 10;
                            C_ADDR_WIDTH_2 : integer := 10;
                            C_ADDR_WIDTH_3 : integer := 10;
                            C_ADDR_WIDTH_4 : integer := 10;
                            C_ADDR_WIDTH_5 : integer := 10;
                            C_ADDR_WIDTH_6 : integer := 10;
                            C_ADDR_WIDTH_7 : integer := 10);
port(   picoblaze_reset : out std_logic_vector(C_NUM_PICOBLAZE-1 downto 0);
                jtag_en : out std_logic_vector(C_NUM_PICOBLAZE-1 downto 0) := (others => '0');
               jtag_din : out std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0) := (others => '0');
              jtag_addr : out std_logic_vector(C_BRAM_MAX_ADDR_WIDTH-1 downto 0) := (others => '0');
               jtag_clk : out std_logic := '0';
                jtag_we : out std_logic := '0';
            jtag_dout_0 : in  std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
            jtag_dout_1 : in  std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
            jtag_dout_2 : in  std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
            jtag_dout_3 : in  std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
            jtag_dout_4 : in  std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
            jtag_dout_5 : in  std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
            jtag_dout_6 : in  std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
            jtag_dout_7 : in  std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0));
end jtag_loader_6;
--
architecture Behavioral of jtag_loader_6 is
  --
  signal num_picoblaze       : std_logic_vector(2 downto 0);
  signal picoblaze_instruction_data_width : std_logic_vector(4 downto 0);
  --
  signal drck                : std_logic;
  signal shift_clk           : std_logic;
  signal shift_din           : std_logic;
  signal shift_dout          : std_logic;
  signal shift               : std_logic;
  signal capture             : std_logic;
  --
  signal control_reg_ce      : std_logic;
  signal bram_ce             : std_logic_vector(C_NUM_PICOBLAZE-1 downto 0);
  signal bus_zero            : std_logic_vector(C_NUM_PICOBLAZE-1 downto 0) := (others => '0');
  signal jtag_en_int         : std_logic_vector(C_NUM_PICOBLAZE-1 downto 0);
  signal jtag_en_expanded    : std_logic_vector(7 downto 0) := (others => '0');
  signal jtag_addr_int       : std_logic_vector(C_BRAM_MAX_ADDR_WIDTH-1 downto 0);
  signal jtag_din_int        : std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
  signal control_din         : std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0):= (others => '0');
  signal control_dout        : std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0):= (others => '0');
  signal control_dout_int    : std_logic_vector(7 downto 0):= (others => '0');
  signal bram_dout_int       : std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0) := (others => '0');
  signal jtag_we_int         : std_logic;
  signal jtag_clk_int        : std_logic;
  signal bram_ce_valid       : std_logic;
  signal din_load            : std_logic;
  --
  signal jtag_dout_0_masked  : std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
  signal jtag_dout_1_masked  : std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
  signal jtag_dout_2_masked  : std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
  signal jtag_dout_3_masked  : std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
  signal jtag_dout_4_masked  : std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
  signal jtag_dout_5_masked  : std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
  signal jtag_dout_6_masked  : std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
  signal jtag_dout_7_masked  : std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto 0);
  signal picoblaze_reset_int : std_logic_vector(C_NUM_PICOBLAZE-1 downto 0) := (others => '0');
  --        
begin
  bus_zero <= (others => '0');
  --
  jtag_loader_gen: if (C_JTAG_LOADER_ENABLE = 1) generate
    --
    -- Insert BSCAN primitive for target device architecture.
    --
    BSCAN_SPARTAN6_gen: if (C_FAMILY="S6") generate
    begin
      BSCAN_BLOCK_inst : BSCAN_SPARTAN6
      generic map ( JTAG_CHAIN => C_JTAG_CHAIN)
      port map( CAPTURE => capture,
                   DRCK => drck,
                  RESET => open,
                RUNTEST => open,
                    SEL => bram_ce_valid,
                  SHIFT => shift,
                    TCK => open,
                    TDI => shift_din,
                    TMS => open,
                 UPDATE => jtag_clk_int,
                    TDO => shift_dout);
    end generate BSCAN_SPARTAN6_gen;   
    --
    BSCAN_VIRTEX6_gen: if (C_FAMILY="V6") generate
    begin
      BSCAN_BLOCK_inst: BSCAN_VIRTEX6
      generic map(    JTAG_CHAIN => C_JTAG_CHAIN,
                    DISABLE_JTAG => FALSE)
      port map( CAPTURE => capture,
                   DRCK => drck,
                  RESET => open,
                RUNTEST => open,
                    SEL => bram_ce_valid,
                  SHIFT => shift,
                    TCK => open,
                    TDI => shift_din,
                    TMS => open,
                 UPDATE => jtag_clk_int,
                    TDO => shift_dout);
    end generate BSCAN_VIRTEX6_gen;   
    --
    BSCAN_7SERIES_gen: if (C_FAMILY="7S") generate
    begin
      BSCAN_BLOCK_inst: BSCANE2
      generic map(    JTAG_CHAIN => C_JTAG_CHAIN,
                    DISABLE_JTAG => "FALSE")
      port map( CAPTURE => capture,
                   DRCK => drck,
                  RESET => open,
                RUNTEST => open,
                    SEL => bram_ce_valid,
                  SHIFT => shift,
                    TCK => open,
                    TDI => shift_din,
                    TMS => open,
                 UPDATE => jtag_clk_int,
                    TDO => shift_dout);
    end generate BSCAN_7SERIES_gen;   
    --
    --
    -- Insert clock buffer to ensure reliable shift operations.
    --
    upload_clock: BUFG
    port map( I => drck,
              O => shift_clk);
    --        
    --        
    --  Shift Register      
    --        
    --
    control_reg_ce_shift: process (shift_clk)
    begin
      if shift_clk'event and shift_clk = '1' then
        if (shift = '1') then
          control_reg_ce <= shift_din;
        end if;
      end if;
    end process control_reg_ce_shift;
    --        
    bram_ce_shift: process (shift_clk)
    begin
      if shift_clk'event and shift_clk='1' then  
        if (shift = '1') then
          if(C_NUM_PICOBLAZE > 1) then
            for i in 0 to C_NUM_PICOBLAZE-2 loop
              bram_ce(i+1) <= bram_ce(i);
            end loop;
          end if;
          bram_ce(0) <= control_reg_ce;
        end if;
      end if;
    end process bram_ce_shift;
    --        
    bram_we_shift: process (shift_clk)
    begin
      if shift_clk'event and shift_clk='1' then  
        if (shift = '1') then
          jtag_we_int <= bram_ce(C_NUM_PICOBLAZE-1);
        end if;
      end if;
    end process bram_we_shift;
    --        
    bram_a_shift: process (shift_clk)
    begin
      if shift_clk'event and shift_clk='1' then  
        if (shift = '1') then
          for i in 0 to C_BRAM_MAX_ADDR_WIDTH-2 loop
            jtag_addr_int(i+1) <= jtag_addr_int(i);
          end loop;
          jtag_addr_int(0) <= jtag_we_int;
        end if;
      end if;
    end process bram_a_shift;
    --        
    bram_d_shift: process (shift_clk)
    begin
      if shift_clk'event and shift_clk='1' then  
        if (din_load = '1') then
          jtag_din_int <= bram_dout_int;
         elsif (shift = '1') then
          for i in 0 to C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-2 loop
            jtag_din_int(i+1) <= jtag_din_int(i);
          end loop;
          jtag_din_int(0) <= jtag_addr_int(C_BRAM_MAX_ADDR_WIDTH-1);
        end if;
      end if;
    end process bram_d_shift;
    --
    shift_dout <= jtag_din_int(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1);
    --
    --
    din_load_select:process (bram_ce, din_load, capture, bus_zero, control_reg_ce) 
    begin
      if ( bram_ce = bus_zero ) then
        din_load <= capture and control_reg_ce;
       else
        din_load <= capture;
      end if;
    end process din_load_select;
    --
    --
    -- Control Registers 
    --
    num_picoblaze <= conv_std_logic_vector(C_NUM_PICOBLAZE-1,3);
    picoblaze_instruction_data_width <= conv_std_logic_vector(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1,5);
    --	
    control_registers: process(jtag_clk_int) 
    begin
      if (jtag_clk_int'event and jtag_clk_int = '1') then
        if (bram_ce_valid = '1') and (jtag_we_int = '0') and (control_reg_ce = '1') then
          case (jtag_addr_int(3 downto 0)) is 
            when "0000" => -- 0 = version - returns (7 downto 4) illustrating number of PB
                           --               and (3 downto 0) picoblaze instruction data width
                           control_dout_int <= num_picoblaze & picoblaze_instruction_data_width;
            when "0001" => -- 1 = PicoBlaze 0 reset / status
                           if (C_NUM_PICOBLAZE >= 1) then 
                            control_dout_int <= picoblaze_reset_int(0) & "00" & (conv_std_logic_vector(C_ADDR_WIDTH_0-1,5) );
                           else 
                            control_dout_int <= (others => '0');
                           end if;
            when "0010" => -- 2 = PicoBlaze 1 reset / status
                           if (C_NUM_PICOBLAZE >= 2) then 
                             control_dout_int <= picoblaze_reset_int(1) & "00" & (conv_std_logic_vector(C_ADDR_WIDTH_1-1,5) );
                            else 
                             control_dout_int <= (others => '0');
                           end if;
            when "0011" => -- 3 = PicoBlaze 2 reset / status
                           if (C_NUM_PICOBLAZE >= 3) then 
                            control_dout_int <= picoblaze_reset_int(2) & "00" & (conv_std_logic_vector(C_ADDR_WIDTH_2-1,5) );
                           else 
                            control_dout_int <= (others => '0');
                           end if;
            when "0100" => -- 4 = PicoBlaze 3 reset / status
                           if (C_NUM_PICOBLAZE >= 4) then 
                            control_dout_int <= picoblaze_reset_int(3) & "00" & (conv_std_logic_vector(C_ADDR_WIDTH_3-1,5) );
                           else 
                            control_dout_int <= (others => '0');
                           end if;
            when "0101" => -- 5 = PicoBlaze 4 reset / status
                           if (C_NUM_PICOBLAZE >= 5) then 
                            control_dout_int <= picoblaze_reset_int(4) & "00" & (conv_std_logic_vector(C_ADDR_WIDTH_4-1,5) );
                           else 
                            control_dout_int <= (others => '0');
                           end if;
            when "0110" => -- 6 = PicoBlaze 5 reset / status
                           if (C_NUM_PICOBLAZE >= 6) then 
                            control_dout_int <= picoblaze_reset_int(5) & "00" & (conv_std_logic_vector(C_ADDR_WIDTH_5-1,5) );
                           else 
                            control_dout_int <= (others => '0');
                           end if;
            when "0111" => -- 7 = PicoBlaze 6 reset / status
                           if (C_NUM_PICOBLAZE >= 7) then 
                            control_dout_int <= picoblaze_reset_int(6) & "00" & (conv_std_logic_vector(C_ADDR_WIDTH_6-1,5) );
                           else 
                            control_dout_int <= (others => '0');
                           end if;
            when "1000" => -- 8 = PicoBlaze 7 reset / status
                           if (C_NUM_PICOBLAZE >= 8) then 
                            control_dout_int <= picoblaze_reset_int(7) & "00" & (conv_std_logic_vector(C_ADDR_WIDTH_7-1,5) );
                           else 
                            control_dout_int <= (others => '0');
                           end if;
            when "1111" => control_dout_int <= conv_std_logic_vector(C_BRAM_MAX_ADDR_WIDTH -1,8);
            when others => control_dout_int <= (others => '1');
          end case;
        else 
          control_dout_int <= (others => '0');
        end if;
      end if;
    end process control_registers;
    -- 
    control_dout(C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-1 downto C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-8) <= control_dout_int;
    --
    pb_reset: process(jtag_clk_int) 
    begin
      if (jtag_clk_int'event and jtag_clk_int = '1') then
        if (bram_ce_valid = '1') and (jtag_we_int = '1') and (control_reg_ce = '1') then
          picoblaze_reset_int(C_NUM_PICOBLAZE-1 downto 0) <= control_din(C_NUM_PICOBLAZE-1 downto 0);
        end if;
      end if;
    end process pb_reset;    
    --
    --
    -- Assignments 
    --
    control_dout (C_PICOBLAZE_INSTRUCTION_DATA_WIDTH-9 downto 0) <= (others => '0') when (C_PICOBLAZE_INSTRUCTION_DATA_WIDTH > 8);
    --
    -- Qualify the blockram CS signal with bscan select output
    jtag_en_int <= bram_ce when bram_ce_valid = '1' else (others => '0');
    --      
    jtag_en_expanded(C_NUM_PICOBLAZE-1 downto 0) <= jtag_en_int;
    jtag_en_expanded(7 downto C_NUM_PICOBLAZE) <= (others => '0') when (C_NUM_PICOBLAZE < 8);
    --        
    bram_dout_int <= control_dout or jtag_dout_0_masked or jtag_dout_1_masked or jtag_dout_2_masked or jtag_dout_3_masked or jtag_dout_4_masked or jtag_dout_5_masked or jtag_dout_6_masked or jtag_dout_7_masked;
    --
    control_din <= jtag_din_int;
    --        
    jtag_dout_0_masked <= jtag_dout_0 when jtag_en_expanded(0) = '1' else (others => '0');
    jtag_dout_1_masked <= jtag_dout_1 when jtag_en_expanded(1) = '1' else (others => '0');
    jtag_dout_2_masked <= jtag_dout_2 when jtag_en_expanded(2) = '1' else (others => '0');
    jtag_dout_3_masked <= jtag_dout_3 when jtag_en_expanded(3) = '1' else (others => '0');
    jtag_dout_4_masked <= jtag_dout_4 when jtag_en_expanded(4) = '1' else (others => '0');
    jtag_dout_5_masked <= jtag_dout_5 when jtag_en_expanded(5) = '1' else (others => '0');
    jtag_dout_6_masked <= jtag_dout_6 when jtag_en_expanded(6) = '1' else (others => '0');
    jtag_dout_7_masked <= jtag_dout_7 when jtag_en_expanded(7) = '1' else (others => '0');
    --
    jtag_en <= jtag_en_int;
    jtag_din <= jtag_din_int;
    jtag_addr <= jtag_addr_int;
    jtag_clk <= jtag_clk_int;
    jtag_we <= jtag_we_int;
    picoblaze_reset <= picoblaze_reset_int;
    --        
  end generate jtag_loader_gen;
--
end Behavioral;
--
--
------------------------------------------------------------------------------------
--
-- END OF FILE quackterm.vhd
--
------------------------------------------------------------------------------------
