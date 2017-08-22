-- Aaron Friedman, Sam Lopez, (Bridget Benson)
-- CPE 233-01
-- Control Unit
-- Lab_5
-- Start with your It's Alive project and add your Scratch Ram and Stack Pointer to the CPU.
-- Connect the components as shown in the CPU diagram and add the appropriate muxes. Be sure
-- to make any changes to muxes you have already implemented to support the new components.
-- Add all of the control signals from your Control Signal table for the It's Alive lab to the Control
-- Unit.
-- Due May 17, 2016
--------------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ControlUnit is

-- INPUTS TO CONTROL UNIT.
    Port ( CLK           : in   STD_LOGIC;
           C             : in   STD_LOGIC;                     -- From DATA_OUT on FLAG. Corresponding signal (wire) is C_FLAG
           Z             : in   STD_LOGIC;                     -- From DATA_OUT on FLAG. Corresponding signal (wire) is Z_FLAG
           INT           : in   STD_LOGIC;                     -- Interrupt input
		   RESET         : in   STD_LOGIC;                     -- RESET Input from development board.
		   OPCODE_HI_5   : in   STD_LOGIC_VECTOR (4 downto 0); -- Upper 5 bits of instruction code from PROG_ROM.
		   OPCODE_LO_2   : in   STD_LOGIC_VECTOR (1 downto 0); -- Lower 2 bits of instruction code from PROG_ROM.
-- OUTPUTS FROM CONTROL UNIT.
           RST           : out  STD_LOGIC;                     -- RESET Output To PC, SP.
-- OUTPUTS TO PC.           
           PC_LD         : out  STD_LOGIC;                     -- To LD for branch instructions.
		   PC_INC        : out  STD_LOGIC;                     -- To INC to increment PC by 1.        		  
           PC_MUX_SEL    : out  STD_LOGIC_VECTOR (1 downto 0); -- To PC MUX.
-- OUTPUTS TO SP.     
           SP_LD_CU      : out  STD_LOGIC;                     -- To SP_LD.
           SP_INCR_CU    : out  STD_LOGIC;                     -- To SP_INCR.
           SP_DECR_CU    : out  STD_LOGIC;                     -- To SP_DECR.
-- OUTPUTS TO REG_FILE. (32 BIT REGISTER)
           RF_WR         : out  STD_LOGIC;                     -- To WR.
		   RF_WR_SEL     : out  STD_LOGIC_VECTOR (1 downto 0); -- To REG_FILE MUX.
-- OUTPUTS TO ALU.
           ALU_SEL       : out  STD_LOGIC_VECTOR (3 downto 0); -- To SEL.
           ALU_OPY_SEL   : out  STD_LOGIC;                     -- To ALU MUX.
-- OUTPUTS TO SCR. (256 ADDRESS LOCATIONS - 10 BITS EACH)
           WR_SEL        : out  STD_LOGIC;                     -- To WR_SEL ON SCRATCH RAM.
           SCR_ADDR_SEL  : out  STD_LOGIC_VECTOR (1 downto 0); -- To SCR 2 by 4 MUX. (SCR_ADDR_MUX)
           SCR_DATA_SEL  : out  STD_LOGIC;                     -- To SCR 1 by 2 MUX. (SCR_DATA_IN_MUX)
-- OUTPUTS TO FLAG.
            
           FLAG_C_SET    : out  STD_LOGIC;                     -- To FLAG. Set C.
           FLAG_C_CLR    : out  STD_LOGIC;                     -- To FLAG. Clear C.
           FLAG_C_LD     : out  STD_LOGIC;                     -- To FLAG. Load C.
           FLAG_Z_LD     : out  STD_LOGIC;                     -- To FLAG. Load Z.
           FLAG_LD_SEL   : out  STD_LOGIC;                     -- To FLAG MUXes.
           FLAG_SHAD_LD  : out  STD_LOGIC;                     -- To SHAD_Z and SHAD_C.
-- OUTPUTS TO INTERRUPTS
           I_SET         : out  STD_LOGIC;                     -- Set interreupt.
           I_CLR         : out  STD_LOGIC;                     -- Clear interrupt.
           IO_STRB		 : out	STD_LOGIC);
