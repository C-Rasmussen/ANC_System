
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity flag_data_driver is 
	port(
		clk : in std_logic;
		rst : in std_logic;
		advance : in std_logic;
		Hflag : in std_logic;
		Vflag : in std_logic;
		red : out std_logic_vector (3 downto 0);
		blue : out std_logic_vector (3 downto 0);
		green : out std_logic_vector (3 downto 0)
		);
end entity flag_data_driver;


architecture behavior of flag_data_driver is

	type state_type is (FRANCE, ITALY, IRELAND, BELGIUM, MALI, CHAD, NIGERIA, IVORY_COAST, POLAND, FRAME_BUFFER_1, 
								GERMANY, FRAME_BUFFER_2, AUSTRIA, FRAME_BUFFER_3, CONGO, FRAME_BUFFER_4);
	signal state : state_type;
	signal count : integer := 0;
	signal yellow_line : integer := 0;
	signal red_line : integer := 0;



begin
	process (clk) begin
		if rising_edge(clk) then
			if rst = '0' then
				red <= "0000";
				blue <= "0000";
				green <= "0000";
				count <= 0;
				state <= FRANCE;
			end if;
			if Vflag = '0' then
				yellow_line <= 489;
				red_line <= 640;
			end if;
			if(Hflag = '0' or Vflag = '0') then
				red <= "0000";
				blue <= "0000";
				green <= "0000";
			end if;
				case state is
					when FRANCE =>
						if (Hflag = '1' and Vflag = '1') then
							count <= count + 1;
							if count < 213 then 
								red <= "0000";
								blue <= "1111";
								green <= "0000";
							elsif count < 427 then
								red <= "1111";
								blue <= "1111";
								green <= "1111";
							elsif count < 640 then
								red <= "1111";
								blue <= "0000";
								green <= "0000";
								if count = 639 then
									count <= 0;
								end if;
							end if;
						end if;
						if advance = '1' then
							state <= ITALY;
						end if;
						
					when ITALY =>
						if (Hflag = '1' and Vflag = '1') then
							count <= count + 1;
							if count < 213 then 
								red <= "0000";
								green <= "1001";
								blue <= "0010";
							elsif count < 427 then
								red <= "1111";
								green <= "1111";
								blue <= "1111";
							elsif count < 640 then
								red <= "1101";
								green <= "0010";
								blue <= "0011";
								if count = 639 then
									count <= 0;
								end if;
							end if;
						end if;
						if advance = '1' then
							state <= IRELAND;
						end if;
						
					when IRELAND =>
						if (Hflag = '1' and Vflag = '1') then
							count <= count + 1;
							if count < 213 then 
								red <= "0000";
								blue <= "0100";
								green <= "1010";
							elsif count < 427 then
								red <= "1111";
								blue <= "1111";
								green <= "1111";
							elsif count < 640 then
								red <= "1111";
								blue <= "0000";
								green <= "1000";
								if count = 639 then
									count <= 0;
								end if;
							end if;
						end if;
						if advance = '1' then
							state <= BELGIUM;
						end if;
						
						when BELGIUM =>
						if (Hflag = '1' and Vflag = '1') then
							count <= count + 1;
							if count < 213 then 
								red <= "0000";
								green <= "0000";
								blue <= "0000";
							elsif count < 427 then
								red <= "1111";
								green <= "1101";
								blue <= "0000";
							elsif count < 640 then
								red <= "1101";
								green <= "0001";
								blue <= "0011";
								if count = 639 then
									count <= 0;
								end if;
							end if;
						end if;
						if advance = '1' then
							state <= MALI;
						end if;
						
						when MALI =>
						if (Hflag = '1' and Vflag = '1') then
							count <= count + 1;
							if count < 213 then 
								red <= "0001";
								green <= "1011";
								blue <= "0100";
							elsif count < 427 then
								red <= "1111";
								green <= "1101";
								blue <= "0001";
							elsif count < 640 then
								red <= "1101";
								green <= "0001";
								blue <= "0010";
								if count = 639 then
									count <= 0;
								end if;
							end if;
						end if;
						if advance = '1' then
							state <= CHAD;
						end if;
						
						when CHAD =>
						if (Hflag = '1' and Vflag = '1') then
							count <= count + 1;
							if count < 213 then 
								red <= "0000";
								green <= "0010";
								blue <= "0110";
							elsif count < 427 then
								red <= "1111";
								green <= "1101";
								blue <= "0000";
							elsif count < 640 then
								red <= "1011";
								green <= "0001";
								blue <= "0011";
								if count = 639 then
									count <= 0;
								end if;
							end if;
						end if;
						if advance = '1' then
							state <= NIGERIA;
						end if;
						
						when NIGERIA =>
						if (Hflag = '1' and Vflag = '1') then
							count <= count + 1;
							if count < 213 then 
								red <= "0010";
								green <= "0111";
								blue <= "0100";
							elsif count < 427 then
								red <= "1111";
								green <= "1111";
								blue <= "1111";
							elsif count < 640 then
								red <= "0010";
								green <= "0111";
								blue <= "0100";
								if count = 639 then
									count <= 0;
								end if;
							end if;
						end if;
						if advance = '1' then
							state <= IVORY_COAST;
						end if;
						
						when IVORY_COAST =>
						if (Hflag = '1' and Vflag = '1') then
							count <= count + 1;
							if count < 213 then 
								red <= "1111";
								green <= "1000";
								blue <= "0000";
							elsif count < 427 then
								red <= "1111";
								green <= "1111";
								blue <= "1111";
							elsif count < 640 then
								red <= "0000";
								green <= "1010";
								blue <= "0100";
								if count = 639 then
									count <= 0;
								end if;
							end if;
						end if;
						if advance = '1' then
							state <= FRAME_BUFFER_1;
							red <= "0000";
							blue <= "0000";
							green <= "0000";
							count <= 0;
						end if;
						
						when FRAME_BUFFER_1 =>
							if Vflag = '0' and Hflag = '0' then
								state <= POLAND;
							end if;
						
						when POLAND =>
						if (Hflag = '1' and Vflag = '1') then
							count <= count + 1;
							if count < 153600 then 
								red <= "1111";
								green <= "1111";
								blue <= "1111";
							elsif count < 307200 then
								red <= "1110";
								green <= "0001";
								blue <= "0100";
								if count = 307199 then
									count <= 0;
								end if;
							end if;
						end if;
						if advance = '1' then
							state <= FRAME_BUFFER_2;
							red <= "0000";
							blue <= "0000";
							green <= "0000";
							count <= 0;
						end if;
						
						when FRAME_BUFFER_2 =>
							if Vflag = '0' and Hflag = '0' then
								state <= GERMANY;
							end if;
							
						when GERMANY =>
						if (Hflag = '1' and Vflag = '1') then
							count <= count + 1;
							if count < 102400 then 
								red <= "0000";
								green <= "0000";
								blue <= "0000";
							elsif count < 204800 then
								red <= "1110";
								green <= "0000";
								blue <= "0000";
							elsif count < 307200 then
								red <= "1111";
								green <= "1101";
								blue <= "0000";
								if count = 307199 then
									count <= 0;
								end if;
							end if;
						end if;
						if advance = '1' then
							state <= FRAME_BUFFER_3;
							red <= "0000";
							blue <= "0000";
							green <= "0000";
							count <= 0;
						end if;
						
						when FRAME_BUFFER_3 =>
							if Vflag = '0' and Hflag = '0' then
								state <= AUSTRIA;
							end if;
						
						when AUSTRIA =>
						if (Hflag = '1' and Vflag = '1') then
							count <= count + 1;
							if count < 102400 then 
								red <= "1111";
								green <= "0011";
								blue <= "0100";
							elsif count < 204800 then
								red <= "1111";
								green <= "1111";
								blue <= "1111";
							elsif count < 307200 then
								red <= "1111";
								green <= "0011";
								blue <= "0100";
								if count = 307199 then
									count <= 0;
								end if;
							end if;
						end if;
						if advance = '1' then
							state <= FRAME_BUFFER_4;
							red <= "0000";
							blue <= "0000";
							green <= "0000";
							yellow_line <= 489;
							red_line <= 640;
							count <= 0;
						end if;
						
						when FRAME_BUFFER_4 =>
							if Vflag = '0' and Hflag = '0' then
								state <= CONGO;
							end if;
						
						when CONGO =>
						if (Hflag = '1' and Vflag = '1') then
							count <= count + 1;
							if count < yellow_line then 
								red <= "0000";
								green <= "1001";
								blue <= "0100";
							elsif count < red_line then
								red <= "1111";
								green <= "1110";
								blue <= "0101";
							elsif count < 640 then
								red <= "1110";
								green <= "0010";
								blue <= "0010";
							end if;
							if count = 639 then
									count <= 0;
									yellow_line <= yellow_line - 1;
									red_line <= red_line - 1;
							end if;
						end if;
						if advance = '1' then
							state <= FRAME_BUFFER_4;
							red <= "0000";
							blue <= "0000";
							green <= "0000";
							count <= 0;
						end if;
						
					end case;
		end if;
	end process;
end architecture behavior;
