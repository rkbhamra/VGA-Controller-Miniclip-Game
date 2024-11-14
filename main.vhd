library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity display is
    Port (  clk : in  STD_LOGIC;
                SW0 : in STD_LOGIC;
                SW1 : in STD_LOGIC;
                SW2 : in STD_LOGIC;
                SW3 : in STD_LOGIC;
                H : out STD_LOGIC := '0';
                V : out STD_LOGIC := '0';
                DAC_CLK : out STD_LOGIC;
                Rout : out STD_LOGIC_VECTOR(7 downto 0);
                Gout : out STD_LOGIC_VECTOR(7 downto 0);
                Bout : out STD_LOGIC_VECTOR(7 downto 0)
              );
end display;

architecture Behavioral of display is 
	 signal dac : std_logic := '0';  
    signal dac_counter : integer := 0;
	 
    signal pixel : unsigned(9 downto 0) := (others => '0');
    signal line : unsigned(9 downto 0) := (others => '0');
	 signal frame : std_logic := '0';
	 
	 signal blueMove : unsigned(9 downto 0) := "0000101000";
	 signal redMove : unsigned(9 downto 0) := "0000101000";	
	 signal ballx : unsigned(9 downto 0) := "0011100001";
	 signal bally : unsigned(9 downto 0) := "0011100001";
	 signal directionx : std_logic := '0';
	 signal directiony : std_logic := '0';
	 signal blueScore : integer := 5;
	 signal redScore : integer := 5;
	 signal rstBall : integer := 1;
	 signal middleSet : integer := 0;
	 signal endGame : integer := 0;
	 
    constant DAC_CLK_DIVIDE : integer := 2; 
	 constant playerLen : integer := 100;
	 constant ballsize : integer := 15; 
	 constant bluex : integer := 30;
	 constant redx : integer := 600;
	 constant playTop : integer := 20;
	 constant playBottom : integer := 420;
	 constant playLeft : integer := 20;
	 constant playRight : integer := 620;
	 
	 
