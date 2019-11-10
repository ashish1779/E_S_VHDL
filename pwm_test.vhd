--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   21:52:39 11/10/2019
-- Design Name:   
-- Module Name:   D:/complete_pro/pro_test.vhd
-- Project Name:  complete_pro
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: pro
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY pro_test IS
END pro_test;
 
ARCHITECTURE behavior OF pro_test IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT pro
    PORT(
         i_clk : IN  std_logic;
         i_rstb : IN  std_logic;
         i_sync_reset : IN  std_logic;
         i_pwm_module : IN  std_logic_vector(7 downto 0);
         i_pwm_width : IN  std_logic_vector(7 downto 0);
         o_pwm : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal i_clk : std_logic := '0';
   signal i_rstb : std_logic := '0';
   signal i_sync_reset : std_logic := '0';
   signal i_pwm_module : std_logic_vector(7 downto 0) := (others => '0');
   signal i_pwm_width : std_logic_vector(7 downto 0) := (others => '0');

 	--Outputs
   signal o_pwm : std_logic;

   -- Clock period definitions
   constant i_clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: pro PORT MAP (
          i_clk => i_clk,
          i_rstb => i_rstb,
          i_sync_reset => i_sync_reset,
          i_pwm_module => i_pwm_module,
          i_pwm_width => i_pwm_width,
          o_pwm => o_pwm
        );

   -- Clock process definitions
   i_clk_process :process
   begin
		i_clk <= '0';
		wait for i_clk_period/2;
		i_clk <= '1';
		wait for i_clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 10 ns;
		i_rstb <= '0';
      wait for 10 ns;
		i_rstb <= '1';
      i_sync_reset <= '0';
      i_pwm_module <= "01100100";
      i_pwm_width <= "00110010";

      wait;
   end process;

END;
