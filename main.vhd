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
    signal pixel : unsigned(10 downto 0) := (others => '0');
    signal line : unsigned(10 downto 0) := (others => '0');
    signal dac : std_logic := '0';  
    signal dac_counter : integer := 0;  
    constant DAC_CLK_DIVIDE : integer := 2;  
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
            if dac = '1' then  
                
                if pixel = to_unsigned(799, pixel'length) then  
                    pixel <= (others => '0'); 
                    line <= line + 1; 

                    if line > to_unsigned(489, line'length) and line <= to_unsigned(491, line'length) then
                        V <= '1';  -- Vertical sync pulse
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
						  if (line >= 460 and line <= 470 and pixel >= 10 and pixel <= 630) or (line >= 400 and line <= 470 and ((pixel >= 10 and pixel <= 20)  or (pixel >= 620 and pixel <= 630))) then
								Rout <= "11111111";  
							   Gout <= "11111111";  
							   Bout <= "11111111"; 
						  end if;
						  
						  -- BLUE PLAYER
						  if SW3 = '1' then
						      Rout <= "00000000";  
							   Gout <= "00000000";  
							   Bout <= "11111111";
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
