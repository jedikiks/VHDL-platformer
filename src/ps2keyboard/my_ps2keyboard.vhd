---------------------------------------------------------------------------
-- This VHDL file was developed by Daniel Llamocca (2015).  It may be
-- freely copied and/or distributed at no cost.  Any persons using this
-- file for any purpose do so at their own risk, and are responsible for
-- the results of such use.  Daniel Llamocca does not guarantee that
-- this file is complete, correct, or fit for any particular purpose.
-- NO WARRANTY OF ANY KIND IS EXPRESSED OR IMPLIED.  This notice must
-- accompany any copy of this file.
--------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.math_real.log2;
use ieee.math_real.ceil;


-- Output Data: 10 bits: DOUT(9): Stop bit (1), DOUT(8): Parity bit (odd). DOUT(7 downto 0): 8-bit data from keyboard
-- For each 10-bit output, the done is asserted for one clock cycle. Done is asserted when data is already available to capture.
-- Keyboard behavior: if a key is pressed and held, the scan code (8 bits, see Nexys4-DDR datashet) is sent every 100 ms
--                    Once the key is released, a keyup code is sent first (F0), followed by the 8-bit scan code.
--                    For all these instances (repeated scan code every 100 ms, keyup code, and scan code), the done signal is asserted
--                    for one clock cycle. Some keys send two keyup codes: E0 F0.
--                    If  using shift + key: we get F0 12 (or 59), then the scan code. For this, make sure to release 'shift' first. 12 (shift left side), 59 (shift right side)
--                    If you want to only read one scan code, design an FSM that waits for the keyupcode (F0), and then retrieves the scan code once.
entity my_ps2keyboard is
	port (resetn, clock: in std_logic;
			ps2c, ps2d: in std_logic;
			DOUT: out std_logic_vector (7 downto 0);
			done: out std_logic);
end my_ps2keyboard;

architecture Behavioral of my_ps2keyboard is

    component my_ps2read
        port (resetn, clock: in std_logic;
                ps2c, ps2d: in std_logic;
                DOUT: out std_logic_vector (9 downto 0);
                done: out std_logic);
    end component;
    
    component my_pashiftreg
       generic (N: INTEGER:= 4;
                 DIR: STRING:= "LEFT");
        port ( clock, resetn: in std_logic;
               din, E, s_l: in std_logic; -- din: shiftin input
                 D: in std_logic_vector (N-1 downto 0);
               Q: out std_logic_vector (N-1 downto 0);
              shiftout: out std_logic);
    end component;
    
   	component dffe
        Port ( d : in  STD_LOGIC;
                clrn: in std_logic:= '1';
                  prn: in std_logic:= '1';
               clk : in  STD_LOGIC;
                  ena: in std_logic;
               q : out  STD_LOGIC);
    end component;
	
	type state is (S1, S2);
	signal y: state;	
	
	signal dout10: std_logic_vector (9 downto 0);
	signal dout8: std_logic_vector (7 downto 0);
	signal done_r, Er: std_logic;
	
begin

a1: my_ps2read port map (resetn => resetn, clock => clock, ps2c => ps2c, ps2d => ps2d, dout => dout10, done => done_r);

dout8 <= dout10 (7 downto 0);
-----------------------------------------------------
-- Shift Register for ps2c: Filtering
fi: my_pashiftreg generic map (N => 8, DIR => "RIGHT")
    port map (clock => clock, resetn => resetn, din => '0', E => Er, s_l => '1', D => dout8, Q => DOUT);
	 	
-- Main FSM:
	Transitions: process (resetn, clock, done_r, dout8)
	begin
		if resetn = '0' then -- asynchronous signal 
			y <= S1; -- if resetn asserted, go to initial state: S1			
		elsif (clock'event and clock = '1') then
			case y is
				when S1 =>
					if done_r = '1'then
					   if dout8 = x"F0" then y <= S2; else y <= S1; end if;
					else
					   y <= S1;
					end if;
					
				when S2 =>
				    if done_r = '1' then y <= S1; else y <= S2; end if;
					
			end case;			
		end if;		
	end process;
	
	Outputs: process (y, done_r)
	begin
		-- Initialization of FSM outputs:
		Er <= '0';
		case y is
			when S1 =>
				
			when S2 =>
				if done_r = '1' then Er <= '1'; end if;
				
		end case;
	end process;
	
 rd: dffe port map ( d => Er, clrn => resetn, prn => '1', clk => clock, ena => '1', q => done);

end Behavioral;

