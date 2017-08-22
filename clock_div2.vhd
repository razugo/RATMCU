----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/09/2016 10:30:26 AM
-- Design Name: 
-- Module Name: Clk_Div_2 - Behavioral
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

entity clock_div2 is
    Port ( CLK     : in  STD_LOGIC;
           DIV_CLK : out STD_LOGIC);
end clock_div2;

architecture Behavioral of clock_div2 is

   signal DIV_CLK_sig : std_logic := '0';
   
begin
   proc: process(CLK, DIV_CLK_sig)
   begin
      if (rising_edge(CLK)) then
         DIV_CLK_sig <= NOT DIV_CLK_sig;
      end if;   
   end process proc;
   
   DIV_CLK <= DIV_CLK_sig;
  
end Behavioral;