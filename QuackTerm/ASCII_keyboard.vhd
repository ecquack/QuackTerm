----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:25:09 04/15/2017 
-- Design Name: 
-- Module Name:    ASCII_keyboard - Behavioral 
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
Library UNISIM;
use UNISIM.vcomponents.all;
use IEEE.numeric_std.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ASCII_keyboard is
    Port ( PS2_CLK : inout  STD_LOGIC;
           PS2_DAT : inout  STD_LOGIC;
           CLK_fifty : in  STD_LOGIC;
           keyboard_strobe : out  STD_LOGIC;
           keyboard_data : out  STD_LOGIC_VECTOR (7 downto 0));
end ASCII_keyboard;

architecture Behavioral of ASCII_keyboard is

 	COMPONENT FIFO64FWFT
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

	COMPONENT io_ps2_keyboard
	port (
		clk: in std_logic;
		reset : in std_logic;
		
		-- PS/2 connector
		ps2_clk_in: in std_logic;
		ps2_dat_in: in std_logic;
		ps2_clk_out: out std_logic;
		ps2_dat_out: out std_logic;

		-- LED status
		caps_lock : in std_logic;
		num_lock : in std_logic;
		scroll_lock : in std_logic;

		typematic : in std_logic_vector(7 downto 0);

		-- Read scancode
		trigger : out std_logic;
		scancode : out std_logic_vector(7 downto 0)
	);
	END COMPONENT;

component ps2_interpreter
    Port (      address : in std_logic_vector(11 downto 0);
            instruction : out std_logic_vector(17 downto 0);
                 enable : in std_logic;
                    clk : in std_logic);
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


	constant ps2_reset					: STD_LOGIC:='0';

	signal ps2_clk_in						: STD_LOGIC:='1';
	signal ps2_clk_out					: STD_LOGIC:='1';
	signal ps2_clk_z						: STD_LOGIC:='1';
	signal ps2_dat_in						: STD_LOGIC:='1';
	signal ps2_dat_out					: STD_LOGIC:='1';
	signal ps2_dat_z						: STD_LOGIC:='1';

	signal caps_lock_led					: STD_LOGIC:='0';
	signal caps_lock_led_set			: STD_LOGIC:='0';
	signal caps_lock_led_clr			: STD_LOGIC:='0';

	signal num_lock_led					: STD_LOGIC:='0';
	signal num_lock_led_set				: STD_LOGIC:='0';
	signal num_lock_led_clr				: STD_LOGIC:='0';

	signal scroll_lock_led				: STD_LOGIC:='0';
	signal scroll_lock_led_set			: STD_LOGIC:='0';
	signal scroll_lock_led_clr			: STD_LOGIC:='0';
	
	signal typematic_rate				: STD_LOGIC_VECTOR(7 downto 0):=x"2B"; -- default typematic rate after reset
	signal typematic_rate_set 			: STD_LOGIC :='0';
	
	signal ps2_en							: STD_LOGIC:='0';
	signal ps2_scancode					: STD_LOGIC_VECTOR(7 downto 0):=(others=>'0');
	
	signal keyboard_address 			: STD_LOGIC_VECTOR(11 downto 0);
	signal keyboard_instruction 		: STD_LOGIC_VECTOR(17 downto 0);
	signal keyboard_bram_enable 		: STD_LOGIC;
	signal keyboard_port_id 			: STD_LOGIC_VECTOR(7 downto 0);
	signal keyboard_write_strobe 		: STD_LOGIC;
	signal keyboard_k_write_strobe	: STD_LOGIC;
	signal keyboard_out_port 			: STD_LOGIC_VECTOR(7 downto 0);
	signal keyboard_read_strobe 		: STD_LOGIC;
	signal keyboard_in_port 			: STD_LOGIC_VECTOR(7 downto 0);
	signal keyboard_interrupt 			: STD_LOGIC;
	signal keyboard_interrupt_ack 	: STD_LOGIC;
	signal keyboard_kcpsm6_sleep 		: STD_LOGIC;
	signal keyboard_kcpsm6_reset		: STD_LOGIC;
	signal keyboard_rdl					: STD_LOGIC;

	signal ps2_fifo_din					: std_logic_vector(7 downto 0) := (others =>'0');
	signal ps2_fifo_dout					: std_logic_vector(7 downto 0) := (others =>'0');
	signal ps2_fifo_rd					: std_logic := '0';
	signal ps2_fifo_wr					: std_logic := '0';
	signal ps2_fifo_full					: std_logic := '0';
	signal ps2_fifo_empty				: std_logic := '0';

begin

