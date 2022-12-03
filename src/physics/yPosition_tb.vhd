library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity yPosition_tb is
end yPosition_tb;

architecture Behavioral of yPosition_tb is
component yPosition
	port ( clock, resetn, posY_E: in std_logic;
	       falling: std_logic_vector( 1 downto 0 );
	       posX_Q, Y_immediate: in std_logic_vector( 9 downto 0 );
	       posY_Q: out std_logic_vector( 9 downto 0 );
	       fall_newPosY_addr, posY_jump_addr: out std_logic_vector( 19 downto 0 ) -- change this if address width is different
      	 );
end component;

   --Inputs
   signal resetn, clock, posY_E: std_logic := '0';
   signal falling: std_logic_vector( 1 downto 0 ) := "10";
   signal posX_Q_tb: std_logic_vector ( 9 downto 0 ) := (others => '0');
   signal Y_immediate: std_logic_vector ( 9 downto 0 ) := "0111011110"; --478

   --Outputs
   signal posY_Q_tb : std_logic_vector ( 9 downto 0 );
   signal fall_newPosY_addr, posY_jump_addr : std_logic_vector ( 19 downto 0 );

   -- Clock period definitions
   constant clock_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: yPosition PORT MAP (resetn=>resetn, clock=>clock, posY_E=>posY_E, falling=>falling, posX_Q=>posX_Q_tb, posY_Q=>posY_Q_tb, fall_newPosY_addr=>fall_newPosY_addr, posY_jump_addr=>posY_jump_addr, Y_immediate=>Y_immediate);

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
      
      posY_E <= '1'; wait for 2 * clock_period;
      posY_E <= '0'; wait for 2 * clock_period;

      -- jumping ( not falling )
      falling <= "00"; posY_E <= '1'; wait for 2 * clock_period;
      posY_E <= '1'; wait for 2 * clock_period;

      
      -- falling
      falling <= "01"; posY_E <= '1'; wait for 2 * clock_period;
      posY_E <= '1'; wait for 2 * clock_period;

      wait;
   end process;

END;