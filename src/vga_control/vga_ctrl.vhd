library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity vga_ctrl is
    port(clock, resetn : in std_logic;
		 HS, VS : out std_logic;
		 vga_tick : inout std_logic;
		 HC, VC : inout std_logic_vector(9 downto 0);
		 display_on : out std_logic);
end vga_ctrl;

architecture arc of vga_ctrl is

-- HS Timing:
constant hdisp: integer := 640;
constant r_border: integer := 16;
constant h_retrace: integer := 96;
constant l_border: integer := 48;

-- VS Timing:
constant vdisp: integer := 480;
constant bot_border: integer := 10;
constant v_retrace: integer := 2;
constant top_border: integer := 33;

-- Signals for VC and HC Counters:
signal E_HC: std_logic;
signal E_VC: std_logic;
signal sclr_HC: std_logic;
signal sclr_VC: std_logic;

-- VS, HS and display_on Pre-Registered Signals:
signal e_VS, e_HS, e_display_on : std_logic;
signal d_VS, d_HS, d_display_on : std_logic;

-- VGA Clock Definitions:
constant COUNT: integer := 4; -- To achieve a 25MHz clock, we divide the global clock (100MHz) by the pixel clock (25Mhz)
signal Qt: std_logic_vector(3 downto 0); -- Internal counter, vga_tick goes to 1 when Qt reaches 3

-- FSM Definitions
type state is (S1, S2);
signal y: state;

begin

-- 25MHz Clock Gen, using 100MHz Sys Clock
vgaclk: process(clock,resetn,Qt,vga_tick)
begin
	if resetn = '0' then
		Qt <= (others => '0');
		vga_tick <= '0';
	elsif (clock'event and clock = '1') then
		if (Qt = COUNT - 1) then
			Qt <= (others => '0'); 
			vga_tick <= '1';
		else
			Qt <= Qt + 1;
			vga_tick <= '0';
		end if;
	end if;
end process;

-- HC counter
hc_ct: process(clock,resetn,sclr_HC,HC)
begin
	if resetn = '0' then
		HC <= (others => '0');
	elsif (clock'event and clock = '1') then
		if vga_tick = '1' then
			if sclr_HC = '1' then
				HC <= (others => '0');
			elsif E_HC = '1' then
				if (HC = hdisp + r_border + h_retrace + l_border - 1) then -- Max count of 800 (799 downto 0)
					HC <= (others => '0');
				else HC <= HC + 1;
				end if;
			end if;
		end if;
	end if;
end process;

-- VC counter
vc_ct: process(clock,resetn,sclr_VC,VC)
begin
	if resetn = '0' then
		VC <= (others => '0');
	elsif (clock'event and clock = '1') then
		if vga_tick = '1' then
			if sclr_VC = '1' then
				VC <= (others => '0');
			elsif E_VC = '1' then
				if (VC = vdisp + bot_border + v_retrace + top_border - 1) then -- Max count of 525 (524 downto 0)
					VC <= (others => '0');
				else VC <= VC + 1;
				end if;
			end if;
		end if;
	end if;
end process;

-- display_on, HS and VS signal register
-- reg: process(clock, resetn, HSt, VSt, display_ont)
-- begin
    -- if resetn = '0' then
        -- HS <= '0'; VS <= '0'; display_on <= '0';
    -- elsif (clock'event and clock = '1') then
		-- if HSt = '1' then HS <= '1'; else HS <= '0'; end if;
		-- if VSt = '1' then VS <= '1'; else VS <= '0'; end if;
		-- if display_ont = '1' then display_on <= '1'; else display_on <= '0'; end if;
    -- end if;
-- end process;

-- HS dffe
hsdffe: process(clock,resetn,e_HS,d_HS)
begin
	if resetn = '0' then
		HS <= '0';
	elsif (clock'event and clock = '1') then
		if e_HS = '1' then
			HS <= d_HS;
			end if;
		end if;
end process;

-- VS dffe
vsdffe: process(clock,resetn,e_VS,d_VS)
begin
	if resetn = '0' then
		VS <= '0';
	elsif (clock'event and clock = '1') then
		if e_VS = '1' then
			VS <= d_VS;
			end if;
		end if;
end process;

-- display_on dffe
viddispdffe: process(clock,resetn,e_display_on,d_display_on)
begin
	if resetn = '0' then
		display_on <= '0';
	elsif (clock'event and clock = '1') then
		if e_display_on = '1' then
			display_on <= d_display_on;
			end if;
		end if;
end process;

-- Control FSM
Transistions: process (clock,resetn,y)
begin
	if resetn = '0' then
		y <= S1;
	elsif (clock'event and clock = '1') then
		case y is
			when S1 => y <= S2;
			when S2 => y <= S2;
		end case;
	end if;
end process;

Outputs: process (vga_tick, y, HC, VC)
begin
	sclr_HC <= '0'; sclr_VC <= '0'; E_HC <= '0'; E_VC <= '0'; d_VS <= '0'; e_VS <= '0'; d_HS <= '0'; e_HS <= '0';
	d_display_on <= '0'; e_display_on <= '0';
	case y is
		when S1 =>
		when S2 =>
			if vga_tick = '1' then
				if ((HC < hdisp) and (VC < vdisp)) then
					e_display_on <= '1';
					d_display_on <= '1'; -- video on only when (VC<480) and (HC<640)
				else
					e_display_on <= '1';
					d_display_on <= '0';
				end if;
				if ((VC >= vdisp + bot_border) and (VC < vdisp + bot_border + v_retrace)) then -- VS condition
					d_VS <= '0'; e_VS <= '1';
				else
					d_VS <= '1'; e_VS <= '1';
				end if;
				if ((HC >= hdisp + r_border) and (HC < hdisp + r_border + h_retrace)) then -- HS condition
					d_HS <= '0'; e_HS <= '1';
				else
					d_HS <= '1'; e_HS <= '1';
				end if;
				if (HC = hdisp + r_border + h_retrace + l_border - 1) then -- if HC = 799, reset the HC counter and add 1 to VC
					sclr_HC <= '1';
					E_VC <= '1';
				else
					E_HC <= '1';
				end if;
				if (VC = vdisp + bot_border + v_retrace + top_border - 1) then -- if VC = 524, reset the VC counter
					sclr_VC <= '1';
				end if;
			end if;
	end case;
end process;
	
end;	
