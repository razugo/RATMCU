----------------------------------------------------------------------------------
-- Name: 
-- Date: 
-- 
-- Description: Top Level RAT CPU
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity RAT_CPU is
    Port ( IN_PORT : in  STD_LOGIC_VECTOR (7 downto 0);
           RESET : in  STD_LOGIC;
           CLK : in  STD_LOGIC;
           INTR : in  STD_LOGIC;           
           OUT_PORT : out  STD_LOGIC_VECTOR (7 downto 0);
           PORT_ID : out  STD_LOGIC_VECTOR (7 downto 0);
           IO_STRB : out  STD_LOGIC);
end RAT_CPU;



architecture Behavioral of RAT_CPU is

   --declare all of your components here
   --hint (just copy the entities and change the word entity to component
   --and end with end component
   component prog_rom  
      port (     ADDRESS : in std_logic_vector(9 downto 0); 
             INSTRUCTION : out std_logic_vector(17 downto 0); 
                     CLK : in std_logic);  
   end component;
   
   component ControlUnit 
         port (CLK           : in   STD_LOGIC;
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
              IO_STRB         : out    STD_LOGIC);  
      end component;
   
   component ALU 
            port (A: in std_logic_vector (7 downto 0);
           B: in std_logic_vector (7 downto 0);
           SEL: in std_logic_vector (3 downto 0);
           Cin: in std_logic;
           RESULT: out std_logic_vector (7 downto 0);        
           C: out std_logic;
           Z: out std_logic);  
         end component;
         
   component ProgramCounter
               port (D_IN : in STD_LOGIC_VECTOR (9 downto 0);
              PC_LD : in STD_LOGIC;
              PC_INC : in STD_LOGIC;
              RST : in STD_LOGIC;
              CLK : in STD_LOGIC;
              PC_COUNT : out STD_LOGIC_VECTOR (9 downto 0));  
            end component;         
    
    component REG_FILE
                  port (RF_WR_DATA: in std_logic_vector (7 downto 0);
            ADRX: in std_logic_vector (4 downto 0);
            ADRY: in std_logic_vector (4 downto 0);
            RF_WR: in std_logic;
            CLK: in std_logic;
            DX_OUT: out std_logic_vector (7 downto 0);
            DY_OUT: out std_logic_vector (7 downto 0));  
               end component;
    
    component MUX_IN_PC
        port (FROM_IMMED : in STD_LOGIC_VECTOR (9 downto 0);
               FROM_STACK : in STD_LOGIC_VECTOR (9 downto 0);
               INT : in STD_LOGIC_VECTOR (9 downto 0);
               PC_MUX_SEL : in STD_LOGIC_VECTOR (1 downto 0);
               OUTPUT_PC : out STD_LOGIC_VECTOR (9 downto 0));
    end component;
    
    component MUX_IN_REG
        port (IN_PORT_IN: IN STD_LOGIC_VECTOR (7 downto 0);
            B: IN STD_LOGIC_VECTOR (7 downto 0);
            INPUT: IN STD_LOGIC_VECTOR (7 downto 0);
            RF_WR_SEL: IN STD_LOGIC_VECTOR (1 downto 0);
            ALU_RESULT: IN STD_LOGIC_VECTOR (7 downto 0);
            OUTPUT_REG: OUT STD_LOGIC_VECTOR (7 downto 0));
    end component;
    
    component MUX_IN_ALU
        port (MUX_ALU_IN: IN STD_LOGIC_VECTOR (7 downto 0);
            IR: IN STD_LOGIC_VECTOR (7 downto 0);
            ALU_OPY_SEL: IN STD_LOGIC;
            OUTPUT_ALU: OUT STD_LOGIC_VECTOR (7 downto 0));
     end component;
     
     component C
        port (C_IN    : in  STD_LOGIC; --flag input
                FLG_C_LD   : in  STD_LOGIC; --load Q with the D value
                FLG_C_SET  : in  STD_LOGIC; --set the flag to '1'
                FLG_C_CLR  : in  STD_LOGIC; --clear the flag to '0'
                CLK  : in  STD_LOGIC; --system clock
                C_FLAG    : out  STD_LOGIC);                                     
     end component;
     
     component Z
        port (Z_IN    : in  STD_LOGIC; --flag input
                FLG_Z_LD   : in  STD_LOGIC; --load Q with the D value
                CLK  : in  STD_LOGIC; --system clock
                Z_FLAG    : out  STD_LOGIC);
     end component;
     
     component SP
        port (RST: IN STD_LOGIC;
             LD: IN STD_LOGIC;
             INCR: IN STD_LOGIC;
             DECR: IN STD_LOGIC;
             DATA_IN: IN STD_LOGIC_VECTOR (7 downto 0);
             CLK: IN STD_LOGIC;
             DATA_OUT: OUT STD_LOGIC_VECTOR (7 downto 0));
     end component;        
     
     component SCRATCH_RAM
        port (SCR_ADDR: in std_logic_vector (7 downto 0);
             SCR_WR: in std_logic;
             SCR_DATA_IN: in std_logic_vector (9 downto 0);
             CLK: in std_logic;
             SCR_DATA_OUT: out std_logic_vector (9 downto 0));
     end component;
     
     component SCRATCH_MUX_1
        port (DATA_IN_1: in STD_LOGIC_VECTOR (7 downto 0);
             DATA_IN_2: in STD_LOGIC_VECTOR (9 downto 0);
             MUX_SEL: in STD_LOGIC;
             DATA_OUT: out STD_LOGIC_VECTOR (9 downto 0));
     end component;
     
     component SCRATCH_MUX_2
        port (DATA_IN_1: in STD_LOGIC_VECTOR (7 downto 0);
             DATA_IN_2: in STD_LOGIC_VECTOR (7 downto 0);
             DATA_IN_3: in STD_LOGIC_VECTOR (7 downto 0);
             ADDR_SEL: in STD_LOGIC_VECTOR (1 downto 0);
             DATA_OUT: out STD_LOGIC_VECTOR (7 downto 0));
     end component;                        
     
     component SHAD_Z
       port (Z_IN    : in  STD_LOGIC; --flag input
                LD   : in  STD_LOGIC; --load Q with the D value
                CLK  : in  STD_LOGIC; --system clock
                Z_OUT    : out  STD_LOGIC);
     end component;
     
     component SHAD_C
        port (C_IN    : in  STD_LOGIC; --flag input
                LD   : in  STD_LOGIC; --load Q with the D value
                CLK  : in  STD_LOGIC; --system clock
                C_OUT    : out  STD_LOGIC);
     end component;
     
     component MUX_IN_C
        port (INPUT_1: IN STD_LOGIC;
             INPUT_2: IN STD_LOGIC;
             MUX_SEL: IN STD_LOGIC;
             OUTPUT: OUT STD_LOGIC);
     end component;
     
     component MUX_IN_Z
        port (INPUT_1: IN STD_LOGIC;
             INPUT_2: IN STD_LOGIC;
             MUX_SEL: IN STD_LOGIC;
             OUTPUT: OUT STD_LOGIC);
     end component;            
     
     component I
        port (CLK : in STD_LOGIC;
                I_SET : in STD_LOGIC;
                I_CLR : in STD_LOGIC;
                INT_OUT : out STD_LOGIC);
     end component;                                     
                          
   -- declare intermediate signals here -----------
   -- these should match the signal names you hand drew on the diagram
signal INT_OUT_SIG, I_SET_SIG, I_CLR_SIG, INT_SIG, SHAD_Z_IN_SIG,SHAD_Z_OUT_SIG, MUX_Z_OUT_SIG, FLAG_SHAD_LD_SIG, SHAD_C_IN_SIG, SHAD_C_OUT_SIG,FLAG_LD_SEL_SIG, MUX_C_OUT_SIG,SP_LD_SIG, SP_INCR_SIG, SP_DECR_SIG, SCR_WE_SIG, SCR_DATA_SEL_SIG, CLK_SIG, RF_WR_SIG, RST_SIG, PC_LD_SIG, PC_INC_SIG, C_SIG, C_IN_SIG, Z_SIG, Z_IN_SIG, Cin_SIG, IO_STRB_SIG, ALU_OPY_SEL_SIG, FLG_C_LD_SIG, FLG_C_SET_SIG, FLG_C_CLR_SIG, FLG_Z_CLR_SIG, FLG_Z_LD_SIG, C_FLAG_SIG, Z_FLAG_SIG: STD_LOGIC;
signal OPCODE_LO_2_SIG, PC_MUX_SEL_SIG, RF_WR_SEL_SIG, SCR_ADDR_SEL_SIG: STD_LOGIC_VECTOR (1 downto 0);
signal SEL_SIG, ALU_SEL_SIG: STD_LOGIC_VECTOR (3 downto 0);
signal ADRX_SIG, ADRY_SIG, OPCODE_HI_5_SIG: STD_LOGIC_VECTOR (4 downto 0);
signal DX_OUT_SIG, DY_OUT_SIG, RF_WR_DATA_SIG, RESULT_SIG, A_SIG, B_SIG, IN_PORT_SIG, INPUT_SIG, ALU_RESULT_SIG, OUTPUT_REG_SIG, OUTPUT_ALU_SIG, IR_SIG, DATA_IN_3_SIG, SCR_ADDR_SIG, B_ALU_SIG: STD_LOGIC_VECTOR (7 downto 0);   
signal PC_COUNT_SIG, D_IN_SIG, ADDRESS_SIG, FROM_IMMED_SIG, FROM_STACK_SIG, OUTPUT_PC_SIG, SCR_DATA_IN_SIG, SCR_DATA_OUT_SIG: STD_LOGIC_VECTOR (9 downto 0);
signal INSTRUCTION_SIG: STD_LOGIC_VECTOR (17 downto 0);

begin
    
    I_PM: I PORT MAP(
        I_SET => I_SET_SIG,
        I_CLR => I_CLR_SIG,
        CLK => CLK,
        INT_OUT => INT_OUT_SIG);
    --Interrupt_flag: C PORT MAP(
      --      C_IN => '0',
        --        FLG_C_LD => '0',
          --      FLG_C_SET => I_SET_SIG,
            --    FLG_C_CLR => I_CLR_SIG,
              --  CLK => CLK,
                --C_FLAG => INT_OUT_SIG);
        
            
               
    ControlUnit_PM: ControlUnit PORT MAP (
            C => C_SIG,
            Z => Z_SIG,
            RESET => RESET,
            INT => INT_SIG,
            OPCODE_HI_5 => INSTRUCTION_SIG (17 downto 13),
            OPCODE_LO_2 => INSTRUCTION_SIG (1 downto 0),
            CLK => CLK,
            PC_LD => PC_LD_SIG,
            PC_INC => PC_INC_SIG,
            PC_MUX_SEL => PC_MUX_SEL_SIG,
            ALU_OPY_SEL => ALU_OPY_SEL_SIG,
            ALU_SEL => ALU_SEL_SIG,
            RF_WR => RF_WR_SIG,
            RF_WR_SEL => RF_WR_SEL_SIG,
            FLAG_C_SET => FLG_C_SET_SIG,
            FLAG_C_CLR => FLG_C_CLR_SIG,
            FLAG_C_LD => FLG_C_LD_SIG,
            FLAG_Z_LD => FLG_Z_LD_SIG,
            FLAG_LD_SEL => FLAG_LD_SEL_SIG,
            FLAG_SHAD_LD => FLAG_SHAD_LD_SIG,
            SP_LD_CU => SP_LD_SIG,
            SP_INCR_CU => SP_INCR_SIG,
            SP_DECR_CU => SP_DECR_SIG,
            WR_SEL => SCR_WE_SIG,
            SCR_ADDR_SEL => SCR_ADDR_SEL_SIG,
            SCR_DATA_SEL => SCR_DATA_SEL_SIG,
            I_SET => I_SET_SIG,
            I_CLR => I_CLR_SIG,
            IO_STRB => IO_STRB,        
            RST => RST_SIG);
     MUX_IN_PC_PM: MUX_IN_PC PORT MAP(
            FROM_IMMED => INSTRUCTION_SIG (12 downto 3),       
            FROM_STACK => SCR_DATA_OUT_SIG,
            INT => "11" & x"ff",
            PC_MUX_SEL => PC_MUX_SEL_SIG,
            OUTPUT_PC => D_IN_SIG);
     ProgramCounter_PM: ProgramCounter PORT MAP(
            RST => RST_SIG,
            PC_LD => PC_LD_SIG,
            PC_INC => PC_INC_SIG,
            D_IN => D_IN_SIG,
            CLK => CLK,
            PC_COUNT => ADDRESS_SIG);
      prog_rom_PM: prog_rom PORT MAP (
            CLK => CLK,
            ADDRESS => ADDRESS_SIG,
            INSTRUCTION => INSTRUCTION_SIG);      
      MUX_IN_REG_PM: MUX_IN_REG PORT MAP(
            IN_PORT_IN => IN_PORT,
            B => B_SIG,
            INPUT => SCR_DATA_OUT_SIG (7 downto 0),
            RF_WR_SEL => RF_WR_SEL_SIG,
            ALU_RESULT => ALU_RESULT_SIG,
            OUTPUT_REG => OUTPUT_REG_SIG);
                              
      REG_FILE_PM: REG_FILE PORT MAP(
            RF_WR_DATA => OUTPUT_REG_SIG,
            RF_WR => RF_WR_SIG,
            ADRX => INSTRUCTION_SIG (12 downto 8),
            ADRY => INSTRUCTION_SIG (7 downto 3),      
            CLK => CLK,
            DX_OUT => A_SIG,
            DY_OUT => DY_OUT_SIG);
      MUX_IN_ALU_PM: MUX_IN_ALU PORT MAP(
            MUX_ALU_IN => DY_OUT_SIG,
            IR => INSTRUCTION_SIG (7 downto 0),
            ALU_OPY_SEL => ALU_OPY_SEL_SIG,
            OUTPUT_ALU => B_ALU_SIG);
      ALU_PM: ALU PORT MAP(
            A => A_SIG,     
            B => B_ALU_SIG,    
            SEL => ALU_SEL_SIG,
            Cin => C_SIG,
            RESULT => ALU_RESULT_SIG,
            C => C_IN_SIG,      
            Z => Z_IN_SIG );
      MUX_IN_C_PM: MUX_IN_C PORT MAP(
            INPUT_1 => C_IN_SIG,
            INPUT_2 => SHAD_C_OUT_SIG,
            MUX_SEL => FLAG_LD_SEL_SIG,
            OUTPUT => MUX_C_OUT_SIG);        
      C_PM: C PORT MAP(
            C_IN => MUX_C_OUT_SIG,
            FLG_C_LD => FLG_C_LD_SIG,
            FLG_C_SET => FLG_C_SET_SIG,
            FLG_C_CLR => FLG_C_CLR_SIG,
            CLK => CLK,
            C_FLAG => C_SIG);
      SHAD_C_PM: SHAD_C PORT MAP(
            C_IN => C_SIG,
            LD => FLAG_SHAD_LD_SIG,
            CLK => CLK,
            C_OUT => SHAD_C_OUT_SIG);
      MUX_IN_Z_PM: MUX_IN_Z PORT MAP(
            INPUT_1 => Z_IN_SIG,
            INPUT_2 => SHAD_Z_OUT_SIG,
            MUX_SEL => FLAG_LD_SEL_SIG,
            OUTPUT => MUX_Z_OUT_SIG);            
      Z_PM: Z PORT MAP(
            Z_IN => MUX_Z_OUT_SIG,
            FLG_Z_LD => FLG_Z_LD_SIG,
            CLK => CLK,
            Z_FLAG => Z_SIG);
      SHAD_Z_PM: SHAD_Z PORT MAP(
            Z_IN => Z_SIG,
            LD => FLAG_SHAD_LD_SIG,
            CLK => CLK,
            Z_OUT => SHAD_Z_OUT_SIG);                     
      SP_PM: SP PORT MAP(
            RST => RST_SIG,
            CLK => CLK,
            LD => SP_LD_SIG,      
            INCR => SP_INCR_SIG,
            DECR => SP_DECR_SIG,
            DATA_IN => A_SIG,
            DATA_OUT => B_SIG);
      SCRATCH_MUX_1_PM: SCRATCH_MUX_1 PORT MAP(
            DATA_IN_1 => A_SIG,
            DATA_IN_2 => ADDRESS_SIG,      
            MUX_SEL => SCR_DATA_SEL_SIG,
            DATA_OUT => SCR_DATA_IN_SIG);
      SCRATCH_MUX_2_PM: SCRATCH_MUX_2 PORT MAP(
            DATA_IN_1 => DY_OUT_SIG,
            DATA_IN_2 => INSTRUCTION_SIG (7 downto 0),
            DATA_IN_3 => B_SIG,
            ADDR_SEL => SCR_ADDR_SEL_SIG,
            DATA_OUT => SCR_ADDR_SIG);
      SCRATCH_RAM_PM: SCRATCH_RAM PORT MAP(
            SCR_ADDR => SCR_ADDR_SIG,
            SCR_DATA_IN => SCR_DATA_IN_SIG,
            SCR_WR => SCR_WE_SIG,
            CLK => CLK,
            SCR_DATA_OUT => SCR_DATA_OUT_SIG);          
  
  INT_SIG <= INTR AND INT_OUT_SIG;                
  PORT_ID <= INSTRUCTION_SIG (7 downto 0);
  OUT_PORT <= A_SIG;

end Behavioral;

