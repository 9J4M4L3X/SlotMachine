library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--random clock generator
--input is the time period of a clock given in miliseconds
entity rcg is
    port(
        clk     : in std_logic;
        reset   : in std_logic;
        rcp     : in unsigned (12 downto 0);--randomly generated clock period(max = 8192)
        
        rc      : out std_logic--random period clock signal
    );
end rcg;

architecture Behavioral of rcg is
    
    type CLK_state is (zero, one);
    signal curr_st, next_st : CLK_state;
    signal cnt : unsigned(12 downto 0) := (others => '0');--counts rising_edge(clk)
    signal cnt_unit : unsigned(12 downto 0) := (others => '0');--counts 0.1us
    signal change : std_logic := '0';--initiates change of state

begin
    
    STATE_TRANSITION : process(clk, reset) is
    begin
        if (reset = '1') then
            curr_st <= zero;
        elsif rising_edge(clk) then
            curr_st <= next_st;
        end if; 
    end process;
    
    COUNT : process(clk) is
        variable counter : unsigned(12 downto 0);
    begin 
        counter := cnt;
        if rising_edge(clk) then
            counter := counter + 1;
        end if;
        cnt <= counter;
    end process COUNT;
    
    --increments cnt_unit_var every time 0.1ms passes(5000*Tclk)
    DETECT_100US : process(cnt) is
        variable cnt_unit_var : unsigned (12 downto 0);
    begin
        cnt_unit_var := cnt_unit;--sets variable to current counter state
        if(cnt = 5000) then --reached 5000 rising_edge(clk)->increment base time unit cnt 
            cnt <= (others => '0');--reset counter
            cnt_unit_var := cnt_unit_var + 1;
        end if;
        cnt_unit <= cnt_unit_var;
    end process DETECT_100US;
    
    
    DETECT_RCP : process(cnt_unit) is 
        variable change_var : std_logic;
    begin
        change_var := change;
        if(cnt_unit = rcp) then
            cnt_unit <= (others => '0');
            change_var := not change_var;--changes the change signal to change fsm state
        end if;
        change <= change_var;
    end process DETECT_RCP;
    
    NEXT_STATE_TRANSITION : process(change) is
    begin 
        case(curr_st) is
            when zero =>
                next_st <= one;
            when one => 
                next_st <= zero;
        end case;
    end process NEXT_STATE_TRANSITION;
    
    
    OUTPUT_LOGIC : process (curr_st) is
    begin
        if reset = '1' then 
            rc <= '0';
        else
            case (curr_st) is 
                when zero =>
                    if (rcp = 0) then
                        rc <= '0';
                    else
                        rc <= '1';
                    end if;
                when one =>
                    if (rcp = 0) then
                        rc <= '0';
                    else
                        rc <= '0';
                    end if;
                when others =>
                    null;
            end case;
        end if;
    end process;
    
end architecture Behavioral;