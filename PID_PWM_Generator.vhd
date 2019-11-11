LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
ENTITY PID IS
generic(
		N                     : integer := 12);      -- number of bit of PWM counter
PORT   (
		
		i_rstb                      : in  std_logic;
		i_sync_reset                : in  std_logic;
		i_pwm_module                : in  std_logic_vector(N-1 downto 0);  -- PWM Freq  = clock freq/ (i_pwm_module+1); max value = 2^N-1
	        --i_pwm_width                 : in  std_logic_vector(N-1 downto 0);  -- PWM width = (others=>0)=> OFF; i_pwm_module => MAX ON 
	        o_pwm                       : out std_logic;
		kp_sw          : IN std_logic; --determines if p term is needed
		ki_sw          : IN std_logic; --determines if i term is needed
		kd_sw          : IN std_logic; --determines if d term is needed
		SetVal         : IN std_logic_vector(11 DOWNTO 0); --user input reference
		adc_data       : IN std_logic_vector(11 DOWNTO 0); --feedbac value from sensor
		on_off_switch  : IN std_logic; --determines if controller is active
	        --output         : OUT std_logic_vector(11 DOWNTO 0); --output of controller
		clk            : IN STD_LOGIC );
END PID;

ARCHITECTURE Behavioral OF PID IS

	signal r_max_count                           : unsigned(N-1 downto 0);
	signal r_pwm_counter                         : unsigned(N-1 downto 0);
	signal r_pwm_width                           : unsigned(N-1 downto 0);
	signal w_tc_pwm_counter                      : std_logic;
	signal i_pwm_width                           : std_logic_vector(N-1 downto 0); 
	
	CONSTANT con_Kp 	: INTEGER := 1; --proportional constant
	CONSTANT con_kp_den 	: INTEGER := 2;
	CONSTANT con_Kd 	: INTEGER := 1; --differential constant
	CONSTANT con_kd_den 	: INTEGER := 100;
	CONSTANT con_Ki 	: INTEGER := 1; --integral constant
	CONSTANT con_ki_den 	: INTEGER := 10;
	SIGNAL Error, Error_difference, error_sum, old_error : INTEGER := 0; --store values for controller
	SIGNAL p, i, d 		: INTEGER := 0; 													--Contain the proportional, derivative and integral errors respectively
	SIGNAL output_loaded, output_saturation_buffer : INTEGER := 0;			--allows to check if output is within range
	SIGNAL old_adc 		: std_logic_vector(11 DOWNTO 0);               			--stores old adc value
	CONSTANT divider_for_time : INTEGER := 1;                    			--stores the time in which the controller acts over example a value of 100 would be equalt to 10ms so 1/divider_for_time = sampling_period
        SIGNAL output 		: std_logic_vector(11 DOWNTO 0);
BEGIN

	w_tc_pwm_counter  <= '0' when(r_pwm_counter<r_max_count) else '1';  -- use to strobe new word
 
PROCESS (kp_sw, kd_sw, ki_sw, clk, ADC_DATA, Error, SetVal, i, p, d,i_rstb)
BEGIN
	IF clk'EVENT AND clk = '1' THEN
		IF on_off_switch = '0' THEN --functions as an on/off switch and sets all main variables to null
			error_sum <= 0;
			error_difference <= 0;
			error <= 0;
			p <= 0;
			i <= 0;
			d <= 0;
			output_loaded <= 0;
			output <= (OTHERS => '0');
		ELSE
			FOR k IN 0 TO 9 LOOP --for loop to run through case statement
				CASE k IS
					WHEN 0 => Error <= (to_integer(unsigned(SetVal)) - to_integer(unsigned(ADC_data))); --calculates error between sensor and reference
					WHEN 1 => IF adc_data /= old_adc THEN --calculate integral and derivative term
									error_sum <= error_sum + error;
									error_difference <= error - old_error;
								  END IF;
					WHEN 2 => IF kp_sw = '1' THEN   --calculate p term if desired
										p <= (con_Kp * error)/con_kp_den;
									ELSE
										  p <= 0;
									END IF;
					WHEN 3 => IF ki_sw = '1' THEN --calculate i term if desired
										 i <= (con_Ki * error_sum)/(divider_for_time * con_ki_den);
								  ELSE 
										 i <= 0;
									 END IF; 
					WHEN 4 => IF kd_sw = '1' THEN  --calculate d term if desired
										  d <= ((con_Kd * error_difference) * divider_for_time)/con_kd_den;
									  ELSE 
											 d <= 0;
									  END IF; 
					WHEN 5 => output_saturation_buffer <= (p + i + d); --calculate output of controller
					WHEN 6 => IF output_saturation_buffer < 0 THEN --checks if output within certain range
										  output_loaded <= 0;
										ELSIF output_saturation_buffer > 4095 THEN
											output_loaded <= 4095;
										ELSE
											output_loaded <= output_saturation_buffer;
										END IF;
					WHEN 7 => output <= std_logic_vector(to_unsigned(output_loaded, 12)); --converts to std_logic_vector which can be output to DAC or input to PWM code
					WHEN 8 => old_adc <= adc_data; --storing old adc
					WHEN 9 => old_error <= error; --storing old error for derivative term
					WHEN OTHERS => NULL;
END CASE;
END LOOP;
END IF;
END IF;

i_pwm_width <= output ;

if(i_rstb='0') then
    r_max_count     <= (others=>'0');
    r_pwm_width     <= (others=>'0');
    r_pwm_counter   <= (others=>'0');
    o_pwm           <= '0';

elsif(rising_edge(clk)) then
    r_max_count     <= unsigned(i_pwm_module);
    if(i_sync_reset='1') then
      r_pwm_width     <= unsigned(i_pwm_width);
      r_pwm_counter   <= to_unsigned(0,N);
      o_pwm           <= '0';
    else
      if(r_pwm_counter=0) and (r_pwm_width/=r_max_count) then
        o_pwm           <= '0';
      elsif(r_pwm_counter<=r_pwm_width) then
        o_pwm           <= '1';
      else
        o_pwm           <= '0';
      end if;
      
      if(w_tc_pwm_counter='1') then
        r_pwm_width      <= unsigned(i_pwm_width);
      end if;
      
      if(r_pwm_counter=r_max_count) then
        r_pwm_counter   <= to_unsigned(0,N);
      else
        r_pwm_counter   <= r_pwm_counter + 1;
      end if;
    end if;
end if;
  
END PROCESS; --end of process
END Behavioral; --end of Architecture
