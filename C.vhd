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


entity C is
    Port ( C_IN    : in  STD_LOGIC; --flag input
           FLG_C_LD   : in  STD_LOGIC; --load Q with the D value
           FLG_C_SET  : in  STD_LOGIC; --set the flag to '1'
           FLG_C_CLR  : in  STD_LOGIC; --clear the flag to '0'
           CLK  : in  STD_LOGIC; --system clock
           C_FLAG    : out  STD_LOGIC); --flag output
end C;

architecture Behavioral of C is
   signal s_C : STD_LOGIC := '0';  
begin
    process(CLK)
    begin
        if( rising_edge(CLK) ) then
            if( FLG_C_LD = '1' ) then
                s_C <= C_IN;
            elsif( FLG_C_SET = '1' ) then
                s_C <= '1';
            elsif( FLG_C_CLR = '1' ) then
                s_C <= '0';
         end if;
      end if;
    end process;	

    C_FLAG <= s_C; 
    
end Behavioral;

