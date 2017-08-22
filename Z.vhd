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


entity Z is
    Port ( Z_IN    : in  STD_LOGIC; --flag input
           FLG_Z_LD   : in  STD_LOGIC; --load Q with the D value
           CLK  : in  STD_LOGIC; --system clock
           Z_FLAG    : out  STD_LOGIC); --flag output
end Z;

architecture Behavioral of Z is
   signal s_Z : STD_LOGIC := '0';  
begin
    process(CLK)
    begin
        if( rising_edge(CLK) ) then
            if( FLG_Z_LD = '1' ) then
                s_Z <= Z_IN;
         end if;
      end if;
    end process;	

    Z_FLAG <= s_Z; 
    
end Behavioral;
