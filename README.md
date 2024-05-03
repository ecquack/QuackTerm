# QuackTerm

QuackTerm is an open source ANSI terminal with HDMI output and PS/2 keyboard input that talks to the host over a USB serial port.
 
    • Designed for Xilinx Spartan-6
    • ANSI terminal with 16 color display
    • ISO 8859-1 font (with Windows codepage 1252 and VT100 extensions)
    • Alternate IBM PC codepage 437 font
    • Up to 120 characters by 67 lines on a 1080p HDMI display
    • PS/2 keyboard for input
    • UART connection defaults to 115200 baud
    • Hardware scrolling
    • No external memory required. Uses thirteen 18kb Xilinx block rams. 
    • Uses two PicoBlaze-6 soft core processors
    

QuackTerm is a VHDL IP core which you can adapt and use in your own designs.  It was designed for the Saanlima Electronics Pipistrello evaluation board but it uses only a small fraction of the Xilinx Spartan-6 LX45. It does not require any external memory. It should be easily ported to any Spartan-6 board. Drop me a line if you need assistance porting it.  It is not easily portable to a Spartan-3 or an Altera part because it uses the Xilinx Picoblaze-6 microprocessor IP core which is built for the LUT size of a Spartan 6, but it should work on a Xilinx Virtex-6 or 7 (or a Zynq) if you're lucky enough to have one.

## Video Display

QuackTerm generates a display using HDMI 1080p30 (1920x1080 progressive scan 30 FPS) which can display up to 67 lines of characters with 120 characters per line (120x67). The character resolution can also be set to 80x50, 80x25, and a few other resolutions. You can change the pixel clock from 75mhz to 150mhz to generate 1080p60 (the cursor will blink faster), which works for me but which doesn't quite meet the FPGA timing constraints for a chip with a -3 speed rating so use it at your own risk. I've thought about implementing support for 1080i60 (interlaced) but so far what I have works fine on every HDMI display I have tried it with. It does not use HDCP or any advanced features of HDMI- it basically acts as a DVI port.

I had hoped to add HDMI audio support in version 2 for the terminal bell, but I've moved on to other projects. Right now it just flashes the screen.

The HDMI code is based on the work of Mike Field (hamster@snap.net.nz), so he should get all the credit for the 1080p display unless there's something wrong with it in which case it's probably due to my modifications.

The terminal supports  sixteen foreground and sixteen background colors for each character. These are used to implement reverse video and boldface. The palette is the same as the original IBM VGA default palette. The terminal has a hardware underline cursor which blinks every 32 video frames. The hardware supports underlining but does not directly support blinking text.

## Keyboard

