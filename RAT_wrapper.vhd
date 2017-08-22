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

entity RAT_wrapper is
    Port ( LEDS     : out   STD_LOGIC_VECTOR (7 downto 0);
           SWITCHES : in    STD_LOGIC_VECTOR (7 downto 0);
           VGA_RED  : out   STD_LOGIC_VECTOR (3 downto 0);
           VGA_GRN  : out   STD_LOGIC_VECTOR (3 downto 0);
           VGA_BLUE : out   STD_LOGIC_VECTOR (3 downto 0);
           VGA_HS   : out   STD_LOGIC;
           VGA_VS   : out   STD_LOGIC;
           AN       : out   STD_LOGIC_VECTOR (3 downto 0);
           --BUTTONS  : in    STD_LOGIC_VECTOR (3 downto 0); 
           btnL      : in    STD_LOGIC; --interrupt
           btnC      : in    STD_LOGIC; --reset
           CLK      : in    STD_LOGIC;
           SSEG_OUT: out STD_LOGIC_VECTOR (7 downto 0);
           SSEG_EN: out STD_LOGIC_VECTOR (3 downto 0));
end RAT_wrapper;

architecture Behavioral of RAT_wrapper is

   -- INPUT PORT IDS -------------------------------------------------------------
   -- Right now, the only possible inputs are the switches
   -- In future labs you can add more port IDs, and you'll have
   -- to add constants here for the mux below
   CONSTANT SWITCHES_ID : STD_LOGIC_VECTOR (7 downto 0) := X"20";
   -------------------------------------------------------------------------------
   
   -------------------------------------------------------------------------------
   -- OUTPUT PORT IDS ------------------------------------------------------------
   -- In future labs you can add more port IDs
   CONSTANT LEDS_ID       : STD_LOGIC_VECTOR (7 downto 0) := X"40";
   CONSTANT SSEG_ID       : STD_LOGIC_VECTOR (7 downto 0) := X"81";
   CONSTANT AN_ID         : STD_LOGIC_VECTOR (7 downto 0) := X"82";
   CONSTANT VGA_HADD_ID   : STD_LOGIC_VECTOR (7 downto 0) := X"90";
   CONSTANT VGA_LADD_ID   : STD_LOGIC_VECTOR (7 downto 0) := X"91";
   CONSTANT VGA_COLOR_ID  : STD_LOGIC_VECTOR (7 downto 0) := X"92";
   CONSTANT VGA_WE_ID     : STD_LOGIC_VECTOR (7 downto 0) := X"93";
   CONSTANT VGA_PIXEL_DATA_ID  : STD_LOGIC_VECTOR (7 downto 0) := X"94";
   --CONSTANT BUTTONS_ID  : STD_LOGIC_VECTOR (7 downto 0) := X"50";
   -------------------------------------------------------------------------------

   -- Declare RAT_CPU ------------------------------------------------------------
   component RAT_CPU 
       Port ( IN_PORT  : in  STD_LOGIC_VECTOR (7 downto 0);
              OUT_PORT : out STD_LOGIC_VECTOR (7 downto 0);
              PORT_ID  : out STD_LOGIC_VECTOR (7 downto 0);
              IO_STRB    : out STD_LOGIC;
              RESET      : in  STD_LOGIC;
              INTR   : in  STD_LOGIC;
              CLK      : in  STD_LOGIC);
   end component RAT_CPU;
   
   component vgaDriverBuffer is
           Port (    CLK, we      : in  std_logic;
                     wa           : in  std_logic_vector (10 downto 0);
                     wd           : in  std_logic_vector (7 downto 0);
                     Rout         : out std_logic_vector(2 downto 0);
                     Gout         : out std_logic_vector(2 downto 0);
                     Bout         : out std_logic_vector(1 downto 0);
                     HS           : out std_logic;
                     VS           : out std_logic;
                     pixelData    : out std_logic_vector(7 downto 0)
                            );
      end component;
   -------------------------------------------------------------------------------

    component clock_div2 is
        Port (CLK     : in  STD_LOGIC;
               DIV_CLK : out STD_LOGIC);
    end component;     
    
    component db_1shot_FSM
            Port (A    : in STD_LOGIC;
                   CLK  : in STD_LOGIC;
                   A_DB : out STD_LOGIC);
       end component db_1shot_FSM;
    
    component sseg_dec_uni
        Port (COUNT1 : in std_logic_vector(13 downto 0); 
                     COUNT2 : in std_logic_vector(7 downto 0);
                        SEL : in std_logic_vector(1 downto 0);
                            dp_oe : in std_logic;
                         dp : in std_logic_vector(1 downto 0);                       
                        CLK : in std_logic;
                             SIGN : in std_logic;
                            VALID : in std_logic;
                    DISP_EN : out std_logic_vector(3 downto 0);
                   SEGMENTS : out std_logic_vector(7 downto 0));
    end component sseg_dec_uni;                      
    
   -- Signals for connecting RAT_CPU to RAT_wrapper -------------------------------
   signal s_input_port  : std_logic_vector (7 downto 0);
   signal s_output_port : std_logic_vector (7 downto 0);
   signal s_port_id     : std_logic_vector (7 downto 0);
   signal s_load, CLK50, INTR_SIG        : std_logic;
   --signal s_interrupt   : std_logic; -- not yet used
   signal COUNT2_SIG      : std_logic_vector(7 downto 0) := x"00";
   signal COUNT1_SIG    : std_logic_vector(13 downto 0) := (others => '0');
   
   -- Register definitions for output devices ------------------------------------
   signal r_LEDS        : std_logic_vector (7 downto 0); 

   -------------------------------------------------------------------------------
   
   -- VGA signals
       signal s_vga_wa         : std_logic_vector(10 downto 0)  := (others => '0');
       signal s_vga_wd         : std_logic_vector(7 downto 0)  := (others => '0');
       signal s_vga_we         : std_logic := '1';
       signal s_vga_pixelData  : std_logic_vector(7 downto 0)  := (others => '0');     
       signal s_vga_hadd       : std_logic_vector(7 downto 0)  := (others => '0');
       signal s_vga_ladd       : std_logic_vector(7 downto 0)  := (others => '0');
       signal s_vga_color      : std_logic_vector(7 downto 0)  := (others => '0');
       
       signal s_vga_red        : std_logic_vector(2 downto 0)  := (others => '1');
       signal s_vga_grn        : std_logic_vector(2 downto 0)  := (others => '1');
       signal s_vga_blue       : std_logic_vector(1 downto 0)  := (others => '1');
       signal s_vga_hs         : std_logic := '0';
       signal s_vga_vs         : std_logic := '0';

