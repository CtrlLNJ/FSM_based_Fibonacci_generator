library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Synchronous write / asynchrounous read 32x16 single-port RAM
entity RAM is
    Port ( clk : in  STD_LOGIC;
           write_en : in  STD_LOGIC;                -- Write enable
           Data_In : in  UNSIGNED (15 downto 0);    -- 16-bit data input
           Address : in  UNSIGNED (4 downto 0);     -- 5-bit address
           Data_Out : out  UNSIGNED (15 downto 0)); -- 16-bit data output
end RAM;

architecture Behavioral of RAM is

type ram_type is array (0 to 31) of UNSIGNED(15 downto 0);
signal ram_inst: ram_type;

begin

  -- Asynchronous read
  Data_Out <= ram_inst(to_integer(Address)); 

  -- Synchronous write (write enable signal)
  process (clk)
  begin
    if (rising_edge(clk)) then 
       if (write_en='1') then
          ram_inst(to_integer(Address)) <= Data_In;
       end if;
    end if;
  end process;

end Behavioral;

