library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Datapath for Fibonacci number generator
-- The datapath computes and outputs Fibonacci numbers up to 16 bits (max number= 46368)
-- Except for the first two numbers (0 and 1), the following numbers are computed by
--   adding the previous two numbers, which are retrieved from a local RAM and stored
--   in two D-type registers. The current number is both output though a D-type register
--   and stored in the RAM.
-- The first two numbers (0 and 1) are sourced as constants.
entity Datapath is
   Port (clk : in  STD_LOGIC;
         rst : in  STD_LOGIC;      -- synchronous reset
         mem_wr : in  STD_LOGIC;   -- RAM write enable
         Mem_Addr : in  UNSIGNED (4 downto 0); -- RAM address
         r1_en, r2_en, out_en : in  STD_LOGIC;  -- register enable signals
         Mux_Sel : in  STD_LOGIC_VECTOR (1 downto 0); -- 00 = adder output
                                                      -- 01 = unused
                                                      -- 10 = 0
                                                      -- 11 = 1
         Fib_Out : out  STD_LOGIC_VECTOR (15 downto 0)); -- current fibonacci number
end Datapath;

architecture Behavioral of Datapath is

-- internal 16-bit data busses
signal Mem_Out, R1_Out, R2_Out, Mem_In : UNSIGNED (15 downto 0);

begin

-- Multiplexer to select data to be written to memory (0, 1, or
--   the sum of two previous Fibonacci numbers)
Mem_In <= to_unsigned(0,16) when Mux_Sel = "10" else
          to_unsigned(1,16) when Mux_Sel = "11" else
          R1_Out + R2_Out   when Mux_Sel = "00" else
          (others => 'U');

-- Register to store next-to-last Fibonacci number
Reg1: process (clk)
begin
   if (rising_edge(clk)) then
      if (rst = '1') then           -- synchronous reset
         R1_Out <= (others => '0');     
      elsif (r1_en = '1') then
         R1_Out <= Mem_Out;
       end if;
   end if;
end process Reg1;

-- Register to store last Fibonacci number
Reg2: process (clk)
begin
   if (rising_edge(clk)) then
      if (rst = '1') then           -- synchronous reset
         R2_Out <= (others => '0');     
      elsif (r2_en = '1') then
         R2_Out <= Mem_Out;
       end if;
   end if;
end process Reg2;

-- Register to store and display newest Fibonacci number
OutReg: process (clk)
begin
   if (rising_edge(clk)) then
      if (rst = '1') then 
         Fib_Out <= (others => '0');     
      elsif (out_en = '1') then
         Fib_Out <= STD_LOGIC_VECTOR(Mem_In);
       end if;
   end if;
end process OutReg;

-- 32x16 RAM to store Fibonacci sequence
Memory: entity work.RAM port map(
   clk => clk,
   write_en => mem_wr,
   Data_In => Mem_In,
   Address => Mem_Addr,
   Data_Out => Mem_Out
);


end Behavioral;

