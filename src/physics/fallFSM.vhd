library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use ieee.math_real.log2;
use ieee.math_real.ceil;

entity fallFSM is
	    port ( clock, resetn: in std_logic;
	           canFall, check_fall, E_phy: in std_logic;
	           E_fallCt, posY_E_falling, E_addr_falling: out std_logic;
	           fall_done, sclrQ: out std_logic;
	           falling: out std_logic_vector( 1 downto 0 );
	           addr_sel: out std_logic_vector( 2 downto 0 )
          	 );
end fallFSM;

architecture Behavioral of fallFSM is
    signal zQ, sclrQ_t, EQ: std_logic;

	type state is ( S0, S1, S2, S3 );
	signal y: state;

	component my_genpulse_sclr is
		--generic (COUNT: INTEGER:= (10**8)/2); -- (10**8)/2 cycles of T = 10 ns --> 0.5 s
		generic (COUNT: INTEGER:= (10**2)/2); -- (10**2)/2 cycles of T = 10 ns --> 0.5us
		port (clock, resetn, E, sclr: in std_logic;
				Q: out std_logic_vector ( integer(ceil(log2(real(COUNT)))) - 1 downto 0);
				z: out std_logic);
	end component;

begin
    sclrQ <= sclrQ_t;
    
	pg: my_genpulse_sclr generic map( COUNT => (10**6)/3 ) -- TODO: change this to non-tb value
		     	     port map( clock => clock,
				       resetn => resetn,
				       E => EQ,
				       sclr => sclrQ_t,
				       z => zQ
				     );

	Transitions: process ( resetn, clock, canFall, check_fall, zQ )
	begin
		if resetn = '0' then
			y <= S0;
		elsif (clock'event and clock = '1') then
			case y is
				when S0 => y <= S1;
				when S1 =>
				    if check_fall = '1' then
				        y <= S2;
				    end if;

				when S2 =>
					if E_phy = '1' and canFall = '1' then y <= S3;
					elsif E_phy = '1' and canFall ='0' then y <= S1;
					else y <= S2; end if;
					
				when S3 =>
					if E_phy = '1' and zQ ='1' then y <= S2; else y <= S3; end if;
                                    
                end case;
		end if;
		
	end process;
	
	Outputs: process ( y, canFall, zQ, E_phy )
	begin		
	    E_addr_falling <= '0'; posY_E_falling <= '0'; falling <= "00"; EQ <= '0'; 	-- Default values
	    fall_done <= '0'; E_fallCt <= '0'; sclrQ_t <= '0'; addr_sel <= ( others => '0' );
		case y is	
			when S0 => falling <= "10";
            when S1 => 
			when S2 => if E_phy = '1' then E_addr_falling <= '1'; addr_sel <= "011"; end if;
					   if E_phy = '1' and canFall = '0' then fall_done <= '1'; end if;
					   
			when S3 => falling <= "01";
					   if E_phy = '1' then
							if zQ = '0' then EQ <= '1';
								else EQ <= '1'; sclrQ_t <= '1'; posY_E_falling <= '1'; E_fallCt <= '1';
							end if;
						end if;
		end case;
	end process;

end;
