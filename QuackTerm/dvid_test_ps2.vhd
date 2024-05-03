----------------------------------------------------------------------------------
-- Engineer: Erik Quackenbush erikcq@quackenbush.com
-- 
-- Description: ANSI terminal emulation coreware
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
Library UNISIM;
use UNISIM.vcomponents.all;
use IEEE.numeric_std.ALL;

entity dvid_test is
    Port ( clk_50	: in  STD_LOGIC;							-- 50 mhz clock oscillator pin
           tmds   : out STD_LOGIC_VECTOR(3 downto 0);	-- tmds (HDMI) channel pins
           tmdsb  : out STD_LOGIC_VECTOR(3 downto 0); -- tmds (HDMI) channel pins
			  uart_tx	: out STD_LOGIC;						-- USB RS232 transmit pin
			  uart_rx	: in	STD_LOGIC;						-- USB RS232 receive pin
			  PS2_CLK	: inout STD_LOGIC;						-- PS/2 "A" on arcade megawing
			  PS2_DATA	: inout STD_LOGIC
			  );
end dvid_test;

architecture Behavioral of dvid_test is
	
   component clocking
   port (
      -- Clock in ports
      CLK_50      : in     std_logic;
      -- Clock out ports
		CLK_fifty	: out 	std_logic;
      CLK_TMDS0   : out    std_logic;
      CLK_TMDS90  : out    std_logic;
      CLK_pixel     : out    std_logic
   );
   end component;

   COMPONENT dvid
   PORT(
      clk_tmds0  : IN std_logic;
      clk_tmds90 : IN std_logic;
      clk_pixel  : IN std_logic;
      red_p      : IN std_logic_vector(7 downto 0);
      green_p    : IN std_logic_vector(7 downto 0);
      blue_p     : IN std_logic_vector(7 downto 0);
      blank      : IN std_logic;
      hsync      : IN std_logic;
      vsync      : IN std_logic;          
      red_s      : OUT std_logic;
      green_s    : OUT std_logic;
      blue_s     : OUT std_logic;
      clock_s    : OUT std_logic
      );
   END COMPONENT;

	COMPONENT CGROM
	PORT(
		CGROM_ADDR		: IN std_logic_vector(13 downto 0);
		CGROM_CLK		: IN std_logic;
		CGROM_DO			: OUT std_logic_vector;
		
		CGROM_EN			: IN std_logic;

		DI					: in STD_LOGIC_VECTOR(0 downto 0);
		REGCE				: in STD_LOGIC;
		RST				: in STD_LOGIC;
		WE					: in STD_LOGIC_VECTOR(0 downto 0)
	);
	END COMPONENT;
			
	COMPONENT CGRAM8K
	PORT(
	 clka : IN STD_LOGIC;
    wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addra : IN STD_LOGIC_VECTOR(12 DOWNTO 0);
    dina : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    clkb : IN STD_LOGIC;
    web : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
    addrb : IN STD_LOGIC_VECTOR(12 DOWNTO 0);
    dinb : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    doutb : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
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

	COMPONENT io_ps2_keyboard
	port (
		clk: in std_logic;
		reset : in std_logic := '0';
		
		-- PS/2 connector
		ps2_clk_in: in std_logic;
		ps2_dat_in: in std_logic;
		ps2_clk_out: out std_logic;
		ps2_dat_out: out std_logic;

		-- LED status
		caps_lock : in std_logic := '0';
		num_lock : in std_logic := '0';
		scroll_lock : in std_logic := '0';

		-- Read scancode
		trigger : out std_logic;
		scancode : out std_logic_vector(7 downto 0)
	);
	END COMPONENT;
		
   COMPONENT ps2_keyboard
	PORT(
    clk          : IN  STD_LOGIC;                     --system clock
    ps2_clk      : IN  STD_LOGIC;                     --clock signal from PS/2 keyboard
    ps2_data     : IN  STD_LOGIC;                     --data signal from PS/2 keyboard
    ps2_code_new : OUT STD_LOGIC;                     --flag that new PS/2 code is available on ps2_code bus
    ps2_code     : OUT STD_LOGIC_VECTOR(7 DOWNTO 0) --code received from PS/2
	 );
	END COMPONENT;	

 	COMPONENT PS2FIFO
 	  PORT (
     clk : IN STD_LOGIC;
     rst : IN STD_LOGIC;
     din : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
     wr_en : IN STD_LOGIC;
     rd_en : IN STD_LOGIC;
     dout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
     full : OUT STD_LOGIC;
     empty : OUT STD_LOGIC
   );
   END COMPONENT;
		
	COMPONENT vga
   generic (
      hRez        : natural;
      hStartSync  : natural;
      hEndSync    : natural;
      hMaxCount   : natural;
      hsyncActive : std_logic;

      vRez        : natural;
      vStartSync  : natural;
      vEndSync    : natural;
      vMaxCount   : natural;
      vsyncActive : std_logic
    );

   PORT(
      pixelClock 	: IN std_logic;          
		pixelTall	: IN std_logic;
		pixelEighty	: IN std_logic;
		pixelFifty	: IN std_logic;
      Red 			: OUT std_logic_vector(7 downto 0);
      Green 		: OUT std_logic_vector(7 downto 0);
      Blue 			: OUT std_logic_vector(7 downto 0);
      hSync 		: OUT std_logic;
      vSync 		: OUT std_logic;
      blank 		: OUT std_logic;
		-- interface to CGROM (character bitmaps)
		romADDR 		: OUT std_logic_vector(13 downto 0);
--		romCLOCK		: OUT std_logic;
		romENABLE	: OUT std_logic;
		romPIXEL		: IN	std_logic_vector(0 downto 0);
		-- interface to CGRAM (ASCII characters)
		ramADDR 		: OUT std_logic_vector(12 downto 0);
		ramCHAR		: IN std_logic_vector(7 downto 0);
		ramATTR		: IN std_logic_vector(8 downto 0);
		ramOFFSET	: IN std_logic_vector(12 downto 0);
		cursorADDR	: IN std_logic_vector(12 downto 0)
		
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
		CGRAM_DI_CPU		: out STD_LOGIC_VECTOR(7 downto 0);
		CGRAM_EN_CPU		: out STD_LOGIC;
		CGRAM_WE_CPU		: out STD_LOGIC_VECTOR(0 downto 0);

		CGATTR_DI_CPU		: out STD_LOGIC_VECTOR(8 downto 0);
		CGATTR_EN_CPU		: out STD_LOGIC;
		CGATTR_WE_CPU		: out STD_LOGIC_VECTOR(0 downto 0);

		
		CURSOR_REG		: out STD_LOGIC_VECTOR(12 downto 0)
	);
	
END COMPONENT;

--
-- declaration of KCPSM6
-- (this is the PicoBlaze-6 microprocessor)

--


  component kcpsm6 
    generic(                 hwbuild : std_logic_vector(7 downto 0) := X"00";
                    interrupt_vector : std_logic_vector(11 downto 0) := X"3FF";
             scratch_pad_memory_size : integer := 64); -- we may want to increase this to 256
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

  component uart_control
    generic(             C_FAMILY : string := "S6"; -- SPARTAN6
                C_RAM_SIZE_KWORDS : integer := 1; -- 1024 x 18 bit wide program ROM (we could go to 2k)
             C_JTAG_LOADER_ENABLE : integer := 1); -- we allow programming the ROM via JTAG
    Port (      address : in std_logic_vector(11 downto 0);
            instruction : out std_logic_vector(17 downto 0);
                 enable : in std_logic;
                    rdl : out std_logic;                    
                    clk : in std_logic);
  end component;


--
-- UART Transmitter with integral 16 byte FIFO buffer
--

  component uart_tx6 
    Port (             data_in : in std_logic_vector(7 downto 0);
                  en_16_x_baud : in std_logic;
                    serial_out : out std_logic;
                  buffer_write : in std_logic;
           buffer_data_present : out std_logic;
              buffer_half_full : out std_logic;
                   buffer_full : out std_logic;
                  buffer_reset : in std_logic;
                           clk : in std_logic);
  end component;

--
-- UART Receiver with integral 16 byte FIFO buffer
--

  component uart_rx6 
    Port (           serial_in : in std_logic;
                  en_16_x_baud : in std_logic;
                      data_out : out std_logic_vector(7 downto 0);
                   buffer_read : in std_logic;
           buffer_data_present : out std_logic;
              buffer_half_full : out std_logic;
                   buffer_full : out std_logic;
                  buffer_reset : in std_logic;
                           clk : in std_logic);
  end component;

--
--
-------------------------------------------------------------------------------------------
--
-- Signals
--
-------------------------------------------------------------------------------------------
--
signal cgrom_di 		: std_logic_vector(0 downto 0) := (others => '0');
signal cgrom_wraddr	: std_logic_vector(13 downto 0) := (others => '0');

constant true_bit	: std_logic := '1';
constant false_bit : std_logic :='0';

signal pixel_tall			: std_logic := '0';
signal pixel_tall_set 	: std_logic :='0';
signal pixel_tall_clr 	: std_logic :='0';

signal pixel_eighty		: std_logic := '0';
signal pixel_eighty_set	: std_logic := '0';
signal pixel_eighty_clr	: std_logic := '0';

signal pixel_fifty		: std_logic := '0';
signal pixel_fifty_set	: std_logic := '0';
signal pixel_fifty_clr	: std_logic := '0';

--
-- Signals used to create 50MHz clock from 200MHz differential clock
--
signal               clk200 : std_logic;
signal                  clk : std_logic;
--
--
-- Signals used to connect KCPSM6
--
signal              address : std_logic_vector(11 downto 0);
signal          instruction : std_logic_vector(17 downto 0);
signal          bram_enable : std_logic;
signal              in_port : std_logic_vector(7 downto 0);
signal             out_port : std_logic_vector(7 downto 0);
signal              port_id : std_logic_vector(7 downto 0);
signal         write_strobe : std_logic;
signal       k_write_strobe : std_logic;
signal          read_strobe : std_logic;
signal            interrupt : std_logic;
signal        interrupt_ack : std_logic;
signal         kcpsm6_sleep : std_logic;
signal         kcpsm6_reset : std_logic;
signal                  rdl : std_logic;
--
-- Signals used to connect UART_TX6
--
signal      uart_tx_data_in : std_logic_vector(7 downto 0);
signal     write_to_uart_tx : std_logic;
signal uart_tx_data_present : std_logic;
signal    uart_tx_half_full : std_logic;
signal         uart_tx_full : std_logic;
signal         uart_tx_reset : std_logic;
--
-- Signals used to connect UART_RX6
--
signal     uart_rx_data_out : std_logic_vector(7 downto 0);
signal    read_from_uart_rx : std_logic;
signal uart_rx_data_present : std_logic;
signal    uart_rx_half_full : std_logic;
signal         uart_rx_full : std_logic;
signal        uart_rx_reset : std_logic;

signal uart_rx_data_flag		: std_logic;
--
-- Signals used to define baud rate
--
--signal           baud_count : integer range 0 to 162 := 0; 
signal           baud_count : integer range 0 to 26 := 0; 
signal         en_16_x_baud : std_logic := '0';
--
--
signal ps2_code_new			: STD_LOGIC :='0';
signal ps2_code_old			: STD_LOGIC :='0';

signal ps2_fifo_din			: std_logic_vector(7 downto 0) := (others =>'0');
signal ps2_fifo_dout			: std_logic_vector(7 downto 0) := (others =>'0');
signal ps2_fifo_rd			: std_logic := '0';
signal ps2_fifo_wr			: std_logic := '0';
signal ps2_fifo_full			: std_logic := '0';
signal ps2_fifo_empty		: std_logic := '0';

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
--
-- relevant signals for the RGB DVI, CGRAM, and CGRAM
-- to glue things together
--

   signal clk_tmds0  : std_logic := '0';
   signal clk_tmds90 : std_logic := '0';
   signal clk_pixel  : std_logic := '0';
	signal clk_fifty	: std_logic := '0';

	signal ramaddr		: std_logic_vector(12 downto 0) := (others =>'0');
	signal ramchar		: std_logic_vector( 7 downto 0) := (others =>'0');
	signal ramattr		: std_logic_vector( 8 downto 0) := (others =>'0');
	signal ramoffset	: std_logic_vector(12 downto 0) := (others =>'0');

	signal cursoraddr : std_logic_vector(12 downto 0) := (others=>'0');

	signal romenable: std_logic := '0';
	signal romaddr : std_logic_vector(13 downto 0) := (others => '0');
	signal rompixel : std_logic_vector( 0 downto 0) := (others =>'0');

   signal red     : std_logic_vector(7 downto 0) := (others => '0');
   signal green   : std_logic_vector(7 downto 0) := (others => '0');
   signal blue    : std_logic_vector(7 downto 0) := (others => '0');
   signal hsync   : std_logic := '0';
   signal vsync   : std_logic := '0';
   signal blank   : std_logic := '0';
   signal red_s   : std_logic;
   signal green_s : std_logic;
   signal blue_s  : std_logic;
   signal clock_s : std_logic;
	
	
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
		
	signal cgRAM_DI_CPU		: STD_LOGIC_VECTOR(7 downto 0) := (others=>'0');
	signal cgRAM_DO_CPU		: STD_LOGIC_VECTOR(7 downto 0) := (others=>'0');
	signal cgRAM_ADDR_CPU	: STD_LOGIC_VECTOR(12 downto 0) := (others=>'0');
	signal cgRAM_OFFSET_CPU	: STD_LOGIC_VECTOR(12 downto 0) := (others=>'0');

	signal cgRAM_CLK_CPU		: STD_LOGIC:='0';
	signal cgRAM_EN_CPU		: STD_LOGIC:='0';
	signal cgRAM_WE_CPU		: STD_LOGIC_VECTOR(0 downto 0);

	signal cgATTR_EN_CPU		: STD_LOGIC:='0';
	signal cgATTR_WE_CPU		: STD_LOGIC_VECTOR(0 downto 0);

	
	signal cgATTR_DI_CPU		: STD_LOGIC_VECTOR(8 downto 0) := (others=>'0');
	signal cgATTR_DO_CPU		: STD_LOGIC_VECTOR(8 downto 0) := (others=>'0');
	
	signal di_null : std_logic_vector(0 downto 0);

	signal ps2_code			: STD_LOGIC_VECTOR(7 downto 0) := (others=>'0');
	signal ps2_write_new		: STD_LOGIC:='0';
	signal ps2_write_old		: STD_LOGIC:='0';

	constant ps2_reset		: STD_LOGIC:='0';
	signal ps2_clk_in			: STD_LOGIC:='1';
	signal ps2_clk_out		: STD_LOGIC:='1';
	signal ps2_clk_z			: STD_LOGIC:='1';
	signal ps2_dat_in			: STD_LOGIC:='1';
	signal ps2_dat_out		: STD_LOGIC:='1';
	signal ps2_dat_z			: STD_LOGIC:='1';
	signal caps_lock_led		: STD_LOGIC:='0';
	signal num_lock_led		: STD_LOGIC:='0';
	signal scroll_lock_led	: STD_LOGIC:='0';
	
	signal caps_lock_led_set		: STD_LOGIC:='0';
	signal num_lock_led_set			: STD_LOGIC:='0';
	signal scroll_lock_led_set		: STD_LOGIC:='0';
	
	signal caps_lock_led_clr		: STD_LOGIC:='0';
	signal num_lock_led_clr			: STD_LOGIC:='0';
	signal scroll_lock_led_clr		: STD_LOGIC:='0';
	
	signal ps2_en				: STD_LOGIC:='0';
	signal ps2_scancode		: STD_LOGIC_VECTOR(7 downto 0):=(others=>'0');
--	signal ps2_scancode		: unsigned(7 downto 0):=(others=>'0');
	

-------------------------------------------------------------------------------------------
begin
  -----------------------------------------------------------------------------------------
  -- Instantiate KCPSM6 and connect to program ROM
  -----------------------------------------------------------------------------------------
  --
  -- The generics can be defined as required. In this case the 'hwbuild' value is used to 
  -- define a version using the ASCII code for the desired letter. 
  --

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
                       clk => CLK_fifty);
 

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

  program_rom: uart_control
    generic map(             C_FAMILY => "S6", 
                    C_RAM_SIZE_KWORDS => 2,	-- 2K by 18 consumes 2 block RAMs but we've exceeded the program size for one.
                 C_JTAG_LOADER_ENABLE => 1)
    port map(      address => address,      
               instruction => instruction,
                    enable => bram_enable,
                       rdl => rdl,
                       clk => CLK_fifty);



  --
  -----------------------------------------------------------------------------------------
  -- UART Transmitter with integral 16 byte FIFO buffer
  -----------------------------------------------------------------------------------------
  --
  -- Write to buffer in UART Transmitter at port address 01 hex
  -- 

  tx: uart_tx6 
  port map (              data_in => uart_tx_data_in,
                     en_16_x_baud => en_16_x_baud,
                       serial_out => uart_tx,
                     buffer_write => write_to_uart_tx,
              buffer_data_present => uart_tx_data_present,
                 buffer_half_full => uart_tx_half_full,
                      buffer_full => uart_tx_full,
                     buffer_reset => uart_tx_reset,              
                              clk => CLK_fifty);


  --
  -----------------------------------------------------------------------------------------
  -- UART Receiver with integral 16 byte FIFO buffer
  -----------------------------------------------------------------------------------------
  --
  -- Read from buffer in UART Receiver at port address 01 hex.
  --
  -- When KCPMS6 reads data from the receiver a pulse must be generated so that the 
  -- FIFO buffer presents the next character to be read and updates the buffer flags.
  -- 
  
  rx: uart_rx6 
  port map (            serial_in => uart_rx,
                     en_16_x_baud => en_16_x_baud,
                         data_out => uart_rx_data_out,
                      buffer_read => read_from_uart_rx,
              buffer_data_present => uart_rx_data_present,
                 buffer_half_full => uart_rx_half_full,
                      buffer_full => uart_rx_full,
                     buffer_reset => uart_rx_reset,              
                              clk => CLK_fifty);

  --
  -----------------------------------------------------------------------------------------
  -- RS232 (UART) baud rate 
  -----------------------------------------------------------------------------------------
  --
  -- To set serial communication baud rate to 115,200 then en_16_x_baud must pulse 
  -- High at 1,843,200Hz which is every 27.13 cycles at 50MHz. In this implementation 
  -- a pulse is generated every 27 cycles resulting is a baud rate of 115,741 baud which
  -- is only 0.5% high and well within limits.
  --

  baud_rate: process(CLK_fifty)
  begin
    if CLK_fifty'event and CLK_fifty = '1' then
      if baud_count = 26 then                    -- counts 27 states including zero for 115,200 baud
