library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top is
    generic( X_IM: integer := 320; -- These change initial
             Y_IM: integer := 240;  -- starting positions
             RGB_BITS: integer := 12;
             PLAYER_WIDTH: integer:= 5;
             PLAYER_HEIGHT: integer:= 5;
             BOX_WIDTH: integer:= 200; 
             BOX_HEIGHT: integer:= 200;
             LINE_THICK: integer:= 2;
             PLATFORM_WIDTH: integer:= 40;
             PLATFORM_HEIGHT: integer:= 5
           );
	port ( clock, resetn: in std_logic;
           SW: in std_logic; -- Switches that control canMove___
           ps2c, ps2d: in std_logic;
           HS, VS: out std_logic;
           RGB : out std_logic_vector(RGB_BITS-1 downto 0);
           LED: out std_logic
      	 );
end top;

architecture structure of top is

    signal X_immediate, Y_immediate: std_logic_vector( 9 downto 0 );
    signal pause, E_phy, moveLeft, moveRight, moveUp, canFall, canMoveLeft, canMoveRight, canMoveUp,  ps2_done,  E_fallCt, E_jumpCt : std_logic;
    signal dout, din: std_logic_vector( 7 downto 0 );
    signal posX, posY: std_logic_vector( 9 downto 0 );

	component physics 
	    port ( clock, resetn: in std_logic;
	           canFall, canMoveLeft, canMoveRight, canMoveUp, ps2_done, E_phy: in std_logic;
	           din: in std_logic_vector( 7 downto 0 );	-- change this if you have bigger scan codes
	           X_immediate, Y_immediate: in std_logic_vector( 9 downto 0 );
	           E_jumpCt, E_fallCt, moveLeft, moveRight, moveUp: out std_logic;
	           posX, posY: out std_logic_vector( 9 downto 0 );
	           addr: out std_logic_vector( 19 downto 0 ) -- change this if address width is different
          	 );
	end component;

	component vga_display 
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
	end component;

	component my_ps2keyboard 
	    port (resetn, clock: in std_logic;
	    		ps2c, ps2d: in std_logic;
	    		DOUT: out std_logic_vector (7 downto 0);
	    		done: out std_logic);
	end component;

