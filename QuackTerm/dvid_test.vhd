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

COMPONENT ANSI_terminal
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
		character_address			: in  STD_LOGIC_VECTOR (12 downto 0);
		character_offset			: out STD_LOGIC_VECTOR (12 downto 0);

		character_data				: out STD_LOGIC_VECTOR (8 downto 0);
		character_attribute		: out STD_LOGIC_VECTOR (8 downto 0);

		pixel_address				: in  STD_LOGIC_VECTOR (14 downto 0);
		pixel_enable				: in  STD_LOGIC;
		pixel_data					: out STD_LOGIC_VECTOR (0 downto 0);

		mode_tall_characters		: out STD_LOGIC;
		mode_eighty_column		: out STD_LOGIC;
		mode_fifty_line			: out STD_LOGIC;
		mode_block_cursor			: out STD_LOGIC;
		
		clk_fifty					: in  STD_LOGIC;
		clk_pixel					: in  STD_LOGIC
		);
END COMPONENT;
	
	COMPONENT ASCII_keyboard
    Port ( PS2_CLK : inout  STD_LOGIC;
           PS2_DAT : inout  STD_LOGIC;
           CLK_fifty : in  STD_LOGIC;
           keyboard_strobe : out  STD_LOGIC;
           keyboard_data : out  STD_LOGIC_VECTOR (7 downto 0));
	END COMPONENT;

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
      pixelClock 	: IN  std_logic;          
		pixelTall	: IN  std_logic;
		pixelEighty	: IN  std_logic;
		pixelFifty	: IN  std_logic;
		cursorBlock	: IN  std_logic;
      Red 			: OUT std_logic_vector(7 downto 0);
      Green 		: OUT std_logic_vector(7 downto 0);
      Blue 			: OUT std_logic_vector(7 downto 0);
      hSync 		: OUT std_logic;
      vSync 		: OUT std_logic;
      blank 		: OUT std_logic;
		-- interface to CGROM (character bitmaps)
		romADDR 		: OUT std_logic_vector(14 downto 0);
--		romCLOCK		: OUT std_logic;
		romENABLE	: OUT std_logic;
		romPIXEL		: IN	std_logic_vector(0 downto 0);
		-- interface to CGRAM (ASCII characters)
		ramADDR 		: OUT std_logic_vector(12 downto 0);
		ramCHAR		: IN std_logic_vector(8 downto 0);
		ramATTR		: IN std_logic_vector(8 downto 0);
		ramOFFSET	: IN std_logic_vector(12 downto 0);
		cursorADDR	: IN std_logic_vector(12 downto 0)
		
      );
   END COMPONENT;
--
-- declaration of KCPSM6
-- (this is the PicoBlaze-6 microprocessor)

--


  

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
-- Signals used to connect UART_TX6
--
	signal uart_tx_data_in 			: std_logic_vector(7 downto 0);
	signal write_to_uart_tx			: std_logic;
	signal uart_tx_data_present	: std_logic;
	signal uart_tx_half_full		: std_logic;
	signal uart_tx_full				: std_logic;
	signal uart_tx_reset				: std_logic;
--
-- Signals used to connect UART_RX6
--
	signal uart_rx_data_out			: std_logic_vector(7 downto 0);
	signal read_from_uart_rx		: std_logic;
	signal uart_rx_data_present	: std_logic;
	signal uart_rx_half_full		: std_logic;
	signal uart_rx_full				: std_logic;
	signal uart_rx_reset				: std_logic;

