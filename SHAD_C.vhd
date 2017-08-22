------------------------------------------------------------------------------
-- Company: RAT Technologies
-- Engineer: James Ratner
-- 
-- Create Date:    13:55:34 04/06/2014 
-- Design Name: 
-- Module Name:    Mux - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: Full featured D Flip-flop intended for use as flag registers. 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity SHAD_C is
    Port ( C_IN    : in  STD_LOGIC; --flag input
           LD   : in  STD_LOGIC; --load Q with the D value
           CLK  : in  STD_LOGIC; --system clock
           C_OUT    : out  STD_LOGIC); --flag output
end SHAD_C;

architecture Behavioral of SHAD_C is
   signal s_C : STD_LOGIC := '0';  
begin
    process(CLK)
    begin
        if( rising_edge(CLK) ) then
            if( LD = '1' ) then
                s_C <= C_IN;
         end if;
      end if;
    end process;	

    C_OUT <= s_C; 
    
end Behavioral;