--      if baud_count = 162 then                    -- counts 163 states including zero for 19,200 baud
        baud_count <= 0;
        en_16_x_baud <= '1';                     -- single cycle enable pulse
       else
        baud_count <= baud_count + 1;
        en_16_x_baud <= '0';
      end if;
    end if;
  end process baud_rate;


  --
  -----------------------------------------------------------------------------------------
  -- General Purpose Input Ports. 
  -----------------------------------------------------------------------------------------
  --
  -- Two input ports are used with the UART macros. The first is used to monitor the flags
  -- on both the transmitter and receiver. The second is used to read the data from the 
  -- receiver and generate the 'buffer_read' pulse.
  --

  input_ports: process(CLK_fifty)
  begin
    --if CLK_fifty'event and CLK_fifty = '1' then
		if rising_edge(CLK_fifty) then
			if port_id=x"00" then       					-- Read UART status at port address 00 hex
				in_port(0) <= uart_tx_data_present;
				in_port(1) <= uart_tx_half_full;
				in_port(2) <= uart_tx_full; 
				in_port(3) <= uart_rx_data_present;
				in_port(4) <= uart_rx_half_full;
				in_port(5) <= uart_rx_full;
				in_port(7 downto 6) <= (others=>'0');
			elsif port_id=x"01" then        				-- Read UART_RX6 data at port address 01 hex; note that this is obsolete now that we have a primary FIFO
				in_port <= uart_rx_data_out;
			elsif port_id=x"05" then						-- read from character memory at port address 05
				in_port <= cgram_do_cpu;
			elsif port_id=x"06" then						-- read PS/2 keyboard data at port address 06
				in_port <= ps2_fifo_dout;
			elsif port_id=x"07" then						-- read PS/2 keyboard status at port 07 (bit 0 is the FIFO empty flag)
				in_port(0) <= ps2_fifo_empty;
				in_port(1) <= ps2_fifo_full;
				in_port(7 downto 2) <= (others=>'0');
			elsif port_id=x"0A" then						-- read from attribute memory at port 0A
				in_port <= cgattr_do_cpu(7 downto 0);
			elsif port_id=x"0C" then						-- read UART primary FIFO status at port 0C
				in_port(0) <= uart_fifo_empty;
				in_port(1) <= uart_fifo_full;
				in_port(2) <= uart_rx_data_flag;			-- this bit is a workaround for chipscope debugging and can be removed if necessary
