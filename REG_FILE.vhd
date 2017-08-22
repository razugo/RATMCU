----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/09/2016 02:40:03 PM
-- Design Name: 
-- Module Name: REG_FILE - Behavioral
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

entity REG_FILE is
  Port (RF_WR_DATA: in std_logic_vector (7 downto 0);
        ADRX: in std_logic_vector (4 downto 0);
        ADRY: in std_logic_vector (4 downto 0);
        RF_WR: in std_logic;
        CLK: in std_logic;
        DX_OUT: out std_logic_vector (7 downto 0);
        DY_OUT: out std_logic_vector (7 downto 0));
end REG_FILE;

architecture Behavioral of REG_FILE is
type ram_type is array (31 downto 0) of std_logic_vector(7 downto 0);
   signal ram : ram_type;

begin
   RamProc: process(RF_WR, ADRX, RF_WR_DATA, CLK) is
    begin
            if (rising_edge(CLK) and RF_WR = '1') then
                ram(conv_integer(ADRX)) <= RF_WR_DATA;
            end if;
    end process;
    
    DX_OUT <= ram(conv_integer(ADRX));
    DY_OUT <= ram(conv_integer(ADRY));            
    
end Behavioral;
