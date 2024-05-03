----------------------------------------------------------------------------------
-- Company: 
-- Engineer: Erik C. Quackenbush (erikcq@quackenbush.com)
-- 
-- Create Date:    15:52:44 04/18/2017 
-- Design Name: 
-- Module Name:    ANSI-terminal - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ANSI_terminal is
	Port (	
		keyboard_data				: in  STD_LOGIC_VECTOR (7 downto 0);
		keyboard_strobe			: in  STD_LOGIC;

		host_data_out				: out STD_LOGIC_VECTOR (7 downto 0);
		host_data_out_strobe		: out STD_LOGIC;
		host_data_out_wait		: in 	STD_LOGIC;
		host_out_reset				: out STD_LOGIC;

		host_data_in				: in  STD_LOGIC_VECTOR (7 downto 0);
		host_data_in_strobe		: out STD_LOGIC;
		host_data_in_ready		: in  STD_LOGIC;
		host_in_reset				: out STD_LOGIC;

		cursor_address				: out STD_LOGIC_VECTOR (12 downto 0);
		character_address			: in STD_LOGIC_VECTOR (12 downto 0);
		character_offset			: out STD_LOGIC_VECTOR (12 downto 0);

		character_data				: out STD_LOGIC_VECTOR (8 downto 0);
		character_attribute		: out STD_LOGIC_VECTOR (8 downto 0);

		pixel_address				: in  STD_LOGIC_VECTOR (14 downto 0);
		pixel_enable				: in  STD_LOGIC;
		pixel_data					: out STD_LOGIC_VECTOR(0 downto 0);

		mode_tall_characters		: out STD_LOGIC;
		mode_eighty_column		: out STD_LOGIC;
		mode_fifty_line			: out STD_LOGIC;
		mode_block_cursor			: out STD_LOGIC;
		clk_fifty					: in  STD_LOGIC;
		clk_pixel					: in  STD_LOGIC);
	end ANSI_terminal;

architecture Behavioral of ANSI_terminal is

 	COMPONENT FIFO64FWFT		-- generic 64 byte FWFT FIFO
 	  PORT (
     clk : IN STD_LOGIC;
     din : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
     wr_en : IN STD_LOGIC;
     rd_en : IN STD_LOGIC;
     dout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
     full : OUT STD_LOGIC;
     empty : OUT STD_LOGIC
   );
   END COMPONENT;


