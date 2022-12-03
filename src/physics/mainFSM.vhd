library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.std_logic_arith.all;
use ieee.math_real.log2;
use ieee.math_real.ceil;

entity mainFSM is
	    port ( clock, resetn: in std_logic;
	           canMoveUp, canMoveLeft, canMoveRight, ps2_done, fall_done, E_phy: in std_logic;
	           din: in std_logic_vector( 7 downto 0 );	-- change this if you have bigger scan codes
	           addr_sel, l_r: out std_logic_vector( 1 downto 0 );
	           E_jumpCt, posY_E_main, posX_E, E_addr_sel, posY_E_sel, E_addr_main,
    	           check_fall, moveLeft, moveRight, moveUp: out std_logic
          	 );
end mainFSM;

architecture Behavioral of mainFSM is

component my_genpulse_sclr is
		--generic (COUNT: INTEGER:= (10**8)/2); -- (10**8)/2 cycles of T = 10 ns --> 0.5 s
		generic (COUNT: INTEGER:= (10**2)/2); -- (10**2)/2 cycles of T = 10 ns --> 0.5us
		port (clock, resetn, E, sclr: in std_logic;
				Q: out std_logic_vector ( integer(ceil(log2(real(COUNT)))) - 1 downto 0);
				z: out std_logic);
	end component;
	
    signal falling, jwait_zQ, jwait_EQ, jwait_sclrQ, jumpPx_EQ,
           jumpPx_sclrQ, jumpPx_zQ, mwait_zQ, mwait_EQ, mwait_sclrQ : std_logic;

	type state is ( S0, S1, S2, S3, S4, S5a, S5b );
	signal y: state;
	
begin

	jpx: my_genpulse_sclr generic map( COUNT => 4 ) -- TODO: change this to non-tb value
		     	     port map( clock => clock,
				       resetn => resetn,
				       E => jumpPx_EQ,
				       sclr => jumpPx_sclrQ,
				       z => jumpPx_zQ
				     );
	jw: my_genpulse_sclr generic map( COUNT => 4 ) -- TODO: change this to non-tb value
		     	     port map( clock => clock,
				       resetn => resetn,
				       E => jwait_EQ,
				       sclr => jwait_sclrQ,
				       z => jwait_zQ
				     );
	mw: my_genpulse_sclr generic map( COUNT => 4 ) -- TODO: change this to non-tb value
		     	     port map( clock => clock,
				       resetn => resetn,
				       E => mwait_EQ,
				       sclr => mwait_sclrQ,
				       z => mwait_zQ
				     );
				     
	Transitions: process ( resetn, clock, canMoveUp, canMoveLeft, canMoveRight, ps2_done, fall_done, din )
	begin
		if resetn = '0' then
			y <= S0;
		elsif (clock'event and clock = '1') then
			case y is
				when S0 => y <= S1;
				when S1 =>
				    if  E_phy = '1' then
						if ps2_done = '1' then
							y <= S2;
						else y <= S1;
						end if;
					else y <= S1;
				    end if;

				when S2 =>
					if fall_done='1' then y <= S3; else y <= S2; end if;
					
				when S3 =>	
					if din = x"29" then y <= S4;
                        elsif din = x"23" and canMoveLeft = '1' then y <= S5b;
						elsif din = x"1C" and canMoveRight <= '1' then y <= S5b; 
                        else y <= S1;
                    end if;
					
				when S4 =>
                    if canMoveUp = '1' then y <= S5a; else y <= S1; end if;

                when S5a =>
                    if jwait_zQ = '1' then
                        if jumpPx_zQ = '1' then y <= S1;
                            else y <= S4;
                        end if;
                    else y <= S5a; end if;

                when S5b =>
                    if mwait_zQ = '1' then y <= S1; else y <= S5b; end if;
                                    
                end case;
		end if;
		
	end process;
	
	Outputs: process ( y, E_phy, canMoveUp, canMoveLeft, canMoveRight, ps2_done, fall_done, din, jwait_zQ, jumpPx_zQ, mwait_zQ )
	begin		
	    E_addr_sel <= '0'; E_addr_main <= '0'; posY_E_main <= '0'; falling <= '0'; posX_E <= '0'; check_fall <= '0';
	    posY_E_sel <= '0'; addr_sel <= "00"; l_r <= "00"; jwait_EQ <= '0'; jwait_sclrQ <= '0'; -- Default values
        jumpPx_EQ <= '0'; jumpPx_sclrQ <= '0'; mwait_EQ <= '0'; mwait_sclrQ <= '0';
        E_jumpCt <= '0'; moveLeft <= '0'; moveRight <= '0'; moveUp <= '0';
        
		case y is	
			when S0 => posY_E_main <= '1'; l_r <= "10"; posX_E <= '1';	
			
			when S1 => if  E_phy = '1' and ps2_done = '1' then check_fall <= '1'; end if;
						-- if E_phy <= '1' then 
							-- if ps2_done <= '1' then 
								-- check_fall <= '1';
							-- end if;
						-- end if;

            when S2 => E_addr_sel <= '1'; posY_E_sel <= '1';
			
			when S3 => if din = x"23" then
                                moveLeft <= '1'; E_addr_main <= '1'; addr_sel <= "00"; 
		    		            if canMoveLeft = '1' then posX_E <= '1'; end if;
		    		        end if;
		    		        if din = x"1C" then
                                moveRight <= '1'; E_addr_main <= '1'; addr_sel <= "01"; l_r <= "01";
		    		            if canMoveRight = '1' then posX_E <= '1'; end if;
		    		        end if;

            when S4 => moveUp <= '1'; addr_sel <= "10"; E_addr_main <= '1'; 
                       if canMoveUp = '1' then posY_E_main <= '1'; end if;

            when S5a => if jwait_zQ = '1' then jwait_EQ <= '1'; jwait_sclrQ <= '1';
                             if jumpPx_zQ = '1' then E_jumpCt <= '1'; jumpPx_EQ <= '1'; jumpPX_sclrQ <= '1';
                             else E_jumpCt <= '1'; jumpPx_EQ <= '1';
                             end if;
                         else jwait_EQ <= '1';
                         end if;
            when S5b => if mwait_zQ = '1' then mwait_EQ <= '1'; mwait_sclrQ <= '1';
                        else mwait_EQ <= '1';
                        end if;
		end case;
	end process;
end;