--				in_port(3) <= pixel_tall_set;				-- chipscope
--				in_port(4) <= pixel_tall_clr;				-- chipscope
				in_port(7 downto 3) <= (others=>'0');
			elsif port_id=x"0D" then						-- read UART primary FIFO data at port 0D
				in_port <= uart_fifo_dout;
			elsif port_id=x"20" then 						-- port 20 is a workaround for chipscope debugging and can be removed if necessary
				in_port <= port_id_reg;
			elsif port_id=x"21" then 						-- port 20 is a workaround for chipscope debugging and can be removed if necessary
				in_port <= out_port_reg;
			else
				in_port <= "XXXXXXXX";
			end if;

			if (read_strobe = '1') and (port_id = x"0D") then
				uart_fifo_rd <= '1';
			else
				uart_fifo_rd <= '0';	
			end if;
		
			if (read_strobe = '1') and (port_id = x"06") then
				ps2_fifo_rd <= '1';
			else
				ps2_fifo_rd <= '0';	
			end if;
    end if;

  -- Generate 'buffer_read' pulse following read from port address 01
  -- use this code only if you're not using the primary FIFO.
  --
  --    if (read_strobe = '1') and (port_id = x"01") then
  --      read_from_uart_rx <= '1';
  --     else
  --      read_from_uart_rx <= '0';
  --    end if;
 
  end process input_ports;