begin
    ---------------------------
    -- Signal Assignments:
    ---------------------------
    X_immediate <= std_logic_vector( to_unsigned( X_IM, X_immediate'length ) ); 
    Y_immediate <= std_logic_vector( to_unsigned( Y_IM, Y_immediate'length ) ); 
    LED <= SW;

    ---------------------------
    -- Movement enc:
    ---------------------------
    process( moveLeft, moveRight, moveUp, canFall, canMoveLeft, canMoveRight, canMoveUp, posX, posY )
    begin
	    -- Move left 
	    if moveLeft = '1' and posX >= std_logic_vector( to_unsigned( ( 320 - ( BOX_WIDTH / 2 ) + 2 ), posX'length ) ) then
		    canMoveLeft <= '1';
	    else
		    canMoveLeft <= '0';
	    end if;

	    -- Move right 
	    if moveRight = '1' and posX < std_logic_vector( to_unsigned( ( 320 + ( BOX_WIDTH / 2 ) - 2  ), posX'length ) ) then
		    canMoveRight <= '1';
	    else
		    canMoveRight <= '0';
	    end if;

	    -- Move up 
	    if moveUp = '1' and posY > std_logic_vector( to_unsigned( ( ( 240 - ( BOX_HEIGHT / 2 ) ) + LINE_THICK ), posY'length ) ) then
		    canMoveUp <= '1';
	    else
		    canMoveUp <= '0';
	    end if;

	    ---------------------
	    -- Move down 
	    ---------------------

	    -- top platform
            if( (
                    ( posX >= std_logic_vector( to_unsigned( ( 320 - ( PLATFORM_WIDTH / 2 ) ), posX'length ) ) ) and
                    ( posX < std_logic_vector( to_unsigned( ( 320 + ( PLATFORM_WIDTH / 2 ) ), posX'length ) ) )
                )
                and
                (
                    posY = std_logic_vector( to_unsigned( ( ( 240 + 75 ) + ( PLATFORM_HEIGHT / 2 ) - PLAYER_HEIGHT ) , posY'length ) )
                )
            )then
		    canFall <= '0';
	    
	    -- left platform
            elsif( (
                    ( posX >= std_logic_vector( to_unsigned( ( ( 320 - 40 ) - ( PLATFORM_WIDTH / 2 ) ), posX'length ) ) ) and
                    ( posX < std_logic_vector( to_unsigned( ( ( 320 - 40 ) + ( PLATFORM_WIDTH / 2 ) ), posX'length ) ) )
                )
                and
                (
                    posY = std_logic_vector( to_unsigned( ( ( 240 + 50 ) + ( PLATFORM_HEIGHT / 2 ) - PLAYER_HEIGHT ) , posY'length ) )
                )
            )then
		    canFall <= '0';
	    
	    -- right platform
            elsif( (
                    ( posX >= std_logic_vector( to_unsigned( ( ( 320 + 40 ) - ( PLATFORM_WIDTH / 2 ) ), posX'length ) ) ) and
                    ( posX < std_logic_vector( to_unsigned( ( ( 320 + 40 ) + ( PLATFORM_WIDTH / 2 ) ), posX'length ) ) )
                )
                and
                (
                    posY = std_logic_vector( to_unsigned( ( ( 240 + 50 ) + ( PLATFORM_HEIGHT / 2 ) - PLAYER_HEIGHT ) , posY'length ) )
                )
            )then
		    canFall <= '0';
	    
	    elsif posY < std_logic_vector( to_unsigned( ( ( 240 - LINE_THICK + ( BOX_HEIGHT / 2 ) ) - PLAYER_HEIGHT ), posY'length ) ) then canFall <= '1';
	    
	    else
		    canFall <= '0';
	    end if;

    end process;


    ---------------------------
    -- Components:
    ---------------------------
    phy: physics port map( clock => clock,
                           resetn => resetn,
                           ps2_done => ps2_done,
                           E_phy => SW,
                           din => din,
                           X_immediate => std_logic_vector( to_unsigned( X_IM, X_immediate'length ) ),
                           Y_immediate => std_logic_vector( to_unsigned( Y_IM, Y_immediate'length ) ),
                           E_fallCt => E_fallCt,
                           E_jumpCt => E_jumpCt,
                           moveLeft => moveLeft,
                           moveRight => moveRight,
                           moveUp => moveUp,
                           posX => posX,
                           posY => posY,
                           canFall => canFall,
                           canMoveLeft => canMoveLeft,
                           canMoveRight => canMoveRight,
                           canMoveUp => canMoveUp 
                         );
    ps2kb: my_ps2keyboard port map( clock => clock,
                                    resetn => resetn,
                                    ps2c => ps2c,
                                    ps2d => ps2d,
                                    DOUT => din,
                                    done => ps2_done
                                  );
    vga: vga_display generic map( RGB_BITS => RGB_BITS,
                                  PLAYER_WIDTH => PLAYER_WIDTH,
                                  PLAYER_HEIGHT => PLAYER_HEIGHT,
                                  BOX_WIDTH => BOX_WIDTH,
                                  BOX_HEIGHT => BOX_HEIGHT,
                                  LINE_THICK => LINE_THICK,
             			  PLATFORM_WIDTH => PLATFORM_WIDTH,
		                  PLATFORM_HEIGHT => PLATFORM_HEIGHT
                                )
                     port map( clock => clock,
                               resetn => resetn,
                               x => posX,
                               y => posY,
                               HS => HS,
                               VS => VS,
                               RGB => RGB
                            );
end;
