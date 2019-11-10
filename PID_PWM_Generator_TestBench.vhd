--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   23:40:04 11/10/2019
-- Design Name:   
-- Module Name:   D:/Embedded_Project/pid/test_my.vhd
-- Project Name:  pid
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: PID
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
 
ENTITY test_my IS
END test_my;
 
ARCHITECTURE behavior OF test_my IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT PID
    PORT(
         i_rstb : IN  std_logic;
         i_sync_reset : IN  std_logic;
         i_pwm_module : IN  std_logic_vector(11 downto 0);
         o_pwm : OUT  std_logic;
         kp_sw : IN  std_logic;
         ki_sw : IN  std_logic;
         kd_sw : IN  std_logic;
         SetVal : IN  std_logic_vector(11 downto 0);
         adc_data : IN  std_logic_vector(11 downto 0);
         on_off_switch : IN  std_logic;
         clk : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal i_rstb : std_logic := '0';
   signal i_sync_reset : std_logic := '0';
   signal i_pwm_module : std_logic_vector(11 downto 0) := (others => '0');
   signal kp_sw : std_logic := '0';
   signal ki_sw : std_logic := '0';
   signal kd_sw : std_logic := '0';
   signal SetVal : std_logic_vector(11 downto 0) := (others => '0');
   signal adc_data : std_logic_vector(11 downto 0) := (others => '0');
   signal on_off_switch : std_logic := '0';
   signal clk : std_logic := '0';

 	--Outputs
   signal o_pwm : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: PID PORT MAP (
          i_rstb => i_rstb,
          i_sync_reset => i_sync_reset,
          i_pwm_module => i_pwm_module,
          o_pwm => o_pwm,
          kp_sw => kp_sw,
          ki_sw => ki_sw,
          kd_sw => kd_sw,
          SetVal => SetVal,
          adc_data => adc_data,
          on_off_switch => on_off_switch,
          clk => clk
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;
		on_off_switch <= '0';
		i_rstb <= '0';
		wait for 20 ns;
		on_off_switch <= '1';
		i_rstb <= '1';
		i_sync_reset <= '0';
      i_pwm_module <= "000001100100";
		kp_sw <= '1';
		ki_sw <= '1';
		kd_sw <= '0';
		SetVal <= "000000111100";   ---60
		adc_data <= "000000011110";  --30
		wait for 1000 ns;
		adc_data <= "000000110010";  --50
		wait for 1000 ns;
		adc_data <= "000000001111";  --15
		wait for 1000 ns;
		adc_data <= "000000001010";
		wait for 1000 ns;
		adc_data <= "000000100100";
      wait;
   end process;

END;