end ControlUnit;

architecture Behavioral of ControlUnit is
-- FSM DECLARATION
type state_type is (ST_init, ST_fet, ST_interrupt, ST_exec);
-- SIGNAL DECLARATIONS
signal PS,NS : state_type;
signal sig_OPCODE_7: std_logic_vector (6 downto 0);
begin

sig_OPCODE_7 <= OPCODE_HI_5 & OPCODE_LO_2;
-- Concatenate the all opcodes into a 7-bit complete opcode for easy instruction decoding.

FSM_P: process (CLK, NS, RESET)
   begin
	   if (RESET = '1') then
		   PS <= ST_init;
	   elsif (rising_edge(CLK)) then 
	       PS <= NS;
	   end if;
end process FSM_P;


FSM_C: process (sig_OPCODE_7, C, Z, PS, NS)
begin
-- preset everything to zero --------------------------

-- INITIALIZE PC INPUTS:   
     PC_LD         <= '0';     PC_MUX_SEL   <= "00";   PC_INC       <= '0';
-- INITIALIZE SP INPUTS:  
     SP_LD_CU      <= '0';     SP_INCR_CU   <= '0';    SP_DECR_CU   <= '0';
-- INITIALIZE REG_FILE INPUTS:   
     RF_WR         <= '0';     RF_WR_SEL    <= "00";
-- INITIALIZE ALU INPUTS:
     ALU_SEL       <= "0000";  ALU_OPY_SEL  <= '0'; 
-- INITIALIZE SCR INPUTS:   
     WR_SEL        <= '0';     SCR_DATA_SEL <= '0';    SCR_ADDR_SEL <= "00";
-- INITIALIZE FLAG INPUTS:
     FLAG_C_SET    <= '0';     FLAG_C_LD    <= '0';    FLAG_C_CLR   <= '0';
     FLAG_Z_LD     <= '0';     FLAG_LD_SEL  <= '0';
     FLAG_SHAD_LD <= '0';      
--  RESET & IO_STRB TO ZERO:
     RST     <= '0';
     IO_STRB <= '0';
    I_SET <= '0';
    I_CLR <= '0';

-- OUTER CASE STATEMENT
case PS is
	
-- STATE: the init cycle
when ST_init => 
     RST <= '1';
-- Will reset PC & SP.
	  FLAG_C_CLR <= '1';
      NS  <= ST_fet;
    
-- STATE: the fetch cycle -----------------------------------
when ST_fet => 
   NS <= ST_exec;
   PC_INC <= '1';

    
       
-- STATE: the execute cycle ---------------------------------
when ST_exec => 
     if (INT = '0') then 
        NS <= ST_fet;
     else 
        NS <= ST_interrupt;
     end if;           


-- INNER CASE STATEMENT:		
case sig_OPCODE_7 is

-- ADD reg-reg------------
when "0000100" =>
  ALU_SEL <= "0000";  RF_WR <= '1';  FLAG_C_LD <= '1'; FLAG_Z_LD <= '1';
  
-- ADD reg-immed ---------
when "1010000" | "1010001" | "1010010" | "1010011" =>
  ALU_SEL <= "0000";  RF_WR <= '1';  FLAG_C_LD <= '1'; FLAG_Z_LD <= '1';  ALU_OPY_SEL <= '1';

-- ADDC reg-reg-----------
when "0000101" =>
  ALU_SEL <= "0001"; RF_WR <= '1';  FLAG_C_LD <= '1'; FLAG_Z_LD <= '1';
  
