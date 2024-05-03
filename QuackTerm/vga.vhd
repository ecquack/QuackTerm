----------------------------------------------------------------------------------
-- Engineer:       Erik Quackenbush (erikcq@quackenbush.com)
--
-- Module Name:   Character Display
--
-- Description:   creates a character display using an 8x8 pixel CGROM
--						in a block memory (256 characters).
--						
--						we double pixels X and Y (for a 16x16 character cell) which gives
--						us 120 characters by 67 lines of text on a 1920x1080 display (with 8 scan lines left over). This takes
--						8K of RAM to store, or four block memories. 
--
--						We also have an attribute memory that specifies 16 foreground
--						and 16 background colors for each character. This uses another 8K of RAM (four block memories).
--						The attribute RAM is defined as 9 bits wide but we're not using the parity bit for anything yet.
--						It could be used for an underline attribute or to specify an alternate font. 
--
--						This module is built upon some VGA test pattern code written by Mike Field (hamster@snap.net.nz)
--						Thank you Mike!
--
--
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.NUMERIC_STD.ALL;

--
-- Entity VGA takes a pixel clock in and generates RGB and SYNC
-- which are then fed to the DVID entity.
--
--

entity vga is
   generic (
      hRez       : natural := 640; -- 1920 default is 640x480, but these values are overridden to 1920x1080 in DVID.VHD
      hStartSync : natural := 656; -- 2008
      hEndSync   : natural := 752; -- 2052
      hMaxCount  : natural := 800; -- 2200
      hsyncActive : std_logic := '0'; -- 1
		
      vRez       : natural := 480; -- 1080
      vStartSync : natural := 490; -- 1084
      vEndSync   : natural := 492; -- 1089
      vMaxCount  : natural := 525; -- 1125
      vsyncActive : std_logic := '1'; -- 1
--
--
		charMaxX  		: integer :=120; -- columns of characters
		charMaxPX 		: integer :=16; -- pixels per character horizontally
		charMaxPY 		: integer :=16; -- pixels per character vertically
		charTabX  		: integer :=0; -- number of characters offset from left

		charMax120X		: integer :=120;

		charMaxShortPY	: integer :=32;
		charMaxTallPY	: integer :=16;
		
		charMax80X		: integer :=80;
		charMax50Y		: integer :=50;
		charTallPY		: integer :=32;

		charStartPX		: integer :=0;-- left margin (pixels)
		charEndPX		: integer :=1920; -- right margin+1
		charStartPY		: integer :=0;	-- top margin
		charEndPY		: integer :=1072;   -- bottom margin+1

		charStart120PX	: integer :=0;-- left margin (pixels)
		charEnd120PX	: integer :=1920; -- right margin+1
		charStart67PY	: integer :=0;	-- top margin
		charEnd67PY		: integer :=1072;   -- bottom margin+1
		charEnd33PY		: integer :=1056;

		charStart80PX	: integer :=320;
		charEnd80PX		: integer :=1600;
		charStart50PY	: integer :=128;
		charEnd50PY		: integer :=928;

		backgroundRed: 	std_logic_vector(7 downto 0)	:= x"00";
		backgroundGreen:	std_logic_vector(7 downto 0)	:= x"00";
		backgroundBlue:	std_logic_vector(7 downto 0)	:= x"00" -- was 0x88, a nice blue
   );

    Port ( 
			pixelClock	: in  STD_LOGIC;

			pixelTall	: in STD_LOGIC;	-- tall mode (33/25 lines depending on pixelFifty)
			pixelEighty	: in STD_LOGIC;	-- eighty column mode (otherwise 120 columns)
			pixelFifty  : in STD_LOGIC;	-- fifty line mode 
			cursorBlock	: in STD_LOGIC;	-- underline or block cursor
	

			romADDR 		: out STD_LOGIC_VECTOR(14 downto 0); -- this is the address we feed the character generator
			romPIXEL		: in	STD_LOGIC_VECTOR (0 downto 0); -- this is the pixel data from the ROM
			romENABLE	: out STD_LOGIC;-- this is the ROM enable, we use it to clock in a pixel
				
			ramADDR 		: out STD_LOGIC_VECTOR(12 downto 0); -- this is the address we feed the character generator
			ramCHAR		: in	STD_LOGIC_VECTOR(8 downto 0); -- this is the pixel data from the ROM, including the extended font bit
			ramATTR		: in  STD_LOGIC_VECTOR(8 downto 0); -- these are our attribute bits

			ramOFFSET	: in STD_LOGIC_VECTOR(12 downto 0);

			cursorADDR	: in STD_LOGIC_VECTOR(12 downto 0); -- this is the address of the cursor
				
         Red        : out STD_LOGIC_VECTOR (7 downto 0);
         Green      : out STD_LOGIC_VECTOR (7 downto 0);
         Blue       : out STD_LOGIC_VECTOR (7 downto 0);
         hSync      : out STD_LOGIC;
         vSync      : out STD_LOGIC;
			blank      : out STD_LOGIC);
