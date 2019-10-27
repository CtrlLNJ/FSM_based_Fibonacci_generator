library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity Fibonacci_tb is
end Fibonacci_tb;

architecture Behavioral of Fibonacci_tb is
    -- Defines clock period as a constant
    constant clock_period: time := 20ns;
    
    --Internal signals in testbench are defined
    signal clk    : STD_LOGIC:='0'; -- set initial value for clk rst and nxt
    signal rst    : STD_LOGIC:='0';
    signal nxt    : STD_LOGIC:='0';
    signal Fib_Out: STD_LOGIC_VECTOR (15 downto 0);
   
begin
    -- Instantiate UUT as a component in testbanch
    UUT: entity work.Fibonacci
         Port map (clk => clk,
                  rst => rst,
                  nxt => nxt,
                  Fib_Out => Fib_Out);
    
    -- Clock process
    -- This process generates a clock signal to control sequential elements
    clk_process: process
        begin
            clk <= '0';
            wait for clock_period/2;
            clk <= '1';
            wait for clock_period/2;
        end process;
    
    -- Test process used for testbench to test I/O ports in entity
    TEST : process
            begin
                -- wait 100 ns for global reset to finish
                wait for 100 ns;
            
                -- Input values to change the falling edge of the clock
                wait until falling_edge(clk);
                
                -- Reset circuits to define intial value not U
                rst <= '1';
                nxt <= '0';
                wait for clock_period*2;
                
                rst <= '0';
                wait for clock_period*3;
                
                -- Set reset back to 0
                rst <= '1';
                wait for clock_period*3;
                
                -- test FSM transitions and another reset at middle-way and hold several clock periods
                pulse_1x13: for i in 0 to 12 loop
                    nxt <= '1';
                    wait for clock_period*2; -- 2-period pulse
                    nxt <= '0';
                    wait for clock_period; -- 1-period pulse
                end loop pulse_1x13;
                
                rst <= '0';
                wait for clock_period*2;
                
                -- Test resume and freeze state
                -- Insert stimulus loop below
                pulse_1x100: for i in 0 to 99 loop
                    nxt <= '1';
                    wait for clock_period*2; -- 2-period pulse
                    nxt <= '0';
                    wait for clock_period; -- 1-period pulse 
                end loop pulse_1x100;
                    
                wait; -- wll wait forever
        end process;
        
end Behavioral;
