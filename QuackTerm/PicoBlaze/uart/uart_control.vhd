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
-- Program defined by 'C:\Users\equack\Documents\Xilinx\DVI-1080p\dvid_test_hd\PicoBlaze\uart_control.psm'.
--
-- Generated by KCPSM6 Assembler: 15 Apr 2017 - 12:47:09. 
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
entity uart_control is
  generic(             C_FAMILY : string := "S6"; 
              C_RAM_SIZE_KWORDS : integer := 1;
           C_JTAG_LOADER_ENABLE : integer := 0);
  Port (      address : in std_logic_vector(11 downto 0);
          instruction : out std_logic_vector(17 downto 0);
               enable : in std_logic;
                  rdl : out std_logic;                    
                  clk : in std_logic);
  end uart_control;
--
architecture low_level_definition of uart_control is
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
                    INIT_00 => X"D0101001D00BF030F018F031F033F0321000FC351C0017001D78078820290002",
                    INIT_01 => X"1010152006DB130012430270157806DB130002D006461981180605A9F6341670",
                    INIT_02 => X"900C11A7202902702029002E0041500005CF16706020D0009001160102700270",
                    INIT_03 => X"DB03DA021A001B015000BA009B01500010011000950D202F100091012035D001",
                    INIT_04 => X"37FB6051D459206537FD6065D780604DD4122067D70194065000D40194075000",
                    INIT_05 => X"37DF6061D414206537EF6065D411205DD780206537BF6057D4142057D7802065",
                    INIT_06 => X"D47E50005701606FD4F050005780606BD4E05000377E206537F76065D4112065",
                    INIT_07 => X"5000F0187001B0182080D706608BD47750002633662EDC207C202078D7066078",
                    INIT_08 => X"661ADC807C806092D458500026296624DC407C405000F0187002B0182086D760",
                    INIT_09 => X"60A3D41420A3D78050005704609CD459500057025000D7806098D4125000261F",
                    INIT_0A => X"60B2D4115000377F571060AED41120AED7805000572060A7D4145000377F5740",
                    INIT_0B => X"1533064260C3D4712256152F60BCD44A2256150D60B8D45A2125D78050005708",
                    INIT_0C => X"D474226B154200E9064260CFD472226B154100E9064260C9D475264000DF026B",
                    INIT_0D => X"00F5226B154500E90642226B154400E906426100D46B226B154300E9064260D5",
                    INIT_0E => X"1531F03C10301000D001100100F5226BB53C026B153BF03C10301000D0011001",
                    INIT_0F => X"5000100420FFD760100220FCD718100120F9D7061000226BB53C026B153B026B",
                    INIT_10 => X"6115D469264000DF026B15320642610ED470264000DF026B153106426107D46C",
                    INIT_11 => X"153606426123D47A264000DF026B15350642611CD47D264000DF026B15340642",
                    INIT_12 => X"2151D46C2141D4712143D4702157D502B518216DDC405000377F264000DF026B",
                    INIT_13 => X"214DD473214FD474214BD46B2147D4722153D4752149D47A2155D47D2145D469",
                    INIT_14 => X"156C2256152E225615682256156E2256156A22561562225615302256152E216D",
                    INIT_15 => X"D47D20BED4712109D4702110D4692102D46C225615752256156B225615792256",
                    INIT_16 => X"151B6175D40520DBD47320D1D47420D7D46B20CBD47220C5D475211ED47A211E",
                    INIT_17 => X"151B6185D404226B155100DF026B154F151B617DD406226B155000DF026B154F",
                    INIT_18 => X"06426196D403226B155300DF026B154F151B618DD40C226B155200DF026B154F",
                    INIT_19 => X"D483264000DF026B1537026B15310642619FD40B264000DF026B1535026B1531",
                    INIT_1A => X"00DF026B1539026B1531064261B1D40A264000DF026B1538026B1531064261A8",
                    INIT_1B => X"1531026B1532064261C3D409264000DF026B1530026B1532064261BAD4012640",
                    INIT_1C => X"1532064261D5D407264000DF026B1533026B1532064261CCD478264000DF026B",
                    INIT_1D => X"61E3D5092240D706489038000940190A1807D000D47E264000DF026B1534026B",
                    INIT_1E => X"D5342268152361EFD5332268154061EBD5322268152161E7D531226B155A0642",
                    INIT_1F => X"6202D5372268151E2268D760155E61FED5362268152561F7D5352268152461F3",
                    INIT_20 => X"6212D56022681529620ED53022681528620AD5392268152A6206D53822681526",
                    INIT_21 => X"153A6221D53B2268152B621DD53D2268151F2268D760155F6219D52D2268157E",
                    INIT_22 => X"157C6231D55C2268157D622DD55D2268157B6229D55B226815226225D5272268",
                    INIT_23 => X"2268157F2268D760153F6256D52F2268153E6239D52E2268153C6235D52C2268",
                    INIT_24 => X"6252D5322268151D624ED55D2268151C624AD55C2268151B6246D55B2256D760",
                    INIT_25 => X"DC8022689560225FD7602268A268D560E268D57B2268157F6256D508226E1500",
                    INIT_26 => X"5000078B0270226EDC205580226BD71895202268D706226895206268D7062265",
                    INIT_27 => X"D001B018F03D62AEDC0262D5DC011000D5006296DC10F5316275DC032275D51B",
                    INIT_28 => X"25A9D50C2592D50A25D1D50D2563D509255FD57F255ED50822ACD51BB03D6296",
                    INIT_29 => X"15C462A0D57122A0D004B0181520229ADC08F03D2638D5012603D507255BD505",
                    INIT_2A => X"62B3D55B50005C0225DC05BA003E00395000FA1FDB68003CD609D5043CEFB03D",
                    INIT_2B => X"BC35B634BA33BB3262C2D53822C8FC35F634FA33FB3262BAD537500002CA5C01",
                    INIT_2C => X"110010085000F011F007100050003CFD5C1062C8D54E200262C5D56322C8003E",
                    INIT_2D => X"F1111101E5000010B111101222E1A2E1D52FE2E1D53A500062D0D0101001E100",
                    INIT_2E => X"0ED00FA00EB02300FA1EDBF005BAFA01FB006302D54D500062E5D53B05335000",
                    INIT_2F => X"62F1FF1FDE683F001E013A001B01D509D404003E950A94050000DF02DE033F00",
                    INIT_30 => X"8BD00AF00BE0BF009E011F1F1E6803A002B005BAFA01FB006323D54C253005E6",
                    INIT_31 => X"0B206311EF30CE20BF009E010039D509D4040000DF02DE03950A9405003EBA00",
                    INIT_32 => X"9001003CD609D50415201001632BD000B008FA01FB006336D558253005F50A30",
                    INIT_33 => X"00D00693FA01FB001101633CD100B1086359D5402530003EBA01BB00632BD000",
                    INIT_34 => X"D0009001003EBA009B02D509D404003C950A94051001003E3A000B00900180E0",
                    INIT_35 => X"FB001101635FD100B108637BD5502530633CD1009101D609D4041420003C6346",
                    INIT_36 => X"6364D00090011A001B01D509D404003E0039950A9405003C80E000D00693FA01",
                    INIT_37 => X"6382D002B0086388D54A2530635FD1009101003EBA01BB00D609D4041420003E",
                    INIT_38 => X"6399D400A41000101108B0076416D56D253005AB253005996386D001253005A9",
                    INIT_39 => X"454EDC045680454EDC0463A1D4012412B039F01830FBB018F0393CF73CFB1670",
                    INIT_3A => X"24125C04054E6412DC0463B0D4072412454EDC045608454EDC0463A9D4052412",
                    INIT_3B => X"B018F03963C4D40B2412B039F01830FBB018F03963BCD40A24125C0863B4D408",
                    INIT_3C => X"2412454EDC04367F454EDC0463D0D41624123CF763C8D41C2412B039F0185004",
                    INIT_3D => X"D42724123CFB054E2412DC0463DFD41B2412454EDC0436F7454EDC0463D8D419",
                    INIT_3E => X"2412454EDC0436F0454EDC0463F0D4312412454EDC045670360F454EDC0463E8",
                    INIT_3F => X"DC0406404406440644064406368F941EF43D454EDC04E403C540151DE403D426",
                   INITP_00 => X"A0CDAC336363623636372372363370C2A59642DC0AEA8D5A082208288AAA202A",
                   INITP_01 => X"9C71C222275A2275A2A2B62B62B62B6A2D8D8DC8D8372360DC8D8CDAC36B0A0C",
                   INITP_02 => X"36283628377777777777622222222222DDDDDDDDDDDC322A2DA8B6A2DA8B6A2D",
                   INITP_03 => X"D8C3636363636362DC9436A22DA88B6A22DA88B6A22DA88B6A22DA88B6283628",
                   INITP_04 => X"0B3372CDAB0C7273273DD8D8D8D8D8DC8C36363636363636363630D8D8D8D8D8",
                   INITP_05 => X"D556A029435AB6DA990F76D60A8836DA00DAAB68D8AAD6A037032DDDDDDDDDD3",
                   INITP_06 => X"D36D60A2D56A824A9D36D68B596A06552A74DA0D6A1D2B68355A8A0941402ADA",
                   INITP_07 => X"1551B34DB0CDB03362CDB0CDB0CD8D882D882D8D8B36C336C3362080D10DAADA")
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
                    INIT_00 => X"D0101001D00BF030F018F031F033F0321000FC351C0017001D78078820290002",
                    INIT_01 => X"1010152006DB130012430270157806DB130002D006461981180605A9F6341670",
                    INIT_02 => X"900C11A7202902702029002E0041500005CF16706020D0009001160102700270",
                    INIT_03 => X"DB03DA021A001B015000BA009B01500010011000950D202F100091012035D001",
                    INIT_04 => X"37FB6051D459206537FD6065D780604DD4122067D70194065000D40194075000",
                    INIT_05 => X"37DF6061D414206537EF6065D411205DD780206537BF6057D4142057D7802065",
                    INIT_06 => X"D47E50005701606FD4F050005780606BD4E05000377E206537F76065D4112065",
                    INIT_07 => X"5000F0187001B0182080D706608BD47750002633662EDC207C202078D7066078",
                    INIT_08 => X"661ADC807C806092D458500026296624DC407C405000F0187002B0182086D760",
                    INIT_09 => X"60A3D41420A3D78050005704609CD459500057025000D7806098D4125000261F",
                    INIT_0A => X"60B2D4115000377F571060AED41120AED7805000572060A7D4145000377F5740",
                    INIT_0B => X"1533064260C3D4712256152F60BCD44A2256150D60B8D45A2125D78050005708",
                    INIT_0C => X"D474226B154200E9064260CFD472226B154100E9064260C9D475264000DF026B",
                    INIT_0D => X"00F5226B154500E90642226B154400E906426100D46B226B154300E9064260D5",
                    INIT_0E => X"1531F03C10301000D001100100F5226BB53C026B153BF03C10301000D0011001",
                    INIT_0F => X"5000100420FFD760100220FCD718100120F9D7061000226BB53C026B153B026B",
                    INIT_10 => X"6115D469264000DF026B15320642610ED470264000DF026B153106426107D46C",
                    INIT_11 => X"153606426123D47A264000DF026B15350642611CD47D264000DF026B15340642",
                    INIT_12 => X"2151D46C2141D4712143D4702157D502B518216DDC405000377F264000DF026B",
                    INIT_13 => X"214DD473214FD474214BD46B2147D4722153D4752149D47A2155D47D2145D469",
                    INIT_14 => X"156C2256152E225615682256156E2256156A22561562225615302256152E216D",
                    INIT_15 => X"D47D20BED4712109D4702110D4692102D46C225615752256156B225615792256",
                    INIT_16 => X"151B6175D40520DBD47320D1D47420D7D46B20CBD47220C5D475211ED47A211E",
                    INIT_17 => X"151B6185D404226B155100DF026B154F151B617DD406226B155000DF026B154F",
                    INIT_18 => X"06426196D403226B155300DF026B154F151B618DD40C226B155200DF026B154F",
                    INIT_19 => X"D483264000DF026B1537026B15310642619FD40B264000DF026B1535026B1531",
                    INIT_1A => X"00DF026B1539026B1531064261B1D40A264000DF026B1538026B1531064261A8",
                    INIT_1B => X"1531026B1532064261C3D409264000DF026B1530026B1532064261BAD4012640",
                    INIT_1C => X"1532064261D5D407264000DF026B1533026B1532064261CCD478264000DF026B",
                    INIT_1D => X"61E3D5092240D706489038000940190A1807D000D47E264000DF026B1534026B",
                    INIT_1E => X"D5342268152361EFD5332268154061EBD5322268152161E7D531226B155A0642",
                    INIT_1F => X"6202D5372268151E2268D760155E61FED5362268152561F7D5352268152461F3",
                    INIT_20 => X"6212D56022681529620ED53022681528620AD5392268152A6206D53822681526",
                    INIT_21 => X"153A6221D53B2268152B621DD53D2268151F2268D760155F6219D52D2268157E",
                    INIT_22 => X"157C6231D55C2268157D622DD55D2268157B6229D55B226815226225D5272268",
                    INIT_23 => X"2268157F2268D760153F6256D52F2268153E6239D52E2268153C6235D52C2268",
                    INIT_24 => X"6252D5322268151D624ED55D2268151C624AD55C2268151B6246D55B2256D760",
                    INIT_25 => X"DC8022689560225FD7602268A268D560E268D57B2268157F6256D508226E1500",
                    INIT_26 => X"5000078B0270226EDC205580226BD71895202268D706226895206268D7062265",
                    INIT_27 => X"D001B018F03D62AEDC0262D5DC011000D5006296DC10F5316275DC032275D51B",
                    INIT_28 => X"25A9D50C2592D50A25D1D50D2563D509255FD57F255ED50822ACD51BB03D6296",
                    INIT_29 => X"15C462A0D57122A0D004B0181520229ADC08F03D2638D5012603D507255BD505",
                    INIT_2A => X"62B3D55B50005C0225DC05BA003E00395000FA1FDB68003CD609D5043CEFB03D",
                    INIT_2B => X"BC35B634BA33BB3262C2D53822C8FC35F634FA33FB3262BAD537500002CA5C01",
                    INIT_2C => X"110010085000F011F007100050003CFD5C1062C8D54E200262C5D56322C8003E",
                    INIT_2D => X"F1111101E5000010B111101222E1A2E1D52FE2E1D53A500062D0D0101001E100",
                    INIT_2E => X"0ED00FA00EB02300FA1EDBF005BAFA01FB006302D54D500062E5D53B05335000",
                    INIT_2F => X"62F1FF1FDE683F001E013A001B01D509D404003E950A94050000DF02DE033F00",
                    INIT_30 => X"8BD00AF00BE0BF009E011F1F1E6803A002B005BAFA01FB006323D54C253005E6",
                    INIT_31 => X"0B206311EF30CE20BF009E010039D509D4040000DF02DE03950A9405003EBA00",
                    INIT_32 => X"9001003CD609D50415201001632BD000B008FA01FB006336D558253005F50A30",
                    INIT_33 => X"00D00693FA01FB001101633CD100B1086359D5402530003EBA01BB00632BD000",
                    INIT_34 => X"D0009001003EBA009B02D509D404003C950A94051001003E3A000B00900180E0",
                    INIT_35 => X"FB001101635FD100B108637BD5502530633CD1009101D609D4041420003C6346",
                    INIT_36 => X"6364D00090011A001B01D509D404003E0039950A9405003C80E000D00693FA01",
                    INIT_37 => X"6382D002B0086388D54A2530635FD1009101003EBA01BB00D609D4041420003E",
                    INIT_38 => X"6399D400A41000101108B0076416D56D253005AB253005996386D001253005A9",
                    INIT_39 => X"454EDC045680454EDC0463A1D4012412B039F01830FBB018F0393CF73CFB1670",
                    INIT_3A => X"24125C04054E6412DC0463B0D4072412454EDC045608454EDC0463A9D4052412",
                    INIT_3B => X"B018F03963C4D40B2412B039F01830FBB018F03963BCD40A24125C0863B4D408",
                    INIT_3C => X"2412454EDC04367F454EDC0463D0D41624123CF763C8D41C2412B039F0185004",
                    INIT_3D => X"D42724123CFB054E2412DC0463DFD41B2412454EDC0436F7454EDC0463D8D419",
                    INIT_3E => X"2412454EDC0436F0454EDC0463F0D4312412454EDC045670360F454EDC0463E8",
                    INIT_3F => X"DC0406404406440644064406368F941EF43D454EDC04E403C540151DE403D426",
                   INITP_00 => X"A0CDAC336363623636372372363370C2A59642DC0AEA8D5A082208288AAA202A",
                   INITP_01 => X"9C71C222275A2275A2A2B62B62B62B6A2D8D8DC8D8372360DC8D8CDAC36B0A0C",
                   INITP_02 => X"36283628377777777777622222222222DDDDDDDDDDDC322A2DA8B6A2DA8B6A2D",
                   INITP_03 => X"D8C3636363636362DC9436A22DA88B6A22DA88B6A22DA88B6A22DA88B6283628",
                   INITP_04 => X"0B3372CDAB0C7273273DD8D8D8D8D8DC8C36363636363636363630D8D8D8D8D8",
                   INITP_05 => X"D556A029435AB6DA990F76D60A8836DA00DAAB68D8AAD6A037032DDDDDDDDDD3",
                   INITP_06 => X"D36D60A2D56A824A9D36D68B596A06552A74DA0D6A1D2B68355A8A0941402ADA",
                   INITP_07 => X"1551B34DB0CDB03362CDB0CDB0CD8D882D882D8D8B36C336C3362080D10DAADA")
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
                    INIT_00 => X"D0101001D00BF030F018F031F033F0321000FC351C0017001D78078820290002",
                    INIT_01 => X"1010152006DB130012430270157806DB130002D006461981180605A9F6341670",
                    INIT_02 => X"900C11A7202902702029002E0041500005CF16706020D0009001160102700270",
                    INIT_03 => X"DB03DA021A001B015000BA009B01500010011000950D202F100091012035D001",
                    INIT_04 => X"37FB6051D459206537FD6065D780604DD4122067D70194065000D40194075000",
                    INIT_05 => X"37DF6061D414206537EF6065D411205DD780206537BF6057D4142057D7802065",
                    INIT_06 => X"D47E50005701606FD4F050005780606BD4E05000377E206537F76065D4112065",
                    INIT_07 => X"5000F0187001B0182080D706608BD47750002633662EDC207C202078D7066078",
                    INIT_08 => X"661ADC807C806092D458500026296624DC407C405000F0187002B0182086D760",
                    INIT_09 => X"60A3D41420A3D78050005704609CD459500057025000D7806098D4125000261F",
                    INIT_0A => X"60B2D4115000377F571060AED41120AED7805000572060A7D4145000377F5740",
                    INIT_0B => X"1533064260C3D4712256152F60BCD44A2256150D60B8D45A2125D78050005708",
                    INIT_0C => X"D474226B154200E9064260CFD472226B154100E9064260C9D475264000DF026B",
                    INIT_0D => X"00F5226B154500E90642226B154400E906426100D46B226B154300E9064260D5",
                    INIT_0E => X"1531F03C10301000D001100100F5226BB53C026B153BF03C10301000D0011001",
                    INIT_0F => X"5000100420FFD760100220FCD718100120F9D7061000226BB53C026B153B026B",
                    INIT_10 => X"6115D469264000DF026B15320642610ED470264000DF026B153106426107D46C",
                    INIT_11 => X"153606426123D47A264000DF026B15350642611CD47D264000DF026B15340642",
                    INIT_12 => X"2151D46C2141D4712143D4702157D502B518216DDC405000377F264000DF026B",
                    INIT_13 => X"214DD473214FD474214BD46B2147D4722153D4752149D47A2155D47D2145D469",
                    INIT_14 => X"156C2256152E225615682256156E2256156A22561562225615302256152E216D",
                    INIT_15 => X"D47D20BED4712109D4702110D4692102D46C225615752256156B225615792256",
                    INIT_16 => X"151B6175D40520DBD47320D1D47420D7D46B20CBD47220C5D475211ED47A211E",
                    INIT_17 => X"151B6185D404226B155100DF026B154F151B617DD406226B155000DF026B154F",
                    INIT_18 => X"06426196D403226B155300DF026B154F151B618DD40C226B155200DF026B154F",
                    INIT_19 => X"D483264000DF026B1537026B15310642619FD40B264000DF026B1535026B1531",
                    INIT_1A => X"00DF026B1539026B1531064261B1D40A264000DF026B1538026B1531064261A8",
                    INIT_1B => X"1531026B1532064261C3D409264000DF026B1530026B1532064261BAD4012640",
                    INIT_1C => X"1532064261D5D407264000DF026B1533026B1532064261CCD478264000DF026B",
                    INIT_1D => X"61E3D5092240D706489038000940190A1807D000D47E264000DF026B1534026B",
                    INIT_1E => X"D5342268152361EFD5332268154061EBD5322268152161E7D531226B155A0642",
                    INIT_1F => X"6202D5372268151E2268D760155E61FED5362268152561F7D5352268152461F3",
                    INIT_20 => X"6212D56022681529620ED53022681528620AD5392268152A6206D53822681526",
                    INIT_21 => X"153A6221D53B2268152B621DD53D2268151F2268D760155F6219D52D2268157E",
                    INIT_22 => X"157C6231D55C2268157D622DD55D2268157B6229D55B226815226225D5272268",
                    INIT_23 => X"2268157F2268D760153F6256D52F2268153E6239D52E2268153C6235D52C2268",
                    INIT_24 => X"6252D5322268151D624ED55D2268151C624AD55C2268151B6246D55B2256D760",
                    INIT_25 => X"DC8022689560225FD7602268A268D560E268D57B2268157F6256D508226E1500",
                    INIT_26 => X"5000078B0270226EDC205580226BD71895202268D706226895206268D7062265",
                    INIT_27 => X"D001B018F03D62AEDC0262D5DC011000D5006296DC10F5316275DC032275D51B",
                    INIT_28 => X"25A9D50C2592D50A25D1D50D2563D509255FD57F255ED50822ACD51BB03D6296",
                    INIT_29 => X"15C462A0D57122A0D004B0181520229ADC08F03D2638D5012603D507255BD505",
                    INIT_2A => X"62B3D55B50005C0225DC05BA003E00395000FA1FDB68003CD609D5043CEFB03D",
                    INIT_2B => X"BC35B634BA33BB3262C2D53822C8FC35F634FA33FB3262BAD537500002CA5C01",
                    INIT_2C => X"110010085000F011F007100050003CFD5C1062C8D54E200262C5D56322C8003E",
                    INIT_2D => X"F1111101E5000010B111101222E1A2E1D52FE2E1D53A500062D0D0101001E100",
                    INIT_2E => X"0ED00FA00EB02300FA1EDBF005BAFA01FB006302D54D500062E5D53B05335000",
                    INIT_2F => X"62F1FF1FDE683F001E013A001B01D509D404003E950A94050000DF02DE033F00",
                    INIT_30 => X"8BD00AF00BE0BF009E011F1F1E6803A002B005BAFA01FB006323D54C253005E6",
                    INIT_31 => X"0B206311EF30CE20BF009E010039D509D4040000DF02DE03950A9405003EBA00",
                    INIT_32 => X"9001003CD609D50415201001632BD000B008FA01FB006336D558253005F50A30",
                    INIT_33 => X"00D00693FA01FB001101633CD100B1086359D5402530003EBA01BB00632BD000",
                    INIT_34 => X"D0009001003EBA009B02D509D404003C950A94051001003E3A000B00900180E0",
                    INIT_35 => X"FB001101635FD100B108637BD5502530633CD1009101D609D4041420003C6346",
                    INIT_36 => X"6364D00090011A001B01D509D404003E0039950A9405003C80E000D00693FA01",
                    INIT_37 => X"6382D002B0086388D54A2530635FD1009101003EBA01BB00D609D4041420003E",
                    INIT_38 => X"6399D400A41000101108B0076416D56D253005AB253005996386D001253005A9",
                    INIT_39 => X"454EDC045680454EDC0463A1D4012412B039F01830FBB018F0393CF73CFB1670",
                    INIT_3A => X"24125C04054E6412DC0463B0D4072412454EDC045608454EDC0463A9D4052412",
                    INIT_3B => X"B018F03963C4D40B2412B039F01830FBB018F03963BCD40A24125C0863B4D408",
                    INIT_3C => X"2412454EDC04367F454EDC0463D0D41624123CF763C8D41C2412B039F0185004",
                    INIT_3D => X"D42724123CFB054E2412DC0463DFD41B2412454EDC0436F7454EDC0463D8D419",
                    INIT_3E => X"2412454EDC0436F0454EDC0463F0D4312412454EDC045670360F454EDC0463E8",
                    INIT_3F => X"DC0406404406440644064406368F941EF43D454EDC04E403C540151DE403D426",
                   INITP_00 => X"A0CDAC336363623636372372363370C2A59642DC0AEA8D5A082208288AAA202A",
                   INITP_01 => X"9C71C222275A2275A2A2B62B62B62B6A2D8D8DC8D8372360DC8D8CDAC36B0A0C",
                   INITP_02 => X"36283628377777777777622222222222DDDDDDDDDDDC322A2DA8B6A2DA8B6A2D",
                   INITP_03 => X"D8C3636363636362DC9436A22DA88B6A22DA88B6A22DA88B6A22DA88B6283628",
                   INITP_04 => X"0B3372CDAB0C7273273DD8D8D8D8D8DC8C36363636363636363630D8D8D8D8D8",
                   INITP_05 => X"D556A029435AB6DA990F76D60A8836DA00DAAB68D8AAD6A037032DDDDDDDDDD3",
                   INITP_06 => X"D36D60A2D56A824A9D36D68B596A06552A74DA0D6A1D2B68355A8A0941402ADA",
                   INITP_07 => X"1551B34DB0CDB03362CDB0CDB0CD8D882D882D8D8B36C336C3362080D10DAADA")
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
                    INIT_00 => X"1020DB00437078DB00D0468106A9347010010B30183133320035000078882902",
                    INIT_01 => X"030200010000010001000D2F000135010CA72970292E4100CF70200001017070",
                    INIT_02 => X"DF611465EF65115D8065BF5714578065FB515965FD65804D1267010600010700",
                    INIT_03 => X"0018011880068B7700332E20207806787E00016FF000806BE0007E65F7651165",
                    INIT_04 => X"A314A38000049C59000200809812001F1A808092580029244040001802188660",
                    INIT_05 => X"3342C371562FBC4A560DB85A25800008B211007F10AE11AE800020A714007F40",
                    INIT_06 => X"F56B45E9426B44E942006B6B43E942D5746B42E942CF726B41E942C97540DF6B",
                    INIT_07 => X"0004FF6002FC1801F906006B3C6B3B6B313C30000101F56B3C6B3B3C30000101",
                    INIT_08 => X"3642237A40DF6B35421C7D40DF6B3442156940DF6B32420E7040DF6B3142076C",
                    INIT_09 => X"4D734F744B6B47725375497A557D4569516C417143705702186D40007F40DF6B",
                    INIT_0A => X"7DBE7109701069026C5675566B5679566C562E5668566E566A56625630562E6D",
                    INIT_0B => X"1B85046B51DF6B4F1B7D066B50DF6B4F1B7505DB73D174D76BCB72C5751E7A1E",
                    INIT_0C => X"8340DF6B376B31429F0B40DF6B356B314296036B53DF6B4F1B8D0C6B52DF6B4F",
                    INIT_0D => X"316B3242C30940DF6B306B3242BA0140DF6B396B3142B10A40DF6B386B3142A8",
                    INIT_0E => X"E30940069000400A07007E40DF6B346B3242D50740DF6B336B3242CC7840DF6B",
                    INIT_0F => X"0237681E68605EFE366825F7356824F3346823EF336840EB326821E7316B5A42",
                    INIT_10 => X"3A213B682B1D3D681F68605F192D687E126068290E3068280A39682A06386826",
                    INIT_11 => X"687F68603F562F683E392E683C352C687C315C687D2D5D687B295B6822252768",
                    INIT_12 => X"8068605F60686860687B687F56086E005232681D4E5D681C4A5C681B465B5660",
                    INIT_13 => X"01183DAE02D50100009610317503751B008B706E20806B182068066820680665",
                    INIT_14 => X"C4A071A00418209A083D380103075B05A90C920AD10D63095F7F5E08AC1B3D96",
                    INIT_15 => X"35343332C238C835343332BA3700CA01B35B0002DCBA3E39001F683C0904EF3D",
                    INIT_16 => X"110100101112E1E12FE13A00D010010000080011070000FD10C84E02C563C83E",
                    INIT_17 => X"F11F680001000109043E0A0500020300D0A0B0001EF0BA0100024D00E53B3300",
                    INIT_18 => X"2011302000013909040002030A053E00D0F0E000011F68A0B0BA0100234C30E6",
                    INIT_19 => X"D0930100013C00085940303E01002B00013C090420012B00080100365830F530",
                    INIT_1A => X"00015F00087B50303C00010904203C4600013E000209043C0A05013E000001E0",
                    INIT_1B => X"820208884A305F00013E01000904203E640001000109043E390A053CE0D09301",
                    INIT_1C => X"4E04804E04A101123918FB1839F7FB70990010100807166D30AB3099860130A9",
                    INIT_1D => X"1839C40B123918FB1839BC0A1208B40812044E1204B007124E04084E04A90512",
                    INIT_1E => X"2712FB4E1204DF1B124E04F74E04D819124E047F4E04D01612F7C81C12391804",
                    INIT_1F => X"0440060606068F1E3D4E0403401D0326124E04F04E04F031124E04700F4E04E8",
                    INIT_20 => X"0809001F02073A661A48308D0001123D4E0440F8283D4E041240271230123D4E",
                    INIT_21 => X"014000085064303E001001D036D001320000014030BDD0100143284301240000",
                    INIT_22 => X"30BDD020983D01D05AD0015600086647303E00E04030BDD0003D983D01434443",
                    INIT_23 => X"920008930100A44B00376F000136963631016F000837FEFD7862303E00003D40",
                    INIT_24 => X"9A00013C0904D09A000040E001D0A08A00013E390904009A00D03E00E0018901",
                    INIT_25 => X"7E0801BF0008C64330B4018B01B40008B84230AA018401AA0008AE41303E0100",
                    INIT_26 => X"DA00013D6A3D01DA0008E15A30CD00080108770801CD0008D44430BF00080108",
                    INIT_27 => X"C800013F988B5B8B1B3E3D01000D06080E6E30E700013D633D01E70008EE4930",
                    INIT_28 => X"012203303C011D0230BA1801082E7E301172303E3D01008B52C80001003F8B3B",
                    INIT_29 => X"E001440001403000124400110000FEFD745030C52E0630C12A0530C92604305F",
                    INIT_2A => X"7777008B06003E40060606060E0E0E0E603E000701110000100708E03840BD0A",
                    INIT_2B => X"0198003E00010000983E00083E0000740007E00000983E0010000807B0777020",
                    INIT_2C => X"00390904200100003E00D0DC1EF0003E00D0001EF0003E00D00000D0003C00D0",
                    INIT_2D => X"3E00E0000098003E0100AE1F68000109043E2001000000003E010009049C3E00",
                    INIT_2E => X"1F1E01001EF0003EDA1F6800D000BAD3D1003E00D039BA003E1EF0003E000000",
                    INIT_2F => X"00F70001000109043ED000003E0100E91F68000109043E001EF00E0F1F1E00D0",
                    INIT_30 => X"30000B30083000101F680001094E0A3E0000003E3D01000EB00E3D0100003E01",
                    INIT_31 => X"3900000101960100000B30DF30000B302030000B30EF30000B301030000B30F7",
                    INIT_32 => X"63967B008B6F0F408B6F0E0E0E0E4046000101007001000000906B5B6B1B6B7E",
                    INIT_33 => X"00963E9640005D0800963C00003A07720A00966F0F40966F0E0E0E0E4000967D",
                    INIT_34 => X"0030209D00D0A0B09A0001A0B000202020302E3156206D7265546B6361755100",
                    INIT_35 => X"00000100B8000001B8A86100B8688909A20001080E00069080AA07A790800900",
                    INIT_36 => X"06EEEB0000008B30CE0100028B30D40050E00006EED8000000C006080880C320",
                    INIT_37 => X"070190800D00A000003020EF01000640F502007030E10100027030E70050E000",
                    INIT_38 => X"71000000000000600900000000000000000000000000FC0001080E0006908004",
                    INIT_39 => X"796768626E000035727466762000003334656478630000327761737A00000031",
                    INIT_3A => X"3D5B00270000002D703B6C2F2E000039306F696B2C00003837756A6D00000036",
                    INIT_3B => X"383635322E300000003734003100000800000000000000005C005D0D00000000",
                    INIT_3C => X"0000000000000000000000000000000000018B0400000131392A2D332B00001B",
                    INIT_3D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3F => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_00 => X"124A80A022482080844D18A3145000010402222888A28A20922440805294001C",
                   INITP_01 => X"57BBBBBAD302A150A8542A150A8549C9C9C9C005152AAAABAAAAABC8A142850A",
                   INITP_02 => X"532556E6E8A1802414284C24A217FFF4009145AA295555555AAAAAAAAAB55555",
                   INITP_03 => X"004C4A45124A4A2020222494940089FB9F908C40FFE10C841FE61A3EE928B55F",
                   INITP_04 => X"47CCEFDB7ED8206081BB6ED90000000805408465200199000676D2DB017C8261",
                   INITP_05 => X"C523556A94AB8A22206A0A2482344890041300E5D800184938703BBBDEE7F3AB",
                   INITP_06 => X"6340082F130DE20D42220D094657FFFEA8368CF92BBE64953B00000000544208",
                   INITP_07 => X"000000000000000000000000000060FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC35")
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
                    INIT_00 => X"080A030909010A030901030C0C027B0B6808687878787878087E0E0B0E031000",
                    INIT_01 => X"6D6D8D8D28DDCD2888084A1088C890684808100190000028020BB0E8C88B0101",
                    INIT_02 => X"1BB0EA101BB0EA906B101BB0EA906B101BB0EA101BB06BB0EA906B4AA86A4A28",
                    INIT_03 => X"28783858906BB0EA2813B36E3E906BB0EA282BB0EA282BB0EA281B101BB0EA10",
                    INIT_04 => X"B0EA906B282BB0EA282BA86BB0EA2813B36E3EB0EA2813B36E3E28783858906B",
                    INIT_05 => X"0A03B0EA110AB0EA110AB0EA906B282BB0EA281B2BB0EA906B282BB0EA281B2B",
                    INIT_06 => X"00110A0003110A0003B0EA110A0003B0EA110A0003B0EA110A0003B0EA130001",
                    INIT_07 => X"2888906B88906B88906B08115A010A010A788888E88800115A010A788888E888",
                    INIT_08 => X"0A03B0EA1300010A03B0EA1300010A03B0EA1300010A03B0EA1300010A03B0EA",
                    INIT_09 => X"90EA90EA90EA90EA90EA90EA90EA90EA90EA90EA90EA906A5A906E281B130001",
                    INIT_0A => X"EA90EA90EA90EA90EA110A110A110A110A110A110A110A110A110A110A110A10",
                    INIT_0B => X"0AB0EA110A00010A0AB0EA110A00010A0AB0EA90EA90EA90EA90EA90EA90EA90",
                    INIT_0C => X"EA1300010A010A03B0EA1300010A010A03B0EA110A00010A0AB0EA110A00010A",
                    INIT_0D => X"0A010A03B0EA1300010A010A03B0EA1300010A010A03B0EA1300010A010A03B0",
                    INIT_0E => X"B0EA916B249C840C0CE8EA1300010A010A03B0EA1300010A010A03B0EA130001",
                    INIT_0F => X"B1EA110A916B0AB0EA110AB0EA110AB0EA110AB0EA110AB0EA110AB0EA110A03",
                    INIT_10 => X"0AB1EA110AB1EA110A916B0AB1EA110AB1EA110AB1EA110AB1EA110AB1EA110A",
                    INIT_11 => X"110A916B0AB1EA110AB1EA110AB1EA110AB1EA110AB1EA110AB1EA110AB1EA11",
                    INIT_12 => X"6E11CA916B91D1EAF1EA110AB1EA110AB1EA110AB1EA110AB1EA110AB1EA916B",
                    INIT_13 => X"685878B16EB16E88EAB16E7AB16E91EA280301916E2A916BCA916B11CAB16B91",
                    INIT_14 => X"0AB1EA9168580A916E7893EA93EA92EA92EA92EA92EA92EA92EA92EA91EA58B1",
                    INIT_15 => X"5E5B5D5DB1EA117E7B7D7DB1EA28012EB1EA282E12020000A8FDED006B6A1E58",
                    INIT_16 => X"78887280580891D1EAF1EA28B1E88870080828787808281E2EB1EA10B1EA1100",
                    INIT_17 => X"B1FFEF9F8F9D8D6A6A004A4A006F6F9F87070791FDED027D7DB1EA28B1EA0228",
                    INIT_18 => X"05B1F7E7DFCF006A6A006F6F4A4A00DDC50505DFCF0F0F0101027D7DB1EA1202",
                    INIT_19 => X"00037D7D88B1E858B1EA12005D5DB1E8C8006B6A0A88B1E8587D7DB1EA120205",
                    INIT_1A => X"7D88B1E858B1EA12B1E8C86B6A0A00B1E8C800DDCD6A6A004A4A88009D85C8C0",
                    INIT_1B => X"B1E858B1EA12B1E8C8005D5D6B6A0A00B1E8C88D8D6A6A00004A4A00C000037D",
                    INIT_1C => X"A26E2BA26EB1EA1258781858781E1E0BB1EA52800858B2EA12021202B1E81202",
                    INIT_1D => X"5878B1EA125878185878B1EA122EB1EA122E02B26EB1EA12A26E2BA26EB1EA12",
                    INIT_1E => X"EA121E02926EB1EA12A26E1BA26EB1EA12A26E1BA26EB1EA121EB1EA12587828",
                    INIT_1F => X"6E83A2A2A2A21BCA7AA26EF2E20AF2EA12A26E1BA26EB1EA12A26E2B1BA26EB1",
                    INIT_20 => X"08780892E858B2EA92EA12B1E088125AA26E831BCA7AA26EF2E20AF2EA125AA2",
                    INIT_21 => X"C892E858B2EA12009D85C800D2E0C892E850880505030404C808D2E8C892E850",
                    INIT_22 => X"050304040378C800D2E0C892E858B2EA12009D850505030404580378C808D2E8",
                    INIT_23 => X"92EA5A037D7DB2EA285AB2E8C85801785A88B2E8587A1E1EB2EA12009D855805",
                    INIT_24 => X"B2EFCF006B6A07B2EF0A07C28A0212B2EFCF00006B6A0A120A0700DDC5CF92EA",
                    INIT_25 => X"027888B2E858B2EA12B2C80288B2E858B2EA12B2C80288B2E858B2EA12005D5D",
                    INIT_26 => X"B2E8C858027888B2E858B2EA12B2E878C858027888B2E858B2EA12B2E878C858",
                    INIT_27 => X"0399897F03030A030A7A7A7D7DB2E858B2EA12B2E8C858027888B2E858B2EA12",
                    INIT_28 => X"08B2E8120108B2E81202B2E858B2EA12B2EA125A5A5D5D030A0399890959030A",
                    INIT_29 => X"048892E8C887CA520892E8580F281E1E03021202B2E81202B2E81202B2E81201",
                    INIT_2A => X"021228030A285A23A2A2A2A2A3A3A3A3027A287888780877805808021207030C",
                    INIT_2B => X"8F032800DDCD88EF0310DDCD10DDC592E8180088EF03109D85C008180012010A",
                    INIT_2C => X"ED006B6A0A7D7D28009D85F2FDED28009D85E8FDED2800DDC5C8FDE5280088E7",
                    INIT_2D => X"00DDC588EF0328005D5DB2FDED9D8D6B6A000A7D7D0D0D28005D5D6B6AB200FD",
                    INIT_2E => X"5F5F7D7D0D0D280092FDED9D852802120228009D85000228000D0D28000D0D28",
                    INIT_2F => X"5DB2E8C89D8D6B6A00000A28005D5DB2FDED9D8D6B6A000A0D0D6F6F7F7F9F87",
                    INIT_30 => X"58286878285828B3FDED9D8D6B024B000D0D28005B5D5D0303037B7D7D28005D",
                    INIT_31 => X"1388EA8A5A017A0A286878185828687828582868781858286878285828687818",
                    INIT_32 => X"03010A2803031A020303A2A2A2A202139C8C5C5C017C7C88EA24110A010A110A",
                    INIT_33 => X"0A010A01025A035A7A010A7A288A8AD3CA2801031A020103A2A2A2A20228010A",
                    INIT_34 => X"090707130C04010113998901010A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A28",
                    INIT_35 => X"0A090928B3D9D8C813080809130808091388C8A4A4A1A1978713A1D3D7C70809",
                    INIT_36 => X"0F0393F9E928030A13CF88EF038A93EF87520F0F0393F9E928B3A1A2A1819364",
                    INIT_37 => X"A1D3D7C7080C0C09090707138A88EA77030A28010A13CF88EF018A93EF87520F",
                    INIT_38 => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A1388C8A4A4A1A1978713",
                    INIT_39 => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_3A => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_3B => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_3C => X"00000000000000000000000000000000286AB368482858580A0A0A0A0A0A0A0A",
                    INIT_3D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3F => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_00 => X"A4955354DDD75D776AAAA554AAAB9732CAE5555555555549C91A3FA32526BF47",
                   INITP_01 => X"A9555555A85D6EB75BADD6EB75BAD6565656555555555555AAAAAA576EDDBB76",
                   INITP_02 => X"81C613DBA3593A5B0BF6AF9C516AAAA9355AF25556AAAAAAA5555555554AAAAA",
                   INITP_03 => X"00D2CAC55ACACAAA6A6AB595954882FB964D8793A59B271074B2727643B2007B",
                   INITP_04 => X"9D7CB1A58D2D34B4D2D4B52C9D033D229EA324B04C92C2324B09042452B28695",
                   INITP_05 => X"43990E3C3387E7999721D99E7793264E72C91606F400750A2044BBBB5AE5A142",
                   INITP_06 => X"4015B55066AA0CC21888C0501087FFFF52D97306DCC10F6AC6E739CE730D31FE",
                   INITP_07 => X"0000000000000000000000000000E7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF01")
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
                    INIT_00 => X"D0101001D00BF030F018F031F033F0321000FC351C0017001D78078820290002",
                    INIT_01 => X"1010152006DB130012430270157806DB130002D006461981180605A9F6341670",
                    INIT_02 => X"900C11A7202902702029002E0041500005CF16706020D0009001160102700270",
                    INIT_03 => X"DB03DA021A001B015000BA009B01500010011000950D202F100091012035D001",
                    INIT_04 => X"37FB6051D459206537FD6065D780604DD4122067D70194065000D40194075000",
                    INIT_05 => X"37DF6061D414206537EF6065D411205DD780206537BF6057D4142057D7802065",
                    INIT_06 => X"D47E50005701606FD4F050005780606BD4E05000377E206537F76065D4112065",
                    INIT_07 => X"5000F0187001B0182080D706608BD47750002633662EDC207C202078D7066078",
                    INIT_08 => X"661ADC807C806092D458500026296624DC407C405000F0187002B0182086D760",
                    INIT_09 => X"60A3D41420A3D78050005704609CD459500057025000D7806098D4125000261F",
                    INIT_0A => X"60B2D4115000377F571060AED41120AED7805000572060A7D4145000377F5740",
                    INIT_0B => X"1533064260C3D4712256152F60BCD44A2256150D60B8D45A2125D78050005708",
                    INIT_0C => X"D474226B154200E9064260CFD472226B154100E9064260C9D475264000DF026B",
                    INIT_0D => X"00F5226B154500E90642226B154400E906426100D46B226B154300E9064260D5",
                    INIT_0E => X"1531F03C10301000D001100100F5226BB53C026B153BF03C10301000D0011001",
                    INIT_0F => X"5000100420FFD760100220FCD718100120F9D7061000226BB53C026B153B026B",
                    INIT_10 => X"6115D469264000DF026B15320642610ED470264000DF026B153106426107D46C",
                    INIT_11 => X"153606426123D47A264000DF026B15350642611CD47D264000DF026B15340642",
                    INIT_12 => X"2151D46C2141D4712143D4702157D502B518216DDC405000377F264000DF026B",
                    INIT_13 => X"214DD473214FD474214BD46B2147D4722153D4752149D47A2155D47D2145D469",
                    INIT_14 => X"156C2256152E225615682256156E2256156A22561562225615302256152E216D",
                    INIT_15 => X"D47D20BED4712109D4702110D4692102D46C225615752256156B225615792256",
                    INIT_16 => X"151B6175D40520DBD47320D1D47420D7D46B20CBD47220C5D475211ED47A211E",
                    INIT_17 => X"151B6185D404226B155100DF026B154F151B617DD406226B155000DF026B154F",
                    INIT_18 => X"06426196D403226B155300DF026B154F151B618DD40C226B155200DF026B154F",
                    INIT_19 => X"D483264000DF026B1537026B15310642619FD40B264000DF026B1535026B1531",
                    INIT_1A => X"00DF026B1539026B1531064261B1D40A264000DF026B1538026B1531064261A8",
                    INIT_1B => X"1531026B1532064261C3D409264000DF026B1530026B1532064261BAD4012640",
                    INIT_1C => X"1532064261D5D407264000DF026B1533026B1532064261CCD478264000DF026B",
                    INIT_1D => X"61E3D5092240D706489038000940190A1807D000D47E264000DF026B1534026B",
                    INIT_1E => X"D5342268152361EFD5332268154061EBD5322268152161E7D531226B155A0642",
                    INIT_1F => X"6202D5372268151E2268D760155E61FED5362268152561F7D5352268152461F3",
                    INIT_20 => X"6212D56022681529620ED53022681528620AD5392268152A6206D53822681526",
                    INIT_21 => X"153A6221D53B2268152B621DD53D2268151F2268D760155F6219D52D2268157E",
                    INIT_22 => X"157C6231D55C2268157D622DD55D2268157B6229D55B226815226225D5272268",
                    INIT_23 => X"2268157F2268D760153F6256D52F2268153E6239D52E2268153C6235D52C2268",
                    INIT_24 => X"6252D5322268151D624ED55D2268151C624AD55C2268151B6246D55B2256D760",
                    INIT_25 => X"DC8022689560225FD7602268A268D560E268D57B2268157F6256D508226E1500",
                    INIT_26 => X"5000078B0270226EDC205580226BD71895202268D706226895206268D7062265",
                    INIT_27 => X"D001B018F03D62AEDC0262D5DC011000D5006296DC10F5316275DC032275D51B",
                    INIT_28 => X"25A9D50C2592D50A25D1D50D2563D509255FD57F255ED50822ACD51BB03D6296",
                    INIT_29 => X"15C462A0D57122A0D004B0181520229ADC08F03D2638D5012603D507255BD505",
                    INIT_2A => X"62B3D55B50005C0225DC05BA003E00395000FA1FDB68003CD609D5043CEFB03D",
                    INIT_2B => X"BC35B634BA33BB3262C2D53822C8FC35F634FA33FB3262BAD537500002CA5C01",
                    INIT_2C => X"110010085000F011F007100050003CFD5C1062C8D54E200262C5D56322C8003E",
                    INIT_2D => X"F1111101E5000010B111101222E1A2E1D52FE2E1D53A500062D0D0101001E100",
                    INIT_2E => X"0ED00FA00EB02300FA1EDBF005BAFA01FB006302D54D500062E5D53B05335000",
                    INIT_2F => X"62F1FF1FDE683F001E013A001B01D509D404003E950A94050000DF02DE033F00",
                    INIT_30 => X"8BD00AF00BE0BF009E011F1F1E6803A002B005BAFA01FB006323D54C253005E6",
                    INIT_31 => X"0B206311EF30CE20BF009E010039D509D4040000DF02DE03950A9405003EBA00",
                    INIT_32 => X"9001003CD609D50415201001632BD000B008FA01FB006336D558253005F50A30",
                    INIT_33 => X"00D00693FA01FB001101633CD100B1086359D5402530003EBA01BB00632BD000",
                    INIT_34 => X"D0009001003EBA009B02D509D404003C950A94051001003E3A000B00900180E0",
                    INIT_35 => X"FB001101635FD100B108637BD5502530633CD1009101D609D4041420003C6346",
                    INIT_36 => X"6364D00090011A001B01D509D404003E0039950A9405003C80E000D00693FA01",
                    INIT_37 => X"6382D002B0086388D54A2530635FD1009101003EBA01BB00D609D4041420003E",
                    INIT_38 => X"6399D400A41000101108B0076416D56D253005AB253005996386D001253005A9",
                    INIT_39 => X"454EDC045680454EDC0463A1D4012412B039F01830FBB018F0393CF73CFB1670",
                    INIT_3A => X"24125C04054E6412DC0463B0D4072412454EDC045608454EDC0463A9D4052412",
                    INIT_3B => X"B018F03963C4D40B2412B039F01830FBB018F03963BCD40A24125C0863B4D408",
                    INIT_3C => X"2412454EDC04367F454EDC0463D0D41624123CF763C8D41C2412B039F0185004",
                    INIT_3D => X"D42724123CFB054E2412DC0463DFD41B2412454EDC0436F7454EDC0463D8D419",
                    INIT_3E => X"2412454EDC0436F0454EDC0463F0D4312412454EDC045670360F454EDC0463E8",
                    INIT_3F => X"DC0406404406440644064406368F941EF43D454EDC04E403C540151DE403D426",
                    INIT_40 => X"454EDC04064036F89428F43D454EDC04E412C5401527E412D4302412B43D454E",
                    INIT_41 => X"1008F0091000241FD002B007643AD566241AD5482530638DC10011012412B43D",
                    INIT_42 => X"D100A10010010B400A3006BD09D0081091011143A428D14391012424D100A100",
                    INIT_43 => X"90012440D000B0086450D5642530003E3A000B10910101D0A436C1D091012432",
                    INIT_44 => X"2530003E3A000BE00B400A3006BD09D00800B03D0698F03D90011043A444D043",
                    INIT_45 => X"0A3006BD09D008200698F03D900100D0A45AC0D090012456D000B0086466D547",
                    INIT_46 => X"B5311001646FD000B008F5373CFE3CFD6478D5622530003E3A000B00B03D0B40",
                    INIT_47 => X"2492D400B4080693FA01FB0064A4D54B5000B537646FD0009001B0360296F036",
                    INIT_48 => X"DE009E01003E0039D609D4041400249A14000ED0003EBA008BE09E012489D401",
                    INIT_49 => X"649ADE009E01003CD609D4040ED0649ADE0014000E4084E0140104D024A0648A",
                    INIT_4A => X"64B8D542253064AA91010584110164AAD100B10864AED5412530003EBA01BB00",
                    INIT_4B => X"057EF008100164BFD000B00864C6D543253064B49101058B110164B4D100B108",
                    INIT_4C => X"9001B0080577F008100164CDD000B00864D4D544253064BFD000F0089001B008",
                    INIT_4D => X"64DAD1009101B13D056AF13D110164DAD100B10864E1D55A253064CDD000F008",
                    INIT_4E => X"650ED56E253064E7D1009101B13D0563F13D110164E7D100B10864EED5492530",
                    INIT_4F => X"06C833001201FE3F0698078B155B078B151BF53EF43DFA01FB00650DD006B008",
                    INIT_50 => X"6511D5722530B53EB43DBA01BB00078B155206C8330012011300B23F078B153B",
                    INIT_51 => X"11016522D0032530033C1101651DD002253005BA6518D001B008652ED57E2530",
                    INIT_52 => X"06740450253005C5652ED006253005C1652AD005253005C96526D0042530035F",
                    INIT_53 => X"08E010012544D10091010E409430A40010122544D100B1111E0050003CFE3CFD",
                    INIT_54 => X"0460F43E5000F1071101F0111000EE000010B107100804E025380E4006BD190A",
                    INIT_55 => X"057725775000078B15065000B43E46404406440644064406460E460E460E460E",
                    INIT_56 => X"D000300700E01000DE000698203E3A000B1081001108300700B0257702701520",
                    INIT_57 => X"1E0106985000003EBA009B011000DE000698203EBA009B08203EBA008B002574",
                    INIT_58 => X"3A000BD0D000FA1EDBF05000003EBA008BD09000FA00CBD05000003C1000CED0",
                    INIT_59 => X"DB000039D609D4041420FA01FB005000003E3A000BD0E5DCFA1EDBF05000003E",
                    INIT_5A => X"D404003E1420FA01FB001A001B005000003EBA01BB00D609D404659C003EFA00",
                    INIT_5B => X"003EBA008BE01000DE0006985000003EBA01BB0065AEFA1FDB683A001B01D609",
                    INIT_5C => X"05D15000003E3A000BD0003905BA5000003E1A1E1BF05000003E1A001B005000",
                    INIT_5D => X"BF1FBE1EFA01FB001A1E1BF05000003E25DAFA1FDB683A000BD0500005BA25D3",
                    INIT_5E => X"FA1FDB683A001B01D609D504003E15001A1E1BF0DF0EDE0FFF1FFE1E3F000ED0",
                    INIT_5F => X"BB0065F7D00090013A001B01D609D504003E00D015005000003EBA01BB0065E9",
                    INIT_60 => X"1A001B005000003EB63DBA01BB00060E06B0060EF63DFA01FB005000003EBA01",
                    INIT_61 => X"B0305000D00BF0305008B03050006610FA1FDB683A001B01D609054E960A003E",
                    INIT_62 => X"5020B0305000D00BF03030EFB0305000D00BF0305010B0305000D00BF03030F7",
                    INIT_63 => X"26391000D5001501B5010296F50115005000D00BF03030DFB0305000D00BF030",
                    INIT_64 => X"38001901B901B8000270F901F8001000D5004890226B155B026B151B226B157E",
                    INIT_65 => X"06630296157B5000078B066F350F0540078B066F450E450E450E450E05402646",
                    INIT_66 => X"950A50000296066F350F05400296066F450E450E450E450E054050000296157D",
                    INIT_67 => X"15000296153E02960540B400065DB408F4000296153CF5005000153A1507A672",
                    INIT_68 => X"15201530152E153115561520156D157215651554156B15631561157515515000",
                    INIT_69 => X"12000F300E20269D180009D003A002B0269A3300120103A002B0150015201520",
                    INIT_6A => X"26A2100090014808490E430042062F900E8026AA4207A6A7AF908E8010091300",
                    INIT_6B => X"140013001201500066B8B200B100900126B810A81161120026B8106811891209",
                    INIT_6C => X"0F50A5E01F001E0606EE26D8F300D200500066C0420644084308038026C3C920",
                    INIT_6D => X"1E0606EE26EBF300D2005000078B153026CE9E011000DE02078B153026D4DF00",
                    INIT_6E => X"06F5140250000270153026E19E011000DE020270153026E7DF000F50A5E01F00",
                    INIT_6F => X"4207A701AF908E80100D180019A0130012000F300E2026EF14011000D406EE40",
                    INIT_70 => X"15001500150015001500150026FC100090014808490E430042062F900E802704",
                    INIT_71 => X"1571150015001500150015001500156015091500150015001500150015001500",
                    INIT_72 => X"15341565156415781563150015001532157715611573157A1500150015001531",
                    INIT_73 => X"1579156715681562156E15001500153515721574156615761520150015001533",
                    INIT_74 => X"1530156F1569156B152C15001500153815371575156A156D1500150015001536",
                    INIT_75 => X"153D155B15001527150015001500152D1570153B156C152F152E150015001539",
                    INIT_76 => X"15001500150015001500150015001500155C1500155D150D1500150015001500",
                    INIT_77 => X"1538153615351532152E15301500150015001537153415001531150015001508",
                    INIT_78 => X"5000D501678BD00490005000B001B0311539152A152D1533152B15001500151B",
                    INIT_79 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7F => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_00 => X"A0CDAC336363623636372372363370C2A59642DC0AEA8D5A082208288AAA202A",
                   INITP_01 => X"9C71C222275A2275A2A2B62B62B62B6A2D8D8DC8D8372360DC8D8CDAC36B0A0C",
                   INITP_02 => X"36283628377777777777622222222222DDDDDDDDDDDC322A2DA8B6A2DA8B6A2D",
                   INITP_03 => X"D8C3636363636362DC9436A22DA88B6A22DA88B6A22DA88B6A22DA88B6283628",
                   INITP_04 => X"0B3372CDAB0C7273273DD8D8D8D8D8DC8C36363636363636363630D8D8D8D8D8",
                   INITP_05 => X"D556A029435AB6DA990F76D60A8836DA00DAAB68D8AAD6A037032DDDDDDDDDD3",
                   INITP_06 => X"D36D60A2D56A824A9D36D68B596A06552A74DA0D6A1D2B68355A8A0941402ADA",
                   INITP_07 => X"1551B34DB0CDB03362CDB0CDB0CD8D882D882D8D8B36C336C3362080D10DAADA",
                   INITP_08 => X"D2AD8D4A1D20DA5020A4D74DA5080A4D74DA54D744204D74234DDB58C46CD363",
                   INITP_09 => X"96A22AB4DB529D36D4A74DB64A74DB64A74DB674DB674DA0D6A3414B5AA2095D",
                   INITP_0A => X"6A5DA59743695028AA2055552A6240881D5434208ADADADA368DAD36D8022508",
                   INITP_0B => X"355A828355A80AA50A0AD56AA96A8282976A0D56A28282B96A2A975A5D6975AD",
                   INITP_0C => X"2208A2976A0A5528A2A0A55250AB6888B528A82A0A82A0A82A0B55A20A02AAA8",
                   INITP_0D => X"750002768A2767502D689D9D40B5B55C02D58080B55567500200942AAAAAAAAA",
                   INITP_0E => X"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAB5556",
                   INITP_0F => X"00000000000000000000000000000000000000000000000000000000AC2AAAAA")
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
                    INIT_00 => X"D0101001D00BF030F018F031F033F0321000FC351C0017001D78078820290002",
                    INIT_01 => X"1010152006DB130012430270157806DB130002D006461981180605A9F6341670",
                    INIT_02 => X"900C11A7202902702029002E0041500005CF16706020D0009001160102700270",
                    INIT_03 => X"DB03DA021A001B015000BA009B01500010011000950D202F100091012035D001",
                    INIT_04 => X"37FB6051D459206537FD6065D780604DD4122067D70194065000D40194075000",
                    INIT_05 => X"37DF6061D414206537EF6065D411205DD780206537BF6057D4142057D7802065",
                    INIT_06 => X"D47E50005701606FD4F050005780606BD4E05000377E206537F76065D4112065",
                    INIT_07 => X"5000F0187001B0182080D706608BD47750002633662EDC207C202078D7066078",
                    INIT_08 => X"661ADC807C806092D458500026296624DC407C405000F0187002B0182086D760",
                    INIT_09 => X"60A3D41420A3D78050005704609CD459500057025000D7806098D4125000261F",
                    INIT_0A => X"60B2D4115000377F571060AED41120AED7805000572060A7D4145000377F5740",
                    INIT_0B => X"1533064260C3D4712256152F60BCD44A2256150D60B8D45A2125D78050005708",
                    INIT_0C => X"D474226B154200E9064260CFD472226B154100E9064260C9D475264000DF026B",
                    INIT_0D => X"00F5226B154500E90642226B154400E906426100D46B226B154300E9064260D5",
                    INIT_0E => X"1531F03C10301000D001100100F5226BB53C026B153BF03C10301000D0011001",
                    INIT_0F => X"5000100420FFD760100220FCD718100120F9D7061000226BB53C026B153B026B",
                    INIT_10 => X"6115D469264000DF026B15320642610ED470264000DF026B153106426107D46C",
                    INIT_11 => X"153606426123D47A264000DF026B15350642611CD47D264000DF026B15340642",
                    INIT_12 => X"2151D46C2141D4712143D4702157D502B518216DDC405000377F264000DF026B",
                    INIT_13 => X"214DD473214FD474214BD46B2147D4722153D4752149D47A2155D47D2145D469",
                    INIT_14 => X"156C2256152E225615682256156E2256156A22561562225615302256152E216D",
                    INIT_15 => X"D47D20BED4712109D4702110D4692102D46C225615752256156B225615792256",
                    INIT_16 => X"151B6175D40520DBD47320D1D47420D7D46B20CBD47220C5D475211ED47A211E",
                    INIT_17 => X"151B6185D404226B155100DF026B154F151B617DD406226B155000DF026B154F",
                    INIT_18 => X"06426196D403226B155300DF026B154F151B618DD40C226B155200DF026B154F",
                    INIT_19 => X"D483264000DF026B1537026B15310642619FD40B264000DF026B1535026B1531",
                    INIT_1A => X"00DF026B1539026B1531064261B1D40A264000DF026B1538026B1531064261A8",
                    INIT_1B => X"1531026B1532064261C3D409264000DF026B1530026B1532064261BAD4012640",
                    INIT_1C => X"1532064261D5D407264000DF026B1533026B1532064261CCD478264000DF026B",
                    INIT_1D => X"61E3D5092240D706489038000940190A1807D000D47E264000DF026B1534026B",
                    INIT_1E => X"D5342268152361EFD5332268154061EBD5322268152161E7D531226B155A0642",
                    INIT_1F => X"6202D5372268151E2268D760155E61FED5362268152561F7D5352268152461F3",
                    INIT_20 => X"6212D56022681529620ED53022681528620AD5392268152A6206D53822681526",
                    INIT_21 => X"153A6221D53B2268152B621DD53D2268151F2268D760155F6219D52D2268157E",
                    INIT_22 => X"157C6231D55C2268157D622DD55D2268157B6229D55B226815226225D5272268",
                    INIT_23 => X"2268157F2268D760153F6256D52F2268153E6239D52E2268153C6235D52C2268",
                    INIT_24 => X"6252D5322268151D624ED55D2268151C624AD55C2268151B6246D55B2256D760",
                    INIT_25 => X"DC8022689560225FD7602268A268D560E268D57B2268157F6256D508226E1500",
                    INIT_26 => X"5000078B0270226EDC205580226BD71895202268D706226895206268D7062265",
                    INIT_27 => X"D001B018F03D62AEDC0262D5DC011000D5006296DC10F5316275DC032275D51B",
                    INIT_28 => X"25A9D50C2592D50A25D1D50D2563D509255FD57F255ED50822ACD51BB03D6296",
                    INIT_29 => X"15C462A0D57122A0D004B0181520229ADC08F03D2638D5012603D507255BD505",
                    INIT_2A => X"62B3D55B50005C0225DC05BA003E00395000FA1FDB68003CD609D5043CEFB03D",
                    INIT_2B => X"BC35B634BA33BB3262C2D53822C8FC35F634FA33FB3262BAD537500002CA5C01",
                    INIT_2C => X"110010085000F011F007100050003CFD5C1062C8D54E200262C5D56322C8003E",
                    INIT_2D => X"F1111101E5000010B111101222E1A2E1D52FE2E1D53A500062D0D0101001E100",
                    INIT_2E => X"0ED00FA00EB02300FA1EDBF005BAFA01FB006302D54D500062E5D53B05335000",
                    INIT_2F => X"62F1FF1FDE683F001E013A001B01D509D404003E950A94050000DF02DE033F00",
                    INIT_30 => X"8BD00AF00BE0BF009E011F1F1E6803A002B005BAFA01FB006323D54C253005E6",
                    INIT_31 => X"0B206311EF30CE20BF009E010039D509D4040000DF02DE03950A9405003EBA00",
                    INIT_32 => X"9001003CD609D50415201001632BD000B008FA01FB006336D558253005F50A30",
                    INIT_33 => X"00D00693FA01FB001101633CD100B1086359D5402530003EBA01BB00632BD000",
                    INIT_34 => X"D0009001003EBA009B02D509D404003C950A94051001003E3A000B00900180E0",
                    INIT_35 => X"FB001101635FD100B108637BD5502530633CD1009101D609D4041420003C6346",
                    INIT_36 => X"6364D00090011A001B01D509D404003E0039950A9405003C80E000D00693FA01",
                    INIT_37 => X"6382D002B0086388D54A2530635FD1009101003EBA01BB00D609D4041420003E",
                    INIT_38 => X"6399D400A41000101108B0076416D56D253005AB253005996386D001253005A9",
                    INIT_39 => X"454EDC045680454EDC0463A1D4012412B039F01830FBB018F0393CF73CFB1670",
                    INIT_3A => X"24125C04054E6412DC0463B0D4072412454EDC045608454EDC0463A9D4052412",
                    INIT_3B => X"B018F03963C4D40B2412B039F01830FBB018F03963BCD40A24125C0863B4D408",
                    INIT_3C => X"2412454EDC04367F454EDC0463D0D41624123CF763C8D41C2412B039F0185004",
                    INIT_3D => X"D42724123CFB054E2412DC0463DFD41B2412454EDC0436F7454EDC0463D8D419",
                    INIT_3E => X"2412454EDC0436F0454EDC0463F0D4312412454EDC045670360F454EDC0463E8",
                    INIT_3F => X"DC0406404406440644064406368F941EF43D454EDC04E403C540151DE403D426",
                    INIT_40 => X"454EDC04064036F89428F43D454EDC04E412C5401527E412D4302412B43D454E",
                    INIT_41 => X"1008F0091000241FD002B007643AD566241AD5482530638DC10011012412B43D",
                    INIT_42 => X"D100A10010010B400A3006BD09D0081091011143A428D14391012424D100A100",
                    INIT_43 => X"90012440D000B0086450D5642530003E3A000B10910101D0A436C1D091012432",
                    INIT_44 => X"2530003E3A000BE00B400A3006BD09D00800B03D0698F03D90011043A444D043",
                    INIT_45 => X"0A3006BD09D008200698F03D900100D0A45AC0D090012456D000B0086466D547",
                    INIT_46 => X"B5311001646FD000B008F5373CFE3CFD6478D5622530003E3A000B00B03D0B40",
                    INIT_47 => X"2492D400B4080693FA01FB0064A4D54B5000B537646FD0009001B0360296F036",
                    INIT_48 => X"DE009E01003E0039D609D4041400249A14000ED0003EBA008BE09E012489D401",
                    INIT_49 => X"649ADE009E01003CD609D4040ED0649ADE0014000E4084E0140104D024A0648A",
                    INIT_4A => X"64B8D542253064AA91010584110164AAD100B10864AED5412530003EBA01BB00",
                    INIT_4B => X"057EF008100164BFD000B00864C6D543253064B49101058B110164B4D100B108",
                    INIT_4C => X"9001B0080577F008100164CDD000B00864D4D544253064BFD000F0089001B008",
                    INIT_4D => X"64DAD1009101B13D056AF13D110164DAD100B10864E1D55A253064CDD000F008",
                    INIT_4E => X"650ED56E253064E7D1009101B13D0563F13D110164E7D100B10864EED5492530",
                    INIT_4F => X"06C833001201FE3F0698078B155B078B151BF53EF43DFA01FB00650DD006B008",
                    INIT_50 => X"6511D5722530B53EB43DBA01BB00078B155206C8330012011300B23F078B153B",
                    INIT_51 => X"11016522D0032530033C1101651DD002253005BA6518D001B008652ED57E2530",
                    INIT_52 => X"06740450253005C5652ED006253005C1652AD005253005C96526D0042530035F",
                    INIT_53 => X"08E010012544D10091010E409430A40010122544D100B1111E0050003CFE3CFD",
                    INIT_54 => X"0460F43E5000F1071101F0111000EE000010B107100804E025380E4006BD190A",
                    INIT_55 => X"057725775000078B15065000B43E46404406440644064406460E460E460E460E",
                    INIT_56 => X"D000300700E01000DE000698203E3A000B1081001108300700B0257702701520",
                    INIT_57 => X"1E0106985000003EBA009B011000DE000698203EBA009B08203EBA008B002574",
                    INIT_58 => X"3A000BD0D000FA1EDBF05000003EBA008BD09000FA00CBD05000003C1000CED0",
                    INIT_59 => X"DB000039D609D4041420FA01FB005000003E3A000BD0E5DCFA1EDBF05000003E",
                    INIT_5A => X"D404003E1420FA01FB001A001B005000003EBA01BB00D609D404659C003EFA00",
                    INIT_5B => X"003EBA008BE01000DE0006985000003EBA01BB0065AEFA1FDB683A001B01D609",
                    INIT_5C => X"05D15000003E3A000BD0003905BA5000003E1A1E1BF05000003E1A001B005000",
                    INIT_5D => X"BF1FBE1EFA01FB001A1E1BF05000003E25DAFA1FDB683A000BD0500005BA25D3",
                    INIT_5E => X"FA1FDB683A001B01D609D504003E15001A1E1BF0DF0EDE0FFF1FFE1E3F000ED0",
                    INIT_5F => X"BB0065F7D00090013A001B01D609D504003E00D015005000003EBA01BB0065E9",
                    INIT_60 => X"1A001B005000003EB63DBA01BB00060E06B0060EF63DFA01FB005000003EBA01",
                    INIT_61 => X"B0305000D00BF0305008B03050006610FA1FDB683A001B01D609054E960A003E",
                    INIT_62 => X"5020B0305000D00BF03030EFB0305000D00BF0305010B0305000D00BF03030F7",
                    INIT_63 => X"26391000D5001501B5010296F50115005000D00BF03030DFB0305000D00BF030",
                    INIT_64 => X"38001901B901B8000270F901F8001000D5004890226B155B026B151B226B157E",
                    INIT_65 => X"06630296157B5000078B066F350F0540078B066F450E450E450E450E05402646",
                    INIT_66 => X"950A50000296066F350F05400296066F450E450E450E450E054050000296157D",
                    INIT_67 => X"15000296153E02960540B400065DB408F4000296153CF5005000153A1507A672",
                    INIT_68 => X"15201530152E153115561520156D157215651554156B15631561157515515000",
                    INIT_69 => X"12000F300E20269D180009D003A002B0269A3300120103A002B0150015201520",
                    INIT_6A => X"26A2100090014808490E430042062F900E8026AA4207A6A7AF908E8010091300",
                    INIT_6B => X"140013001201500066B8B200B100900126B810A81161120026B8106811891209",
                    INIT_6C => X"0F50A5E01F001E0606EE26D8F300D200500066C0420644084308038026C3C920",
                    INIT_6D => X"1E0606EE26EBF300D2005000078B153026CE9E011000DE02078B153026D4DF00",
                    INIT_6E => X"06F5140250000270153026E19E011000DE020270153026E7DF000F50A5E01F00",
                    INIT_6F => X"4207A701AF908E80100D180019A0130012000F300E2026EF14011000D406EE40",
                    INIT_70 => X"15001500150015001500150026FC100090014808490E430042062F900E802704",
                    INIT_71 => X"1571150015001500150015001500156015091500150015001500150015001500",
                    INIT_72 => X"15341565156415781563150015001532157715611573157A1500150015001531",
                    INIT_73 => X"1579156715681562156E15001500153515721574156615761520150015001533",
                    INIT_74 => X"1530156F1569156B152C15001500153815371575156A156D1500150015001536",
                    INIT_75 => X"153D155B15001527150015001500152D1570153B156C152F152E150015001539",
                    INIT_76 => X"15001500150015001500150015001500155C1500155D150D1500150015001500",
                    INIT_77 => X"1538153615351532152E15301500150015001537153415001531150015001508",
                    INIT_78 => X"5000D501678BD00490005000B001B0311539152A152D1533152B15001500151B",
                    INIT_79 => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7A => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7B => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7C => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_7F => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_00 => X"A0CDAC336363623636372372363370C2A59642DC0AEA8D5A082208288AAA202A",
                   INITP_01 => X"9C71C222275A2275A2A2B62B62B62B6A2D8D8DC8D8372360DC8D8CDAC36B0A0C",
                   INITP_02 => X"36283628377777777777622222222222DDDDDDDDDDDC322A2DA8B6A2DA8B6A2D",
                   INITP_03 => X"D8C3636363636362DC9436A22DA88B6A22DA88B6A22DA88B6A22DA88B6283628",
                   INITP_04 => X"0B3372CDAB0C7273273DD8D8D8D8D8DC8C36363636363636363630D8D8D8D8D8",
                   INITP_05 => X"D556A029435AB6DA990F76D60A8836DA00DAAB68D8AAD6A037032DDDDDDDDDD3",
                   INITP_06 => X"D36D60A2D56A824A9D36D68B596A06552A74DA0D6A1D2B68355A8A0941402ADA",
                   INITP_07 => X"1551B34DB0CDB03362CDB0CDB0CD8D882D882D8D8B36C336C3362080D10DAADA",
                   INITP_08 => X"D2AD8D4A1D20DA5020A4D74DA5080A4D74DA54D744204D74234DDB58C46CD363",
                   INITP_09 => X"96A22AB4DB529D36D4A74DB64A74DB64A74DB674DB674DA0D6A3414B5AA2095D",
                   INITP_0A => X"6A5DA59743695028AA2055552A6240881D5434208ADADADA368DAD36D8022508",
                   INITP_0B => X"355A828355A80AA50A0AD56AA96A8282976A0D56A28282B96A2A975A5D6975AD",
                   INITP_0C => X"2208A2976A0A5528A2A0A55250AB6888B528A82A0A82A0A82A0B55A20A02AAA8",
                   INITP_0D => X"750002768A2767502D689D9D40B5B55C02D58080B55567500200942AAAAAAAAA",
                   INITP_0E => X"AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAB5556",
                   INITP_0F => X"00000000000000000000000000000000000000000000000000000000AC2AAAAA")
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
                    INIT_00 => X"1020DB00437078DB00D0468106A9347010010B30183133320035000078882902",
                    INIT_01 => X"030200010000010001000D2F000135010CA72970292E4100CF70200001017070",
                    INIT_02 => X"DF611465EF65115D8065BF5714578065FB515965FD65804D1267010600010700",
                    INIT_03 => X"0018011880068B7700332E20207806787E00016FF000806BE0007E65F7651165",
                    INIT_04 => X"A314A38000049C59000200809812001F1A808092580029244040001802188660",
                    INIT_05 => X"3342C371562FBC4A560DB85A25800008B211007F10AE11AE800020A714007F40",
                    INIT_06 => X"F56B45E9426B44E942006B6B43E942D5746B42E942CF726B41E942C97540DF6B",
                    INIT_07 => X"0004FF6002FC1801F906006B3C6B3B6B313C30000101F56B3C6B3B3C30000101",
                    INIT_08 => X"3642237A40DF6B35421C7D40DF6B3442156940DF6B32420E7040DF6B3142076C",
                    INIT_09 => X"4D734F744B6B47725375497A557D4569516C417143705702186D40007F40DF6B",
                    INIT_0A => X"7DBE7109701069026C5675566B5679566C562E5668566E566A56625630562E6D",
                    INIT_0B => X"1B85046B51DF6B4F1B7D066B50DF6B4F1B7505DB73D174D76BCB72C5751E7A1E",
                    INIT_0C => X"8340DF6B376B31429F0B40DF6B356B314296036B53DF6B4F1B8D0C6B52DF6B4F",
                    INIT_0D => X"316B3242C30940DF6B306B3242BA0140DF6B396B3142B10A40DF6B386B3142A8",
                    INIT_0E => X"E30940069000400A07007E40DF6B346B3242D50740DF6B336B3242CC7840DF6B",
                    INIT_0F => X"0237681E68605EFE366825F7356824F3346823EF336840EB326821E7316B5A42",
                    INIT_10 => X"3A213B682B1D3D681F68605F192D687E126068290E3068280A39682A06386826",
                    INIT_11 => X"687F68603F562F683E392E683C352C687C315C687D2D5D687B295B6822252768",
                    INIT_12 => X"8068605F60686860687B687F56086E005232681D4E5D681C4A5C681B465B5660",
                    INIT_13 => X"01183DAE02D50100009610317503751B008B706E20806B182068066820680665",
                    INIT_14 => X"C4A071A00418209A083D380103075B05A90C920AD10D63095F7F5E08AC1B3D96",
                    INIT_15 => X"35343332C238C835343332BA3700CA01B35B0002DCBA3E39001F683C0904EF3D",
                    INIT_16 => X"110100101112E1E12FE13A00D010010000080011070000FD10C84E02C563C83E",
                    INIT_17 => X"F11F680001000109043E0A0500020300D0A0B0001EF0BA0100024D00E53B3300",
                    INIT_18 => X"2011302000013909040002030A053E00D0F0E000011F68A0B0BA0100234C30E6",
                    INIT_19 => X"D0930100013C00085940303E01002B00013C090420012B00080100365830F530",
                    INIT_1A => X"00015F00087B50303C00010904203C4600013E000209043C0A05013E000001E0",
                    INIT_1B => X"820208884A305F00013E01000904203E640001000109043E390A053CE0D09301",
                    INIT_1C => X"4E04804E04A101123918FB1839F7FB70990010100807166D30AB3099860130A9",
                    INIT_1D => X"1839C40B123918FB1839BC0A1208B40812044E1204B007124E04084E04A90512",
                    INIT_1E => X"2712FB4E1204DF1B124E04F74E04D819124E047F4E04D01612F7C81C12391804",
                    INIT_1F => X"0440060606068F1E3D4E0403401D0326124E04F04E04F031124E04700F4E04E8",
                    INIT_20 => X"0809001F02073A661A48308D0001123D4E0440F8283D4E041240271230123D4E",
                    INIT_21 => X"014000085064303E001001D036D001320000014030BDD0100143284301240000",
                    INIT_22 => X"30BDD020983D01D05AD0015600086647303E00E04030BDD0003D983D01434443",
                    INIT_23 => X"920008930100A44B00376F000136963631016F000837FEFD7862303E00003D40",
                    INIT_24 => X"9A00013C0904D09A000040E001D0A08A00013E390904009A00D03E00E0018901",
                    INIT_25 => X"7E0801BF0008C64330B4018B01B40008B84230AA018401AA0008AE41303E0100",
                    INIT_26 => X"DA00013D6A3D01DA0008E15A30CD00080108770801CD0008D44430BF00080108",
                    INIT_27 => X"C800013F988B5B8B1B3E3D01000D06080E6E30E700013D633D01E70008EE4930",
                    INIT_28 => X"012203303C011D0230BA1801082E7E301172303E3D01008B52C80001003F8B3B",
                    INIT_29 => X"E001440001403000124400110000FEFD745030C52E0630C12A0530C92604305F",
                    INIT_2A => X"7777008B06003E40060606060E0E0E0E603E000701110000100708E03840BD0A",
                    INIT_2B => X"0198003E00010000983E00083E0000740007E00000983E0010000807B0777020",
                    INIT_2C => X"00390904200100003E00D0DC1EF0003E00D0001EF0003E00D00000D0003C00D0",
                    INIT_2D => X"3E00E0000098003E0100AE1F68000109043E2001000000003E010009049C3E00",
                    INIT_2E => X"1F1E01001EF0003EDA1F6800D000BAD3D1003E00D039BA003E1EF0003E000000",
                    INIT_2F => X"00F70001000109043ED000003E0100E91F68000109043E001EF00E0F1F1E00D0",
                    INIT_30 => X"30000B30083000101F680001094E0A3E0000003E3D01000EB00E3D0100003E01",
                    INIT_31 => X"3900000101960100000B30DF30000B302030000B30EF30000B301030000B30F7",
                    INIT_32 => X"63967B008B6F0F408B6F0E0E0E0E4046000101007001000000906B5B6B1B6B7E",
                    INIT_33 => X"00963E9640005D0800963C00003A07720A00966F0F40966F0E0E0E0E4000967D",
                    INIT_34 => X"0030209D00D0A0B09A0001A0B000202020302E3156206D7265546B6361755100",
                    INIT_35 => X"00000100B8000001B8A86100B8688909A20001080E00069080AA07A790800900",
                    INIT_36 => X"06EEEB0000008B30CE0100028B30D40050E00006EED8000000C006080880C320",
                    INIT_37 => X"070190800D00A000003020EF01000640F502007030E10100027030E70050E000",
                    INIT_38 => X"71000000000000600900000000000000000000000000FC0001080E0006908004",
                    INIT_39 => X"796768626E000035727466762000003334656478630000327761737A00000031",
                    INIT_3A => X"3D5B00270000002D703B6C2F2E000039306F696B2C00003837756A6D00000036",
                    INIT_3B => X"383635322E300000003734003100000800000000000000005C005D0D00000000",
                    INIT_3C => X"0000000000000000000000000000000000018B0400000131392A2D332B00001B",
                    INIT_3D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3F => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_00 => X"124A80A022482080844D18A3145000010402222888A28A20922440805294001C",
                   INITP_01 => X"57BBBBBAD302A150A8542A150A8549C9C9C9C005152AAAABAAAAABC8A142850A",
                   INITP_02 => X"532556E6E8A1802414284C24A217FFF4009145AA295555555AAAAAAAAAB55555",
                   INITP_03 => X"004C4A45124A4A2020222494940089FB9F908C40FFE10C841FE61A3EE928B55F",
                   INITP_04 => X"47CCEFDB7ED8206081BB6ED90000000805408465200199000676D2DB017C8261",
                   INITP_05 => X"C523556A94AB8A22206A0A2482344890041300E5D800184938703BBBDEE7F3AB",
                   INITP_06 => X"6340082F130DE20D42220D094657FFFEA8368CF92BBE64953B00000000544208",
                   INITP_07 => X"000000000000000000000000000060FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC35")
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
                    INIT_00 => X"080A030909010A030901030C0C027B0B6808687878787878087E0E0B0E031000",
                    INIT_01 => X"6D6D8D8D28DDCD2888084A1088C890684808100190000028020BB0E8C88B0101",
                    INIT_02 => X"1BB0EA101BB0EA906B101BB0EA906B101BB0EA101BB06BB0EA906B4AA86A4A28",
                    INIT_03 => X"28783858906BB0EA2813B36E3E906BB0EA282BB0EA282BB0EA281B101BB0EA10",
                    INIT_04 => X"B0EA906B282BB0EA282BA86BB0EA2813B36E3EB0EA2813B36E3E28783858906B",
                    INIT_05 => X"0A03B0EA110AB0EA110AB0EA906B282BB0EA281B2BB0EA906B282BB0EA281B2B",
                    INIT_06 => X"00110A0003110A0003B0EA110A0003B0EA110A0003B0EA110A0003B0EA130001",
                    INIT_07 => X"2888906B88906B88906B08115A010A010A788888E88800115A010A788888E888",
                    INIT_08 => X"0A03B0EA1300010A03B0EA1300010A03B0EA1300010A03B0EA1300010A03B0EA",
                    INIT_09 => X"90EA90EA90EA90EA90EA90EA90EA90EA90EA90EA90EA906A5A906E281B130001",
                    INIT_0A => X"EA90EA90EA90EA90EA110A110A110A110A110A110A110A110A110A110A110A10",
                    INIT_0B => X"0AB0EA110A00010A0AB0EA110A00010A0AB0EA90EA90EA90EA90EA90EA90EA90",
                    INIT_0C => X"EA1300010A010A03B0EA1300010A010A03B0EA110A00010A0AB0EA110A00010A",
                    INIT_0D => X"0A010A03B0EA1300010A010A03B0EA1300010A010A03B0EA1300010A010A03B0",
                    INIT_0E => X"B0EA916B249C840C0CE8EA1300010A010A03B0EA1300010A010A03B0EA130001",
                    INIT_0F => X"B1EA110A916B0AB0EA110AB0EA110AB0EA110AB0EA110AB0EA110AB0EA110A03",
                    INIT_10 => X"0AB1EA110AB1EA110A916B0AB1EA110AB1EA110AB1EA110AB1EA110AB1EA110A",
                    INIT_11 => X"110A916B0AB1EA110AB1EA110AB1EA110AB1EA110AB1EA110AB1EA110AB1EA11",
                    INIT_12 => X"6E11CA916B91D1EAF1EA110AB1EA110AB1EA110AB1EA110AB1EA110AB1EA916B",
                    INIT_13 => X"685878B16EB16E88EAB16E7AB16E91EA280301916E2A916BCA916B11CAB16B91",
                    INIT_14 => X"0AB1EA9168580A916E7893EA93EA92EA92EA92EA92EA92EA92EA92EA91EA58B1",
                    INIT_15 => X"5E5B5D5DB1EA117E7B7D7DB1EA28012EB1EA282E12020000A8FDED006B6A1E58",
                    INIT_16 => X"78887280580891D1EAF1EA28B1E88870080828787808281E2EB1EA10B1EA1100",
                    INIT_17 => X"B1FFEF9F8F9D8D6A6A004A4A006F6F9F87070791FDED027D7DB1EA28B1EA0228",
                    INIT_18 => X"05B1F7E7DFCF006A6A006F6F4A4A00DDC50505DFCF0F0F0101027D7DB1EA1202",
                    INIT_19 => X"00037D7D88B1E858B1EA12005D5DB1E8C8006B6A0A88B1E8587D7DB1EA120205",
                    INIT_1A => X"7D88B1E858B1EA12B1E8C86B6A0A00B1E8C800DDCD6A6A004A4A88009D85C8C0",
                    INIT_1B => X"B1E858B1EA12B1E8C8005D5D6B6A0A00B1E8C88D8D6A6A00004A4A00C000037D",
                    INIT_1C => X"A26E2BA26EB1EA1258781858781E1E0BB1EA52800858B2EA12021202B1E81202",
                    INIT_1D => X"5878B1EA125878185878B1EA122EB1EA122E02B26EB1EA12A26E2BA26EB1EA12",
                    INIT_1E => X"EA121E02926EB1EA12A26E1BA26EB1EA12A26E1BA26EB1EA121EB1EA12587828",
                    INIT_1F => X"6E83A2A2A2A21BCA7AA26EF2E20AF2EA12A26E1BA26EB1EA12A26E2B1BA26EB1",
                    INIT_20 => X"08780892E858B2EA92EA12B1E088125AA26E831BCA7AA26EF2E20AF2EA125AA2",
                    INIT_21 => X"C892E858B2EA12009D85C800D2E0C892E850880505030404C808D2E8C892E850",
                    INIT_22 => X"050304040378C800D2E0C892E858B2EA12009D850505030404580378C808D2E8",
                    INIT_23 => X"92EA5A037D7DB2EA285AB2E8C85801785A88B2E8587A1E1EB2EA12009D855805",
                    INIT_24 => X"B2EFCF006B6A07B2EF0A07C28A0212B2EFCF00006B6A0A120A0700DDC5CF92EA",
                    INIT_25 => X"027888B2E858B2EA12B2C80288B2E858B2EA12B2C80288B2E858B2EA12005D5D",
                    INIT_26 => X"B2E8C858027888B2E858B2EA12B2E878C858027888B2E858B2EA12B2E878C858",
                    INIT_27 => X"0399897F03030A030A7A7A7D7DB2E858B2EA12B2E8C858027888B2E858B2EA12",
                    INIT_28 => X"08B2E8120108B2E81202B2E858B2EA12B2EA125A5A5D5D030A0399890959030A",
                    INIT_29 => X"048892E8C887CA520892E8580F281E1E03021202B2E81202B2E81202B2E81201",
                    INIT_2A => X"021228030A285A23A2A2A2A2A3A3A3A3027A287888780877805808021207030C",
                    INIT_2B => X"8F032800DDCD88EF0310DDCD10DDC592E8180088EF03109D85C008180012010A",
                    INIT_2C => X"ED006B6A0A7D7D28009D85F2FDED28009D85E8FDED2800DDC5C8FDE5280088E7",
                    INIT_2D => X"00DDC588EF0328005D5DB2FDED9D8D6B6A000A7D7D0D0D28005D5D6B6AB200FD",
                    INIT_2E => X"5F5F7D7D0D0D280092FDED9D852802120228009D85000228000D0D28000D0D28",
                    INIT_2F => X"5DB2E8C89D8D6B6A00000A28005D5DB2FDED9D8D6B6A000A0D0D6F6F7F7F9F87",
                    INIT_30 => X"58286878285828B3FDED9D8D6B024B000D0D28005B5D5D0303037B7D7D28005D",
                    INIT_31 => X"1388EA8A5A017A0A286878185828687828582868781858286878285828687818",
                    INIT_32 => X"03010A2803031A020303A2A2A2A202139C8C5C5C017C7C88EA24110A010A110A",
                    INIT_33 => X"0A010A01025A035A7A010A7A288A8AD3CA2801031A020103A2A2A2A20228010A",
                    INIT_34 => X"090707130C04010113998901010A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A28",
                    INIT_35 => X"0A090928B3D9D8C813080809130808091388C8A4A4A1A1978713A1D3D7C70809",
                    INIT_36 => X"0F0393F9E928030A13CF88EF038A93EF87520F0F0393F9E928B3A1A2A1819364",
                    INIT_37 => X"A1D3D7C7080C0C09090707138A88EA77030A28010A13CF88EF018A93EF87520F",
                    INIT_38 => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A1388C8A4A4A1A1978713",
                    INIT_39 => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_3A => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_3B => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_3C => X"00000000000000000000000000000000286AB368482858580A0A0A0A0A0A0A0A",
                    INIT_3D => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3E => X"0000000000000000000000000000000000000000000000000000000000000000",
                    INIT_3F => X"0000000000000000000000000000000000000000000000000000000000000000",
                   INITP_00 => X"A4955354DDD75D776AAAA554AAAB9732CAE5555555555549C91A3FA32526BF47",
                   INITP_01 => X"A9555555A85D6EB75BADD6EB75BAD6565656555555555555AAAAAA576EDDBB76",
                   INITP_02 => X"81C613DBA3593A5B0BF6AF9C516AAAA9355AF25556AAAAAAA5555555554AAAAA",
                   INITP_03 => X"00D2CAC55ACACAAA6A6AB595954882FB964D8793A59B271074B2727643B2007B",
                   INITP_04 => X"9D7CB1A58D2D34B4D2D4B52C9D033D229EA324B04C92C2324B09042452B28695",
                   INITP_05 => X"43990E3C3387E7999721D99E7793264E72C91606F400750A2044BBBB5AE5A142",
                   INITP_06 => X"4015B55066AA0CC21888C0501087FFFF52D97306DCC10F6AC6E739CE730D31FE",
                   INITP_07 => X"0000000000000000000000000000E7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF01")
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
                    INIT_00 => X"1020DB00437078DB00D0468106A9347010010B30183133320035000078882902",
                    INIT_01 => X"030200010000010001000D2F000135010CA72970292E4100CF70200001017070",
                    INIT_02 => X"DF611465EF65115D8065BF5714578065FB515965FD65804D1267010600010700",
                    INIT_03 => X"0018011880068B7700332E20207806787E00016FF000806BE0007E65F7651165",
                    INIT_04 => X"A314A38000049C59000200809812001F1A808092580029244040001802188660",
                    INIT_05 => X"3342C371562FBC4A560DB85A25800008B211007F10AE11AE800020A714007F40",
                    INIT_06 => X"F56B45E9426B44E942006B6B43E942D5746B42E942CF726B41E942C97540DF6B",
                    INIT_07 => X"0004FF6002FC1801F906006B3C6B3B6B313C30000101F56B3C6B3B3C30000101",
                    INIT_08 => X"3642237A40DF6B35421C7D40DF6B3442156940DF6B32420E7040DF6B3142076C",
                    INIT_09 => X"4D734F744B6B47725375497A557D4569516C417143705702186D40007F40DF6B",
                    INIT_0A => X"7DBE7109701069026C5675566B5679566C562E5668566E566A56625630562E6D",
                    INIT_0B => X"1B85046B51DF6B4F1B7D066B50DF6B4F1B7505DB73D174D76BCB72C5751E7A1E",
                    INIT_0C => X"8340DF6B376B31429F0B40DF6B356B314296036B53DF6B4F1B8D0C6B52DF6B4F",
                    INIT_0D => X"316B3242C30940DF6B306B3242BA0140DF6B396B3142B10A40DF6B386B3142A8",
                    INIT_0E => X"E30940069000400A07007E40DF6B346B3242D50740DF6B336B3242CC7840DF6B",
                    INIT_0F => X"0237681E68605EFE366825F7356824F3346823EF336840EB326821E7316B5A42",
                    INIT_10 => X"3A213B682B1D3D681F68605F192D687E126068290E3068280A39682A06386826",
                    INIT_11 => X"687F68603F562F683E392E683C352C687C315C687D2D5D687B295B6822252768",
                    INIT_12 => X"8068605F60686860687B687F56086E005232681D4E5D681C4A5C681B465B5660",
                    INIT_13 => X"01183DAE02D50100009610317503751B008B706E20806B182068066820680665",
                    INIT_14 => X"C4A071A00418209A083D380103075B05A90C920AD10D63095F7F5E08AC1B3D96",
                    INIT_15 => X"35343332C238C835343332BA3700CA01B35B0002DCBA3E39001F683C0904EF3D",
                    INIT_16 => X"110100101112E1E12FE13A00D010010000080011070000FD10C84E02C563C83E",
                    INIT_17 => X"F11F680001000109043E0A0500020300D0A0B0001EF0BA0100024D00E53B3300",
                    INIT_18 => X"2011302000013909040002030A053E00D0F0E000011F68A0B0BA0100234C30E6",
                    INIT_19 => X"D0930100013C00085940303E01002B00013C090420012B00080100365830F530",
                    INIT_1A => X"00015F00087B50303C00010904203C4600013E000209043C0A05013E000001E0",
                    INIT_1B => X"820208884A305F00013E01000904203E640001000109043E390A053CE0D09301",
                    INIT_1C => X"4E04804E04A101123918FB1839F7FB70990010100807166D30AB3099860130A9",
                    INIT_1D => X"1839C40B123918FB1839BC0A1208B40812044E1204B007124E04084E04A90512",
                    INIT_1E => X"2712FB4E1204DF1B124E04F74E04D819124E047F4E04D01612F7C81C12391804",
                    INIT_1F => X"0440060606068F1E3D4E0403401D0326124E04F04E04F031124E04700F4E04E8",
                    INIT_20 => X"0809001F02073A661A48308D0001123D4E0440F8283D4E041240271230123D4E",
                    INIT_21 => X"014000085064303E001001D036D001320000014030BDD0100143284301240000",
                    INIT_22 => X"30BDD020983D01D05AD0015600086647303E00E04030BDD0003D983D01434443",
                    INIT_23 => X"920008930100A44B00376F000136963631016F000837FEFD7862303E00003D40",
                    INIT_24 => X"9A00013C0904D09A000040E001D0A08A00013E390904009A00D03E00E0018901",
                    INIT_25 => X"7E0801BF0008C64330B4018B01B40008B84230AA018401AA0008AE41303E0100",
                    INIT_26 => X"DA00013D6A3D01DA0008E15A30CD00080108770801CD0008D44430BF00080108",
                    INIT_27 => X"C800013F988B5B8B1B3E3D01000D06080E6E30E700013D633D01E70008EE4930",
                    INIT_28 => X"012203303C011D0230BA1801082E7E301172303E3D01008B52C80001003F8B3B",
                    INIT_29 => X"E001440001403000124400110000FEFD745030C52E0630C12A0530C92604305F",
                    INIT_2A => X"7777008B06003E40060606060E0E0E0E603E000701110000100708E03840BD0A",
                    INIT_2B => X"0198003E00010000983E00083E0000740007E00000983E0010000807B0777020",
                    INIT_2C => X"00390904200100003E00D0DC1EF0003E00D0001EF0003E00D00000D0003C00D0",
                    INIT_2D => X"3E00E0000098003E0100AE1F68000109043E2001000000003E010009049C3E00",
                    INIT_2E => X"1F1E01001EF0003EDA1F6800D000BAD3D1003E00D039BA003E1EF0003E000000",
                    INIT_2F => X"00F70001000109043ED000003E0100E91F68000109043E001EF00E0F1F1E00D0",
                    INIT_30 => X"30000B30083000101F680001094E0A3E0000003E3D01000EB00E3D0100003E01",
                    INIT_31 => X"3900000101960100000B30DF30000B302030000B30EF30000B301030000B30F7",
                    INIT_32 => X"63967B008B6F0F408B6F0E0E0E0E4046000101007001000000906B5B6B1B6B7E",
                    INIT_33 => X"00963E9640005D0800963C00003A07720A00966F0F40966F0E0E0E0E4000967D",
                    INIT_34 => X"0030209D00D0A0B09A0001A0B000202020302E3156206D7265546B6361755100",
                    INIT_35 => X"00000100B8000001B8A86100B8688909A20001080E00069080AA07A790800900",
                    INIT_36 => X"06EEEB0000008B30CE0100028B30D40050E00006EED8000000C006080880C320",
                    INIT_37 => X"070190800D00A000003020EF01000640F502007030E10100027030E70050E000",
                    INIT_38 => X"71000000000000600900000000000000000000000000FC0001080E0006908004",
                    INIT_39 => X"796768626E000035727466762000003334656478630000327761737A00000031",
                    INIT_3A => X"3D5B00270000002D703B6C2F2E000039306F696B2C00003837756A6D00000036",
                    INIT_3B => X"383635322E300000003734003100000800000000000000005C005D0D00000000",
                    INIT_3C => X"0000000000000000000000000000000000018B0400000131392A2D332B00001B",
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
                   INITP_00 => X"124A80A022482080844D18A3145000010402222888A28A20922440805294001C",
                   INITP_01 => X"57BBBBBAD302A150A8542A150A8549C9C9C9C005152AAAABAAAAABC8A142850A",
                   INITP_02 => X"532556E6E8A1802414284C24A217FFF4009145AA295555555AAAAAAAAAB55555",
                   INITP_03 => X"004C4A45124A4A2020222494940089FB9F908C40FFE10C841FE61A3EE928B55F",
                   INITP_04 => X"47CCEFDB7ED8206081BB6ED90000000805408465200199000676D2DB017C8261",
                   INITP_05 => X"C523556A94AB8A22206A0A2482344890041300E5D800184938703BBBDEE7F3AB",
                   INITP_06 => X"6340082F130DE20D42220D094657FFFEA8368CF92BBE64953B00000000544208",
                   INITP_07 => X"000000000000000000000000000060FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC35",
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
                    INIT_00 => X"080A030909010A030901030C0C027B0B6808687878787878087E0E0B0E031000",
                    INIT_01 => X"6D6D8D8D28DDCD2888084A1088C890684808100190000028020BB0E8C88B0101",
                    INIT_02 => X"1BB0EA101BB0EA906B101BB0EA906B101BB0EA101BB06BB0EA906B4AA86A4A28",
                    INIT_03 => X"28783858906BB0EA2813B36E3E906BB0EA282BB0EA282BB0EA281B101BB0EA10",
                    INIT_04 => X"B0EA906B282BB0EA282BA86BB0EA2813B36E3EB0EA2813B36E3E28783858906B",
                    INIT_05 => X"0A03B0EA110AB0EA110AB0EA906B282BB0EA281B2BB0EA906B282BB0EA281B2B",
                    INIT_06 => X"00110A0003110A0003B0EA110A0003B0EA110A0003B0EA110A0003B0EA130001",
                    INIT_07 => X"2888906B88906B88906B08115A010A010A788888E88800115A010A788888E888",
                    INIT_08 => X"0A03B0EA1300010A03B0EA1300010A03B0EA1300010A03B0EA1300010A03B0EA",
                    INIT_09 => X"90EA90EA90EA90EA90EA90EA90EA90EA90EA90EA90EA906A5A906E281B130001",
                    INIT_0A => X"EA90EA90EA90EA90EA110A110A110A110A110A110A110A110A110A110A110A10",
                    INIT_0B => X"0AB0EA110A00010A0AB0EA110A00010A0AB0EA90EA90EA90EA90EA90EA90EA90",
                    INIT_0C => X"EA1300010A010A03B0EA1300010A010A03B0EA110A00010A0AB0EA110A00010A",
                    INIT_0D => X"0A010A03B0EA1300010A010A03B0EA1300010A010A03B0EA1300010A010A03B0",
                    INIT_0E => X"B0EA916B249C840C0CE8EA1300010A010A03B0EA1300010A010A03B0EA130001",
                    INIT_0F => X"B1EA110A916B0AB0EA110AB0EA110AB0EA110AB0EA110AB0EA110AB0EA110A03",
                    INIT_10 => X"0AB1EA110AB1EA110A916B0AB1EA110AB1EA110AB1EA110AB1EA110AB1EA110A",
                    INIT_11 => X"110A916B0AB1EA110AB1EA110AB1EA110AB1EA110AB1EA110AB1EA110AB1EA11",
                    INIT_12 => X"6E11CA916B91D1EAF1EA110AB1EA110AB1EA110AB1EA110AB1EA110AB1EA916B",
                    INIT_13 => X"685878B16EB16E88EAB16E7AB16E91EA280301916E2A916BCA916B11CAB16B91",
                    INIT_14 => X"0AB1EA9168580A916E7893EA93EA92EA92EA92EA92EA92EA92EA92EA91EA58B1",
                    INIT_15 => X"5E5B5D5DB1EA117E7B7D7DB1EA28012EB1EA282E12020000A8FDED006B6A1E58",
                    INIT_16 => X"78887280580891D1EAF1EA28B1E88870080828787808281E2EB1EA10B1EA1100",
                    INIT_17 => X"B1FFEF9F8F9D8D6A6A004A4A006F6F9F87070791FDED027D7DB1EA28B1EA0228",
                    INIT_18 => X"05B1F7E7DFCF006A6A006F6F4A4A00DDC50505DFCF0F0F0101027D7DB1EA1202",
                    INIT_19 => X"00037D7D88B1E858B1EA12005D5DB1E8C8006B6A0A88B1E8587D7DB1EA120205",
                    INIT_1A => X"7D88B1E858B1EA12B1E8C86B6A0A00B1E8C800DDCD6A6A004A4A88009D85C8C0",
                    INIT_1B => X"B1E858B1EA12B1E8C8005D5D6B6A0A00B1E8C88D8D6A6A00004A4A00C000037D",
                    INIT_1C => X"A26E2BA26EB1EA1258781858781E1E0BB1EA52800858B2EA12021202B1E81202",
                    INIT_1D => X"5878B1EA125878185878B1EA122EB1EA122E02B26EB1EA12A26E2BA26EB1EA12",
                    INIT_1E => X"EA121E02926EB1EA12A26E1BA26EB1EA12A26E1BA26EB1EA121EB1EA12587828",
                    INIT_1F => X"6E83A2A2A2A21BCA7AA26EF2E20AF2EA12A26E1BA26EB1EA12A26E2B1BA26EB1",
                    INIT_20 => X"08780892E858B2EA92EA12B1E088125AA26E831BCA7AA26EF2E20AF2EA125AA2",
                    INIT_21 => X"C892E858B2EA12009D85C800D2E0C892E850880505030404C808D2E8C892E850",
                    INIT_22 => X"050304040378C800D2E0C892E858B2EA12009D850505030404580378C808D2E8",
                    INIT_23 => X"92EA5A037D7DB2EA285AB2E8C85801785A88B2E8587A1E1EB2EA12009D855805",
                    INIT_24 => X"B2EFCF006B6A07B2EF0A07C28A0212B2EFCF00006B6A0A120A0700DDC5CF92EA",
                    INIT_25 => X"027888B2E858B2EA12B2C80288B2E858B2EA12B2C80288B2E858B2EA12005D5D",
                    INIT_26 => X"B2E8C858027888B2E858B2EA12B2E878C858027888B2E858B2EA12B2E878C858",
                    INIT_27 => X"0399897F03030A030A7A7A7D7DB2E858B2EA12B2E8C858027888B2E858B2EA12",
                    INIT_28 => X"08B2E8120108B2E81202B2E858B2EA12B2EA125A5A5D5D030A0399890959030A",
                    INIT_29 => X"048892E8C887CA520892E8580F281E1E03021202B2E81202B2E81202B2E81201",
                    INIT_2A => X"021228030A285A23A2A2A2A2A3A3A3A3027A287888780877805808021207030C",
                    INIT_2B => X"8F032800DDCD88EF0310DDCD10DDC592E8180088EF03109D85C008180012010A",
                    INIT_2C => X"ED006B6A0A7D7D28009D85F2FDED28009D85E8FDED2800DDC5C8FDE5280088E7",
                    INIT_2D => X"00DDC588EF0328005D5DB2FDED9D8D6B6A000A7D7D0D0D28005D5D6B6AB200FD",
                    INIT_2E => X"5F5F7D7D0D0D280092FDED9D852802120228009D85000228000D0D28000D0D28",
                    INIT_2F => X"5DB2E8C89D8D6B6A00000A28005D5DB2FDED9D8D6B6A000A0D0D6F6F7F7F9F87",
                    INIT_30 => X"58286878285828B3FDED9D8D6B024B000D0D28005B5D5D0303037B7D7D28005D",
                    INIT_31 => X"1388EA8A5A017A0A286878185828687828582868781858286878285828687818",
                    INIT_32 => X"03010A2803031A020303A2A2A2A202139C8C5C5C017C7C88EA24110A010A110A",
                    INIT_33 => X"0A010A01025A035A7A010A7A288A8AD3CA2801031A020103A2A2A2A20228010A",
                    INIT_34 => X"090707130C04010113998901010A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A28",
                    INIT_35 => X"0A090928B3D9D8C813080809130808091388C8A4A4A1A1978713A1D3D7C70809",
                    INIT_36 => X"0F0393F9E928030A13CF88EF038A93EF87520F0F0393F9E928B3A1A2A1819364",
                    INIT_37 => X"A1D3D7C7080C0C09090707138A88EA77030A28010A13CF88EF018A93EF87520F",
                    INIT_38 => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A1388C8A4A4A1A1978713",
                    INIT_39 => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_3A => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_3B => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_3C => X"00000000000000000000000000000000286AB368482858580A0A0A0A0A0A0A0A",
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
                   INITP_00 => X"A4955354DDD75D776AAAA554AAAB9732CAE5555555555549C91A3FA32526BF47",
                   INITP_01 => X"A9555555A85D6EB75BADD6EB75BAD6565656555555555555AAAAAA576EDDBB76",
                   INITP_02 => X"81C613DBA3593A5B0BF6AF9C516AAAA9355AF25556AAAAAAA5555555554AAAAA",
                   INITP_03 => X"00D2CAC55ACACAAA6A6AB595954882FB964D8793A59B271074B2727643B2007B",
                   INITP_04 => X"9D7CB1A58D2D34B4D2D4B52C9D033D229EA324B04C92C2324B09042452B28695",
                   INITP_05 => X"43990E3C3387E7999721D99E7793264E72C91606F400750A2044BBBB5AE5A142",
                   INITP_06 => X"4015B55066AA0CC21888C0501087FFFF52D97306DCC10F6AC6E739CE730D31FE",
                   INITP_07 => X"0000000000000000000000000000E7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF01",
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
                    INIT_00 => X"1020DB00437078DB00D0468106A9347010010B30183133320035000078882902",
                    INIT_01 => X"030200010000010001000D2F000135010CA72970292E4100CF70200001017070",
                    INIT_02 => X"DF611465EF65115D8065BF5714578065FB515965FD65804D1267010600010700",
                    INIT_03 => X"0018011880068B7700332E20207806787E00016FF000806BE0007E65F7651165",
                    INIT_04 => X"A314A38000049C59000200809812001F1A808092580029244040001802188660",
                    INIT_05 => X"3342C371562FBC4A560DB85A25800008B211007F10AE11AE800020A714007F40",
                    INIT_06 => X"F56B45E9426B44E942006B6B43E942D5746B42E942CF726B41E942C97540DF6B",
                    INIT_07 => X"0004FF6002FC1801F906006B3C6B3B6B313C30000101F56B3C6B3B3C30000101",
                    INIT_08 => X"3642237A40DF6B35421C7D40DF6B3442156940DF6B32420E7040DF6B3142076C",
                    INIT_09 => X"4D734F744B6B47725375497A557D4569516C417143705702186D40007F40DF6B",
                    INIT_0A => X"7DBE7109701069026C5675566B5679566C562E5668566E566A56625630562E6D",
                    INIT_0B => X"1B85046B51DF6B4F1B7D066B50DF6B4F1B7505DB73D174D76BCB72C5751E7A1E",
                    INIT_0C => X"8340DF6B376B31429F0B40DF6B356B314296036B53DF6B4F1B8D0C6B52DF6B4F",
                    INIT_0D => X"316B3242C30940DF6B306B3242BA0140DF6B396B3142B10A40DF6B386B3142A8",
                    INIT_0E => X"E30940069000400A07007E40DF6B346B3242D50740DF6B336B3242CC7840DF6B",
                    INIT_0F => X"0237681E68605EFE366825F7356824F3346823EF336840EB326821E7316B5A42",
                    INIT_10 => X"3A213B682B1D3D681F68605F192D687E126068290E3068280A39682A06386826",
                    INIT_11 => X"687F68603F562F683E392E683C352C687C315C687D2D5D687B295B6822252768",
                    INIT_12 => X"8068605F60686860687B687F56086E005232681D4E5D681C4A5C681B465B5660",
                    INIT_13 => X"01183DAE02D50100009610317503751B008B706E20806B182068066820680665",
                    INIT_14 => X"C4A071A00418209A083D380103075B05A90C920AD10D63095F7F5E08AC1B3D96",
                    INIT_15 => X"35343332C238C835343332BA3700CA01B35B0002DCBA3E39001F683C0904EF3D",
                    INIT_16 => X"110100101112E1E12FE13A00D010010000080011070000FD10C84E02C563C83E",
                    INIT_17 => X"F11F680001000109043E0A0500020300D0A0B0001EF0BA0100024D00E53B3300",
                    INIT_18 => X"2011302000013909040002030A053E00D0F0E000011F68A0B0BA0100234C30E6",
                    INIT_19 => X"D0930100013C00085940303E01002B00013C090420012B00080100365830F530",
                    INIT_1A => X"00015F00087B50303C00010904203C4600013E000209043C0A05013E000001E0",
                    INIT_1B => X"820208884A305F00013E01000904203E640001000109043E390A053CE0D09301",
                    INIT_1C => X"4E04804E04A101123918FB1839F7FB70990010100807166D30AB3099860130A9",
                    INIT_1D => X"1839C40B123918FB1839BC0A1208B40812044E1204B007124E04084E04A90512",
                    INIT_1E => X"2712FB4E1204DF1B124E04F74E04D819124E047F4E04D01612F7C81C12391804",
                    INIT_1F => X"0440060606068F1E3D4E0403401D0326124E04F04E04F031124E04700F4E04E8",
                    INIT_20 => X"0809001F02073A661A48308D0001123D4E0440F8283D4E041240271230123D4E",
                    INIT_21 => X"014000085064303E001001D036D001320000014030BDD0100143284301240000",
                    INIT_22 => X"30BDD020983D01D05AD0015600086647303E00E04030BDD0003D983D01434443",
                    INIT_23 => X"920008930100A44B00376F000136963631016F000837FEFD7862303E00003D40",
                    INIT_24 => X"9A00013C0904D09A000040E001D0A08A00013E390904009A00D03E00E0018901",
                    INIT_25 => X"7E0801BF0008C64330B4018B01B40008B84230AA018401AA0008AE41303E0100",
                    INIT_26 => X"DA00013D6A3D01DA0008E15A30CD00080108770801CD0008D44430BF00080108",
                    INIT_27 => X"C800013F988B5B8B1B3E3D01000D06080E6E30E700013D633D01E70008EE4930",
                    INIT_28 => X"012203303C011D0230BA1801082E7E301172303E3D01008B52C80001003F8B3B",
                    INIT_29 => X"E001440001403000124400110000FEFD745030C52E0630C12A0530C92604305F",
                    INIT_2A => X"7777008B06003E40060606060E0E0E0E603E000701110000100708E03840BD0A",
                    INIT_2B => X"0198003E00010000983E00083E0000740007E00000983E0010000807B0777020",
                    INIT_2C => X"00390904200100003E00D0DC1EF0003E00D0001EF0003E00D00000D0003C00D0",
                    INIT_2D => X"3E00E0000098003E0100AE1F68000109043E2001000000003E010009049C3E00",
                    INIT_2E => X"1F1E01001EF0003EDA1F6800D000BAD3D1003E00D039BA003E1EF0003E000000",
                    INIT_2F => X"00F70001000109043ED000003E0100E91F68000109043E001EF00E0F1F1E00D0",
                    INIT_30 => X"30000B30083000101F680001094E0A3E0000003E3D01000EB00E3D0100003E01",
                    INIT_31 => X"3900000101960100000B30DF30000B302030000B30EF30000B301030000B30F7",
                    INIT_32 => X"63967B008B6F0F408B6F0E0E0E0E4046000101007001000000906B5B6B1B6B7E",
                    INIT_33 => X"00963E9640005D0800963C00003A07720A00966F0F40966F0E0E0E0E4000967D",
                    INIT_34 => X"0030209D00D0A0B09A0001A0B000202020302E3156206D7265546B6361755100",
                    INIT_35 => X"00000100B8000001B8A86100B8688909A20001080E00069080AA07A790800900",
                    INIT_36 => X"06EEEB0000008B30CE0100028B30D40050E00006EED8000000C006080880C320",
                    INIT_37 => X"070190800D00A000003020EF01000640F502007030E10100027030E70050E000",
                    INIT_38 => X"71000000000000600900000000000000000000000000FC0001080E0006908004",
                    INIT_39 => X"796768626E000035727466762000003334656478630000327761737A00000031",
                    INIT_3A => X"3D5B00270000002D703B6C2F2E000039306F696B2C00003837756A6D00000036",
                    INIT_3B => X"383635322E300000003734003100000800000000000000005C005D0D00000000",
                    INIT_3C => X"0000000000000000000000000000000000018B0400000131392A2D332B00001B",
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
                   INITP_00 => X"124A80A022482080844D18A3145000010402222888A28A20922440805294001C",
                   INITP_01 => X"57BBBBBAD302A150A8542A150A8549C9C9C9C005152AAAABAAAAABC8A142850A",
                   INITP_02 => X"532556E6E8A1802414284C24A217FFF4009145AA295555555AAAAAAAAAB55555",
                   INITP_03 => X"004C4A45124A4A2020222494940089FB9F908C40FFE10C841FE61A3EE928B55F",
                   INITP_04 => X"47CCEFDB7ED8206081BB6ED90000000805408465200199000676D2DB017C8261",
                   INITP_05 => X"C523556A94AB8A22206A0A2482344890041300E5D800184938703BBBDEE7F3AB",
                   INITP_06 => X"6340082F130DE20D42220D094657FFFEA8368CF92BBE64953B00000000544208",
                   INITP_07 => X"000000000000000000000000000060FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFC35",
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
                    INIT_00 => X"080A030909010A030901030C0C027B0B6808687878787878087E0E0B0E031000",
                    INIT_01 => X"6D6D8D8D28DDCD2888084A1088C890684808100190000028020BB0E8C88B0101",
                    INIT_02 => X"1BB0EA101BB0EA906B101BB0EA906B101BB0EA101BB06BB0EA906B4AA86A4A28",
                    INIT_03 => X"28783858906BB0EA2813B36E3E906BB0EA282BB0EA282BB0EA281B101BB0EA10",
                    INIT_04 => X"B0EA906B282BB0EA282BA86BB0EA2813B36E3EB0EA2813B36E3E28783858906B",
                    INIT_05 => X"0A03B0EA110AB0EA110AB0EA906B282BB0EA281B2BB0EA906B282BB0EA281B2B",
                    INIT_06 => X"00110A0003110A0003B0EA110A0003B0EA110A0003B0EA110A0003B0EA130001",
                    INIT_07 => X"2888906B88906B88906B08115A010A010A788888E88800115A010A788888E888",
                    INIT_08 => X"0A03B0EA1300010A03B0EA1300010A03B0EA1300010A03B0EA1300010A03B0EA",
                    INIT_09 => X"90EA90EA90EA90EA90EA90EA90EA90EA90EA90EA90EA906A5A906E281B130001",
                    INIT_0A => X"EA90EA90EA90EA90EA110A110A110A110A110A110A110A110A110A110A110A10",
                    INIT_0B => X"0AB0EA110A00010A0AB0EA110A00010A0AB0EA90EA90EA90EA90EA90EA90EA90",
                    INIT_0C => X"EA1300010A010A03B0EA1300010A010A03B0EA110A00010A0AB0EA110A00010A",
                    INIT_0D => X"0A010A03B0EA1300010A010A03B0EA1300010A010A03B0EA1300010A010A03B0",
                    INIT_0E => X"B0EA916B249C840C0CE8EA1300010A010A03B0EA1300010A010A03B0EA130001",
                    INIT_0F => X"B1EA110A916B0AB0EA110AB0EA110AB0EA110AB0EA110AB0EA110AB0EA110A03",
                    INIT_10 => X"0AB1EA110AB1EA110A916B0AB1EA110AB1EA110AB1EA110AB1EA110AB1EA110A",
                    INIT_11 => X"110A916B0AB1EA110AB1EA110AB1EA110AB1EA110AB1EA110AB1EA110AB1EA11",
                    INIT_12 => X"6E11CA916B91D1EAF1EA110AB1EA110AB1EA110AB1EA110AB1EA110AB1EA916B",
                    INIT_13 => X"685878B16EB16E88EAB16E7AB16E91EA280301916E2A916BCA916B11CAB16B91",
                    INIT_14 => X"0AB1EA9168580A916E7893EA93EA92EA92EA92EA92EA92EA92EA92EA91EA58B1",
                    INIT_15 => X"5E5B5D5DB1EA117E7B7D7DB1EA28012EB1EA282E12020000A8FDED006B6A1E58",
                    INIT_16 => X"78887280580891D1EAF1EA28B1E88870080828787808281E2EB1EA10B1EA1100",
                    INIT_17 => X"B1FFEF9F8F9D8D6A6A004A4A006F6F9F87070791FDED027D7DB1EA28B1EA0228",
                    INIT_18 => X"05B1F7E7DFCF006A6A006F6F4A4A00DDC50505DFCF0F0F0101027D7DB1EA1202",
                    INIT_19 => X"00037D7D88B1E858B1EA12005D5DB1E8C8006B6A0A88B1E8587D7DB1EA120205",
                    INIT_1A => X"7D88B1E858B1EA12B1E8C86B6A0A00B1E8C800DDCD6A6A004A4A88009D85C8C0",
                    INIT_1B => X"B1E858B1EA12B1E8C8005D5D6B6A0A00B1E8C88D8D6A6A00004A4A00C000037D",
                    INIT_1C => X"A26E2BA26EB1EA1258781858781E1E0BB1EA52800858B2EA12021202B1E81202",
                    INIT_1D => X"5878B1EA125878185878B1EA122EB1EA122E02B26EB1EA12A26E2BA26EB1EA12",
                    INIT_1E => X"EA121E02926EB1EA12A26E1BA26EB1EA12A26E1BA26EB1EA121EB1EA12587828",
                    INIT_1F => X"6E83A2A2A2A21BCA7AA26EF2E20AF2EA12A26E1BA26EB1EA12A26E2B1BA26EB1",
                    INIT_20 => X"08780892E858B2EA92EA12B1E088125AA26E831BCA7AA26EF2E20AF2EA125AA2",
                    INIT_21 => X"C892E858B2EA12009D85C800D2E0C892E850880505030404C808D2E8C892E850",
                    INIT_22 => X"050304040378C800D2E0C892E858B2EA12009D850505030404580378C808D2E8",
                    INIT_23 => X"92EA5A037D7DB2EA285AB2E8C85801785A88B2E8587A1E1EB2EA12009D855805",
                    INIT_24 => X"B2EFCF006B6A07B2EF0A07C28A0212B2EFCF00006B6A0A120A0700DDC5CF92EA",
                    INIT_25 => X"027888B2E858B2EA12B2C80288B2E858B2EA12B2C80288B2E858B2EA12005D5D",
                    INIT_26 => X"B2E8C858027888B2E858B2EA12B2E878C858027888B2E858B2EA12B2E878C858",
                    INIT_27 => X"0399897F03030A030A7A7A7D7DB2E858B2EA12B2E8C858027888B2E858B2EA12",
                    INIT_28 => X"08B2E8120108B2E81202B2E858B2EA12B2EA125A5A5D5D030A0399890959030A",
                    INIT_29 => X"048892E8C887CA520892E8580F281E1E03021202B2E81202B2E81202B2E81201",
                    INIT_2A => X"021228030A285A23A2A2A2A2A3A3A3A3027A287888780877805808021207030C",
                    INIT_2B => X"8F032800DDCD88EF0310DDCD10DDC592E8180088EF03109D85C008180012010A",
                    INIT_2C => X"ED006B6A0A7D7D28009D85F2FDED28009D85E8FDED2800DDC5C8FDE5280088E7",
                    INIT_2D => X"00DDC588EF0328005D5DB2FDED9D8D6B6A000A7D7D0D0D28005D5D6B6AB200FD",
                    INIT_2E => X"5F5F7D7D0D0D280092FDED9D852802120228009D85000228000D0D28000D0D28",
                    INIT_2F => X"5DB2E8C89D8D6B6A00000A28005D5DB2FDED9D8D6B6A000A0D0D6F6F7F7F9F87",
                    INIT_30 => X"58286878285828B3FDED9D8D6B024B000D0D28005B5D5D0303037B7D7D28005D",
                    INIT_31 => X"1388EA8A5A017A0A286878185828687828582868781858286878285828687818",
                    INIT_32 => X"03010A2803031A020303A2A2A2A202139C8C5C5C017C7C88EA24110A010A110A",
                    INIT_33 => X"0A010A01025A035A7A010A7A288A8AD3CA2801031A020103A2A2A2A20228010A",
                    INIT_34 => X"090707130C04010113998901010A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A28",
                    INIT_35 => X"0A090928B3D9D8C813080809130808091388C8A4A4A1A1978713A1D3D7C70809",
                    INIT_36 => X"0F0393F9E928030A13CF88EF038A93EF87520F0F0393F9E928B3A1A2A1819364",
                    INIT_37 => X"A1D3D7C7080C0C09090707138A88EA77030A28010A13CF88EF018A93EF87520F",
                    INIT_38 => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A1388C8A4A4A1A1978713",
                    INIT_39 => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_3A => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_3B => X"0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A0A",
                    INIT_3C => X"00000000000000000000000000000000286AB368482858580A0A0A0A0A0A0A0A",
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
                   INITP_00 => X"A4955354DDD75D776AAAA554AAAB9732CAE5555555555549C91A3FA32526BF47",
                   INITP_01 => X"A9555555A85D6EB75BADD6EB75BAD6565656555555555555AAAAAA576EDDBB76",
                   INITP_02 => X"81C613DBA3593A5B0BF6AF9C516AAAA9355AF25556AAAAAAA5555555554AAAAA",
                   INITP_03 => X"00D2CAC55ACACAAA6A6AB595954882FB964D8793A59B271074B2727643B2007B",
                   INITP_04 => X"9D7CB1A58D2D34B4D2D4B52C9D033D229EA324B04C92C2324B09042452B28695",
                   INITP_05 => X"43990E3C3387E7999721D99E7793264E72C91606F400750A2044BBBB5AE5A142",
                   INITP_06 => X"4015B55066AA0CC21888C0501087FFFF52D97306DCC10F6AC6E739CE730D31FE",
                   INITP_07 => X"0000000000000000000000000000E7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF01",
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
-- END OF FILE uart_control.vhd
--
------------------------------------------------------------------------------------
