----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/09/2016 03:38:29 PM
-- Design Name: 
-- Module Name: SCRATCH_RAM - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
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
use IEEE.STD_LOGIC_UNSIGNED.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SCRATCH_RAM is
  Port (SCR_ADDR: in std_logic_vector (7 downto 0);
        SCR_WR: in std_logic;
        SCR_DATA_IN: in std_logic_vector (9 downto 0);
        CLK: in std_logic;
        SCR_DATA_OUT: out std_logic_vector (9 downto 0));
end SCRATCH_RAM;

architecture Behavioral of SCRATCH_RAM is
type ram_type is array (255 downto 0) of std_logic_vector(9 downto 0);
   signal ram : ram_type;

begin

ScratchRamProc: process(CLK, SCR_WR, SCR_ADDR, SCR_DATA_IN) is

  begin
    if (rising_edge(CLK) AND SCR_WR = '1') then
        ram(conv_integer(SCR_ADDR)) <= SCR_DATA_IN;
      end if;      
  end process ScratchRamProc;

SCR_DATA_OUT <= ram(conv_integer(SCR_ADDR));


end Behavioral;
