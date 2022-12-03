library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity physics is
	port ( clock, resetn: in std_logic;
	       canFall, canMoveLeft, canMoveRight, canMoveUp, ps2_done, E_phy: in std_logic;
	       din: in std_logic_vector( 7 downto 0 );	-- change this if you have bigger scan codes
	       X_immediate, Y_immediate: in std_logic_vector( 9 downto 0 );
	       E_jumpCt, E_fallCt, moveLeft, moveRight, moveUp: out std_logic;
	       posX, posY: out std_logic_vector( 9 downto 0 );
	       addr: out std_logic_vector( 19 downto 0 ) -- change this if address width is different
      	 );
end physics;

architecture Behavioral of physics is
	signal fall_done, check_fall, posX_E, posY_E, posY_E_falling, posY_E_main, posY_E_sel, E_addr_sel,
	       E_addr_falling,  E_addr_main: std_logic;
	signal addr_sel: std_logic_vector( 1 downto 0 );
	signal l_r, falling : std_logic_vector( 1 downto 0 );
	signal fall_newPosY, nofall_posY_D, r_posX_D, l_posX_D, oldXl_Y, 
           posY_Q, posY_D, posX_D, posX_Q, posX_l, posX_r, newY_jump, newX_r,
	       Xl_Y_addr, newXl_Y, newXl_Y_YQ, newXl_Y_Ymult, newXl_Y_Xlmult, newXl_Y_XlQ: std_logic_vector( 9 downto 0 );
	signal newX_r_addr, newX_l_addr, posY_jump_addr, fall_newPosY_addr, D_addr: std_logic_vector( 19 downto 0 );

	component xPosition 
	port ( clock, resetn, posX_E: in std_logic;
	       l_r: in std_logic_vector( 1 downto 0 );
	       posY_Q, X_immediate: in std_logic_vector( 9 downto 0 );
	       posX_Q : out std_logic_vector( 9 downto 0 );
	       newX_r_addr, newX_l_addr: out std_logic_vector( 19 downto 0 ) -- change this if address width is different
      	 );
	end component;

	component yPosition 
	port ( clock, resetn, posY_E_falling, posY_E_main, posY_E_sel: in std_logic;
	       falling: std_logic_vector( 1 downto 0 );
	       posX_Q, Y_immediate: in std_logic_vector( 9 downto 0 );
	       posY_Q: out std_logic_vector( 9 downto 0 );
	       fall_newPosY_addr, posY_jump_addr: out std_logic_vector( 19 downto 0 ) -- change this if address width is different
      	 );
	end component;

	component address_select 
	port ( fall_newPosY_addr, posY_jump_addr, newX_r_addr, newX_l_addr: in std_logic_vector( 19 downto 0 );
           addr_sel: in std_logic_vector( 1 downto 0 );
           E_addr_sel, E_addr_falling, E_addr_main, clock, resetn: in std_logic;
	       addr: out std_logic_vector( 19 downto 0 ) -- change this if address width is different
      	 );
	end component;

	component fallFSM
	    port ( clock, resetn: in std_logic;
	           canFall, check_fall, E_phy: in std_logic;
	           E_fallCt, posY_E_falling, E_addr_falling: out std_logic;
	           fall_done, sclrQ: out std_logic;
	           falling: out std_logic_vector( 1 downto 0 );
	           addr_sel: out std_logic_vector( 2 downto 0 )
          	 );
	end component;

	component mainFSM
	    port ( clock, resetn: in std_logic;
	           canMoveUp, canMoveLeft, canMoveRight, ps2_done, fall_done, E_phy: in std_logic;
	           din: in std_logic_vector( 7 downto 0 );	-- change this if you have bigger scan codes
	           addr_sel, l_r: out std_logic_vector( 1 downto 0 );
	           E_jumpCt, posY_E_main, posX_E, E_addr_sel, posY_E_sel, E_addr_main, check_fall, moveLeft, moveRight, moveUp: out std_logic
          	 );
	end component;

begin
    posY <= posY_Q;
    posX <= posX_Q;

	xp: xPosition port map( clock => clock,
				            resetn => resetn,
				            X_immediate => X_immediate,
				            posX_E => posX_E,
				            l_r => l_r,
				            posY_Q => posY_Q,
				            posX_Q => posX_Q, 
				            newX_r_addr => newX_r_addr, 
				            newX_l_addr => newX_l_addr
			 	          );
	yp: yPosition port map( clock => clock,
				            resetn => resetn,
				            Y_immediate => Y_immediate,
				            posY_E_falling => posY_E_falling,
							posY_E_main => posY_E_main,
							posY_E_sel => posY_E_sel,
                            falling => falling,
				            posY_Q => posY_Q,
				            posX_Q => posX_Q, 
				            fall_newPosY_addr => fall_newPosY_addr, 
				            posY_jump_addr => posY_jump_addr
			 	          );
	adrsel: address_select port map( clock => clock,
			          	             resetn => resetn,
			          	             fall_newPosY_addr => fall_newPosY_addr,
			          	             posY_jump_addr => posY_jump_addr,
			          	             newX_r_addr => newX_r_addr,
			          	             newX_l_addr => newX_l_addr, 
			          	             addr_sel => addr_sel, 
			          	             E_addr_sel => E_addr_sel,
									 E_addr_falling => E_addr_falling,
									 E_addr_main => E_addr_main,
                                     addr => addr
			           	           );
	-- Two FSMs --
	fallfsmd: fallFSM port map( clock => clock,
				                resetn => resetn,
				                canFall => canFall,
								E_phy => E_phy,
				                check_fall => check_fall,
				                E_fallCt => E_fallCt,
				                posY_E_falling => posY_E_falling, 
				                E_addr_falling => E_addr_falling, 
				                falling => falling, 
				                fall_done => fall_done
			 	              );
	mainfsmd: mainFSM port map( clock => clock,
				                resetn => resetn,
				                check_fall => check_fall,
				                canMoveLeft => canMoveLeft,
				                canMoveRight => canMoveRight,
								canMoveUp => canMoveUp,
				                din => din,
				                ps2_done => ps2_done,
				                E_jumpct => E_jumpct,
				                E_phy => E_phy,
				                posy_E_main => posy_E_main,
								E_addr_sel => E_addr_sel,
								posY_E_sel => posY_E_sel,
				                posx_E => posx_E, 
				                E_addr_main => E_addr_main, 
				                fall_done => fall_done, 
				                addr_sel => addr_sel, 
				                l_r => l_r,
				                moveLeft => moveLeft,
                                moveRight => moveRight,
                                moveUp => moveUp
			 	              );
end;
