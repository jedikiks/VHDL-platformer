library ieee;
use ieee.std_logic_1164.all;

entity vga_display is
    generic(RGB_BITS : integer := 12);
    port(clock, resetn, MISO : in std_logic;
         RGB : out std_logic_vector(RGB_BITS-1 downto 0);
         HS, VS, MOSI, nCS, SCLK : out std_logic);
end vga_display;

architecture arc of vga_display is

signal display_on, vga_tick : std_logic;
signal RGBd: std_logic_vector(RGB_BITS-1 downto 0);
signal HC, VC : std_logic_vector(9 downto 0);
signal LU_HC, LL_HC, RU_HC, RL_HC, LU_VC, LL_VC, RU_VC, RL_VC : std_logic_vector(9 downto 0);

component vga_ctrl
    port(clock, resetn : in std_logic;
     HS, VS : out std_logic;
     vga_tick : inout std_logic;
     HC, VC : inout std_logic_vector(9 downto 0);
     display_on : out std_logic);
end component;

component adxlpxmv
	port (clock, resetn, MISO : in std_logic;
          LU_HC, LL_HC, RU_HC, RL_HC, LU_VC, LL_VC, RU_VC, RL_VC : out std_logic_vector(9 downto 0);
          MOSI, nCS, SCLK : out std_logic);
end component;

begin

vgactrl: vga_ctrl port map(resetn=>resetn,clock=>clock,display_on=>display_on,vga_tick=>vga_tick,HS=>HS,VS=>VS,HC=>HC,VC=>VC);
pxmv: adxlpxmv port map(resetn=>resetn,clock=>clock,MISO=>MISO, MOSI=>MOSI, nCS=>nCS, SCLK=>SCLK,LU_HC=>LU_HC, LL_HC=>LL_HC, RU_HC=>RU_HC, RL_HC=>RL_HC, 
						LU_VC=>LU_VC, LL_VC=>LL_VC, RU_VC=>RU_VC, RL_VC=>RL_VC);


process(clock,resetn,LU_HC, LL_HC, RU_HC, RL_HC, LU_VC, LL_VC, RU_VC, RL_VC)
begin
    if resetn = '0' then
        RGBd <= (others => '0');
    elsif (clock'event and clock = '1') then
        if vga_tick = '1' then
			if (HC = LU_HC) and (VC = LU_VC) then
				RGBd <= x"F00";
			elsif (HC = LL_HC) and (VC = LL_VC) then
			    RGBd <= x"F00";
			elsif (HC = RU_HC) and (VC = RU_VC) then
			    RGBd <= x"F00";
			elsif (HC = RL_HC) and (VC = RL_VC) then
			    RGBd <= x"F00";
			else
				RGBd <= (others => '0');
        end if;
    end if;
    end if;
end process;


-- output RGB mux:
with display_on select
    RGB <= (others => '0') when '0',
           RGBd when '1',
           (others => '-') when others;

end;










