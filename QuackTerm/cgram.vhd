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

entity CGRAM is


Port (

	CGRAM_DI_CPU 		: in STD_LOGIC_VECTOR(7 downto 0);
	CGRAM_DO_CPU 		: out STD_LOGIC_VECTOR(7 downto 0);
	CGRAM_ADDR_CPU 	: in STD_LOGIC_VECTOR(10 downto 0); -- change this to (11 downto 0) once we have a full character set
	CGRAM_WE_CPU		: in STD_LOGIC_VECTOR(0 downto 0);
	CGRAM_CLK_CPU		: in STD_LOGIC;
	CGRAM_EN_CPU		: in STD_LOGIC;

	REGCE_CPU			: in STD_LOGIC;
	RST_CPU				: in STD_LOGIC;

	CGRAM_DI_VGA 		: in STD_LOGIC_VECTOR(7 downto 0);
	CGRAM_DO_VGA 		: out STD_LOGIC_VECTOR(7 downto 0);
	CGRAM_ADDR_VGA 	: in STD_LOGIC_VECTOR(11 downto 0);
	CGRAM_WE_VGA		: in STD_LOGIC_VECTOR(0 downto 0);
	CGRAM_CLK_VGA		: in STD_LOGIC;
	CGRAM_EN_VGA		: in STD_LOGIC;

	REGCE_VGA			: in STD_LOGIC;
	RST_VGA				: in STD_LOGIC
	);

end CGRAM;

architecture Behavioral of CGRAM is

begin
BRAM_TDP_MACRO_inst: BRAM_TDP_MACRO
generic map (
	BRAM_SIZE=>"18Kb",
	DEVICE=>"SPARTAN6",
	WRITE_WIDTH_A=>8,
	WRITE_WIDTH_B=>8,
	READ_WIDTH_A=>8,
	READ_WIDTH_B=>8,
	DOA_REG=>0,
	DOB_REG=>0,
	INIT_FILE=>"NONE",
	SIM_COLLISION_CHECK=>"ALL",
	SIM_MODE=>"SAFE",
	SRVAL_A=>X"00000000000000000",
	SRVAL_B=>X"00000000000000000",
	INIT_A=>X"00000000000000000",
	INIT_B=>X"00000000000000000"
	)
		
	port map (
		DIA=>CGRAM_DI_CPU,
		DOA=>CGRAM_DO_CPU,
		ADDRA=>CGRAM_ADDR_CPU,
		WEA=>CGRAM_WE_CPU,
		CLKA=>CGRAM_CLK_CPU,
		ENA=>CGRAM_EN_CPU,
		RSTA=>RST_CPU,
		REGCEA=>REGCE_CPU, 

		DIB => CGRAM_DI_VGA,
		DOB =>CGRAM_DO_VGA,
		ADDRB =>CGRAM_ADDR_VGA,
		WEB =>CGRAM_WE_VGA,
		CLKB =>CGRAM_CLK_VGA,
		ENB =>CGRAM_EN_VGA,
	   RSTB=>RST_VGA,
		REGCEB=>REGCE_VGA

		);


end Behavioral;