--
-- UART_FIFO_transfer is a state machine which clocks data
-- from the UART's small built in FIFO to the larger primary FIFO.
--

UART_FIFO_transfer: process(CLK_fifty,uart_state_register,uart_rx_data_present,uart_fifo_full) 	-- transfer from the non-empty 16 byte FIFO to the bigger 64 byte FIFO.
begin

		case uart_state_register is
			when idle =>
				if uart_rx_data_present ='1' and uart_fifo_full='0' then
					uart_fifo_wr <= '1';		
					read_from_uart_rx <= '0';
					uart_state_next <= strobe_in;
				else
					uart_fifo_wr <= '0';
					read_from_uart_rx <= '0';
					uart_state_next <= idle;
				end if;
			when strobe_in =>
				uart_fifo_wr <= '0';
				read_from_uart_rx <= '1';
				uart_state_next <= strobe_out;
			when strobe_out =>
				uart_fifo_wr <= '0';
				read_from_uart_rx <= '0';
				uart_state_next <= idle;
		end case;

end process UART_FIFO_transfer;

UART_FIFO_register: process(CLK_fifty)
begin
	if rising_edge(CLK_fifty) then
		uart_state_register <= uart_state_next;
		uart_rx_data_flag <= read_from_uart_rx;-- for chipscope workaround, can be removed (note 1 cycle delay in ILA capture)
		port_id_reg <= port_id; -- for chipscope workaround, can be removed (note 1 cycle delay in ILA capture)
		out_port_reg <= out_port; --for chipscope workaround, can be removed (note 1 cycle delay in ILA capture)
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

