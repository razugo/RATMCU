----------------------------------------------------------------------------------
-- Company:  RAT Technologies
-- Engineer:  Various RAT rats
-- 
-- Create Date:    1/31/2012
-- Design Name: 
-- Module Name:    RAT_wrapper - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: Wrapper for RAT CPU. This model provides a template to interfaces 
--    the RAT CPU to the Nexys2 development board. 
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity BIG_Wrapper is
    Port ( CLK: IN STD_LOGIC;
           BTN: IN STD_LOGIC;
           RST: IN STD_LOGIC;
           INT: IN STD_LOGIC;
           LEDS     : out   STD_LOGIC_VECTOR (7 downto 0);
           SWITCHES : in    STD_LOGIC_VECTOR (7 downto 0);
           DISP_EN: OUT STD_LOGIC_VECTOR(3 downto 0);
           SEGMENTS: OUT STD_LOGIC_VECTOR(7 downto 0));
end BIG_Wrapper;

architecture Behavioral of BIG_Wrapper is

   -- INPUT PORT IDS -------------------------------------------------------------
   -- Right now, the only possible inputs are the switches
   -- In future labs you can add more port IDs, and you'll have
   -- to add constants here for the mux below
   --CONSTANT SWITCHES_ID : STD_LOGIC_VECTOR (7 downto 0) := X"10";
   -------------------------------------------------------------------------------
   
   -------------------------------------------------------------------------------
   -- OUTPUT PORT IDS ------------------------------------------------------------
   -- In future labs you can add more port IDs
   --CONSTANT LEDS_ID       : STD_LOGIC_VECTOR (7 downto 0) := X"20";
   --CONSTANT SSEG_ID       : STD_LOGIC_VECTOR (7 downto 0) := X"30";
   -------------------------------------------------------------------------------

   -- Declare RAT_CPU ------------------------------------------------------------
   component RAT_wrapper 
       Port ( LEDS     : out   STD_LOGIC_VECTOR (7 downto 0);
              SWITCHES : in    STD_LOGIC_VECTOR (7 downto 0);
              btnL      : in    STD_LOGIC; --interrupt
              btnC      : in    STD_LOGIC; --reset
              CLK      : in    STD_LOGIC;
              SSEG_OUT: out STD_LOGIC_VECTOR (7 downto 0);
              SSEG_EN: out STD_LOGIC_VECTOR (3 downto 0));
   end component RAT_wrapper;
   -------------------------------------------------------------------------------

    component db_1shot_FSM
        Port (A    : in STD_LOGIC;
               CLK  : in STD_LOGIC;
               A_DB : out STD_LOGIC);
   end component db_1shot_FSM;
               
               


   -- component clock_div2 is
     --   Port (CLK     : in  STD_LOGIC;
       --        DIV_CLK : out STD_LOGIC);
   -- end component;           
    
   -- Signals for connecting RAT_CPU to RAT_wrapper -------------------------------
   --signal s_leds_port  : std_logic_vector (7 downto 0);
   --signal s_switches_port : std_logic_vector (7 downto 0);
   --signal s_btnL_id     : std_logic;
   --signal s_btnC_id, s_CLK        : std_logic;
   --signal s_interrupt   : std_logic; -- not yet used
   --signal sseg_val      : std_logic_vector(7 downto 0) := x"00";
   
   -- Register definitions for output devices ------------------------------------
   --signal r_LEDS        : std_logic_vector (7 downto 0); 
   -------------------------------------------------------------------------------

    --signal LEDS_SIG, SWITCHES_SIG, btnL_SIG, btnC_SIG,  
    signal btnL_SIG: STD_LOGIC;

begin

   -- Instantiate RAT_CPU --------------------------------------------------------
   Wrapper: RAT_wrapper
   port map( LEDS => LEDS,
            SWITCHES => SWITCHES,
            btnL => INT,
            btnC => RST,
            CLK => CLK,
            SSEG_EN => DISP_EN,
            SSEG_OUT => SEGMENTS); 
                     
   -------------------------------------------------------------------------------

  --  newClk: clock_div2
    --port map( CLK => CLK,
      --        DIV_CLK => CLK50);
    
    
    
    Debounce: db_1shot_FSM
    port map (A => INT,
              CLK => CLK,
              A_DB => btnL_SIG);
              
                 
              
        
                
   ------------------------------------------------------------------------------- 
   -- MUX for selecting what input to read ---------------------------------------
   -------------------------------------------------------------------------------
  -- inputs: process(s_port_id, SWITCHES)
   --begin
     -- if (s_port_id = SWITCHES_ID) then
       --  s_input_port <= SWITCHES;
      --else
        -- s_input_port <= x"00";
      --end if;
   --end process inputs;
   --------------------------------------------------------------------------------


   -------------------------------------------------------------------------------
   -- MUX for updating output registers ------------------------------------------
   -- Register updates depend on rising clock edge and asserted load signal
   -------------------------------------------------------------------------------
   --outputs: process(s_CLK, s_btnC_id,s_btnL_id) 
  -- begin   
    --  if (rising_edge(s_CLK)) then
      --   if (s_btnC_id = '1') then 
           
            -- the register definition for the LEDS
        --    if (s_port_id = LEDS_ID) then
          --     r_LEDS <= s_output_port;
           -- elsif s_port_id = SSEG_ID then
             --   sseg_val <= s_output_port;   
            --end if;
           
        -- end if; 
      --end if;
   --end process outputs;      
   -------------------------------------------------------------------------------

   -- Register Interface Assignments ---------------------------------------------
   --LEDS <= r_LEDS; 

end Behavioral;