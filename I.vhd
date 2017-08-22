----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/21/2016 06:09:55 PM
-- Design Name: 
-- Module Name: I- Behavioral
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

entity I is
    Port ( CLK : in STD_LOGIC;
           I_SET : in STD_LOGIC;
           I_CLR : in STD_LOGIC;
           INT_OUT : out STD_LOGIC);
end I;

architecture Behavioral of I is
signal INT : STD_LOGIC;

begin
process(CLK)
    begin
        if (rising_edge(CLK)) then 
            if (I_SET = '1') then
                INT <= '1';     -- sets AND gate
            elsif (I_CLR = '1') then 
                INT <= '0';     -- kills AND gate
            end if;
        end if;
end process;        
              
INT_OUT <= INT;
              
end Behavioral;