output_ports: process(CLK_fifty,out_port,write_strobe,port_id)
begin

	CGdata <= out_port;
	CGattr <= out_port;
	uart_tx_data_in <= out_port;

	pixel_tall_set<='0';
	pixel_tall_clr<='0';

	pixel_eighty_set<='0';
	pixel_eighty_clr<='0';

	pixel_fifty_set<='0';
	pixel_fifty_clr<='0';

	caps_lock_led_set<='0';
	caps_lock_led_clr<='0';

	num_lock_led_set<='0';
	num_lock_led_clr<='0';

	scroll_lock_led_set<='0';
	scroll_lock_led_clr<='0';

	if port_id = x"01" then	-- port 01 is the UART TX buffer
		write_to_uart_tx <= write_strobe;
	else
		write_to_uart_tx <= '0';
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

--		pixel_eighty<=out_port(1);
--		pixel_fifty<=out_port(2);

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

			if out_port(3)='1' then
				caps_lock_led_set<='1';
				caps_lock_led_clr<='0';
			else
				caps_lock_led_set<='0';
				caps_lock_led_clr<='1';
			end if;

			if out_port(4)='1' then
				num_lock_led_set<='1';
				num_lock_led_clr<='0';
			else
				num_lock_led_set<='0';
				num_lock_led_clr<='1';
			end if;

			if out_port(5)='1' then
				scroll_lock_led_set<='1';
				scroll_lock_led_clr<='0';
			else
				scroll_lock_led_set<='0';
				scroll_lock_led_clr<='1';
			end if;