-- ADDC reg-immed --------
when "1010100" | "1010101" | "1010110" | "1010111" =>
  ALU_SEL <= "0001"; RF_WR <= '1';  FLAG_C_LD <= '1'; FLAG_Z_LD <= '1';  ALU_OPY_SEL <= '1';  

-- AND reg-reg------------
when "0000000" =>
  ALU_SEL <= "0101"; RF_WR <= '1'; FLAG_C_CLR <= '1'; FLAG_Z_LD <= '1';
  
-- AND reg-immed ---------
when "1000000" | "1000001" | "1000010" | "1000011" =>
  ALU_SEL <= "0101"; RF_WR <= '1'; FLAG_C_CLR <= '1'; FLAG_Z_LD <= '1'; ALU_OPY_SEL <= '1'; 
  
-- ASR ------------------
when "0100100" =>
  ALU_SEL <= "1101"; RF_WR <= '1';  FLAG_C_LD <= '1'; FLAG_Z_LD <= '1'; 
  
-- BRCC ------------------
when "0010101" =>
  if(C = '0') then PC_LD <= '1'; end if;  
  
-- BRCS ------------------
when "0010100" =>
  if(C = '1') then PC_LD <= '1'; end if;

-- BREQ ------------------
when "0010010" =>
  if(Z = '1') then PC_LD <= '1'; end if; 
-- BRN -------------------
when "0010000" =>
  PC_LD <= '1';

-- BRNE ------------------
when "0010011" =>
  if(Z = '0') then PC_LD <= '1'; end if; 

-- CALL ------------------
when "0010001" =>
  PC_LD <= '1'; WR_SEL <= '1'; SP_DECR_CU <= '1'; SCR_DATA_SEL <= '1'; SCR_ADDR_SEL <= "11";

-- CLI -------------------
   
-- CLC -------------------
when "0110000" =>     
 FLAG_C_CLR <= '1';
 
-- CMP reg-reg -----------
when "0001000" =>
  ALU_SEL <= "0100"; FLAG_C_LD <= '1'; FLAG_Z_LD <= '1';

-- CMP reg-immed ---------
when "1100000" | "1100001" | "1100010" | "1100011" =>
  ALU_SEL <= "0100"; FLAG_C_LD <= '1'; FLAG_Z_LD <= '1'; ALU_OPY_SEL <= '1';  
       
-- EXOR reg-reg  ---------
when "0000010" =>					
  RF_WR <= '1';      ALU_SEL <= "0111"; FLAG_Z_LD <= '1'; FLAG_C_CLR <= '1';

-- EXOR reg-immed  -------
when "1001000" | "1001001" | "1001010" | "1001011" =>					
  RF_WR <= '1';      ALU_SEL <= "0111"; FLAG_Z_LD <= '1'; FLAG_C_CLR <= '1';  ALU_OPY_SEL <= '1'; 
               
-- IN --------------------
when "1100100" | "1100101" | "1100110" | "1100111" =>
  RF_WR <= '1';    RF_WR_SEL   <= "11";
  
-- LD reg-(reg) ----------
when  "0001010" =>
  RF_WR <= '1'; RF_WR_SEL <= "01"; 

-- LD reg-immed ----------
when  "1110000" | "1110001" | "1110010" | "1110011" =>
  RF_WR <= '1'; RF_WR_SEL <= "01"; SCR_ADDR_SEL <= "01";  

-- LSL ------------------
when "0100000" =>
  RF_WR <= '1'; ALU_SEL <= "1001"; FLAG_C_LD  <= '1'; FLAG_Z_LD <= '1'; 

-- LSR ------------------
when "0100001" =>
  RF_WR <= '1'; ALU_SEL <= "1010"; FLAG_C_LD  <= '1'; FLAG_Z_LD <= '1'; 
                                             
-- MOV reg-reg  ----------
when "0001001" => 
  RF_WR <= '1'; ALU_SEL <= "1110";
             
