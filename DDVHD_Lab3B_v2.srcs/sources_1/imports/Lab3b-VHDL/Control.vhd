library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Control is
    Port ( clk      : in  STD_LOGIC;
           rst      : in  STD_LOGIC;
           nxt      : in  STD_LOGIC;
           mem_wr   : out  STD_LOGIC;
           Mem_Addr : out  UNSIGNED (4 downto 0);
           r1_en    : out  STD_LOGIC;
           r2_en    : out  STD_LOGIC;
           out_en   : out  STD_LOGIC;
           Mux_Sel  : out  STD_LOGIC_VECTOR (1 downto 0));
end Control;

architecture Behavioral of Control is
    
    -- Declare the states as an enumerated type
    type fsm_states is (store_0, store_1, load_R1, load_R2, store_N, wait_st);
    
    -- Internal signals
    signal state, next_state: fsm_states; -- of this type above  
    signal done             : STD_LOGIC; -- Define done from counter to control wait_st state
    signal cnt_en           : STD_LOGIC; -- Define cnt_en as an enable for the counter
    signal count            : UNSIGNED (4 downto 0); -- Define count to transfer address to RAM
    
begin

    -- Define counter process
    five_bit_Counter: entity work.two_four_bit_counters
    PORT MAP( clk => clk,
              en => cnt_en,
              rst => rst,
              output => count);
    
    -- Define the state register
    state_assignment: process (clk) is -- synchronous process sensitive only to clock
        begin
            if (rising_edge(clk)) then
                if(rst = '1') then -- Define a reset state
                    state <= store_0;
                else
                    state <= next_state;
                end if;
            end if;
        end process state_assignment;
        
    -- Define the fsm transition rules
    FSM_transitions: process (state, nxt, done) is
        begin
            case state is
                when store_0 => -- stage 1 to store content to first address
                    if (nxt = '1') then
                        next_state <= store_1;
                    else
                        next_state <= store_0;
                    end if;
                when store_1 => -- stage 2 to store content to second address
                    if (nxt = '1') then
                        next_state <= load_R1;
                    elsif (rst = '1') then -- implying to go reset state when RESET signal is applied
                        next_state <= store_0;
                    else
                        next_state <= store_1;
                    end if;
                when load_R1 => -- stage 3 to load content in first address to reg1
                    if (rst = '1') then -- implying to go reset state when RESET signal is applied
                        next_state <= store_0;
                    else
                        next_state <= Load_R2;
                    end if;
                when load_R2 => -- stage 4 to load content in second address to reg2
                     if (rst = '1') then -- implying to go reset state when RESET signal is applied
                        next_state <= store_0;
                    else
                        next_state <= store_N;
                    end if;
                when store_N => -- stage 5 to store result gotten from adder to the next address
                     if (rst = '1') then -- implying to go reset state when RESET signal is applied
                        next_state <= store_0;
                    else
                        next_state <= wait_st;
                    end if;
                when wait_st => -- stage 6 to wait for the next nxt and done = 0 to load the next number from RAM
                    if (nxt = '1' and done = '0') then
                        next_state <= load_R1;
                    elsif (nxt = '1' and done = '1') then -- frezes in this state
                        next_state <= wait_st;
                    elsif (rst = '1') then -- implying to go reset state when RESET signal is applied
                        next_state <= store_0;
                    end if; 
            end case;          
        end process FSM_transitions;
 
    -- Define output from FSM
    cnt_en <= '1' when ((state = store_0) and (nxt = '1')) else
              '1' when ((state = store_1) and (nxt = '1')) else
              '1' when ((state = wait_st) and ((nxt = '1') and (done = '0'))) else 
              '0';
    
    mem_wr <= '1' when (state = store_0) else -- mem_wr is 1 at store 0, store 1 and store N
              '1' when (state = store_1) else
              '1' when (state = store_N) else
              '0'; -- mem_wr is 0 at other stages
    
    r1_en <= '1' when (state = load_R1) else -- r1_en is 1 at load_R1
             '0'; -- r1_en is 0 at other stages
    
    r2_en <= '1' when (state = load_R2) else -- r2_en is 1 at load_R2
             '0'; -- r2_en is 0 at other stages
    
    out_en <= '1' when (state = store_0) else -- out_en is 1 at store_0, store 1 and store N
              '1' when (state = store_1) else
              '1' when (state = store_N) else
              '0'; -- out_en is 0 at other stages
    
    Mux_Sel <= "10" when (state = store_0) else
               "11" when (state = store_1) else
               "00" when (state = store_N) else
               "00";
    
    Mem_Addr <= count when (state = store_0) else -- Mem_addr stores address counted by counter into an address of RAM
                count when (state = store_1) else -- Mem_addr stores address counted by counter into the next address of RAM 
                count-2 when (state = load_R1) else -- Mem_addr loads content from the first address
                count-1 when (state = load_R2) else -- Mem_addr loads content from the next address
                count when (state = store_N) else -- Mem_addr stores the sum of two fabonacci number
                "00000";
    
    -- Output from Counter
    -- When counter counts to address 24 meanwhile nxt button is pressed
    done <= '1' when (nxt='1' and count = "11000") else '0';         
              
end Behavioral;