--			caps_lock_led<=out_port(3);
--			num_lock_led<=out_port(4);
--			scroll_lock_led<=out_port(5);
		end if; 
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

Video_Mode : process(CLK_fifty)
begin
	if rising_edge(CLK_fifty) then

		if pixel_tall_set='1' then
			pixel_tall<='1';
		end if;
		
		if pixel_tall_clr='1' then
			pixel_tall<='0';
		end if;
		
		if pixel_eighty_set='1' then
			pixel_eighty<='1';
		end if;
		
		if pixel_eighty_clr='1' then
			pixel_eighty<='0';
		end if;

		if pixel_fifty_set='1' then
			pixel_fifty<='1';
		end if;
		
		if pixel_fifty_clr='1' then
			pixel_fifty<='0';
		end if;	
		
		if caps_lock_led_set='1' then
			caps_lock_led<='1';
		end if;

		if caps_lock_led_clr='1' then
			caps_lock_led<='0';
		end if;

		if num_lock_led_set='1' then
			num_lock_led<='1';
		end if;

		if num_lock_led_clr='1' then
			num_lock_led<='0';
		end if;

		if scroll_lock_led_set='1' then
			scroll_lock_led<='1';
		end if;

		if scroll_lock_led_clr='1' then
			scroll_lock_led<='0';
		end if;
		
	end if;
