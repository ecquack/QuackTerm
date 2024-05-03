---------------------------------down-------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:22:44 02/13/2017 
-- Design Name: 
-- Module Name:    CGROM - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
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
library UNIMACRO;
use UNIMACRO.Vcomponents.ALL;

	
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity CGROM is
	Port (

	CGROM_CLK 		: in STD_LOGIC;
	CGROM_EN 		: in STD_LOGIC;
	CGROM_ADDR 		: in STD_LOGIC_VECTOR(13 downto 0); -- change this to (11 downto 0) once we have a full character set
	CGROM_DO 		: out STD_LOGIC_VECTOR(0 downto 0);
	
	DI					: in STD_LOGIC_VECTOR(0 downto 0);
	REGCE				: in STD_LOGIC;
	RST				: in STD_LOGIC;
	WE					: in STD_LOGIC_VECTOR(0 downto 0)
	);

end CGROM;

architecture Behavioral of CGROM is

begin
BRAM_SINGLE_MACRO_inst: BRAM_SINGLE_MACRO
generic map (
	BRAM_SIZE=>"18Kb",
	DEVICE=>"SPARTAN6",
	WRITE_WIDTH=>1,
	READ_WIDTH=>1,
	DO_REG=>0,
	INIT_FILE=>"NONE",
--	SIM_COLLISION_CHECK=>"ALL",
	SIM_MODE=>"SAFE",
	SRVAL=>X"00000000000000000",
	INIT=>X"00000000000000000",

--
-- here's our ASCII 8x8 CGROM. The 3 MSBs control the scan line. 
-- this is a straight codepage 1252 font with VT100 graphics characters in the C0 control set

INIT_00=> X"08001C0000030C180018181800000000FF18180000180500001C01060705AA00", -- 00
INIT_01=> X"1E06001800001E1E3F1C3F381E1E0C3E6000000000000618061C000C36360C00",
INIT_02=> X"00081E031E7F33636333333F1E3F1E3F1C63630F67781E333C7F7F1F3C3F0C3E",
INIT_03=> X"006E07183800000000000008000000000000000E07300C07001C00380007000C",
INIT_04=> X"0A14FF000014006E00000036240604FFFF14FF7600144208080800001000FF00",
INIT_05=> X"0C07C3C3001C0C0000FE00180E0E0C1CFF3E0000003C3E637C1833001C181800",
INIT_06=> X"1E0F38331E38073E00C37F3E60033F1F331E3807331E38071E7C0C633F1E6003",
INIT_07=> X"000700001E0000000C00001E00000018333E1C07337E380700000C333F7E3807",
INIT_08=> X"1C0036103E0606180018181800000000FF181800001805070036010101055500", -- 01
INIT_09=> X"330C000C0C0C33333306033C33330E63300000000C660C0C0636633E36361E00",
INIT_0A=> X"001C1806066333636333332D336633663667770666300C336646463666661E63",
INIT_0B=> X"083B0C180C0000000000000C000000000000000C06000006003600300006000C",
INIT_0C=> X"000881000208073B000000361206028181088109080825141C1C00002800811C",
INIT_0D=> X"00CC636333360E0000DB660C18180C3600410000CC364100C618336336181800",
INIT_0E=> X"3306000033000063631800630C180036003300000033000033360C1C00331C1C",
INIT_0F=> X"33063833333807400C333F3338071F7C0063000000C3000000000C0000C30000",
INIT_10=> X"3E00263F140C031800181818000000FF0018180000187515083671317377AA00", -- 02
INIT_11=> X"30183F060C0C333330031F3630300C73180000000C3C1806031C33037F361E00",
INIT_12=> X"0036180C063133366333330C06663366636F7F0636300C33031616660366337B",
INIT_13=> X"1C000C180C3F33636333333E3E3B6E3B1E1F330C66300E366E061E301E061E18",
INIT_14=> X"333F8136043E02000000002436040681817F8109047E12000808000008008122",
INIT_15=> X"0C66333366360C0000DB66000C0C3F36004D0000663659001C181E3E267E0000",
INIT_16=> X"333E333300333373363C1C1C1E3C33661E001E1E3F3F3F3F033300361E003636",
INIT_17=> X"003E00000000003E00000000000000300E1C0E0E1E3C1E1E1EFE1E1E1E3C1E1E",
INIT_18=> X"7F180F0814060618FFFF1FF80000FFFF00FFF8F81F1F25151C1C115111255500", -- 03
INIT_19=> X"1830000300003E1E181F30331C1C0C7B0C003F003FFF1806006E181E36000C00",
INIT_1A=> X"0063181806181E1C6B33330C0C3E333E637B7F061E300C3F031E1E66033E337B",
INIT_1B=> X"36003800071933366B33330C036E336633337F0C36300C6E330F333E333E3000",
INIT_1C=> X"3319814908036E00FF7F0C12360206818139813902030000080800001800810F",
INIT_1D=> X"063C7BDBCC1C0C0000DE660018060C1C00557E3F337C450036003F630F031800",
INIT_1E=> X"1B6633333333337B1C6636363366376F0C1E0C0C06060606337F1E63331E6363",
INIT_1F=> X"33663333333333733F1E1E1E1E1E1F3E0C180C0C336633330330303030603030",
INIT_20=> X"3E18060414030C18FFFF1FF800FFFF0000FFF8F81F1F2215080037363125AA00", -- 04
INIT_21=> X"0C1800060C0030330C33307F30060C6F060000000C3C1806003B0C307F000C00",
INIT_22=> X"00001830064C0C1C7F33330C18363B0663736B4636330C337316166603663F7B",
INIT_23=> X"63000C180C0C331C7F33330C1E66336633337F0C1E300C6633063F3303663E00",
INIT_24=> X"1E0C8179041E540000000C0000000081811C8109043E22001C08000008008102",
INIT_25=> X"03DFCCEC66001E0018D866000E1E0C00004D00306600450036180C6306031800",
INIT_26=> X"333E1E333333336F3666636333663F660C0C0C0C1E1E1E1E1E33337F3F337F7F",
INIT_27=> X"336633333333336B00333333333333330C180C0C3F7E3F3F03FE3E3E3E7C3E3E",
INIT_28=> X"1C00673F000000181800181800FF000000180018180020100000105010205500", -- 05
INIT_29=> X"000C3F0C0C0C18330C33333033230C67030C000C0C660C0C0033661F36000000",
INIT_2A=> X"0000186006660C36771E330C33661E063663636666330C336606463666663303",
INIT_2B=> X"63000C180C263E367F1E332C30063E3E33336B0C36330C663E06033333663300",
INIT_2C=> X"0C268109023044000000000000000081814E8109086055000808000A0A04810F",
INIT_2D=> X"33EC66F6333E001800D83E000000000000550030CC7E59001C183F3E677E1800",
INIT_2E=> X"63060C3333333367633C36361E3C3B360C0C0C0C0606060618333F63333F6363",
INIT_2F=> X"3E3E3E33333333670C333333333333330C180C0C030603031E33333333663333",
INIT_30=> X"08003F02000F0F1818001818FF00000000180018180020701C0010501020AA00", -- 06
INIT_31=> X"0C060018060C0E1E0C1E1E781E3F3F3E010C000C00000618006E630C36000C00",
INIT_32=> X"00001E401E7F1E63630C3F1E1E67380F1C63637F671E1E337C0F7F1F3C3F331E",
INIT_33=> X"7F000718383F3063360C6E181F0F30061E33631E67331E67300F1E6E1E3B6E00",
INIT_34=> X"0C3F8136001F00000000000000000081817F8176003F22000000150A04048122",
INIT_35=> X"1EF633F30000003000D8060000003F00004100000000410033180C633F181800",
INIT_36=> X"330F1E1E1E1E1E3E00181C1C0C18331F1E1E1E1E3F3F3F3F3073336333336363",
INIT_37=> X"3006307E7E7E7E3E0C1E1E1E1E1E331E1E3C1E1E1E3C1E1E30FE7E7E7EFC7E7E",
INIT_38=> X"000000000000001818001818FF00000000180018180000000000000000005500", -- 07
INIT_39=> X"0000000000000000000000000000000000000006000000000000000000000000",
INIT_3A=> X"FF00000000000000000000000000000000000000000000000000000000000000",
INIT_3B=> X"0000000000001F00000000000000780F00000000001E00001F00000000000000",
INIT_3C=> X"0000FF000000000000000000000000FFFF00FF0000000000000000000000FF1C",
INIT_3D=> X"00C3F0C00000001C0000030000000000003E000000003E001E000C0000180000",
INIT_3E=> X"0000000000000000000000000000000000000000000000001E00000000000000",
INIT_3F=> X"1F0F1E0000000001000000000000000000000000000000001C00000000000000")

--INITP_00=> X"0000000000000000000000000000000000000000000000000000000000000000",
--	INITP_01=> X"0000000000000000000000000000000000000000000000000000000000000000",
--	INITP_02=> X"0000000000000000000000000000000000000000000000000000000000000000",
--	INITP_03=> X"0000000000000000000000000000000000000000000000000000000000000000",
--	INITP_04=> X"0000000000000000000000000000000000000000000000000000000000000000",
--	INITP_05=> X"0000000000000000000000000000000000000000000000000000000000000000",
--	INITP_06=> X"0000000000000000000000000000000000000000000000000000000000000000",
--	INITP_07=> X"0000000000000000000000000000000000000000000000000000000000000000")
		
	port map (
		DO=>CGROM_DO,
		DI=>DI,
		ADDR=>CGROM_ADDR,
		CLK=>CGROM_CLK,
		EN=>CGROM_EN,
		REGCE=>REGCE,
		RST=>RST,
		WE=>WE
		);


end Behavioral;

