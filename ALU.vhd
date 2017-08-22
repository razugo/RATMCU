----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/12/2016 03:25:08 PM
-- Design Name: 
-- Module Name: ALU - Behavioral
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

entity ALU is
  Port (A: in std_logic_vector (7 downto 0);
        B: in std_logic_vector (7 downto 0);
        SEL: in std_logic_vector (3 downto 0);
        Cin: in std_logic;
        RESULT: out std_logic_vector (7 downto 0);        
        C: out std_logic;
        Z: out std_logic);
end ALU;

architecture Behavioral of ALU is
begin
    process (A, B, SEL, Cin)
    variable v_res: std_logic_vector (8 downto 0) := "000000000";    
    begin
        Z <= '0'; C <= '0';
        RESULT <= "00000000";
        case SEL is
            when "0000" =>
                v_res:= ('0' & A) + ('0' & B);
                C <= v_res(8);
                RESULT <= v_res (7 downto 0); 
            when "0001" =>
                v_res:= ('0' & A) + ('0' & B) + Cin;
                C <= v_res(8); 
                RESULT <= v_res (7 downto 0); 
            when "0010" =>
                v_res:= ('1' & A) - ('1' & B);
                C <= v_res(8);
                RESULT <= v_res (7 downto 0); 
            when "0011" =>
                v_res:= ('1' & A) - ('1' & B) - Cin;
                C <= v_res(8);    
                RESULT <= v_res (7 downto 0); 
            when "0100" =>
                v_res:= ('1' & A) - ('1' & B);
                C <= v_res(8);
                RESULT <= A;
            when "0101" =>
                v_res:= ('0' & A) AND ('0' & B);
                C <= v_res(8);
                RESULT <= v_res (7 downto 0); 
            when "0110" =>
                v_res:= ('0' & A) OR ('0' & B);
                C <= v_res(8);
                RESULT <= v_res (7 downto 0); 
            when "0111" =>
                v_res:= ('0' & A) XOR ('0' & B);
                C <= v_res(8);
                RESULT <= v_res (7 downto 0); 
            when "1000" => 
                v_res:= ('0' & A) AND ('0' & B);
                C <= v_res(8);
                RESULT <= v_res (7 downto 0);
            when "1001" => 
                v_res:= A & Cin;
                C <= v_res(8);
                RESULT <= v_res (7 downto 0);
            when "1010" =>
                C <= v_res(0);
                v_res:= Cin & A;
                RESULT <= v_res (8 downto 1);
            when "1011" => 
                v_res:= (A(7 downto 0) & A(7));
                C <= v_res(8);
                RESULT <= v_res (7 downto 0);
            when "1100" => 
                v_res:= A(0) & A(7 downto 0);
                C <= v_res(8);
                RESULT <= v_res (8 downto 1);
            when "1101" =>
                v_res:= (A(0) & A(7) & A(7 downto 1));
                C <= v_res(8);
                RESULT <= v_res (7 downto 0);
            when "1110" =>
                v_res:= (Cin & B(7 downto 0));
                C <= v_res(8);
                RESULT <= v_res (7 downto 0);
            when others => v_res:= (others => '1');
            RESULT <= v_res (7 downto 0);
          end case;
          
          if (v_res(7 downto 0) = X"00") then
            Z <= '1';
          end if;
          
           
       end process;   
            
       
end Behavioral;