-- MOV reg-immed  --------
when "1101100" | "1101101" | "1101110" | "1101111" =>
  RF_WR <= '1'; ALU_SEL <= "1110"; ALU_OPY_SEL <= '1';

-- OR reg-reg ------------
when "0000001" => 
  RF_WR <= '1'; ALU_SEL <= "0110"; FLAG_C_CLR <= '1'; FLAG_Z_LD <= '1';

-- OR reg-immed ----------
when "1000100" | "1000101" | "1000110" | "1000111" => 
  RF_WR <= '1'; ALU_SEL <= "0110"; FLAG_C_CLR <= '1'; FLAG_Z_LD <= '1'; ALU_OPY_SEL <= '1';
                               
-- OUT -------------------
when "1101000" | "1101001" | "1101010" | "1101011" =>
  IO_STRB <= '1';
  
-- POP -------------------
when "0100110" =>
  RF_WR <= '1'; RF_WR_SEL <= "01"; SP_INCR_CU <= '1'; SCR_ADDR_SEL <= "10";

-- PUSH ------------------
when "0100101" =>
  WR_SEL <= '1'; SCR_ADDR_SEL <= "11"; SP_DECR_CU <= '1';
  
-- RET -------------------
when "0110010" =>
  PC_LD <= '1'; PC_MUX_SEL <= "01"; SP_INCR_CU <= '1';  SCR_ADDR_SEL <= "10";
   
-- ROL -------------------
when "0100010" =>   
  RF_WR <= '1'; ALU_SEL <= "1011"; FLAG_C_LD <= '1'; FLAG_Z_LD <= '1';
  
-- ROR -------------------
when "0100011" =>  
  RF_WR <= '1'; ALU_SEL <= "1100"; FLAG_C_LD <= '1'; FLAG_Z_LD <= '1';
  
-- SEC -------------------
when "0110001" =>   
  FLAG_C_SET <= '1';
  
-- SEI -------------------
when "0110100" => 
  I_SET <= '1';
  
  when "0110101" =>
  I_CLR <= '1';
  
  when "0110111" =>
  PC_MUX_SEL <= "01";
  PC_LD <= '1';
  SP_INCR_CU <= '1';
  SCR_ADDR_SEL <= "10";
  I_SET <= '1';
  FLAG_LD_SEL <= '1';
  FLAG_C_LD <= '1';
  FLAG_Z_LD <= '1';
  
  when "0110110" =>
  PC_MUX_SEL <= "01";
    PC_LD <= '1';
    SP_INCR_CU <= '1';
    SCR_ADDR_SEL <= "10";
    I_CLR <= '1';
    FLAG_LD_SEL <= '1';
    FLAG_C_LD <= '1';
    FLAG_Z_LD <= '1';
  
-- ST reg-reg ------------
when "0001011" =>  
 WR_SEL <= '1'; 
  
-- ST reg-immed ----------
when "1110100" | "1110101" | "1110110" | "1110111" =>   
  WR_SEL <= '1'; SCR_ADDR_SEL <= "01"; 
  
-- SUB reg-reg -----------
when "0000110" => 
  RF_WR <= '1';  ALU_SEL <= "0010"; FLAG_C_LD <= '1'; FLAG_Z_LD <= '1';
  
-- SUB reg-immed ---------
when "1011000" | "1011001" | "1011010" | "1011011" =>  
  RF_WR <= '1'; ALU_SEL <= "0010"; FLAG_C_LD <= '1'; FLAG_Z_LD <= '1'; ALU_OPY_SEL <= '1';
  
-- SUBC reg-reg ----------
when "0000111" => 
  RF_WR <= '1'; ALU_SEL <= "0011"; FLAG_C_LD <= '1'; FLAG_Z_LD <= '1';
  
-- SUBC reg-immed --------
when "1011100" | "1011101" | "1011110" | "1011111" =>    
  RF_WR <= '1'; ALU_SEL <= "0011"; FLAG_C_LD <= '1'; FLAG_Z_LD <= '1'; ALU_OPY_SEL <= '1';
  
