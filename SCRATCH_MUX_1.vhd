----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/22/2016 02:01:56 PM
-- Design Name: 
-- Module Name: SCRATCH_MUX_1 - Behavioral
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SCRATCH_MUX_1 is
  Port (DATA_IN_1: in STD_LOGIC_VECTOR (7 downto 0);
        DATA_IN_2: in STD_LOGIC_VECTOR (9 downto 0);
        MUX_SEL: in STD_LOGIC;
        DATA_OUT: out STD_LOGIC_VECTOR (9 downto 0));
end SCRATCH_MUX_1;

architecture Behavioral of SCRATCH_MUX_1 is

begin
with MUX_SEL select
    DATA_OUT <= "00" & DATA_IN_1 when '0',
                DATA_IN_2 when '1',
                "0000000000" when others;
end Behavioral;
