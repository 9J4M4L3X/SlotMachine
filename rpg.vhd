library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;

--12-bit linear feedback shift register for generating random clock periods
entity rpg is
    port(
        clk : in std_logic;
        rst : in std_logic;
        button : in std_logic;
        
        rand_num : out std_logic_vector(12 downto 0)--random output
    );
end rpg;

architecture Behavioral of rpg is
    
    type RPG_state is (zero, init, hold, cross, cross_zero);
    signal curr_state, next_state : RPG_state; 
    
    signal curr_st, next_st : std_logic_vector(12 downto 0);
    signal feedback : std_logic;
    
begin

    STATE_TRANSITION : process(clk, rst) is
    begin
        if (rst = '1') then
            
            curr_state <= zero;--next state is init if button is pressed
            
        elsif rising_edge(clk) then
            
            curr_state <= next_state;
        
        end if;
    end process STATE_TRANSITION;
    
    NEXT_STATE_TRANSITION : process(button, curr_state) is
    begin 
        case(curr_state) is 
            when zero =>
                if button = '1' then--start signal
                    next_state <= init;
                else
                    next_state <= zero;
                end if;
            when init =>
                next_state <= hold;
            when hold =>
                if button = '1' then
                    next_state <= hold; 
                else
                    next_state <= cross; --next button signal will stop the counter
                end if;
            when cross =>
                if button = '1' then--stop signal
                    next_state <= zero; --counter is stopped, stop generating random period
                else
                    next_state <= cross; 
                end if;
            when cross_zero =>
                if button = '1' then 
                    next_state <= cross_zero;--wait until button is off
                else
                    next_state <= zero;--now goes to zero and waits for new start signal
                end if;
        end case;
    end process NEXT_STATE_TRANSITION;
    
    STATE_REG : process (clk, rst) is
    begin 
        if (rst = '1') then
            curr_st <= (0 => '1', Others => '0');--initial state
        elsif rising_edge(clk) then
            curr_st <= next_st;
        end if;
    end process STATE_REG;
    
    feedback <= curr_st(12) xor curr_st(5) xor curr_st(3) xor curr_st(0);  
    next_st <= feedback & curr_st(12 downto 1);

    OUTPUT_LOGIC: process(curr_state, curr_st) is
        
        variable rand : std_logic_vector(12 downto 0);    

    begin 
        case(curr_state) is
            when zero =>
                rand := (Others => '0');--initial state is all zeros
            when init =>
                rand := curr_st;--only in init state it generates a random number
            when others =>                                  
                null;
        end case;
        rand_num <= rand;
    end process OUTPUT_LOGIC;
    
    
end architecture Behavioral;