-- Signals used to define baud rate
--
--signal           baud_count : integer range 0 to 162 := 0; 
	signal baud_count					: integer range 0 to 26 := 0; 
	signal en_16_x_baud				: std_logic := '0';

	signal clk_fifty					: std_logic := '0';
   signal clk_tmds0  				: std_logic := '0';
   signal clk_tmds90 				: std_logic := '0';
   signal clk_pixel  				: std_logic := '0';

   signal red     					: std_logic_vector(7 downto 0) := (others => '0');
   signal green   					: std_logic_vector(7 downto 0) := (others => '0');
   signal blue    					: std_logic_vector(7 downto 0) := (others => '0');
   signal hsync   					: std_logic := '0';
   signal vsync   					: std_logic := '0';
   signal blank   					: std_logic := '0';
   signal red_s   					: std_logic;
   signal green_s 					: std_logic;
   signal blue_s  					: std_logic;
   signal clock_s 					: std_logic;

	signal mode_tall_characters	: std_logic := '0';
	signal mode_eighty_column		: std_logic := '0';
	signal mode_fifty_line 			: std_logic := '0';
	signal mode_block_cursor		: std_logic := '0';

	signal cursor_address			: STD_LOGIC_VECTOR (12 downto 0); 
	signal character_address		: STD_LOGIC_VECTOR (12 downto 0); 
	signal character_offset			: STD_LOGIC_VECTOR (12 downto 0);

	signal pixel_address				: STD_LOGIC_VECTOR (14 downto 0); 
	signal pixel_data					: STD_LOGIC_VECTOR (0 downto 0);
	signal romenable					: STD_LOGIC;

	signal keyboard_data				: STD_LOGIC_VECTOR (7 downto 0);
	signal keyboard_strobe			: STD_LOGIC;

	signal character_data			: STD_LOGIC_VECTOR (8 downto 0);
	signal character_attribute		: STD_LOGIC_VECTOR (8 downto 0);


-------------------------------------------------------------------------------------------
begin
  -----------------------------------------------------------------------------------------
  -- Instantiate KCPSM6 and connect to program ROM
  -----------------------------------------------------------------------------------------
  --
  -- The generics can be defined as required. In this case the 'hwbuild' value is used to 
  -- define a version using the ASCII code for the desired letter. 
  --


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
		pixelTall  => mode_tall_characters,
		pixelEighty=> mode_eighty_column,
		pixelFifty=>  mode_fifty_line,
		cursorBlock=> mode_block_cursor,
      Red        => red,
      Green      => green,
      Blue       => blue,
      hSync      => hSync,
      vSync      => vSync,
      blank      => blank,
		
		romADDR		=> pixel_address,--romaddr,
		romPIXEL		=>	pixel_data,--rompixel,
		romENABLE	=> romenable,
		
		ramCHAR		=> character_data,
		ramATTR		=> character_attribute,
		ramADDR		=>	character_address,
		ramOFFSET	=>	character_offset,
		cursorADDR	=> cursor_address --cursoraddr
		
   );


--O_ROMFONTS: ROMFONTS
-- PORT MAP (
--    clka => clk_pixel,
--    addra => romaddr(13 downto 0),
--    douta => rompixel
--  );


IO_ASCII_keyboard: ASCII_keyboard
    PORT MAP (
		PS2_CLK => PS2_CLK,
		PS2_DAT => PS2_DATA,
      CLK_fifty => clk_fifty,
      keyboard_strobe => keyboard_strobe,
      keyboard_data => keyboard_data
		);
	
IO_ANSI_terminal : ANSI_terminal
	PORT MAP (	
		keyboard_data				=> keyboard_data,
		keyboard_strobe			=> keyboard_strobe,

		host_data_out				=> uart_tx_data_in,
		host_data_out_strobe		=> write_to_uart_tx,
		host_data_out_wait		=> uart_tx_full,
		host_in_reset				=> uart_tx_reset,

		host_data_in				=> uart_rx_data_out,
		host_data_in_strobe		=> read_from_uart_rx,
		host_data_in_ready		=> uart_rx_data_present,
		host_out_reset				=> uart_rx_reset,

		cursor_address				=> cursor_address,      -- address from ANSI terminal
		character_data				=> character_data,		-- data from ANSI terminal
		character_attribute		=> character_attribute,	-- attribute from ANSI terminal

		character_offset			=> character_offset,    -- offset to VGA
		character_address			=> character_address,   -- address from VGA


		pixel_address				=> pixel_address,
		pixel_enable				=> romenable,
		pixel_data					=> pixel_data,


		mode_tall_characters		=> mode_tall_characters,
		mode_eighty_column		=> mode_eighty_column,
		mode_fifty_line			=> mode_fifty_line,
		mode_block_cursor			=> mode_block_cursor,

		clk_fifty					=> clk_fifty,
		clk_pixel					=> clk_pixel
		);
	
end Behavioral;
