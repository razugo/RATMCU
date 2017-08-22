----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/16/2016 02:33:36 PM
-- Design Name: 
-- Module Name: MUX_IN_REG - Behavioral
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

entity MUX_IN_REG is
  Port (IN_PORT_IN: IN STD_LOGIC_VECTOR (7 downto 0);
        B: IN STD_LOGIC_VECTOR (7 downto 0);
        INPUT: IN STD_LOGIC_VECTOR (7 downto 0);
        RF_WR_SEL: IN STD_LOGIC_VECTOR (1 downto 0);
        ALU_RESULT: IN STD_LOGIC_VECTOR (7 downto 0);
        OUTPUT_REG: OUT STD_LOGIC_VECTOR (7 downto 0));
end MUX_IN_REG;

architecture Behavioral of MUX_IN_REG is

begin
with RF_WR_SEL select
    OUTPUT_REG <= ALU_RESULT when "00",
                 INPUT when "01",
                 B when "10",
              IN_PORT_IN when "11",
              "00000000" when others;

end Behavioral;
