library ieee;
use ieee.std_logic_1164.all;

entity address_select is
	port ( fall_newPosY_addr, posY_jump_addr, newX_r_addr, newX_l_addr: in std_logic_vector( 19 downto 0 );
           addr_sel: in std_logic_vector( 1 downto 0 );
           E_addr_sel, E_addr_falling, E_addr_main, clock, resetn: in std_logic;
	       addr: out std_logic_vector( 19 downto 0 ) -- change this if address width is different
      	 );
end address_select;

architecture Behavioral of address_select is
    signal D_addr: std_logic_vector( 19 downto 0 );
	signal E_addr: std_logic;
	
	component my_rege
		generic (N: INTEGER:= 4);
		     port ( clock, resetn: in std_logic;
		            E, sclr: in std_logic; -- sclr: Synchronous clear
		     		 D: in std_logic_vector (N-1 downto 0);
		            Q: out std_logic_vector (N-1 downto 0));
	end component;

begin
	with addr_sel select
		D_addr <= fall_newPosY_addr when "11",
                  posY_jump_addr when "10",
	      		  newX_r_addr when "01",
	      		  newX_l_addr when "00",
	    		  ( others => '-' ) when others;
	
	with E_addr_sel select
		E_addr <= E_addr_falling when '1',
				  E_addr_main when '0',
				  '0' when others;

	addrreg: my_rege generic map( N => 20) -- change this if bit widths for HC and VC are different
	        	     port map( clock=>clock, 
                               resetn => resetn,
                               E => E_addr,
				               sclr => '1', --FIXME: should this be 1?
				               D => D_addr,
				               Q => addr 
				             );
end;
