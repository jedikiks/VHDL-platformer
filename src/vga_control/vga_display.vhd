library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga_display is
    generic( RGB_BITS : integer := 12;
             PLAYER_WIDTH: integer:= 4;
             PLAYER_HEIGHT: integer:= 4;
             BOX_WIDTH: integer:= 200; 
             BOX_HEIGHT: integer:= 200;
             LINE_THICK: integer:= 2;
             PLATFORM_WIDTH: integer:= 40;
             PLATFORM_HEIGHT: integer:= 5
           );
    port( clock, resetn: in std_logic;
          x, y: in std_logic_vector( 9 downto 0 );
          RGB : out std_logic_vector(RGB_BITS-1 downto 0);
          HS, VS : out std_logic
        );
end vga_display;

architecture arc of vga_display is

signal display_on, vga_tick : std_logic;
signal RGBd: std_logic_vector(RGB_BITS-1 downto 0);
signal HC, VC : std_logic_vector(9 downto 0);

component vga_ctrl
    port( clock, resetn : in std_logic;
          HS, VS : out std_logic;
          vga_tick : inout std_logic;
          HC, VC : inout std_logic_vector(9 downto 0);
          display_on : out std_logic
        );
end component;

begin

vgactrl: vga_ctrl port map(resetn=>resetn,clock=>clock,display_on=>display_on,vga_tick=>vga_tick,HS=>HS,VS=>VS,HC=>HC,VC=>VC);