end process Video_mode;

--PS2FIFO_strobe : process(CLK_fifty,ps2_code_new,ps2_code_old)
--begin

--	if ps2_code_new='1' and ps2_code_old='0' then
--		ps2_fifo_wr<='1';
--	else
--		ps2_fifo_wr<='0';
--	end if;
--end process;

--PS2FIFO_clock : process(CLK_fifty)
--begin
--	if rising_edge(CLK_fifty) then
--		ps2_code_old<=ps2_code_new;
--	end if;

--end process;

  --
  -----------------------------------------------------------------------------------------
  -- Constant-Optimised Output Ports 
  -----------------------------------------------------------------------------------------
  --
  -- One constant-optimised output port is used to facilitate resetting of the UART macros.
  --

  constant_output_ports: process(CLK_fifty)
  begin
    if CLK_fifty'event and CLK_fifty = '1' then
      if k_write_strobe = '1' then

        if port_id(0) = '1' then
          uart_tx_reset <= out_port(0);
          uart_rx_reset <= out_port(1);
        end if;

      end if;
    end if; 
  end process constant_output_ports;

  --
  -----------------------------------------------------------------------------------------
  --

      
I_clocking : clocking port map (
      CLK_50     => clk_50,
		CLK_fifty	=> clk_fifty,
      CLK_tmds0  => clk_tmds0,
      CLK_tmds90 => clk_tmds90,
      CLK_pixel  => clk_pixel
    );

I_dvid: dvid PORT MAP(
      clk_tmds0  => clk_tmds0,
      clk_tmds90 => clk_tmds90, 
      clk_pixel  => clk_pixel,
      red_p      => red,
      green_p    => green,
      blue_p     => blue,
      blank      => blank,
      hsync      => hsync,
      vsync      => vsync,
      -- outputs to TMDS drivers
      red_s      => red_s,
      green_s    => green_s,
      blue_s     => blue_s,
      clock_s    => clock_s
   );
   
OBUFDS_blue  : OBUFDS port map ( O  => TMDS(0), OB => TMDSB(0), I  => blue_s  );
OBUFDS_red   : OBUFDS port map ( O  => TMDS(1), OB => TMDSB(1), I  => red_s   );
OBUFDS_green : OBUFDS port map ( O  => TMDS(2), OB => TMDSB(2), I  => green_s );
OBUFDS_clock : OBUFDS port map ( O  => TMDS(3), OB => TMDSB(3), I  => clock_s );
    -- generic map ( IOSTANDARD => "DEFAULT")    

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
		
		CGRAM_ADDR_CPU	=> cgRAM_ADDR_CPU,
		CGRAM_OFFSET_CPU	=> cgRAM_OFFSET_CPU,
		CGRAM_DI_CPU	=> cgRAM_DI_CPU,
		CGRAM_EN_CPU	=> cgRAM_EN_CPU,
		CGRAM_WE_CPU	=> cgRAM_WE_CPU,
		
		ramOffset		=> ramOffset,
		
		
		CGATTR_DI_CPU	=> cgATTR_DI_CPU,
		CGATTR_EN_CPU	=> cgATTR_EN_CPU,
		CGATTR_WE_CPU	=> cgATTR_WE_CPU,

		CURSOR_REG		=> cursor_reg
	);
   
I_vga: vga GENERIC MAP (

-- For 1280x720  - set clocks to 75MHz & 187.5MHz
--     hRez       => 1280, hStartSync => 1352, hEndSync   => 1432, hMaxCount  => 1648, hsyncActive => '1',
--     vRez       => 720,  vStartSync =>  723, vEndSync   =>  728, vMaxCount  =>  750, vsyncActive => '1'
			
-- For 1920x1080 @ 60Hz  - set clocks to 150MHz & 375MHz
--"1920x1080" 148,500 1920 2008 2052 2200 1080 1084 1089 1125 +hsync +vsync
      hRez       => 1920, hStartSync => 2008, hEndSync   => 2052, hMaxCount  => 2200, hsyncActive => '1',
      vRez       => 1080, vStartSync => 1084, vEndSync   => 1089, vMaxCount  => 1125, vsyncActive => '1'

   ) PORT MAP(
      pixelClock => clk_pixel,
		pixelTall  => pixel_tall, -- true_bit,
		pixelEighty=> pixel_eighty,
		pixelFifty=> pixel_fifty,
      Red        => red,
      Green      => green,
      Blue       => blue,
      hSync      => hSync,
      vSync      => vSync,
      blank      => blank,
		
		romADDR		=> romaddr,
		romPIXEL		=>	rompixel,
		romENABLE	=> romenable,
		
		ramCHAR		=> ramchar,
		ramATTR		=> ramattr,
		ramADDR		=>	ramaddr,
		ramOFFSET	=>	ramoffset,
		cursorADDR	=> cursor_reg --cursoraddr
		
   );

