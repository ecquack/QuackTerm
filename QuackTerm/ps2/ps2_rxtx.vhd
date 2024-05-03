-- Listing 9.2
library ieee;
use ieee.std_logic_1164.all;
library unisim;
use unisim.vcomponents.all;

entity ps2_rxtx is
   port (
      clk, reset: in std_logic;
      wr_ps2: in std_logic;
      din: in std_logic_vector(7 downto 0);
      dout: out std_logic_vector(7 downto 0);
      rx_done_tick: out  std_logic;
      tx_done_tick: out std_logic;
		ps2_data_out: in std_logic;
		ps2_data_in: out std_logic;
		ps2_data_z: out std_logic;
		ps2_clk_out: in std_logic;
		ps2_clk_in: out std_logic;
		ps2_clk_z: out std_logic
   );
end ps2_rxtx;

architecture arch of ps2_rxtx is
   signal tx_idle: std_logic :='1';

begin

   ps2_tx_unit: entity work.ps2_tx(arch)
      port map(
					clk=>				clk,
					reset=>			reset,
					wr_ps2=>			wr_ps2,
               din=>				din,
					ps2_data_out=>	ps2_data_in,
					ps2_clk_out=>	ps2_clk_in,
					--ps2_data_in =>	ps2_data_out,
					ps2_clk_in=>	ps2_clk_out,
					ps2_data_z=>	ps2_data_z,
					ps2_clk_z=>		ps2_clk_z,
               tx_idle=>		tx_idle,
					tx_done_tick=>	tx_done_tick
					);
					
   ps2_rx_unit: entity work.ps2_rx(arch)
      port map(clk=>clk, reset=>reset, rx_en=>tx_idle,
               ps2d=>ps2_data_out, ps2c=>ps2_clk_out,
               rx_done_tick=>rx_done_tick, dout=>dout);
end arch;