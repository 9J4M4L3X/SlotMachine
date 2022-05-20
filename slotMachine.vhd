library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity slotMachine is
    port(
        button      : in std_logic;
        reset       : in std_logic;
        clk         : in std_logic;
        
        led0        : out std_logic_vector(6 downto 0);
        led1        : out std_logic_vector(6 downto 0);
        led2        : out std_logic_vector(6 downto 0);
        led3        : out std_logic_vector(6 downto 0);
        max_hit         : out std_logic_vector(3 downto 0)
    );
end slotMachine;

architecture Structural of slotMachine is
        
    --random period generator
    component rpg is
        port(
            clk : in std_logic;
            rst : in std_logic;
            button : in std_logic;
            
            --random generated counter clock periods(range 0.0001 to 0.8192 seconds)
            rand_num : out std_logic_vector(12 downto 0)
        );
    end component;
    
    --random clock generator
    component rcg is
        port(
            clk     : in std_logic;
            reset   : in std_logic;
            
            --randomly generated clock period
            rcp     : in unsigned (12 downto 0);
            rc      : out std_logic--random clock signal
        );
    end component;

    --counter with random clock
    component counter is
        port(
            clk             : in std_logic;--system clock
            clk_rand        : in std_logic;--counting clock
            button          : in std_logic;
            reset           : in std_logic;
            
            cnt             : out unsigned (3 downto 0);
            enable_max      : out std_logic
        );
    end component;    
    
    component max_equal is 
        port(
            en0      : in std_logic;
            en1      : in std_logic;
            en2      : in std_logic;
            en3      : in std_logic;
           
            cnt3 : in unsigned(3 downto 0);
            cnt2 : in unsigned(3 downto 0);
            cnt1 : in unsigned(3 downto 0);
            cnt0 : in unsigned(3 downto 0);
            
            max : out std_logic_vector(3 downto 0)
        );
    end component;
    
    component bcd_to_7_seg is
        port(
            digit : in std_logic_vector(3 downto 0);
            display : out std_logic_vector(6 downto 0)
        );
    end component;
    
    --random counter clock periods(time unit is miliseconds)
    signal random0 : std_logic_vector (12 downto 0);
    signal random1 : std_logic_vector (12 downto 0);
    signal random2 : std_logic_vector (12 downto 0);
    signal random3 : std_logic_vector (12 downto 0);
    
    --random counter clocks
    signal clk0 : std_logic;
    signal clk1 : std_logic;
    signal clk2 : std_logic;
    signal clk3 : std_logic;
    
    --counter outputs
    signal cnt0 : unsigned(3 downto 0);
    signal cnt1 : unsigned(3 downto 0);
    signal cnt2 : unsigned(3 downto 0);
    signal cnt3 : unsigned(3 downto 0);
    
    --enable signals for max_equal component
    signal en0 : std_logic;
    signal en1 : std_logic;
    signal en2 : std_logic;
    signal en3 : std_logic;
    
begin
    --4 RANDOM PERIOD GENERATORS
    RPG_0 : rpg port map (clk, reset, button, random0);
    RPG_1 : rpg port map (clk, reset, button, random1);
    RPG_2 : rpg port map (clk, reset, button, random2);
    RPG_3 : rpg port map (clk, reset, button, random3);
    
    --4 RANDOM CLOCK GENERATORS
    RCG_0 : rcg port map (clk, reset, unsigned(random0), clk0); 
    RCG_1 : rcg port map (clk, reset, unsigned(random0), clk1);
    RCG_2 : rcg port map (clk, reset, unsigned(random0), clk2);
    RCG_3 : rcg port map (clk, reset, unsigned(random0), clk3);
    
    --4 COUNTERS
    COUNTER0 : counter port map(clk, clk0, button, reset, cnt0, en0); 
    COUNTER1 : counter port map(clk, clk1, button, reset, cnt1, en1);
    COUNTER2 : counter port map(clk, clk2, button, reset, cnt2, en2); 
    COUNTER3 : counter port map(clk, clk3, button, reset, cnt3, en3);
    
    --4 bcd code converter to 7 segment display
    BCD0 : bcd_to_7_seg port map (std_logic_vector(cnt0), led0);
    BCD1 : bcd_to_7_seg port map (std_logic_vector(cnt1), led1);
    BCD2 : bcd_to_7_seg port map (std_logic_vector(cnt2), led2);
    BCD3 : bcd_to_7_seg port map (std_logic_vector(cnt3), led3);
    
    --makes instance of entity max_equal, connects counter outputs to its inputs
    MAX : max_equal port map(en0, en1, en2, en3, cnt0, cnt1, cnt2, cnt3, max_hit);
    
end architecture Structural;