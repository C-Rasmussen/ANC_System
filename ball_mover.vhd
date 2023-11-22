
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ball_mover is 
port(
	clk : in std_logic;
	rst : in std_logic;
	btn : in std_logic;
	rand_num : in unsigned (9 downto 0);
	bricks : in std_logic_vector (1214 downto 0);
	ball_xpos : out unsigned (9 downto 0);
	ball_ypos : out unsigned (9 downto 0);
	paddle_pos : in unsigned (9 downto 0);
	hflag : in std_logic;
	vflag : in std_logic
);
end entity ball_mover;


architecture behavior of ball_mover is

signal xmove : unsigned (3 downto 0) := "0011";
signal ymove : unsigned (3 downto 0) := "0011";

signal l_flag : std_logic := '0';
signal r_flag : std_logic := '0';
signal u_flag : std_logic := '0';
signal d_flag : std_logic := '0';

signal temp_ypos : unsigned (9 downto 0);
signal temp_xpos : unsigned (9 downto 0);

type state_type is (INITIAL, UPLEFT, UPRIGHT, DOWNLEFT, DOWNRIGHT);
signal state : state_type := INITIAL;




begin

process (clk) begin
	if rst = '0' then
		xmove <= "0011";
		ymove <= "0011";
		temp_xpos <= rand_num;
		temp_ypos <= "0011110000";
		state <= INITIAL;
	elsif rising_edge (clk) then
		case state is
			when INITIAL =>
			
				if temp_ypos > 471 then
					if temp_xpos >= paddle_pos and temp_xpos <= (paddle_pos + 20) then
						state <= UPLEFT;
					elsif temp_xpos >= (paddle_pos + 20) and temp_xpos <= (paddle_pos + 40) then
						state <= UPRIGHT;
					end if;
				elsif
					if vflag = '0' and hflag = '0' then
						temp_ypos <= temp_ypos - ymove;
					end if;
				end if;
				
			when UPLEFT =>
			
				temp_ypos <= temp_ypos + ymove;
				temp_xpos <= temp_xpos - xmove;
			
			when UPRIGHT =>
		
				temp_ypos <= temp_ypos + ymove;
				temp_xpos <= temp_xpos + xmove;
			
			when DOWNLEFT =>
			
			when DOWNRIGHT =>
			
		end case;
	end if;
	
	ball_ypos <= temp_ypos;
	ball_xpos <= temp_xpos;
end process;

					
					
	


end architecture behavior;