begin

   -- Instantiate RAT_CPU --------------------------------------------------------
   CPU: RAT_CPU
   port map(  IN_PORT  => s_input_port,
              OUT_PORT => s_output_port,
              PORT_ID  => s_port_id,
              RESET      => btnC,  
              IO_STRB    => s_load,
              INTR   => INTR_SIG,
              CLK      => CLK50);         
              
              
   VGAbuffer: vgaDriverBuffer
                  port map(   CLK         => CLK50,
                              we          => s_vga_we,
                              wa          => s_vga_wa,
                              wd          => s_vga_wd,
                              Rout        => s_vga_red,
                              Gout        => s_vga_grn,
                              Bout        => s_vga_blue,
                              HS          => s_vga_hs,
                              VS          => s_vga_vs,
                              pixelData   => s_vga_pixelData);           
   -------------------------------------------------------------------------------

    Debounce: db_1shot_FSM
    port map (A => btnL, 
              CLK => CLK,
              A_DB => INTR_SIG );

    newClk: clock_div2
    port map( CLK => CLK,
              DIV_CLK => CLK50);
              
              
    SSEG: sseg_dec_uni
    port map(COUNT2 => COUNT2_SIG,
            COUNT1 => COUNT1_SIG,
            SIGN => '0',
            VALID => '1',
            CLK => CLK,
            dp_oe => '0',
            dp => "00",
            SEL => "10",
            DISP_EN => SSEG_EN,
            SEGMENTS => SSEG_OUT);       
               
                
   ------------------------------------------------------------------------------- 
   -- MUX for selecting what input to read ---------------------------------------
   -------------------------------------------------------------------------------
   inputs: process(s_port_id, SWITCHES)
   begin
      --if (s_port_id = SWITCHES_ID) then
        -- s_input_port <= SWITCHES;
      --else
        -- s_input_port <= x"00";
      --end if;
      case(s_port_id) is
                  when VGA_PIXEL_DATA_ID =>
                      s_input_port <= s_vga_pixelData;
                      
                  --when BUTTONS_ID =>
                    --  s_input_port <= "0000" & BUTTONS;
                    
                    when SWITCHES_ID =>
                        s_input_port <= SWITCHES;
                        
                      
                  when others =>
                      s_input_port <= x"00";
              end case;
   end process inputs;
   -------------------------------------------------------------------------------


   -------------------------------------------------------------------------------
   -- MUX for updating output registers ------------------------------------------
   -- Register updates depend on rising clock edge and asserted load signal
   -------------------------------------------------------------------------------
   outputs: process(CLK50, s_load,s_port_id) 
   begin   
      if (rising_edge(CLK50)) then
         if (s_load = '1') then 
           
            -- the register definition for the LEDS
            --if (s_port_id = LEDS_ID) then
              -- r_LEDS <= s_output_port;
            --elsif s_port_id = SSEG_ID then
              --  COUNT1_SIG(7 downto 0) <= s_output_port;   
            --end if;
            case(s_port_id) is
                        
                            when LEDS_ID =>           
                               r_LEDS <= s_output_port;
                            
                            when SSEG_ID =>
                                COUNT1_SIG(7 downto 0) <= s_output_port;             
                            
                            when VGA_HADD_ID =>
                                s_vga_hadd <= s_output_port;
                            
                            when VGA_LADD_ID =>
                                s_vga_ladd <= s_output_port;
                            
                            when VGA_COLOR_ID =>
                                s_vga_color <= s_output_port;    
                                
                            when VGA_WE_ID =>
                                s_vga_we    <= s_output_port(0); 
                                  
                                
                            when others =>
                        
                        end case;   
           
         end if; 
      end if;
   end process outputs;      
   -------------------------------------------------------------------------------

   -- Register Interface Assignments ---------------------------------------------
   LEDS <= r_LEDS;
   s_vga_wa <= s_vga_hadd(2 downto 0) & s_vga_ladd;
      s_vga_wd <= s_vga_color;
      VGA_RED  <= s_vga_red & '0';
      VGA_GRN  <= s_vga_grn & '0';
      VGA_BLUE <= s_vga_blue & "00";
      VGA_HS   <= s_vga_hs;
      VGA_VS   <= s_vga_vs;

end Behavioral;