end vga;

architecture Behavioral of vga is

    COMPONENT framebuffer
      PORT (
        clka : IN STD_LOGIC;
        addra : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        douta : OUT STD_LOGIC_VECTOR(17 DOWNTO 0)
      );
    END COMPONENT;


   type reg is record
      hCounter : std_logic_vector(11 downto 0);
      vCounter : std_logic_vector(11 downto 0);

		fCounter : std_logic_vector(5 downto 0); -- frame counter. we blink every 32 frames, or approximately 1 hertz
																-- we use the MSB as the blink state

		lineCounter   	: std_logic_vector(12 downto 0);  -- total number of characters in whole lines (0, 80, 160, etc max 1840 for our 80x24 line display)
		rowCounter		: std_logic_vector(7 downto 0); -- vertical pixel within character line, 0 to 15 for our 16x16 character cells
		columnCounter  : std_logic_vector(7 downto 0); -- horizontal number of characters from left edge

		romADDR			: std_logic_vector(14 downto 0);
		ramADDR			: std_logic_vector(12 downto 0);

      red      : std_logic_vector(7 downto 0);
      green    : std_logic_vector(7 downto 0);
      blue     : std_logic_vector(7 downto 0);

      hSync    : std_logic;
      vSync    : std_logic;
      blank    : std_logic;		
   end record;


--
-- this is the original IBM CGA/VGA palette of 16 colors. There are other variations on this in use.
-- but I like this one because it has brown and because PabloDraw seems to use it for ANSI art.
-- I did increase the luminance of the standard white for readability.
--
--
	type Palette is array (0 to 15) of std_logic_vector(7 downto 0);
	
	-- color 0x07 is now 0xCCCCCC instead of 0xAAAAAA
	
	constant redPal :  Palette := ( x"00",x"AA",x"00",x"AA",x"00",x"AA",x"00",x"CC",
											x"55",x"FF",x"55",x"FF",x"55",x"FF",x"55",x"FF");
	constant greenPal: Palette := ( x"00",x"00",x"AA",x"55",x"00",x"00",x"AA",x"CC",
											x"55",x"55",x"FF",x"FF",x"55",x"55",x"FF",x"FF");
	constant bluePal:  Palette := ( x"00",x"00",x"00",x"00",x"AA",x"AA",x"AA",x"CC",
											x"55",x"55",x"55",x"55",x"FF",x"FF",x"FF",x"FF");

   signal r : reg := ((others=>'0'), (others=>'0'), (others=>'0'),
							 (others=>'0'), (others=>'0'), (others=>'0'),
							 (others=>'0'), (others=>'0'),
                      (others=>'0'), (others=>'0'), (others=>'0'), 
                      '0', '0', '0');
   signal n : reg;   
	
	signal invertPIXEL: std_logic_vector(0 downto 0) := (others=>'0');
	signal forcePIXEL : std_logic_vector(0 downto 0) := (others=>'0');
	
	signal dout 		: std_logic_vector(17 downto 0);
	signal clkdiv2 	: std_logic;

	signal startPX 	: std_logic_vector(11 downto 0) := (others=>'0');
	signal endPX 		: std_logic_vector(11 downto 0) := (others=>'0');

	signal startPY 	: std_logic_vector(11 downto 0) := (others=>'0');
	signal endPY 		: std_logic_vector(11 downto 0) := (others=>'0');

	signal maxX 		: std_logic_vector(11 downto 0) := (others=>'0');
	signal maxPY 		: std_logic_vector(11 downto 0) := (others=>'0');

