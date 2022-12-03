library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb is
end tb;

architecture Behavioral of tb is
component physics
	port ( clock, resetn: in std_logic;
	       canFall, canMoveLeft, canMoveRight, canMoveUp, ps2_done, E_phy: in std_logic;
	       din: in std_logic_vector( 7 downto 0 );	-- change this if you have bigger scan codes
	       X_immediate, Y_immediate: in std_logic_vector( 9 downto 0 );
	       E_fallCt: out std_logic;
	       posX, posY: out std_logic_vector( 9 downto 0 );
	       addr: out std_logic_vector( 19 downto 0 ) -- change this if address width is different
      	 );
end component;

   --Inputs
   signal resetn, clock, canFall, canMoveLeft, canMoveRight, canMoveUp, ps2_done, E_phy : std_logic := '0';
   signal din : std_logic_vector ( 7 downto 0 ) := (others => '0');
   --signal X_immediate : std_logic_vector ( 9 downto 0 ) := (others => '0');
   signal X_immediate : std_logic_vector ( 9 downto 0 ) := "0000001000"; -- 16
   signal Y_immediate : std_logic_vector ( 9 downto 0 ) := "0111011110"; -- 478

   --Outputs
   signal E_fallCt : std_logic;
   signal addr : std_logic_vector( 19 downto 0 );
   signal posX, posY: std_logic_vector( 9 downto 0 );

   -- Clock period definitions
   constant clock_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: physics PORT MAP ( resetn=>resetn, clock=>clock, canFall=>canFall, canMoveLeft=>canMoveLeft,
						   canMoveRight=>canMoveRight, canMoveUp=>canMoveUp, X_immediate=>X_immediate, 
						   Y_immediate=>Y_immediate, ps2_done=>ps2_done, E_phy=>E_phy,
						   din=>din, E_fallCt=>E_fallCt, posX=>posX, posY=>posY, addr=>addr 
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
      wait for 100 ns;	

      wait for clock_period*2; resetn <= '1';

      -- insert stimulus here 
	  wait for clock_period * 2;
	  
	  -- fall
      canFall <= '1'; E_phy <= '1'; ps2_done <= '1'; din <= x"1C"; wait for 2 * clock_period; -- move 1 space to the left
      ps2_done <= '0'; din <= x"1C"; wait for 6 * clock_period;
	  canFall <= '0';
	  
	  -- move left 1
      -- canMoveLeft <= '1'; E_phy <= '1'; ps2_done <= '1'; din <= x"23"; wait for 3*clock_period; -- move 1 space to the left
      -- canMoveLeft <= '0'; E_phy <= '1'; ps2_done <= '0'; wait for 2 * clock_period;
	  
	  
	  -- move right 1
      -- canMoveRight <= '1'; E_phy <= '1'; ps2_done <= '1'; din <= x"1C"; wait for 2*clock_period; -- move 1 space to the left
      -- ps2_done <= '0'; din <= x"1C"; wait for 2 * clock_period;
	  -- canMoveRight <= '0';
	  
	  -- jump 1
      -- canMoveUp <= '1'; E_phy <= '1'; ps2_done <= '1'; din <= x"29"; wait for 3*clock_period; -- move 1 space to the left
      -- din <= x"00"; wait for 2 * clock_period;
	  -- ps2_done <= '0'; canMoveUp <= '0'; wait for 2 * clock_period;
	  -- canMoveUp <= '1'; E_phy <= '1'; ps2_done <= '1'; din <= x"29";
	
      wait;
   end process;

END;