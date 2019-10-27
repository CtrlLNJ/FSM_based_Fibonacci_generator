


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;



entity counter_tb is

end counter_tb;

architecture Behavioral of counter_tb is
    constant clk_period: time := 10ns;
    
        signal clk : STD_LOGIC;
    signal en  : STD_LOGIC;
    signal rst : STD_LOGIC;
    signal output:  unsigned(4 downto 0);

begin

    UUT: entity work.two_four_bit_counters
        PORT MAP (clk => clk,
                  en  => en,
                  rst => rst,
                  output(4 downto 0)=> output (4 downto 0));

    clk_process: process
    begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
    end process;
     TEST : process
           begin             
               -- wait 100 ns for global reset to finish
               wait for 100 ns;
               
               -- Input values should change on the falling edge of the clock
               wait until falling_edge(clk);
               
               -- values are set for reset and enable to test differences
               
               -- test for synchronous and asynchronous counter without enable
               rst <= '1';
               wait for clk_period;
               
               rst <= '0';
               wait for clk_period;
               
               rst <= '0';
               wait for clk_period*15;
               
                          -- test for synchronous and asynchronous with enable           
                en <= '0';
                wait for clk_period;
                
                en <= '1';
                wait for clk_period*10;
                
                               rst <= '1';
                wait for clk_period*2;
                
                wait; -- will wait forever
                          end process;
end Behavioral;
