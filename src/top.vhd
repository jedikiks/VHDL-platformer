library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity top is
    generic( X_IM: integer := 320; -- These change initial
             Y_IM: integer := 240;  -- starting positions
             RGB_BITS: integer := 12
           );
	port ( clock, resetn: in std_logic;
           SW: in std_logic_vector( 3 downto 0 ); -- Switches that control canMove___
           ps2c, ps2d: in std_logic;
           HS, VS: out std_logic;
           RGB : out std_logic_vector(RGB_BITS-1 downto 0);
           LED: out std_logic_vector( 3 downto 0 )
      	 );
end top;

architecture structure of top is

    signal X_immediate, Y_immediate: std_logic_vector( 9 downto 0 );
    signal pause, E_phy, moveLeft, moveRight, jump, canFall, canMoveLeft, canMoveRight, canMoveUp,  ps2_done,  E_fallCt, E_jumpCt : std_logic;
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
                LINE_THICK: integer:= 2
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

    X_immediate <= std_logic_vector( to_unsigned( X_IM, X_immediate'length ) ); 
    Y_immediate <= std_logic_vector( to_unsigned( Y_IM, Y_immediate'length ) ); 

    LED <= SW;

    phy: physics port map( clock => clock,
                           resetn => resetn,
                           ps2_done => ps2_done,
                           E_phy => E_phy,
                           din => din,
                           X_immediate => std_logic_vector( to_unsigned( X_IM, X_immediate'length ) ),
                           Y_immediate => std_logic_vector( to_unsigned( Y_IM, Y_immediate'length ) ),
                           E_fallCt => E_fallCt,
                           E_jumpCt => E_jumpCt,
                           moveLeft => moveLeft,
                           moveRight => moveRight,
                           moveUp => jump,
                           posX => posX,
                           posY => posY,
                           canFall => SW( 0 ),
                           canMoveLeft => SW( 1 ),
                           canMoveRight => SW( 2 ),
                           canMoveUp => SW( 3 )
                         );
    ps2kb: my_ps2keyboard port map( clock => clock,
                                    resetn => resetn,
                                    ps2c => ps2c,
                                    ps2d => ps2d,
                                    DOUT => dout,
                                    done => ps2_done
                                  );
    vga: vga_display generic map( RGB_BITS => RGB_BITS,
                                  PLAYER_WIDTH => 4,
                                  PLAYER_HEIGHT => 4,
                                  BOX_WIDTH => 4,
                                  BOX_HEIGHT => 4,
                                  LINE_THICK => 4
                                )
                     port map( clock => clock,
                               resetn => resetn,
                               x => posX,
                               y => posY,
                               HS => HS,
                               VS => VS
                            );
end;
