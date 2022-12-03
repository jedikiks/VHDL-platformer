library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity xPosition_tb is
end xPosition_tb;

architecture Behavioral of xPosition_tb is
component xPosition
	port ( clock, resetn, posX_E: in std_logic;
	       l_r: in std_logic_vector( 1 downto 0 );
	       posY_Q: in std_logic_vector( 9 downto 0 );
	       posX_Q : out std_logic_vector( 9 downto 0 );
	       newX_r_addr, newX_l_addr: out std_logic_vector( 19 downto 0 ) -- change this if address width is different
      	 );
end component;

   --Inputs
   signal resetn, clock, posX_E: std_logic := '0';
   signal posY_Q_tb: std_logic_vector ( 9 downto 0 ) := (others => '0');
   signal l_r: std_logic_vector( 1 downto 0 ) := "10";
   
   --Outputs
   signal posX_Q : std_logic_vector ( 9 downto 0 );
   signal newX_r_addr, newX_l_addr : std_logic_vector ( 19 downto 0 );

   -- Clock period definitions
   constant clock_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: xPosition PORT MAP (resetn=>resetn, clock=>clock, posX_E=>posX_E, l_r=>l_r, posX_Q=>posX_Q, posY_Q=>posY_Q_tb, newX_l_addr=>newX_l_addr, newX_r_addr=>newX_r_addr);

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
      wait for 100 ns;	

      wait for clock_period*2; resetn <= '1';

      -- insert stimulus here 
      posX_E <= '1'; wait for clock_period;
      --posY_Q <= "0000000000"; wait for clock_period;
	  l_r <= "01";  wait for clock_period;
	  --posX_E <= '0';
      --posY_Q <= "0000010100"; wait for clock_period;
	  l_r <= "00"; wait for clock_period;
	
      wait;
   end process;

END;