begin 
    process(clk)
    begin
        if rising_edge(clk) then
            if dac_counter = (DAC_CLK_DIVIDE - 1) then
                dac <= not dac; 
                dac_counter <= 0; 
            else
                dac_counter <= dac_counter + 1;
            end if;
        end if;
    end process;
    
    DAC_CLK <= dac;
    

    process(clk)
    begin
        if rising_edge(clk) then
            if dac = '1' and endGame/=1 then  
                
                if pixel = to_unsigned(799, pixel'length) then  
                    pixel <= (others => '0'); 
                    line <= line + 1; 

                    if line > to_unsigned(489, line'length) and line <= to_unsigned(491, line'length) then
                        V <= '1';  -- Vertical sync pulse
								frame <= '1';
                    else
                        V <= '0';  -- Active video area
                    end if;

                else
                    -- Increment pixel counter
                    pixel <= pixel + 1;  
                end if;

                -- Reset line counter after complete frame (525 lines in total)
                if line = to_unsigned(524, line'length) then
                    line <= (others => '0'); 
                end if;

                -- Horizontal sync pulse generation
                if pixel < to_unsigned(639, pixel'length) then
                    -- Viewing area (Active Video Area)
                    H <= '0';
						  --background
						  Rout <= "00000000";  
                    Gout <= "11111111";  
                    Bout <= "00000000"; 
						  
						  -- top lines or left side line or right side line
						  if (line >= 10 and line <= 20 and pixel >= 10 and pixel <= 630) or (line >= 20 and line <= 100 and pixel >= 10 and pixel <= 20)  or (line >= 20 and line <= 100 and pixel >= 620 and pixel <= 630) then
								Rout <= "11111111";  
							   Gout <= "11111111";  
							   Bout <= "11111111"; 
						  end if;
						  
						  -- bottom lines or left side line or right side line
						  if (line >= 440 and line <= 450 and pixel >= 10 and pixel <= 630) or (line >= 380 and line <= 450 and ((pixel >= 10 and pixel <= 20)  or (pixel >= 620 and pixel <= 630))) then
								Rout <= "11111111";  
							   Gout <= "11111111";  
							   Bout <= "11111111"; 
						  end if;
						  
						  -- middle line
						  if (line mod 64 = 0) then
								middleSet <= 1;
						  elsif (line mod 32 = 0) then
								middleSet <= 0;
						  end if;
						  if middleSet = 1 then
							  if (pixel >= 320 and pixel <= 322) then
									Rout <= "00000000";  
									Gout <= "00000000";  
									Bout <= "00000000";
								end if;
						  end if;
						  
						  --------------------------------------
						  -- LIVES
						  --------------------------------------
						  if blueScore>=1 then
								if pixel >10 and pixel<=20 and line >=460 and line<=480 then
									Rout <= "11111111";  
									Gout <= "00000000";  
									Bout <= "11111111";
								end if;
							end if;
							if blueScore>=2 then
								if pixel >30 and pixel<=40 and line >=460 and line<=480 then
									Rout <= "11111111";  
									Gout <= "00000000";  
									Bout <= "11111111";
								end if;
							end if;
							if blueScore >= 3 then
								if pixel >50 and pixel<=60 and line >=460 and line<=480 then
									Rout <= "11111111";  
									Gout <= "00000000";  
									Bout <= "11111111";
								end if;
							end if;
							if blueScore >= 4 then
								if pixel >70 and pixel<=80 and line >=460 and line<=480 then
									Rout <= "11111111";  
									Gout <= "00000000";  
									Bout <= "11111111";
								end if;
							end if;
							if blueScore = 5 then
								if pixel >90 and pixel<=100 and line >=460 and line<=480 then
									Rout <= "11111111";  
									Gout <= "00000000";  
									Bout <= "11111111";
								end if;
							end if;
							
							if redScore>=5 then
								if pixel >520 and pixel<=530 and line >=460 and line<=480 then
									Rout <= "11111111";  
									Gout <= "00000000";  
									Bout <= "11111111";
								end if;
							end if;
							if redScore>=4 then
								if pixel >540 and pixel<=550 and line >=460 and line<=480 then
									Rout <= "11111111";  
									Gout <= "00000000";  
									Bout <= "11111111";
								end if;
							end if;
							if redScore >= 3 then
								if pixel >560 and pixel<=570 and line >=460 and line<=480 then
									Rout <= "11111111";  
									Gout <= "00000000";  
									Bout <= "11111111";
								end if;
							end if;
							if redScore >= 2 then
								if pixel >580 and pixel<=590 and line >=460 and line<=480 then
									Rout <= "11111111";  
									Gout <= "00000000";  
									Bout <= "11111111";
								end if;
							end if;
							if redScore = 1 then
								if pixel >600 and pixel<=610 and line >=460 and line<=480 then
									Rout <= "11111111";  
									Gout <= "00000000";  
									Bout <= "11111111";
								end if;
							end if;
							
							if redScore = 0 or blueScore = 0 then
								if pixel>=0 and pixel<=640 and line>=30 and line<=70 then
									Rout <= "00001111";  
									Gout <= "00000000";  
									Bout <= "00000000";
								end if;
								endGame <= 0;
							end if;
							
						  ---------------------------------------
						  --BALL
						  ---------------------------------------
						  -- Ball Colors
						  --normal ball color in the playing area
						  if ballx>=20 and (ballx+ballsize)<=620 then
							  if (pixel >= ballx and pixel <= (ballx+ballsize) and line >= bally and line <= (bally+ballsize)) then
									Rout <= "11111111";  
									Gout <= "11111111";  
									Bout <= "00000000";
							  end if;
							-- color the ball red
						  elsif ballx <=20 then
								if (pixel >= ballx and pixel <= (ballx+ballsize) and line >= bally and line <= (bally+ballsize)) then
									Rout <= "11111111";  
									Gout <= "00000000";  
									Bout <= "00000000";
								end if;
						  -- color the ball red
						  elsif (ballx+ballsize) >=620 then
								if (pixel >= ballx and pixel <= (ballx+ballsize) and line >= bally and line <= (bally+ballsize)) then
									Rout <= "11111111";  
									Gout <= "00000000";  
									Bout <= "00000000";
								end if;
						  end if;
						  --check if needs resetting
						  if rstBall = 1 then
								ballx <= "0101000000";
								bally <= "0011001000";
								rstBall <= 0;
						  end if;
						  --rest of the logic
						  if frame = '1' then
								--if going left
								if directionx = '0' then
									ballx <= ballx - 1;
									frame <= '0';
--									if (ballx <= 20) then
									--hit paddle
									if (bally+ballsize) >= blueMove and bally<=(blueMove+playerLen) and ballx = (bluex+10) then
										directionx <= '1';
									end if;
									--miss paddle, score for red
									if ballx < 1 then
										blueScore <= blueScore - 1;
										rstBall <= 1;
									end if;
								--going right
								elsif directionx = '1' then
									ballx <= ballx + 1;
									frame <= '0';
--									if (ballx+ballsize) >= 620 then
									if (bally+ballsize) >= redMove and bally<=(redMove+playerLen) and (ballx+ballsize) = redx then
										directionx <= '0';
									end if;
									--score for blue
									if (ballx+ballsize) = 640 then
										redScore <= redScore - 1;
										rstBall <= 1;
									end if;
								end if;
									
								--if up, go down
								if directiony = '0' then
									bally <= bally - 1;
									if (bally <= 20) then
										directiony <= '1';
									end if;
								--if down, go up
								elsif directiony = '1' then
									bally <= bally + 1;
									if (bally+ballsize) >= 420 then
										directiony <= '0';
									end if;
								end if;

						  end if;
						  
						  -- BLUE PLAYER
						  -- going up
						  if SW3 = '1' then
								if frame = '1' and blueMove/=30 then
									blueMove <= blueMove - 1;
									frame <= '0';
								end if;
								if (line >= blueMove and line <= (blueMove+playerLen)) and (pixel >=bluex and pixel <= (bluex+10)) then
									Rout <= "00000000";  
									Gout <= "00000000";  
									Bout <= "11111111";
								end if;	
							-- going down
							elsif SW3 = '0' then 
								if frame = '1' and blueMove/=340 then
									blueMove <= blueMove + 1;
									frame <= '0';
								end if;
								if (line >= blueMove and line <= (blueMove+playerLen)) and (pixel >=bluex and pixel <= (bluex+10)) then
									Rout <= "00000000";  
									Gout <= "00000000";  
									Bout <= "11111111";
								end if;
						  end if;
						  
						  -- RED PLAYER
						  -- going up
						  if SW2 = '1' then
								if frame = '1' and redMove/=30 then
									redMove <= redMove - 1;
									frame <= '0';
								end if;
								if (line >= redMove and line <= (redMove+playerLen)) and (pixel >=redx and pixel <= (redx+10)) then
									Rout <= "11111111";  
									Gout <= "00000000";  
									Bout <= "00000000";
								end if;	
							-- going down
							elsif SW2 = '0' then 
								if frame = '1' and redMove/=340 then
									redMove <= redMove + 1;
									frame <= '0';
								end if;
								if (line >= redMove and line <= (redMove+playerLen)) and (pixel >=redx and pixel <= (redx+10)) then
									Rout <= "11111111";  
									Gout <= "00000000";  
									Bout <= "00000000";
								end if;
						  end if;
						  
					  				
					 ---------------------------------------------
					 --        DO NOT TOUCH ME PLEASE			  --
					 ---------------------------------------------
                elsif pixel > to_unsigned(639, pixel'length) and pixel <= to_unsigned(655, pixel'length) then
                    -- Front porch (blank pixels)
                    H <= '0';
                    Rout <= "00000000";
                    Gout <= "00000000";
                    Bout <= "00000000";
                elsif pixel > to_unsigned(655, pixel'length) and pixel <= to_unsigned(751, pixel'length) then
                    -- Sync pulse (Horizontal Sync)
                    H <= '1';
                    Rout <= "00000000";
                    Gout <= "00000000";
                    Bout <= "00000000";
                elsif pixel > to_unsigned(751, pixel'length) and pixel <= to_unsigned(799, pixel'length) then
                    -- Back porch (blank pixels)
                    H <= '0'; 
                    Rout <= "00000000";
                    Gout <= "00000000";
                    Bout <= "00000000";
                end if;
            end if;
        end if;
    end process;

end Behavioral;