--
-- this is a 32768 bit ROM that is 1 bit wide.
--
COMPONENT ROMFONTS
  PORT (
    clka : IN STD_LOGIC;
    ena : IN STD_LOGIC;
    addra : IN STD_LOGIC_VECTOR(14 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(0 DOWNTO 0)
  );
END COMPONENT;


	COMPONENT CGRAM8K9B
	PORT(
	 clka : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(12 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(8 DOWNTO 0);
    clkb : IN STD_LOGIC;
    web : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addrb : IN STD_LOGIC_VECTOR(12 DOWNTO 0);
    dinb : IN STD_LOGIC_VECTOR(8 DOWNTO 0);
    doutb : OUT STD_LOGIC_VECTOR(8 DOWNTO 0)

		);		
	END COMPONENT;


COMPONENT CGWRITE -- write to CGRAM
	PORT (
	
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

		ramOffset			: out STD_LOGIC_VECTOR(12 downto 0);
		
		CGRAM_ADDR_CPU		: out STD_LOGIC_VECTOR(12 downto 0);
		CGRAM_OFFSET_CPU	: out STD_LOGIC_VECTOR(12 downto 0);
		CGRAM_DI_CPU		: out STD_LOGIC_VECTOR(8 downto 0);
		CGRAM_EN_CPU		: out STD_LOGIC;
		CGRAM_WE_CPU		: out STD_LOGIC_VECTOR(0 downto 0);

		CGATTR_DI_CPU		: out STD_LOGIC_VECTOR(8 downto 0);
		CGATTR_EN_CPU		: out STD_LOGIC;
		CGATTR_WE_CPU		: out STD_LOGIC_VECTOR(0 downto 0);

		CG_attr_bit			: IN  STD_LOGIC;
		CG_font_bit			: IN  STD_LOGIC;
		
		CURSOR_REG		: out STD_LOGIC_VECTOR(12 downto 0)
	);
end component;

component kcpsm6 
    generic(                 hwbuild : std_logic_vector(7 downto 0) := X"00";
                    interrupt_vector : std_logic_vector(11 downto 0) := X"3FF";
             scratch_pad_memory_size : integer := 64); -- we could increase this to 256 but we don't need it
    port (                   address : out std_logic_vector(11 downto 0);
                         instruction : in std_logic_vector(17 downto 0);
                         bram_enable : out std_logic;
                             in_port : in std_logic_vector(7 downto 0);
                            out_port : out std_logic_vector(7 downto 0);
                             port_id : out std_logic_vector(7 downto 0);
                        write_strobe : out std_logic;
                      k_write_strobe : out std_logic;
                         read_strobe : out std_logic;
                           interrupt : in std_logic;
                       interrupt_ack : out std_logic;
                               sleep : in std_logic;
                               reset : in std_logic;
                                 clk : in std_logic);
  end component;
--
-- Development Program Memory
-- this is the ROM program for the PicoBlaze 6.
--

  component quackterm
    generic(             C_FAMILY : string := "S6"; -- SPARTAN6
                C_RAM_SIZE_KWORDS : integer := 2; -- 2048 x 18 bit wide program ROM
             C_JTAG_LOADER_ENABLE : integer := 1); -- we allow programming the ROM via JTAG
    Port (      address : in std_logic_vector(11 downto 0);
            instruction : out std_logic_vector(17 downto 0);
                 enable : in std_logic;
                    rdl : out std_logic;                    
                    clk : in std_logic);
  end component;
	

	constant cgrom_di 			: std_logic_vector(0 downto 0) := (others => '0');
	signal cgrom_wraddr			: std_logic_vector(13 downto 0) := (others => '0');

	constant true_bit				: std_logic := '1';
	constant false_bit 			: std_logic :='0';

	signal pixel_tall_set 		: std_logic :='0';
	signal pixel_tall_clr	 	: std_logic :='0';

	signal pixel_eighty_set		: std_logic := '0';
	signal pixel_eighty_clr		: std_logic := '0';

	signal pixel_fifty_set		: std_logic := '0';
	signal pixel_fifty_clr		: std_logic := '0';

	signal pixel_block_set		: std_logic := '0';
	signal pixel_block_clr		: std_logic := '0';
--
	signal CG_attr_bit			: std_logic := '0';
	signal CG_font_bit			: std_logic := '0';

	signal extended_bits_set	: std_logic := '0';

-- Signals used to connect KCPSM6
--
	signal address					: std_logic_vector(11 downto 0);
	signal instruction			: std_logic_vector(17 downto 0);
	signal bram_enable			: std_logic;
	signal in_port					: std_logic_vector(7 downto 0);
	signal out_port				: std_logic_vector(7 downto 0);
	signal port_id					: std_logic_vector(7 downto 0);
	signal write_strobe			: std_logic;
	signal k_write_strobe		: std_logic;
	signal read_strobe			: std_logic;
	signal interrupt				: std_logic;
	signal interrupt_ack			: std_logic;
	signal kcpsm6_sleep			: std_logic;
	signal kcpsm6_reset			: std_logic;
	signal rdl						: std_logic;
--
-- Signals for UART primary FIFO
--
	signal uart_rx_data_flag	: std_logic;

	signal uart_fifo_din 		: std_logic_vector(7 downto 0) := (others =>'0');
	signal uart_fifo_wr			: std_logic := '0';
	signal uart_fifo_rd			: std_logic := '0';
	signal uart_fifo_dout		: std_logic_vector(7 downto 0) := (others =>'0');
	signal uart_fifo_full		: std_logic := '0';
	signal uart_fifo_empty		: std_logic := '0';

	signal uart_data_next		: std_logic := '0';
	signal uart_data_register	: std_logic :='0';

	type fifo_state is (idle,strobe_in, strobe_out);

	signal uart_state_register	: fifo_state := idle;
	signal uart_state_next		: fifo_state := idle;

	signal keyboard_fifo_rd		: std_logic := '0';
	signal keyboard_fifo_dout	: std_logic_vector(7 downto 0):= (others=>'0');
	signal keyboard_fifo_full	: std_logic := '0';
	signal keyboard_fifo_empty	: std_logic := '0';


--
-- relevant signals for the RGB DVI, CGRAM, and CGRAM
-- to glue things together
--
	signal ramaddr		: std_logic_vector(12 downto 0) := (others =>'0');
	signal ramchar		: std_logic_vector( 7 downto 0) := (others =>'0');
	signal ramattr		: std_logic_vector( 8 downto 0) := (others =>'0');
	
	signal cursoraddr : std_logic_vector(12 downto 0) := (others=>'0');

	signal cgaddrHIGH		: std_logic_vector(4 downto 0) := (others=>'0');
	signal cgaddrLOW		: std_logic_vector(7 downto 0) := (others=>'0');
	signal cgoffsetHIGH	: std_logic_vector(4 downto 0) := (others=>'0');
	signal cgoffsetLOW	: std_logic_vector(7 downto 0) := (others=>'0');
	signal cgdata			: std_logic_vector(7 downto 0) := (others=>'0');
	signal cgattr			: std_logic_vector(7 downto 0) := (others=>'0');

	signal port_id_reg	: std_logic_vector(7 downto 0) := (others=>'0'); -- for chipscope only
	signal out_port_reg	: std_logic_vector(7 downto 0) := (others=>'0'); -- for chipscope only

	signal cgenHIGH			: std_logic:='0';
	signal cgenLOW				: std_logic:='0';
	signal cgoffsetenHIGH	: std_logic:='0';
	signal cgoffsetenLOW		: std_logic:='0';
	signal CGenData			: std_logic:='0';
	signal CGenAttr			: std_logic:='0';
		
	signal cursor_reg	: STD_LOGIC_VECTOR(12 downto 0):= (others=>'0');
		
	signal cgRAM_DI_CPU		: STD_LOGIC_VECTOR(8 downto 0) := (others=>'0');
	signal cgRAM_DO_CPU		: STD_LOGIC_VECTOR(8 downto 0) := (others=>'0');
	signal cgRAM_OFFSET_CPU	: STD_LOGIC_VECTOR(12 downto 0) := (others=>'0');

	signal cgRAM_CLK_CPU		: STD_LOGIC:='0';
	signal cgRAM_EN_CPU		: STD_LOGIC:='0';
	signal cgRAM_WE_CPU		: STD_LOGIC_VECTOR(0 downto 0);

	signal cgATTR_EN_CPU		: STD_LOGIC:='0';
	signal cgATTR_WE_CPU		: STD_LOGIC_VECTOR(0 downto 0);

	
	signal cgATTR_DI_CPU		: STD_LOGIC_VECTOR(8 downto 0) := (others=>'0');
	signal cgATTR_DO_CPU		: STD_LOGIC_VECTOR(8 downto 0) := (others=>'0');
	
	signal di_null : std_logic_vector(0 downto 0);


begin

--	host_out_reset <='0';
--	host_in_reset  <='0';


  processor: kcpsm6
    generic map (                 hwbuild => X"42",    -- 42 hex is ASCII Character "B"
                         interrupt_vector => X"7F0",   
                  scratch_pad_memory_size => 64)
    port map(      address => address,
               instruction => instruction,
               bram_enable => bram_enable,
                   port_id => port_id,
              write_strobe => write_strobe,
            k_write_strobe => k_write_strobe,
                  out_port => out_port,
               read_strobe => read_strobe,
                   in_port => in_port,
                 interrupt => interrupt,
             interrupt_ack => interrupt_ack,
                     sleep => kcpsm6_sleep,
                     reset => kcpsm6_reset,
                       clk => clk_fifty);
 


  --
  -- Reset connected to JTAG Loader enabled Program Memory 
  --

  kcpsm6_reset <= rdl;


  --
  -- Unused signals tied off until required.
  --

  kcpsm6_sleep <= '0';
  interrupt <= interrupt_ack;

  
  --
  -- Development Program Memory 
  --   JTAG Loader enabled for rapid code development. 
  --

  program_rom: quackterm
    generic map(             C_FAMILY => "S6", 
                    C_RAM_SIZE_KWORDS => 2,	-- 2K by 18 consumes 2 block RAMs but we've exceeded the program size for one.
                 C_JTAG_LOADER_ENABLE => 1)
    port map(      address => address,      
               instruction => instruction,
                    enable => bram_enable,
                       rdl => rdl,
                       clk => clk_fifty);


--
-- the input and output ports of the main picoblaze processor
--
 
  process(clk_fifty)
  begin
		if rising_edge(clk_fifty) then
			if port_id=x"00" then       					-- Read UART status at port address 00 hex
				in_port(0) <= '0'; -- uart_tx_data_present;
				in_port(1) <= '0'; -- uart_tx_half_full;
				in_port(2) <= host_data_out_wait; --uart_tx_full; 
				--in_port(3) <= uart_rx_data_present;
				--in_port(4) <= uart_rx_half_full;
				--in_port(5) <= uart_rx_full;
				--in_port(7 downto 6) <= (others=>'0');
				in_port(7 downto 2) <= (others=>'0');
			--elsif port_id=x"01" then        				-- Read UART_RX6 data at port address 01 hex; note that this is obsolete now that we have a primary FIFO
			--in_port <= uart_rx_data_out;
			elsif port_id=x"05" then						-- read from character memory at port address 05
				in_port <= cgram_do_cpu(7 downto 0);
			elsif port_id=x"0A" then						-- read from attribute memory at port 0A
				in_port <= cgattr_do_cpu(7 downto 0);
			elsif port_id=x"0C" then						-- read UART primary FIFO status at port 0C
				in_port(0) <= uart_fifo_empty;
				in_port(1) <= uart_fifo_full;
				in_port(7 downto 2) <= (others=>'0');
			elsif port_id=x"0D" then						-- read UART primary FIFO data at port 0D
				in_port <= uart_fifo_dout;
			elsif port_id=x"40" then						-- read keyboard FIFO data at port 40
				in_port <= keyboard_fifo_dout;
			elsif port_id=x"41" then						-- read keyboard FIFO status at port 41
				in_port(0) <= keyboard_fifo_empty;
				in_port(1) <= keyboard_fifo_full;
				in_port(7 downto 2) <= (others=>'0');
			elsif port_id=x"50" then						-- read underline and font bits
				in_port(0) <= cgram_do_cpu(8);
				in_port(1) <= cgattr_do_cpu(8);
				in_port(7 downto 3) <= (others=>'0');
			else
				in_port <= "XXXXXXXX";
			end if;
		
			if (read_strobe = '1') and (port_id = x"0D") then
				uart_fifo_rd <= '1';
			else
				uart_fifo_rd <= '0';	
			end if;

			if (read_strobe = '1') and (port_id = x"40") then
				keyboard_fifo_rd <= '1';
			else
				keyboard_fifo_rd <= '0';	
			end if;

    end if;

  end process;

--
-- UART_FIFO_transfer is a state machine which clocks data
-- from the UART's small built in FIFO to the larger primary FIFO.
--

UART_FIFO_transfer: process(clk_fifty,uart_state_register,host_data_in_ready,uart_fifo_full) 	-- transfer from the non-empty 16 byte FIFO to the bigger 64 byte FIFO.
begin

		case uart_state_register is
			when idle =>
				if host_data_in_ready ='1' and uart_fifo_full='0' then
					uart_fifo_wr <= '1';		
					host_data_in_strobe <= '0';
					uart_state_next <= strobe_in;
				else
					uart_fifo_wr <= '0';
					host_data_in_strobe <= '0';
					uart_state_next <= idle;
				end if;
			when strobe_in =>
				uart_fifo_wr <= '0';
				host_data_in_strobe <= '1';
				uart_state_next <= strobe_out;
			when strobe_out =>
				uart_fifo_wr <= '0';
				host_data_in_strobe <= '0';
				uart_state_next <= idle;
		end case;

end process UART_FIFO_transfer;

UART_FIFO_register: process(clk_fifty)
begin
	if rising_edge(clk_fifty) then
		uart_state_register <= uart_state_next;
	else
	end if;
	
end process UART_FIFO_register;

  --
  -----------------------------------------------------------------------------------------
  -- General Purpose Output Ports 
  -----------------------------------------------------------------------------------------
  --
  -- In this simple example there is only one output port and that it involves writing 
  -- directly to the FIFO buffer within 'uart_tx6'. As such the only requirements are to 
  -- connect the 'out_port' to the transmitter macro and generate the write pulse.
  -- 

output_ports: process(clk_fifty,out_port,write_strobe,port_id)
begin

	CGdata <= out_port;
	CGattr <= out_port;
	host_data_out <= out_port;

	pixel_tall_set<='0';
	pixel_tall_clr<='0';

	pixel_eighty_set<='0';
	pixel_eighty_clr<='0';

	pixel_fifty_set<='0';
	pixel_fifty_clr<='0';

	if port_id = x"01" then	-- port 01 is the UART TX buffer
		host_data_out_strobe <= write_strobe;
	else
		host_data_out_strobe <= '0';
	end if;

	if port_id=x"02" then -- port 02 is the high 3 bits of the CG write address
		CGaddrHIGH <= out_port(4 downto 0);
		CGenHIGH <= write_strobe;
	else
		CGaddrHIGH <= "00000";
		CGenHIGH <= '0';
	end if;
	
	if port_id=x"03" then -- port 03 is the low 8 bits of the CG write address
		CGaddrLOW <= out_port;
		CGenLOW <= write_strobe;
	else
		CGaddrLOW <= x"00";
		CGenLOW <= '0';
	end if;

	if port_id=x"04" then -- port 04 is the CG data address
		CGenData <= write_strobe;
	else
		CGenData <= '0';
	end if;	

	if port_id=x"09" then -- port 08 is the CG attribute address
		CGenAttr <= write_strobe;
	else
		CGenAttr <= '0';
	end if;

	if port_id=x"0B" then -- port 0B bit 0 sets the pixel_tall bit, 1 sets the 80 column width, 2 sets the 50/25 line height
		if write_strobe='1' then
			if out_port(0)='1' then	-- there is undoubtedly a more elegant way to do this, but I haven't learned it yet.
				pixel_tall_set<='1';
				pixel_tall_clr<='0';
			else
				pixel_tall_set<='0';
				pixel_tall_clr<='1';
			end if;

			if out_port(1)='1' then	-- there is undoubtedly a more elegant way to do this, but I haven't learned it yet.
				pixel_eighty_set<='1';
				pixel_eighty_clr<='0';
			else
				pixel_eighty_set<='0';
				pixel_eighty_clr<='1';
			end if;

			if out_port(2)='1' then	-- there is undoubtedly a more elegant way to do this, but I haven't learned it yet.
				pixel_fifty_set<='1';
				pixel_fifty_clr<='0';
			else
				pixel_fifty_set<='0';
				pixel_fifty_clr<='1';
			end if;

			if out_port(3)='1' then	-- there is undoubtedly a more elegant way to do this, but I haven't learned it yet.
				pixel_block_set<='1';
				pixel_block_clr<='0';
			else
				pixel_block_set<='0';
				pixel_block_clr<='1';
			end if;

		end if; 
	end if;
	
	if port_id=x"51" then
		extended_bits_set<='1';
	else
		extended_bits_set<='0';
	end if;
		
	if port_id=x"0E" then -- high byte of scroll offset address
		CGoffsetHIGH <= out_port(4 downto 0);
		CGoffsetenHIGH <= write_strobe;
	else
		CGoffsetHIGH <= "00000";
		CGoffsetenHIGH <= '0';
	end if;
	
	if port_id=x"0F" then -- low byte of scroll offset address
		CGoffsetLOW <= out_port;
		CGoffsetenLOW <= write_strobe;
	else
		CGoffsetLOW <= x"00";
		CGoffsetenLOW <= '0';
	end if;
		

end process output_ports;

Video_Mode : process(clk_fifty)
begin
	if rising_edge(clk_fifty) then

		if extended_bits_set='1' then
			CG_font_bit<=out_port(0);
			CG_attr_bit<=out_port(1);
		end if;
		
		if pixel_tall_set='1' then
			mode_tall_characters<='1';
		end if;
		
		if pixel_tall_clr='1' then
			mode_tall_characters<='0';
		end if;
		
		if pixel_eighty_set='1' then
			mode_eighty_column<='1';
		end if;
		
		if pixel_eighty_clr='1' then
			mode_eighty_column<='0';
		end if;

		if pixel_fifty_set='1' then
			mode_fifty_line<='1';
		end if;
		
		if pixel_fifty_clr='1' then
			mode_fifty_line<='0';
		end if;	

		if pixel_block_set='1' then
			mode_block_cursor<='1';
		end if;
		
		if pixel_block_clr='1' then
			mode_block_cursor<='0';
		end if;	
		
	end if;
end process Video_mode;
  --
  -----------------------------------------------------------------------------------------
  -- Constant-Optimised Output Ports 
  -----------------------------------------------------------------------------------------
  --
  -- One constant-optimised output port is used to facilitate resetting of the UART macros.
  --

  constant_output_ports: process(clk_fifty)
  begin
		if rising_edge(clk_fifty) then
--    if CLK_fifty'event and CLK_fifty = '1' then
      if k_write_strobe = '1' then

        if port_id(0) = '1' then
          host_in_reset <= out_port(0);
          host_out_reset <= out_port(1);
        end if;


      end if;
    end if; 
  end process constant_output_ports;

I_CGWRITE: CGWRITE
	PORT MAP(

		clock_fifty => clk_fifty,

		CGaddrHIGH	=> cgaddrHIGH,
		CGaddrLOW	=> cgaddrLOW,
		CGoffsetHIGH=> cgoffsetHIGH,
		CGoffsetLOW => cgoffsetLOW,
		CGdata		=> cgdata,
		CGattr		=> cgattr,

		CGoffsetenHIGH		=> cgoffsetenHIGH,
		CGoffsetenLOW		=> cgoffsetenLOW,
		CGenHIGH		=> cgenHIGH,
		CGenLOW		=> cgenLOW,
		CGenData		=> cgenData,
		CGenAttr		=> cgenAttr,
		
		CGRAM_ADDR_CPU	=> cursor_address,--cgRAM_ADDR_CPU,
		CGRAM_OFFSET_CPU	=> cgRAM_OFFSET_CPU,
		CGRAM_DI_CPU	=> cgRAM_DI_CPU,
		CGRAM_EN_CPU	=> cgRAM_EN_CPU,
		CGRAM_WE_CPU	=> cgRAM_WE_CPU,
		
		ramOffset		=> character_offset,
		
		
		CGATTR_DI_CPU	=> cgATTR_DI_CPU,
		CGATTR_EN_CPU	=> cgATTR_EN_CPU,
		CGATTR_WE_CPU	=> cgATTR_WE_CPU,

		CG_attr_bit		=> CG_attr_bit,
		CG_font_bit		=> CG_font_bit,

		CURSOR_REG		=> cursor_reg
	);
     
I_UARTFIFO: FIFO64FWFT
	PORT MAP (
		clk	=> clk_fifty,
		din	=> host_data_in,
		wr_en => uart_fifo_wr,
		rd_en => uart_fifo_rd,
		dout	=> uart_fifo_dout,
		full	=> uart_fifo_full,
		empty	=> uart_fifo_empty
		);

I_CGRAM: CGRAM8K9B
 PORT MAP(
		addra=> character_address,
		douta	=> character_data,
		dina	=> (others=>'0'), -- we never write on the VGA side
		clka 	=> clk_pixel,
		wea	=> (others=>'0'), -- we never write on the VGA side

		dinb	=> cgram_di_cpu,
		doutb	=> cgram_do_cpu,
		web	=> CGRAM_WE_CPU,		--(others=>'1'), -- writes are enabled on the CPU side (always? we need to fix this)
		addrb	=> cgram_offset_cpu,
		clkb	=> clk_fifty
		
	);

I_CGATTRIBUTERAM: CGRAM8K9B
 PORT MAP(
		addra=> character_address,
		douta	=> character_attribute,
		dina	=> (others=>'0'), -- we never write on the VGA side
		clka 	=> clk_pixel,
		wea	=> (others=>'0'), -- we never write on the VGA side

		dinb	=> cgattr_di_cpu,
		doutb	=> cgattr_do_cpu,
		web	=> CGattr_WE_CPU,		--(others=>'1'), -- writes are enabled on the CPU side (always? we need to fix this)
		addrb	=> cgram_offset_cpu,
		clkb	=> clk_fifty
		);

I_CGROM: ROMFONTS
  PORT MAP(
    clka		=> clk_pixel,
    ena		=> pixel_enable,
    addra	=> pixel_address,
    douta 	=> pixel_data
  );


I_KEYBOARDFIFO: FIFO64FWFT
	PORT MAP (
		clk	=> clk_fifty,
		din	=> keyboard_data,
		wr_en => keyboard_strobe,
		rd_en => keyboard_fifo_rd,
		dout	=> keyboard_fifo_dout,
		full	=> keyboard_fifo_full,
		empty	=> keyboard_fifo_empty
		);

end Behavioral;