process( clock, resetn, x, y )
begin
    if resetn = '0' then
        RGBd <= (others => '0');
    elsif (clock'event and clock = '1') then
        if vga_tick = '1' then

            ---------------------------------------------------------------------------------------------------------
            -- Draw a square:
            ---------------------------------------------------------------------------------------------------------
            -- Top Line
            if( (
                    ( HC >= std_logic_vector( to_unsigned( ( 320 - ( BOX_WIDTH / 2 ) ), HC'length ) ) ) and
                    ( HC < std_logic_vector( to_unsigned( ( 320 + ( BOX_WIDTH / 2 ) ), HC'length ) ) )
                )
                and
                (
                    ( VC >= std_logic_vector( to_unsigned( ( 240 - ( BOX_HEIGHT / 2 ) ) , VC'length ) ) ) and
                    ( VC < std_logic_vector( to_unsigned( ( ( 240 - ( BOX_HEIGHT / 2 ) ) + LINE_THICK ), VC'length ) ) )
                )
            )then
                RGBd <= x"FFF";
            end if;

            -- Bottom Line
            if( (
                    ( HC >= std_logic_vector( to_unsigned( ( 320 - ( BOX_WIDTH / 2 ) ), HC'length ) ) ) and
                    ( HC < std_logic_vector( to_unsigned( ( 320 + ( BOX_WIDTH / 2 ) ), HC'length ) ) )
                )
                and
                (
                    ( VC >= std_logic_vector( to_unsigned( ( 240 + ( BOX_HEIGHT / 2 ) ) , VC'length ) ) ) and
                    ( VC < std_logic_vector( to_unsigned( ( ( 240 + ( BOX_HEIGHT / 2 ) ) + LINE_THICK ), VC'length ) ) )
                )
            )then
                RGBd <= x"FFF";
            end if;
 
            -- Left Line
            if( (
                    ( HC = std_logic_vector( to_unsigned( ( 320 - ( BOX_WIDTH / 2 ) ), HC'length ) ) )
                )
                and
                (
                    ( VC >= std_logic_vector( to_unsigned( ( 240 - ( BOX_HEIGHT / 2 ) ), VC'length ) ) ) and
                    ( VC < std_logic_vector( to_unsigned( ( 240 + ( BOX_HEIGHT / 2 ) ), VC'length ) ) )
                )
            )then
                RGBd <= x"FFF";
            end if;
 
            -- Right Line
            if( (
                    ( HC = std_logic_vector( to_unsigned( ( 320 + ( BOX_WIDTH / 2 ) ), HC'length ) ) )
                )
                and
                (
                    ( VC >= std_logic_vector( to_unsigned( ( 240 - ( BOX_HEIGHT / 2 ) ), VC'length ) ) ) and
                    ( VC < std_logic_vector( to_unsigned( ( 240 + ( BOX_HEIGHT / 2 ) ), VC'length ) ) )
                )
            )then
                RGBd <= x"FFF";
            end if;


            ---------------------------------------------------------------------------------------------------------
            -- Draw player
            ---------------------------------------------------------------------------------------------------------
            if( (
                    ( HC >= std_logic_vector( to_unsigned( to_integer( unsigned( x ) ) , HC'length ) ) ) and
	                ( HC < std_logic_vector( to_unsigned( to_integer( unsigned( x ) ) + PLAYER_WIDTH, HC'length ) ) )
                )
                and
                (
                    ( VC >= std_logic_vector( to_unsigned( to_integer( unsigned( y ) ) , VC'length ) ) ) and
	                ( VC < std_logic_vector( to_unsigned( to_integer( unsigned( y ) ) + PLAYER_HEIGHT, VC'length ) ) )
                )
            )then
                RGBd <= x"00F";
            end if;

            ---------------------------------------------------------------------------------------------------------
            -- Draw platforms 
            ---------------------------------------------------------------------------------------------------------
	    -- Top most
            if( (
                    ( HC >= std_logic_vector( to_unsigned( ( 320 - ( PLATFORM_WIDTH / 2 ) ), HC'length ) ) ) and
                    ( HC < std_logic_vector( to_unsigned( ( 320 + ( PLATFORM_WIDTH / 2 ) ), HC'length ) ) )
                )
                and
                (
                    VC = std_logic_vector( to_unsigned( ( ( 240 + 75 ) + ( PLATFORM_HEIGHT / 2 ) ) , VC'length ) )
                )
            )then
                RGBd <= x"FFF";
            end if;

	    -- Left 
            if( (
                    ( HC >= std_logic_vector( to_unsigned( ( ( 320 - 40 ) - ( PLATFORM_WIDTH / 2 ) ), HC'length ) ) ) and
                    ( HC < std_logic_vector( to_unsigned( ( ( 320 - 40 ) + ( PLATFORM_WIDTH / 2 ) ), HC'length ) ) )
                )
                and
                (
                    VC = std_logic_vector( to_unsigned( ( ( 240 + 50 ) + ( PLATFORM_HEIGHT / 2 ) ) , VC'length ) )
                )
            )then
                RGBd <= x"FFF";
            end if;

	    -- Right 
            if( (
                    ( HC >= std_logic_vector( to_unsigned( ( ( 320 + 40 ) - ( PLATFORM_WIDTH / 2 ) ), HC'length ) ) ) and
                    ( HC < std_logic_vector( to_unsigned( ( ( 320 + 40 ) + ( PLATFORM_WIDTH / 2 ) ), HC'length ) ) )
                )
                and
                (
                    VC = std_logic_vector( to_unsigned( ( ( 240 + 50 ) + ( PLATFORM_HEIGHT / 2 ) ) , VC'length ) )
                )
            )then
                RGBd <= x"FFF";
            end if;

--			if (HC = LU_HC) and (VC = LU_VC) then
--				RGBd <= x"F00";
--			elsif (HC = LL_HC) and (VC = LL_VC) then
--			    RGBd <= x"F00";
--			elsif (HC = RU_HC) and (VC = RU_VC) then
--			    RGBd <= x"F00";
--			elsif (HC = RL_HC) and (VC = RL_VC) then
--			    RGBd <= x"F00";

			else
				RGBd <= (others => '0');

        end if;
    end if;
end process;


-- output RGB mux:
with display_on select
    RGB <= (others => '0') when '0',
           RGBd when '1';
end;










