
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY tb_my_ps2keyboard IS
END tb_my_ps2keyboard;
 
ARCHITECTURE behavior OF tb_my_ps2keyboard IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
    component my_ps2keyboard
        port (resetn, clock: in std_logic;
                ps2c, ps2d: in std_logic;
                DOUT: out std_logic_vector (7 downto 0);
                done: out std_logic);
    end component;   

   --Inputs
   signal resetn : std_logic := '0';
   signal clock : std_logic := '0';
   signal ps2c : std_logic := '0';
   signal ps2d : std_logic := '0';

 	--Outputs
   signal DOUT : std_logic_vector(7 downto 0);
   signal done: std_logic;
   
   -- Clock period definitions
   constant clock_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: my_ps2keyboard PORT MAP (
          resetn => resetn,
          clock => clock,
          ps2c => ps2c,
          ps2d => ps2d,
          DOUT => DOUT,
          done => done
        );

   -- Clock process definitions
   clock_process :process
   begin
		clock <= '0';
		wait for clock_period/2;
		clock <= '1';
		wait for clock_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	resetn <= '1';

      wait for clock_period*10;

      -- Stimulus: Data (LSB to MSB): 0 (START) 0 0 0 0 1 1 1 1  1 (parity)  1 (STOP): Data is: 1111 0000 (CD) 
		ps2c <= '1'; wait for clock_period*10; ps2d <= '0';
		ps2c <= '0'; wait for clock_period*10;
		ps2c <= '1'; wait for clock_period*10; ps2d <= '0';
		ps2c <= '0'; wait for clock_period*10;
		ps2c <= '1'; wait for clock_period*10; ps2d <= '0';
		ps2c <= '0'; wait for clock_period*10;
		ps2c <= '1'; wait for clock_period*10; ps2d <= '0';
		ps2c <= '0'; wait for clock_period*10;
		ps2c <= '1'; wait for clock_period*10; ps2d <= '0';
		ps2c <= '0'; wait for clock_period*10;
		ps2c <= '1'; wait for clock_period*10; ps2d <= '1';
		ps2c <= '0'; wait for clock_period*10;
		ps2c <= '1'; wait for clock_period*10; ps2d <= '1';
		ps2c <= '0'; wait for clock_period*10;
		ps2c <= '1'; wait for clock_period*10; ps2d <= '1';
		ps2c <= '0'; wait for clock_period*10;
		ps2c <= '1'; wait for clock_period*10; ps2d <= '1';
		ps2c <= '0'; wait for clock_period*10;
		ps2c <= '1'; wait for clock_period*10; ps2d <= '1'; -- parity bit
		ps2c <= '0'; wait for clock_period*10;
		ps2c <= '1'; wait for clock_period*10; ps2d <= '1'; -- stop bit
        ps2c <= '0'; wait for clock_period*10;
		
		wait for clock_period*80;

      -- Stimulus: Data (LSB to MSB): 0 (START) 1 0 1 1 0 0 1 1 1 (parity)  1 (STOP): Data is: 1100 1101 (CD) 
		ps2c <= '1'; wait for clock_period*10; ps2d <= '0';
		ps2c <= '0'; wait for clock_period*10;
		ps2c <= '1'; wait for clock_period*10; ps2d <= '1';
		ps2c <= '0'; wait for clock_period*10;
		ps2c <= '1'; wait for clock_period*10; ps2d <= '0';
		ps2c <= '0'; wait for clock_period*10;
		ps2c <= '1'; wait for clock_period*10; ps2d <= '1';
		ps2c <= '0'; wait for clock_period*10;
		ps2c <= '1'; wait for clock_period*10; ps2d <= '1';
		ps2c <= '0'; wait for clock_period*10;
		ps2c <= '1'; wait for clock_period*10; ps2d <= '0';
		ps2c <= '0'; wait for clock_period*10;
		ps2c <= '1'; wait for clock_period*10; ps2d <= '0';
		ps2c <= '0'; wait for clock_period*10;
		ps2c <= '1'; wait for clock_period*10; ps2d <= '1';
		ps2c <= '0'; wait for clock_period*10;
		ps2c <= '1'; wait for clock_period*10; ps2d <= '1';
		ps2c <= '0'; wait for clock_period*10;
		ps2c <= '1'; wait for clock_period*10; ps2d <= '1'; -- parity bit
        ps2c <= '0'; wait for clock_period*10;		
		ps2c <= '1'; wait for clock_period*10; ps2d <= '1'; -- stop
		ps2c <= '0'; wait for clock_period*10;
		
      wait;
   end process;

END;
