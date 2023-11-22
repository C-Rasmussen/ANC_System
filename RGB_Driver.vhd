
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RGB_Driver is 
port(
	clk : in std_logic;
	rst : in std_logic;
	hflag : in std_logic;
	vflag : in std_logic;
	red : out std_logic_vector (3 downto 0);
	blue : out std_logic_vector (3 downto 0);
	green : out std_logic_vector (3 downto 0);
	xpos : in unsigned (9 downto 0);
	ypos : in unsigned (9 downto 0);
	ball_xpos : in unsigned (9 downto 0);
	ball_ypos : in unsigned (9 downto 0);
	paddle_pos : in unsigned (9 downto 0);
	bricks : in std_logic_vector(1214 downto 0)
	);
end entity RGB_Driver;

architecture behavior of RGB_Driver is

signal xbrick : integer;
signal ybrick : integer;

begin

xbrick <= to_integer (xpos (9 downto 4));
ybrick <= to_integer (ypos (9 downto 3));

process (clk, rst) begin
	if rst = '0' then
		red <= "0000";
		green <= "0000";
		blue <= "0000";
	elsif rising_edge (clk) then
				if hflag = '1' and vflag = '1' then
					if ypos >= 240 and ypos <= (240 + 10) then		--ball data
						if xpos >= 300 and xpos <= (300+10) then --replace 300 with ball position *********
							red <= "1111";
							green <= "1111";
							blue <= "1111";
						else
							red <= "0000";
							green <= "0000";
							blue <= "0000";
						end if;
					elsif ypos > 474 then		--paddle data
						if xpos >= paddle_pos and xpos <= (paddle_pos + 40) then --replace 300 with paddle position *********
							red <= "1001";
							green <= "0100";
							blue <= "0000";
						else
							red <= "0000";
							green <= "0000";
							blue <= "0000";
						end if;
					elsif bricks(xbrick*ybrick) = '1' and ybrick < 30 then	--brick data
						if ypos mod 8 = 0 then
							red <= "1111";
							green <= "1111";
							blue <= "1111";
						elsif ybrick mod 2 = 1 then	--if on odd row, shift vertical mortar
							if (xpos+8) mod 16 = 0 then
								red <= "1111";
								green <= "1111";
								blue <= "1111";
							else
								red <= "1011";
								green <= "0100";
								blue <= "0011";
							end if;
						else									--if not on odd row, leave vertical mortar
							if	xpos mod 16 = 0 then
								red <= "1111";
								green <= "1111";
								blue <= "1111";
							else
								red <= "1011";
								green <= "0100";
								blue <= "0011";
							end if;
						end if;
					end if;
				else         --make data black if not in frame
					red <= "0000";
					green <= "0000";
					blue <= "0000";
				end if;
	end if;
end process;


end architecture behavior;
