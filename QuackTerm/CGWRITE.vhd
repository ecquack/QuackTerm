----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Erik C. Quackenbush erikcq@quackenbush.com
-- 
-- Create Date:    10:48:26 02/21/2017 
-- Design Name: 
-- Module Name:    CGWRITE - Behavioral 
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity CGWRITE is
port(
		clock_fifty 		: IN std_logic;
		CGaddrHIGH			: IN std_logic_vector(4 downto 0);
		CGaddrLOW			: IN std_logic_vector(7 downto 0);
		CGoffsetHIGH		: IN std_logic_vector(4 downto 0);
		CGoffsetLOW			: IN std_logic_vector(7 downto 0);
		CGdata				: IN std_logic_vector(7 downto 0);
		CGattr				: IN std_logic_vector(7 downto 0);

		CGenHIGH				: IN std_logic;
		CGenLOW				: IN std_logic;
		CGoffsetenHIGH		: IN std_logic;
		CGoffsetenLOW		: IN std_logic;
		CGenData				: IN std_logic;
		CGenAttr				: IN std_logic;
		
		CGRAM_DI_CPU		: out STD_LOGIC_VECTOR(8 downto 0);
		CGRAM_ADDR_CPU		: out STD_LOGIC_VECTOR(12 downto 0);
		CGRAM_OFFSET_CPU	: out STD_LOGIC_VECTOR(12 downto 0);
		CGRAM_EN_CPU		: out STD_LOGIC;
		CGRAM_WE_CPU		: out STD_LOGIC_VECTOR(0 downto 0);

		ramOffset			: out STD_LOGIC_VECTOR(12 downto 0);


		CGATTR_DI_CPU		: out STD_LOGIC_VECTOR(8 downto 0);
		CGATTR_EN_CPU		: out STD_LOGIC;
		CGATTR_WE_CPU		: out STD_LOGIC_VECTOR(0 downto 0);
		
		CURSOR_REG			: out STD_LOGIC_VECTOR(12 downto 0);
		
		CG_attr_bit			: IN  STD_LOGIC;
		CG_font_bit			: IN  STD_LOGIC
	);

end CGWRITE;

architecture Behavioral of CGWRITE is

signal CG_address_reg	: std_logic_vector(12 downto 0):= (others=>'0');
signal CG_offset_reg		: std_logic_vector(12 downto 0):= (others=>'0');
--signal CG_data_reg		: std_logic_vector(7 downto 0):= (others=>'0');
--signal CG_attr_reg		: std_logic_vector(7 downto 0):= (others=>'0');
--signal CG_attr_bit		: std_logic := '0';
--signal CG_font_bit		: std_logic := '0';


begin

--
-- we have a register that contains the write address for the CGRAM.
-- we clock the high byte into the upper portion of the address register on the rising edge of high enable
-- we clock the low byte on low enable
-- we clock the data byte on data enable and also clock the RAM
--



process(clock_fifty,CGenHIGH,CGenLOW,CGenData,CG_address_reg,
			CGData,CGenAttr, CGattr, CG_attr_bit,CG_offset_reg)
		--CG_data_reg,CG_attr_reg)
	begin
	
		if rising_edge(clock_fifty) then
			if CGenHIGH= '1' then -- rising edge
				CG_address_reg(12 downto 8) <= CGaddrHIGH;
			end if;
		
			if CGenLOW= '1' then
				CG_address_reg(7 downto 0) <= CGaddrLOW;
			end if;
			
			if CGoffsetenHIGH='1' then 
				CG_offset_reg(12 downto 8) <= CGoffsetHIGH;
			end if;	

			if CGoffsetenLOW='1' then 
				CG_offset_reg(7 downto 0) <= CGoffsetLOW;
			end if;	
			
		
--			if CGenData= '1' then
--				CG_data_reg <= CGdata;
--			end if;

--			if  CGenAttr= '1' then
--				CG_attr_reg <= CGattr;
--			end if;

		end if;

		CURSOR_REG<=CG_address_reg; -- right now the cursor is the same as the CGRAM write address. This could change.

		CGRAM_ADDR_CPU		<=CG_address_reg;
		CGRAM_OFFSET_CPU	<=CG_address_reg + CG_offset_reg; -- here's where we calculate the actual address
		ramOffset			<=CG_offset_reg;
		CGRAM_DI_CPU		<= CG_font_bit & CGdata; --CG_data_reg;
		CGRAM_EN_CPU		<= '1' ;--CGenData; -- we always read
		CGRAM_WE_CPU(0)	<= CGenData;

		CGATTR_DI_CPU		<= CG_attr_bit & CGattr;--CG_attr_reg;
		CGATTR_EN_CPU		<= '1'; -- we always read
		CGATTR_WE_CPU(0)	<= CGenAttr;

	end process;

end Behavioral;