begin
	
   
   Green   <= r.red; -- red and green are swapped for historical reasons
   Red     <= r.green;
   Blue  <= r.blue;


   -- Assign the outputs
   hSync <= r.hSync;
   vSync <= r.vSync;

   blank <= r.blank;


	process(pixelTall)
	begin
		if pixelTall='1' then
			maxPY		<= conv_std_logic_vector(charMaxTallPY,12);
		else
			maxPY		<= conv_std_logic_vector(charMaxShortPY,12);
		end if;
	end process;

	process(pixelEighty)
	begin
		if pixelEighty='1' then
			startPX	<= conv_std_logic_vector(charStart80PX,12); -- type conversion with target size in bits specified because ADA
			endPX		<= conv_std_logic_vector(charEnd80PX,12);
			maxX		<= conv_std_logic_vector(charMax80X,12);
		else
			startPX	<= conv_std_logic_vector(charStartPX,12);
			endPX		<= conv_std_logic_vector(charEndPX,12);
			maxX		<= conv_std_logic_vector(charMaxX,12);
		end if;
	end process;
	
	process(pixelFifty,pixelTall)
	begin
		if pixelFifty='1' then
			startPY	<= conv_std_logic_vector(charStart50PY,12);
			endPY		<= conv_std_logic_vector(charEnd50PY,12);
		else
			startPY	<= conv_std_logic_vector(charStartPY,12);
			if pixelTall='1' then
				endPY		<= conv_std_logic_vector(charEnd33PY,12);
			else
				endPY		<= conv_std_logic_vector(charEnd67PY,12);
			end if;
		end if;
	end process;
		
   process(r,n,romPIXEL,ramchar,cursoraddr,invertpixel,ramOFFSET,ramATTR,pixelTall,endPY,maxX,startPX,endPX,startPY)
   begin
      n <= r;
      n.hSync <= not hSyncActive;      
      n.vSync <= not vSyncActive;      
		invertPIXEL<= (others=>'0');
		forcePIXEL<= (others=>'0');

		-- here is where we do our normal 
		-- pixel X and Y counters.

      if r.hCounter = hMaxCount-1 then
         n.hCounter <= (others => '0');
			if r.vCounter = vMaxCount-1 then
            n.vCounter <= (others => '0'); -- reset the vertical line counter
				n.fCounter <= r.fCounter + 1; -- increment the frame counter
         else
            n.vCounter <= r.vCounter+1;

				if pixelTall='1' then -- 33/25 lines
					if r.vCounter < startPY OR r.vCounter > endPY-1 then -- we must have an even number of lines, so we're at 33, not 33.5 (1055)
						n.lineCounter<=(others=>'0');
						n.columnCounter<=(others=>'0');
						n.rowCounter<=(others=>'0'); -- this is new
					elsif r.rowCounter = 31 then -- first row of new line of characters, which are 32 pixels high in TALL mode
							n.lineCounter<= r.lineCounter+maxX; -- keeps track of whole lines of characters (0, 80, 160, etc.)
							n.rowCounter<=(others=>'0');
					else
						n.rowCounter<=r.rowCounter+1;
					end if;
				else						-- 67/50 lines
					if r.vCounter < StartPY OR r.vCounter > endPY-1 then
						n.lineCounter<=(others=>'0');
						n.columnCounter<=(others=>'0');
						n.rowCounter<=(others=>'0'); -- this is new
					elsif r.rowCounter = charMaxPY-1 then -- first row of new line of characters
							n.lineCounter<= r.lineCounter+maxX; -- keeps track of whole lines of characters (0, 80, 160, etc.)
							n.rowCounter<=(others=>'0');
					else
						n.rowCounter<=r.rowCounter+1;
					end if;
				end if;

         end if;
      else
         n.hCounter <= r.hCounter+1;
      end if;
	
		-- ramOFFSET is used to implement hardware scrolling in the ANSI terminal. 
		-- this address is used for both character and attribute memory.
		ramADDR <= r.lineCounter + r.columnCounter + ramOFFSET;

		if ((r.lineCounter+r.columnCounter) = cursorADDR) then -- we're at the cursor position
			if cursorBlock='1' and r.fCounter(4) = '1' then -- fCounter(4) defines the cursor blink rate. change the 4 to 5 for 1080p60
				invertPIXEL<= (others=>'1');
			elsif pixelTall='1' and (r.vCounter(4 downto 2) = (CharMAXPY/2)-1) and r.fCounter(4)='1' then -- the cursor is four pixels high (4 downto 2 for tall characters)			
				invertPIXEL<= (others=>'1');
			elsif pixelTall='0' and (r.vCounter(3 downto 1) = (CharMAXPY/2)-1) and r.fCounter(4)='1' then -- the cursor is two pixels high (3 downto 1 for short characters)
				invertPIXEL<= (others=>'1');	
			end if;
		elsif	ramATTR(8)='1' then -- we're not at the cursor position, but we're underlined
			if pixelTall='1' and  (r.vCounter(4 downto 0) = (CharMAXPY*2)-1) then -- the underline is one pixels high (4 downto 1 for tall characters)			
				forcePIXEL<= (others=>'1');
			elsif pixelTall='0' and (r.vCounter(3 downto 0) = (CharMAXPY)-1) then -- the underline is one pixels high (3 downto 0 for short characters)
				forcePIXEL<= (others=>'1');
			end if;
		end if;

				-- calculate the pixel address for the character ROM.
		if pixelTall='1' then
			romADDR <=	ramCHAR(8) & -- alternate font
							r.vCounter(4 downto 2) &
							ramCHAR(7 downto 0) & 
							r.hCounter(3 downto 1);
		else
			romADDR <=	ramCHAR(8) &	-- alternate font
							r.vCounter(3 downto 1) &
							ramCHAR(7 downto 0) & 
							r.hCounter(3 downto 1);
		end if;

		if r.hCounter  <= hRez+1 and r.vCounter  < vRez and r.hCounter>1 then -- are we within the active area of the screen? disable blanking
			n.blank <= '0';

			if r.vcounter <endPY AND r.vcounter>= startPY then--!
		
				if r.hcounter>=startPX and r.hcounter<endPX then 
				
					if r.hcounter(3 downto 0) = charMaxPX-1 then
						if r.columnCounter=maxX-1 then
							n.columnCounter<=(others=>'0');
						else
							n.columnCounter<=r.columnCounter+1;
						end if;
					end if;				

					if forcePIXEL=1 then
						if invertPixel=0 then  -- blink/underline
								n.red   <=redPal(   conv_integer(ramATTR(7 downto 4)));
								n.green <=greenPal( conv_integer(ramATTR(7 downto 4)));
								n.blue  <=bluePal(  conv_integer(ramATTR(7 downto 4)));
						else
								n.red   <=redPal(   conv_integer(ramATTR(3 downto 0)));
								n.green <=greenPal( conv_integer(ramATTR(3 downto 0)));
								n.blue  <=bluePal(  conv_integer(ramATTR(3 downto 0)));
						end if;

					else
					
						if romPIXEL /= invertPixel then  -- blink/underline
								n.red   <=redPal(   conv_integer(ramATTR(7 downto 4)));
								n.green <=greenPal( conv_integer(ramATTR(7 downto 4)));
								n.blue  <=bluePal(  conv_integer(ramATTR(7 downto 4)));
						else
								n.red   <=redPal(   conv_integer(ramATTR(3 downto 0)));
								n.green <=greenPal( conv_integer(ramATTR(3 downto 0)));
								n.blue  <=bluePal(  conv_integer(ramATTR(3 downto 0)));
						end if;
					end if;

				else	-- we are outside the edges horizontally so we (optionally?) show a different background color (usually just black)
				 n.red	<=backgroundRed;
				 n.green	<=backgroundGreen;
				 n.blue  <=backgroundBlue;
				end if;
			else
				 n.red	<=backgroundRed;
				 n.green	<=backgroundGreen;
				 n.blue  <=backgroundBlue;
			end if;
      else
         n.red   <= (others => '0');
         n.green <= (others => '0');
         n.blue  <= (others => '0');
         n.blank <= '1';
      end if;
      
      -- Are we in the hSync pulse?
      if r.hCounter >= hStartSync and r.hCounter < hEndSync then
         n.hSync <= hSyncActive;
      end if;

      -- Are we in the vSync pulse?
      if r.vCounter >= vStartSync and r.vCounter < vEndSync then
         n.vSync <= vSyncActive; 
      end if;
   end process;

   process(pixelClock,n,clkdiv2)
   begin
      if rising_edge(pixelClock)
      then
         r <= n;
			clkdiv2 <= not clkdiv2;
      end if;	
			romENABLE<=clkdiv2;
   end process;
end Behavioral;