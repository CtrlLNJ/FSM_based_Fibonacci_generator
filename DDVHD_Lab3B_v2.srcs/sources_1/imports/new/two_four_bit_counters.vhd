library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity two_four_bit_counters is
    Port ( clk   : in  STD_LOGIC;
           en    : in  STD_LOGIC;
           rst   : in  STD_LOGIC;
           
           output: out UNSIGNED (4 downto 0));
end two_four_bit_counters;

architecture Behavioral of two_four_bit_counters is
    -- Internal signals for 4-bit counter
    signal Qint1: UNSIGNED (4 downto 0); -- For outputs in counters reused


    
begin
    -- Counter with synchronous reset and enable
    -- Once enable is pressed, counter increments by 1
    -- Once reset is pressed, counter goes back to 0
    Counter: process(clk)
    begin
        if(rising_edge(clk)) then
            if(rst='1') then
                Qint1 <= (others => '0');
            else
                if(en='1') then
                    if (Qint1 = "11000") then -- Limit count within 24
                        Qint1 <= (others => '0');
                    else
                        Qint1 <= (Qint1 +1);
                    end if;
                end if;
            end if;
         end if;
     end process Counter;
     
        --Get the output value from Counter1
        output <= UNSIGNED(Qint1);
     
end Behavioral;
