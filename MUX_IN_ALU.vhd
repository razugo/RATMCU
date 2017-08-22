----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/16/2016 02:39:05 PM
-- Design Name: 
-- Module Name: MUX_IN_ALU - Behavioral
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

entity MUX_IN_ALU is
  Port (MUX_ALU_IN: IN STD_LOGIC_VECTOR (7 downto 0);
        IR: IN STD_LOGIC_VECTOR (7 downto 0);
        ALU_OPY_SEL: IN STD_LOGIC;
        OUTPUT_ALU: OUT STD_LOGIC_VECTOR (7 downto 0));
end MUX_IN_ALU;

architecture Behavioral of MUX_IN_ALU is

begin
with ALU_OPY_SEL select
    OUTPUT_ALU <= MUX_ALU_IN when '0',
              IR when '1',
              "00000000" when others;

end Behavioral;
