library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity xPosition is
	port ( clock, resetn, posX_E: in std_logic;
	       l_r: in std_logic_vector( 1 downto 0 );
	       posY_Q, X_immediate: in std_logic_vector( 9 downto 0 );
	       posX_Q : out std_logic_vector( 9 downto 0 );
	       newX_r_addr, newX_l_addr: out std_logic_vector( 19 downto 0 ) -- change this if address width is different
      	 );
end xPosition;

architecture Behavioral of xPosition is
	signal posX_r_wp1, posX_l_pm1, posX_r, posX_l, posX_D, posX_Q_t: std_logic_vector( 9 downto 0 );
    --signal : std_logic_vector( 19 downto 0 );
    
	component my_rege
		generic (N: INTEGER:= 4);
		     port ( clock, resetn: in std_logic;
		            E, sclr: in std_logic; -- sclr: Synchronous clear
		     		 D: in std_logic_vector (N-1 downto 0);
		            Q: out std_logic_vector (N-1 downto 0));
	end component;

begin
    posX_Q <= posX_Q_t;
    
	-- inferred adders --
	posX_r_wp1 <= std_logic_vector( to_unsigned( to_integer( unsigned( posX_r ) ) + 5, 10 ) ); -- Assuming a height of 4
	posX_l_pm1 <= std_logic_vector( to_unsigned( to_integer( unsigned( posX_l ) ) - 1, 10 ) );        -- pos - 1

	-- inferred multipliers --
    newX_r_addr <=  std_logic_vector( unsigned( posY_Q ) * 640 + unsigned( posX_r_wp1 ) );
    newX_l_addr <= std_logic_vector( unsigned( posY_Q ) * 640 + unsigned( posX_l_pm1 ) );

	with l_r select
		posX_D <= posX_l_pm1 when "00",
	  		      posX_r_wp1 when "01",
	  		      X_immediate when "10",
			      ( others => '0' ) when others;		  

	posX_r <= posX_Q_t when l_r = "01" else ( others => '0' );
	posX_l <= posX_Q_t when l_r = "00" else ( others => '0' );


	posXreg: my_rege generic map( N => 10) -- change this if bit widths for HC and VC are different
	        	     port map( clock => clock,
				               resetn => resetn,
				               E => posX_E,
				               sclr => '0', --FIXME: should this be 1?
				               D => posX_D,
				               Q => posX_Q_t 
				             );
end;