The terminal accepts user input from a PS/2 keyboard which by default is attached using the main PS/2 port on a Papilio "Arcade Megawing" board from the Gadget Factory. You can edit the UCF file to use a PS/2 port on the PMOD connector (like the Saanlima Oberon Wing), or you could just wire up a mini-DIN connector yourself and attach it to the board (you'll need +5 volts, ground, clock, data, and two 270 ohm current limiting resistors in series with the clock and data). 

The LED lights (CAPS LOCK, NUMLOCK, and SCROLL LOCK) reflect the appropriate states.

If you need local echo for some reason, press shift-scroll_lock, which toggles between normal and local echo mode.

## Serial Communications

QuackTerm communicates over a UART which defaults to 115200 baud (set in hardware). This port is connected to the USB serial port converter on the Pipistrello board but it doesn't have to be. You could easily wire up a MAX232 chip and a DB9 connector to get a true RS-232 port.  It is a two wire interface. There is no hardware handshaking, but the terminal can keep up with the full baud rate under ordinary conditions as long as you don't send a multiple clear screen, delete line, or insert line commands in a row. 

QuackTerm includes a small soft core microprocessor (a PicoBlaze-6 with 1K word of program ROM and 64 bytes of RAM) running a program which converts PS/2 scan codes from the keyboard into ASCII characters. A second microprocessor with 2K ROM processes ANSI escape codes and manages the actual terminal emulation. The programs are written in assembly language.

## Character Display

QuackTerm uses an 8x8 pixel font (scaled up in hardware) which contains an ISO 8859-1 compatible font which is based on Windows codepage 1252 and contains the standard VT100 graphics symbols in the unused 32 lower characters. It thus contains common line drawing characters and alphabetic symbols with diacritics necessary for representing many (but not all) European languages. If you're using QuackTerm and would prefer a different character set please send me an email and I can help you out. Alternate ROM files are supplied which contains codepage 437 (the original U.S. market IBM PC) and codepage 850  (standard on IBM PCs sold in Europe) fonts but you'll have to rebuild the project to use them. The font currently only takes one Xilinx block memory (2K bytes of ROM).

## ANSI Emulation

QuackTerm supports a working subset of the ANSI 3.64 (ECMA-48) terminal specification which is available as a free download from ECMA. The control codes it accepts are detailed in Appendix B. The goal was to approximate the behavior of a typical ANSI emulation well enough to use the terminal with linux, so it's loosely based on the control codes found in PuTTY, GNU xterm, Windows HyperTerminal, and the Microsoft "ANSI.SYS" console in Windows 10.
Linux Support

All my linux testing has been under Ubuntu 16.04.2 LTS desktop. If you're running a different distribution your results may vary. 

If you issue the command

```

sudo setsid agetty -L ttyUSB1 115200 xterm

```

you  should get a login prompt on the terminal. You may have to change the device name from ttyUSB1 if you have other USB serial ports attached. Once you login you should issue the command 

```

	stty cols 120 rows 67

```

to set the screen size. You may also wish to change the locale by issuing the command
```
	LANG=C
```
because the default is UTF-8 and QuackTerm does not support unicode. Sorry!

The following linux programs have been tested and work correctly under Ubuntu 16.0.4:
    • ls (shows directory entries in color)
    • resize (correctly reports the screen size)
    • nano (text editor)
    • vim (text editor)
    • xemacs (text editor)
    • nethack (classic game)
    • mc (midnight commander, a file manager)
    • sc (spreadsheet calculator)
    • htop (task monitor)
    • bastet (a game similar to Tetris)
    • AlienWave (a game in the Space Invaders family)

## TermInfo

The configuration provided in the xterm  terminfo file does not precisely match the capabilities of QuackTerm although it works fine with all the programs I have tested.  You can also use the ansi terminfo file, although it does not support the function keys and graphics characters. If you have problems with an ncurses based linux application you may wish to use the provided quackterm.terminfo file instead. To install it for the current user you use the commands:

```

	tic quackterm.terminfo
	TERM=quack

```

Once you have installed it, reissue the the agetty command:

```

sudo setsid agetty -L ttyUSB1 115200 quack

```

If you're not seeing color coded directory listings from ls you may have to set the LS_COLORS environment variable manually. An example LS_COLORS.quack file is included. 

## Appendix A: Keyboard

The keyboard map is based on the key codes transmitted by the PuTTY program. Note that combining a regular key with the alt key will set the high bit of the ASCII character, generating codes from 128-256. The firmware assumes a U.S. English keyboard because that's what we use here in British Columbia. Send me and email if you need help modifying the code to support a different keyboard.

The following keys produce the escape or control sequences shown:

### Control keys

```

Control-@	ASCII code 0 (NULL)
Control-[	ASCII code 27, 0x1B (ESCAPE)
Control-\	ASCII code 28, 0x1C
Control-]	ASCII code 29, 0x1D
Control-^	ASCII code 30, 0x1E
Control-_	ASCII code 31, 0x1F
Control-?	ASCII code 127, 0x7F (DELETE)
Control-BS	(ctrl-backspace) ASCII code 127, 0x7F (DELETE)

```

### Editing Keys

```

Up-arrow	ESC [ A
Down-arrow	ESC [ B
Right-arrow	ESC [ C
Left-arrow	ESC [ D
Center-key	ESC [ E	(center '5' of numeric keypad when numlock is on)
Home		ESC [ 1 ~
Insert		ESC [ 2 ~
Delete		ESC [ 3 ~
End		ESC [ 4 ~
Page Up	ESC [ 5 ~
Page Down	ESC [ 6 ~

```

### Function Keys

```

F1		ESC O P
F2		ESC O Q
F3		ESC O R
F4		ESC O S
F5		ESC [ 1 5 ~
F6		ESC [ 1 7 ~
F7		ESC [ 1 8 ~
F8		ESC [ 1 9 ~
F9		ESC [ 2 0 ~
F10		ESC [ 2 1 ~
F11		ESC [ 2 3 ~
F12		ESC [ 2 4 ~

```

## #Special Keys 

The following key sequences are non-standard but they do not conflict with GNU xterm's function key definitions.

```

Pause/Break		ESC [ 4 0 ~
Print Screen/SysRq	ESC [ 4 1 ~
Windows		ESC [ 4 2 ~
Menu			ESC [ 4 3 ~
Sleep			ESC [ 4 4 ~

```

### Modifier Keys

When the modifier keys (shift, control, and alt) are used in combination with the function,  editing, and special keys a second modifier parameter is sent which tells the host what combination of modifier keys was used.

The modifier parameters are:

```

    1. none (no parameter is sent in this case)
    2. shift
    3. control
    4. shift-control
    5. alt
    6. shift-alt
    7. control-alt
    8. control-shift-alt

```

For example, if you were to press the F7 key with a shift key held down, Quackterm would send the string ESC [ 1 8 ; 2 ~ to the host. If you were to press control left-arrow the string would be ESC [ 1 ; 3 D. If you were to press shift-F1 the string would be ESC [ 1 ; 2 P.

### System Keys

A few keys do not send codes to the host system. They only change the operating mode of the terminal.
    • Shift-scroll_lock toggles the local echo option on and off. This is primarily useful for debugging since it echoes control and escape codes as well as printable characters.
    • Alt-scroll_lock cycles through the 8 video modes, erasing the screen and displaying a status line in the process. 
    • Control-scroll_lock toggles debug mode on and off. In debug mode all characters are be displayed raw instead of being processed for control and escape sequences, and will appear as special symbols from the IBM PC font.
    • Control-alt-shift-scroll_lock resets the terminal.
    • Numlock switches the numeric keypad from numeric mode to navigation mode.
    • Shift-numlock disables (and enables) the control key on alphabetic characters. This is done in the keyboard processor is used for debugging. 
    • Control-numlock toggles the keypad navigation mode between normal and nethack mode. If you like to play the classic console game nethack, this feature programs the keypad to use the nethack navigation keys. This is done in the keyboard processor. 
    • ALT-numlock sets the keyboard typematic rate to the maximum speed.
    • Shift-pause/break resets the terminal to its default power up state. 

### Video Modes

The terminal supports 8 video modes. They are:

```

Mode 0 (120x67)
Mode 1 (120x33)
Mode 2 (80x67)
Mode 3 (80x33)
Mode 4 (120x50)
Mode 5 (120x25)
Mode 6 (80x50)
Mode 7 (80x25)

```

### In-Band Keys

A few key sequences are sent from the PS/2 keyboard processor to the terminal processor but are never forwarded to the host. These sequences are preceded by hex character 0x9E and followed by a single character.

    • 0x9E 0x9E (symbol 0x9E is forwarded to the host)
    • 0x9E 's' (lower case s)
    • 0x9E 'S' (capital S)
    • 0x9E 0x13 (control-S)
    • 0x9E 0xFE (alt lower case s with high bit set)
    • 0x9E 0x93 (alt control-S with high bit set)
    • 0x9E "$" (dollar sign)
    • 0x9E 0xDE (alt upper case S with high bit set)
    • 0x9E 0xA4 (alt dollar sign with high bit set)

They are used to control special features of the terminal.

## Appendix B: Control and Escape sequences

The supported command sequences are a superset of those supported by PuTTY, HyperTerminal, xterm, and ANSI.SYS. There are many obscure ANSI and VT100 codes that are not supported. If your favorite code is missing just send me an email and I may include it in a future version.

The following CSI escape sequences are supported (ESC followed by an open bracket):

```

ESC [ n @	insert n characters on the current line
ESC [ A		move up one line.
ESC [ n A	move up n lines.
ESC [ B		move down one line.
ESC [ n B	move down n lines.
ESC [ C		move right one character.
ESC [ n C	move right n characters.
ESC [ D		move left one character.
ESC [ n D	move left n characters.
ESC [ y ; x f	alias for ESC [ y; x H (absolute cursor position)
ESC [ G		delete the current line and move subsequent lines up
ESC [ H		move cursor to upper left corner (home)
ESC [ y ; x H	absolute cursor position to row y column x where x and y are decimal numbers with 			the origin at 1,1 (not 0,0). 
ESC [ I		move right one tab stop
ESC [ n I		move right n tab stops (8 spaces per tab fixed)
ESC [  J		clear from current position to end of screen
ESC [  0 J	clear from current position to end of screen
ESC [ 1 J	clear from current position to beginning of screen 
ESC [ 2 J	clear entire screen and home cursor (upper left)
ESC [ K		clear to end of line
ESC [ 0 K	clear to end of line
ESC [ 1 K	clear to beginning of line
ESC [ 2 K	clear entire line
ESC [ M		insert a line
ESC [ m		clear all character attributes. set colors to white on black.
ESC [ 0 m	clear all character attributes as above
ESC [ 1 m	set boldface (sets high bit of foreground color for brighter colors)
ESC [ 4 m	set underline mode
ESC [ 5 m	set bright background (high bit). Normally this sets "blink"
ESC [ 7 m	set inverse video (swaps foreground and background color). 
ESC [ 8 m	set hidden video (foreground matches background color)
ESC [ 10 m	sets normal font, ISO 8859-1 Latin-1 (Windows codepage 1252)
ESC [ 11 m	sets VT100 graphics font, replacing lower case characters with symbols
ESC [ 12  m	sets IBM PC codepage 437 font
ESC [ 13 m	sets IBM PC codepage 437 font with graphics characters in place of lower case
ESC [ 22 m	disable bold (clears high bit of foreground color)
ESC [ 24 m	disable underline mode
ESC [ 25 m	disable blink (clears high bit of background color)
ESC [ 27 m	disable inverse video (restores foreground and background color)
ESC [ 28 m	disable hidden mode (restores foreground color)
ESC [ 30-37 m	set foreground color  (30 black, 31 red, 32 green, 33 yellow, 34 blue, 35 magenta, 36 			cyan, 37 white)
ESC [ 39 m	set foreground color to default
ESC [ 40-47 m	set background color (same sequence as foreground colors)
ESC [ 49 m 	set background color to default
ESC [ 6 n	cursor position report. Returns "ESC [ y ; x R" to host.
ESC [ n P	delete n characters forward on the current line
ESC [ n Z	go back n tab stops (intervals of 8)
ESC [ ? 12 h	block cursor mode
ESC [ ? 12 l	underline cursor mode (default)
ESC [ ? 25 h	makes the cursor visible
ESC [ ? 25 l 	makes the cursor invisible

```

The following regular escape sequences are supported (no open bracket):

```

ESC 7		saves the current cursor position and attributes (non-ANSI VT100 code)
ESC 8		restores the previously saved cursor position and attributes (non-ANSI VT100 code)
ESC c		resets the terminal
ESC N		single shift 2. the next character received is printed raw, even if it's a control character  			(non-standard behavior)
ESC ( B		select default font , equivalent to ESC [ 10 m
ESC ( 0		enable VT100 graphics characters instead of lower case, equivalent to ESC [ 11 m
ESC ( 1		select alternate font, equivalent to ESC [ 12 m
ESC ( 2		select alternate font with low graphics, equivalent to ESC [ 13 m
ESC ( a		resets to video mode 0 (120x67) [not standard ANSI]
ESC ( b		resets to video mode 1 (120x33) [not standard ANSI]
ESC ( c		resets to video mode 2 (80x67) [not standard ANSI]
ESC ( d		resets to video mode 3 (80x33) [not standard ANSI]
ESC ( e		resets to video mode 4 (120x50) [not standard ANSI]
ESC ( f		resets to video mode 5 (120x25) [not standard ANSI]
ESC ( g		resets to video mode 6 (80x50) [not standard ANSI]
ESC ( h		resets to video mode 7 (80x25) [not standard ANSI]
```
The following control characters are supported:
```
Control-G	flashes the screen (bell)
Control-H	backspace- moves the cursor to the left
Control-I	nondestructive move to the next tab stop, a multiple of 8 characters
Control-J	line feed, advances to the next line at the same column
Control-L	form feed. clears the screen and moves the cursor to the upper left
Control-M	carriage return, moves to the first column of the current line
Control-?	Control question mark is ASCII code 127 (0x7F) which performs a destructive backspace, erasing the character preceding the cursor and moving to the left. This code is sometimes called RUBOUT or DELETE and can also be generated by pressing shift-backspace.
```
## VT100 Graphics

The following graphics characters replace some of the lower case letters and symbols when in VT100 graphics mode. 
```
a▒  f° g± j┘ k┐ l┌ m└ n┼ q─ t├ u┤ v┴ w┬ x│ y≤ z≥ {π |≠ }£ ~· `◆
```
The line drawing characters in particular are used by a number of terminfo/ncurses aware applications under linux.

## Appendix C: VHDL Details

### Microprocessors

The design uses two PicoBlaze-6 microprocessors. The main processor interprets the ANSI terminal commands and manages the character display memory and video mode. The secondary processor converts PS/2 scan codes from the keyboard into ASCII characters.

### Block Memory

The design uses thirteen Xilinx 18kbit block memories organized as 2Kx8, 1Kx18, or 16Kx1. 
The design uses 8Kx9 bits for the character display (120x67=8038, with 8 bits for the symbol plus one bit to select the alternate font) and 8Kx9 bits for the character attributes (16 foreground and 16 background colors for each character plus an underline mode bit using the parity bit), for a total of 8 block RAMs. The Xilinx block RAMs have built in parity bits which we're using to select underline mode and the alternate font. These memories are dual ported. One side is read by the VGA process to generate the display. The other side can be read and written by the main microprocessor.

The design uses two block RAMS (arranged as 1Kx18 bits wide) for the main microprocessor's program ROM, giving us a program size of 2048 instruction words. The PicoBlaze-6 has an instruction word size of 18 bits. This RAM is read only, although there is a JTAG port defined which allows you to upload new firmware using the Xilinx "jtagload" utility without requiring a complete rebuild of the FPGA. "jtagload" is included with the PicoBlaze-6 distribution. You can use it with the Pipistrello's built in programming port; there is no need for a dedicated JTAG interface.

The design uses a single block RAM for the secondary (keyboard) microprocessor's program ROM, giving a program size of 1024 instruction words. You cannot use the JTAG utility to program the keyboard processor. You must re-synthesize the design if you make changes to the keyboard firmware.

The design uses two block memories to store the character fonts. This ROM is arranged as 32Kx1 and is read only. It stores 512 characters in an 8x8 pixel matrix. The block RAM's address lines are divided into three sections: there are 3 bits which select the pixel row, 8 bits which select the character, and 3 bits which select the pixel column  The row is selected by the 3 most significant bits. The column is selected by the 3 least significant bits. The character address uses the middle 8 bits. Here is the VHDL statement that calculates the font address:

>		romADDR <=	ramCHAR(8) & 
>				r.vCounter(3 downto 1) &
>				 ramCHAR(7 downto 0) & 
>				 r.hCounter(3 downto 1);
It would not be difficult to support an 8x16 font. You would merely need to change "vCounter(3 downto 1)" to "vCounter(3 downto 0)" and double the size of the ROM.
