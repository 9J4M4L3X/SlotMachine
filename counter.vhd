library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--counter with random clock
entity counter is
    port(
        clk             : in std_logic;--system clock
        clk_rand        : in std_logic;--counting clock
        button          : in std_logic;
        reset           : in std_logic;
        
        cnt             : out unsigned(3 downto 0);
        enable_max      : out std_logic
    );
end counter;

architecture Behavioral of counter is
    
    type CNT_state is (rst, count, cnt_cross, hold, hold_cross);
    signal curr_state, next_state : CNT_state;
    signal counter : unsigned(3 downto 0) := "0000";
    
    signal rising_edge_detected : std_logic;
    signal clk_rand_1q : std_logic;
begin 
    
    PROC_RISING_EDGE_DETECT : process (clk,reset)
    begin

      if rising_edge(clk) then

        if (reset = '1') then
           clk_rand_1q <= '0';
        else
          -- delay input by 1 clock
          clk_rand_1q <= clk_rand;
            
          -- detect rising edge
          rising_edge_detected <= clk_rand and (not clk_rand_1q);
          
          --here input is the current signal and input_1q is 1 clock before
          --so if input_1q is '0' and input is '1' rising edge is detected
          --if input_1q is '1' and input is '0' rising_edge_detected = '0'
        end if;

      end if;
      
    end process;
  
    STATE_TRANSITION : process(clk) is
    begin 
        if reset = '1' then
            curr_state <= rst;
        elsif rising_edge(clk) then
            curr_state <= next_state;
        end if;
    end process STATE_TRANSITION;
        
    NEXT_STATE_TRANSITION : process(curr_state, button) is
    begin
        case (curr_state) is
            when count =>
                if button = '1' then
                    next_state <= count;--keeps the same state if button is still pushed
                else 
                    next_state <= cnt_cross;--button = '0', waits for stop signal
                end if;
            when cnt_cross =>      
                if button = '1' then
                    next_state <= hold;--stop signal activated, hold cnt values
                else 
                    next_state <= cnt_cross;--keep counting
                end if;
            when hold =>
                if button = '1' then
                    next_state <= hold;--holds output 
                else 
                    next_state <= hold_cross;--if the button is off then go wait for another start signal
                end if;
            when hold_cross =>
                if button = '1' then
                    next_state <= count;--start signal activated, counting state next
                else 
                    next_state <= hold_cross;--holds output values
                end if;
            when others =>
                null;
        end case;
    end process NEXT_STATE_TRANSITION;
    
    OUTPUT_LOGIC : process(clk, rising_edge_detected) is
        variable cnt_var : unsigned(3 downto 0);
        variable en_max : std_logic;
    begin         
    
        if rising_edge(clk) then
     
            cnt_var := counter;--sets the counter to its previous value
     
            case curr_state is
                
                when (rst) =>
                    cnt_var := "0000";
                
                when (count) =>
                    
                    --while the counter counts max_equal is disabled
                    en_max := '0';  
                    --incrementing counter
                    if rising_edge_detected = '1' then
                        cnt_var(0) := cnt_var(0) xor '1';
                        if (cnt_var(0) = '0') then 
                            cnt_var(1) := cnt_var(1) xor '1';
                            if(cnt_var(1) = '0') then
                                cnt_var(2) := cnt_var(2) xor '1';
                                if(cnt_var(2) = '0') then
                                    cnt_var(3) := cnt_var(3) xor '1';
                                end if;
                            end if;
                        end if;
                        
                        if (cnt_var > "1001") then
                            cnt_var := "0000";
                        end if;
                    end if;
                when (cnt_cross) =>
                    
                    en_max := '0';
                    
                    if rising_edge_detected = '1' then 
                        --incrementing counter
                        cnt_var(0) := cnt_var(0) xor '1';
                        if (cnt_var(0) = '0') then 
                            cnt_var(1) := cnt_var(1) xor '1';
                            if(cnt_var(1) = '0') then
                                cnt_var(2) := cnt_var(2) xor '1';
                                if(cnt_var(2) = '0') then
                                    cnt_var(3) := cnt_var(3) xor '1';
                                end if;
                            end if;
                        end if;
                        
                        if (cnt_var > "1001") then
                            cnt_var := "0000";
                        end if;
                    end if;

                when others =>
                    en_max := '1';--counter stopped counting so max_equal is enabled
            
            end case;
        
        end if;
        
        counter <= cnt_var;--updates counter signal
        cnt <= cnt_var;--sets output
        
        enable_max <= en_max;
        
    end process OUTPUT_LOGIC;
    
end architecture Behavioral;