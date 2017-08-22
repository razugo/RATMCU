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

entity MUX_IN_Z is
  Port (INPUT_1: IN STD_LOGIC;
        INPUT_2: IN STD_LOGIC;
        MUX_SEL: IN STD_LOGIC;
        OUTPUT: OUT STD_LOGIC);
end MUX_IN_Z;

architecture Behavioral of MUX_IN_Z is
signal ZFLG: STD_LOGIC;
begin
    process (INPUT_1, ZFLG, INPUT_2, MUX_SEL)
    begin
        if (MUX_SEL = '0') then
            ZFLG <= INPUT_1;
        elsif (MUX_SEL = '1') then
            ZFLG <= INPUT_2;
        end if;
    end process;

OUTPUT <= ZFLG;

end Behavioral;
