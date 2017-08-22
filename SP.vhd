----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/18/2016 02:18:20 PM
-- Design Name: 
-- Module Name: SP - Behavioral
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
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SP is
  Port (RST: IN STD_LOGIC;
        LD: IN STD_LOGIC;
        INCR: IN STD_LOGIC;
        DECR: IN STD_LOGIC;
        DATA_IN: IN STD_LOGIC_VECTOR (7 downto 0);
        CLK: IN STD_LOGIC;
        DATA_OUT: OUT STD_LOGIC_VECTOR (7 downto 0));
end SP;

architecture Behavioral of SP is
begin
SP_process: process (RST, CLK, INCR, DECR, LD, DATA_IN)

variable DATA: STD_LOGIC_VECTOR (7 downto 0) := (others => '0');

begin
    
   if (rising_edge(clk)) then
        if (RST = '1') then
           DATA := (others => '0');
        elsif (INCR = '1') then
            DATA := DATA + 1;
        elsif (DECR = '1') then
            DATA := DATA - 1;
        elsif (LD = '1') then
            DATA := DATA_IN;
        end if;
    end if;
    
    DATA_OUT <= DATA;
end process;


end Behavioral;