-- TEST reg-reg ----------
when "0000011" => 
  ALU_SEL <= "1000"; FLAG_C_CLR <= '1'; FLAG_Z_LD <= '1'; 
  
-- TEST reg-immed --------
when "1001100" | "1001101" | "1001110" | "1001111" =>  
  ALU_SEL <= "1000";  FLAG_C_CLR <= '1'; FLAG_Z_LD <= '1'; ALU_OPY_SEL <= '1';
  
-- WSP -------------------
when "0101000" => 
   SP_LD_CU <='1';

-- INNER CASE STATEMENT "OTHERS" CASE
when others =>		
-- Repeat the default block here to avoid incompletely specified outputs and hence avoid
-- the problem of inadvertently created latches within the synthesized system.				
-- RE-INITIALIZE PC OUTPUTS:   
     PC_LD         <= '0';     PC_MUX_SEL   <= "00";   PC_INC       <= '0';
-- RE-INITIALIZE SP OUTPUTS:  
     SP_LD_CU      <= '0';     SP_INCR_CU   <= '0';    SP_DECR_CU   <= '0';
-- RE-INITIALIZE REG_FILE OUTPUTS:   
     RF_WR         <= '0';     RF_WR_SEL    <= "00";
-- RE-INITIALIZE ALU OUTPUTS:
     ALU_SEL       <= "0000";  ALU_OPY_SEL  <= '0'; 
-- RE-INITIALIZE SCR OUTPUTS:   
     WR_SEL        <= '0';     SCR_DATA_SEL <= '0';    SCR_ADDR_SEL <= "00";
-- RE-INITIALIZE FLAG OUTPUTS:
     FLAG_C_SET    <= '0';     FLAG_C_LD    <= '0';  
     FLAG_C_CLR   <= '0';   FLAG_LD_SEL <= '0';
     FLAG_SHAD_LD <= '0'; 
     IO_STRB <= '0';  
end case;

when ST_interrupt =>
    NS <= ST_fet;
    PC_LD <= '1';
    FLAG_SHAD_LD <= '1';
    I_CLR <= '1';
    SCR_DATA_SEL <= '1';
    WR_SEL <= '1';
    SCR_ADDR_SEL <= "11";
    SP_DECR_CU <= '1';
    FLAG_LD_SEL <= '1';
    PC_MUX_SEL <= "10";


-- OUTER CASE STATEMENT "OTHERS" CASE
when others => 
   NS <= ST_fet;
			    
-- Repeat the default block here to avoid incompletely specified outputs and hence avoid
-- the problem of inadvertently created latches within the synthesized system.
-- RE-INITIALIZE PC OUTPUTS:   
     PC_LD         <= '0';     PC_MUX_SEL   <= "00";   PC_INC       <= '0';
-- RE-INITIALIZE SP OUTPUTS:  
     SP_LD_CU      <= '0';     SP_INCR_CU   <= '0';    SP_DECR_CU   <= '0';
-- RE-INITIALIZE REG_FILE OUTPUTS:   
     RF_WR         <= '0';     RF_WR_SEL    <= "00";
-- RE-INITIALIZE ALU OUTPUTS:
     ALU_SEL       <= "0000";  ALU_OPY_SEL  <= '0'; 
-- RE-INITIALIZE SCR OUTPUTS:   
     WR_SEL        <= '0';     SCR_DATA_SEL <= '0';    SCR_ADDR_SEL <= "00";
-- RE-INITIALIZE FLAG OUTPUTS:
     FLAG_C_SET    <= '0';     FLAG_C_LD    <= '0';  
     FLAG_C_CLR   <= '0';       FLAG_LD_SEL <= '0';
     FLAG_SHAD_LD <= '0'; 
      IO_STRB <= '0';  			 
				 
end case;
end process FSM_C;
end Behavioral;