I_CGROM: CGROM 
 PORT MAP(
		CGROM_ADDR =>romaddr,
		CGROM_DO	=>rompixel,
		CGROM_CLK =>clk_pixel,
		CGROM_EN=>romenable,

		DI=> cgrom_di, --(others=>'0'), --di_null,
		REGCE=>'0',
		RST=>'0',
		WE=>(others=>'0') -- write enable
--		WRADDR=>cgrom_wraddr, --(others=>'0'),
--		WRCLK=>'0',
--		WREN=>'0'
		
	);

ps2io_clk: IOBUF
	GENERIC MAP (
			DRIVE=>8
	)
	PORT MAP (
			O=>ps2_clk_out,
			I=>ps2_clk_in,
			T=>ps2_clk_in,
			IO=>PS2_CLK
	);

ps2io_data: IOBUF
	GENERIC MAP (
			DRIVE=>8
	)
	PORT MAP (
			O=>ps2_dat_out,
			I=>ps2_dat_in,
			T=>ps2_dat_in,
			IO=>PS2_DATA
	);


I_PS2KB : ps2_keyboard
 	PORT MAP(
    clk		=> clk_fifty,
--    ps2_clk => PS2_CLK,
--    ps2_data=> PS2_DATA,
    ps2_clk => ps2_clk_out,
    ps2_data=> ps2_dat_out,
    ps2_code_new=>ps2_code_new,
    ps2_code  => ps2_code
	 );

IO_PS2KB : io_ps2_keyboard
	PORT MAP (
		clk => clk_fifty,
		reset => ps2_reset,
		
		ps2_clk_in=> ps2_clk_out,
		ps2_dat_in=> ps2_dat_out,
		ps2_clk_out=> ps2_clk_in,
		ps2_dat_out=> ps2_dat_in,

		-- LED status
		caps_lock => caps_lock_led,
		num_lock => num_lock_led,
		scroll_lock => scroll_lock_led,

		-- Read scancode
		trigger=> ps2_en,
		scancode=> ps2_scancode
	);


I_CGRAM: CGRAM8K
 PORT MAP(
		addra=> ramaddr,
		douta	=> ramchar,
		dina	=> (others=>'0'), -- we never write on the VGA side
		clka 	=> clk_pixel,
		wea	=> (others=>'0'), -- we never write on the VGA side

		dinb	=> cgram_di_cpu,
		doutb	=> cgram_do_cpu,
		web	=> CGRAM_WE_CPU,		--(others=>'1'), -- writes are enabled on the CPU side (always? we need to fix this)
--		addrb	=> cgram_addr_cpu,
		addrb	=> cgram_offset_cpu,
		clkb	=> clk_fifty
		
	);

I_CGATTRIBUTERAM: CGRAM8K9B
 PORT MAP(
		addra=> ramaddr,
		douta	=> ramattr,
		dina	=> (others=>'0'), -- we never write on the VGA side
		clka 	=> clk_pixel,
		wea	=> (others=>'0'), -- we never write on the VGA side

		dinb	=> cgattr_di_cpu,
		doutb	=> cgattr_do_cpu,
		web	=> CGattr_WE_CPU,		--(others=>'1'), -- writes are enabled on the CPU side (always? we need to fix this)
--		addrb	=> cgram_addr_cpu,
		addrb	=> cgram_offset_cpu,
		clkb	=> clk_fifty
		);


 I_PS2FIFO : PS2FIFO
	PORT MAP(
		clk		=> clk_fifty,
		rst		=> '0', 
--		din		=> ps2_code,
		din		=> ps2_scancode,
--     wr_en	=> ps2_fifo_wr,
		wr_en		=> ps2_en,
		rd_en	=> ps2_fifo_rd,
		dout		=> ps2_fifo_dout,
		full		=> ps2_fifo_full,
		empty	=> ps2_fifo_empty
		);

I_UARTFIFO: PS2FIFO
	PORT MAP (
		clk	=> clk_fifty,
		rst	=> '0',
		din	=> uart_rx_data_out,
		wr_en => uart_fifo_wr,
		rd_en => uart_fifo_rd,
		dout	=> uart_fifo_dout,
		full	=> uart_fifo_full,
		empty	=> uart_fifo_empty
		);
---		uart_rx_data_present

end Behavioral;