keyboard_input_ports: process(CLK_fifty)
  begin
    --if CLK_fifty'event and CLK_fifty = '1' then
		if rising_edge(CLK_fifty) then
			if keyboard_port_id=x"00" then       					-- Fake UART status port not full
				keyboard_in_port <= X"00";
			elsif keyboard_port_id=x"06" then						-- read PS/2 keyboard data at port address 06
				keyboard_in_port <= ps2_fifo_dout;
			elsif keyboard_port_id=x"07" then						-- read PS/2 keyboard status at port 07 (bit 0 is the FIFO empty flag)
				keyboard_in_port(0) <= ps2_fifo_empty;
				keyboard_in_port(1) <= ps2_fifo_full;
				keyboard_in_port(7 downto 2) <= (others=>'0');
			else
				keyboard_in_port <= "XXXXXXXX";
			end if;
		
			if (keyboard_read_strobe = '1') and (keyboard_port_id = x"06") then
				ps2_fifo_rd <= '1';
			else
				ps2_fifo_rd <= '0';	
			end if;
    end if;
 end process;
 
 output_ports: process(CLK_fifty,keyboard_out_port,keyboard_write_strobe,keyboard_port_id)
begin

	keyboard_data <= keyboard_out_port;


	caps_lock_led_set<='0';
	caps_lock_led_clr<='0';

	num_lock_led_set<='0';
	num_lock_led_clr<='0';

	scroll_lock_led_set<='0';
	scroll_lock_led_clr<='0';

	typematic_rate_set<='0';

	if keyboard_port_id = x"01" then	-- port 01 is the UART TX buffer
		keyboard_strobe <= keyboard_write_strobe;
	else
		keyboard_strobe <= '0';
	end if;
	

	if keyboard_port_id=x"0B" then -- port 0B bit 0 sets the keyboard LED bits in a roundabout way to prevent a latch
		if keyboard_write_strobe='1' then

			if keyboard_out_port(3)='1' then
				caps_lock_led_set<='1';
				caps_lock_led_clr<='0';
			else
				caps_lock_led_set<='0';
				caps_lock_led_clr<='1';
			end if;

			if keyboard_out_port(4)='1' then
				num_lock_led_set<='1';
				num_lock_led_clr<='0';
			else
				num_lock_led_set<='0';
				num_lock_led_clr<='1';
			end if;

			if keyboard_out_port(5)='1' then
				scroll_lock_led_set<='1';
				scroll_lock_led_clr<='0';
			else
				scroll_lock_led_set<='0';
				scroll_lock_led_clr<='1';
			end if;

		end if; 
	end if;
			
	if keyboard_port_id=x"10" then -- 
		typematic_rate_set<='1';
	else 
		typematic_rate_set<='0';
	end if;

end process output_ports;

Video_Mode : process(CLK_fifty)
begin
	if rising_edge(CLK_fifty) then

		if typematic_rate_set='1' then
			typematic_rate<=keyboard_out_port;
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
			IO=>PS2_DAT
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

		typematic => typematic_rate,

		-- Read scancode
		trigger=> ps2_en,
		scancode=> ps2_scancode
	);

 I_PS2FIFO : FIFO64FWFT
	PORT MAP(
		clk		=> clk_fifty,
		din		=> ps2_scancode,
		wr_en		=> ps2_en,
		rd_en	=> ps2_fifo_rd,
		dout		=> ps2_fifo_dout,
		full		=> ps2_fifo_full,
		empty	=> ps2_fifo_empty
		);

	keyboard_kcpsm6_reset <= '0'; --keyboard_rdl;
	keyboard_kcpsm6_sleep <= '0';
	keyboard_interrupt <= keyboard_interrupt_ack;


	keyboard_processor: kcpsm6
    generic map (                 hwbuild => X"42",    -- 42 hex is ASCII Character "B"
                         interrupt_vector => X"7F0",   
                  scratch_pad_memory_size => 64)
    port map(      address => keyboard_address,
               instruction => keyboard_instruction,
               bram_enable => keyboard_bram_enable,
                   port_id => keyboard_port_id,
              write_strobe => keyboard_write_strobe,
            k_write_strobe => keyboard_k_write_strobe,
                  out_port => keyboard_out_port,
               read_strobe => keyboard_read_strobe,
                   in_port => keyboard_in_port,
                 interrupt => keyboard_interrupt,
             interrupt_ack => keyboard_interrupt_ack,
                     sleep => keyboard_kcpsm6_sleep,
                     reset => keyboard_kcpsm6_reset,
                       clk => CLK_fifty);
 

keyboard_program_rom: ps2_interpreter
--    generic map(  
--	 C_FAMILY => "S6", 
      --              C_RAM_SIZE_KWORDS => 1,	-- 2K by 18 consumes 2 block RAMs but we've exceeded the program size for one.
            --     C_JTAG_LOADER_ENABLE => 0)
    port map(      address => keyboard_address,      
               instruction => keyboard_instruction,
                    enable => keyboard_bram_enable,
                 --      rdl => keyboard_rdl,
                       clk => CLK_fifty);

end Behavioral;

