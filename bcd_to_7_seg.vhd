library ieee;
use ieee.std_logic_1164.all;

entity bcd_to_7_seg is
    port(
        digit : in std_logic_vector(3 downto 0);
        display : out std_logic_vector(6 downto 0)
    );
end bcd_to_7_seg;

architecture Behavioral of bcd_to_7_seg is
begin 

    display(6) <= ((not digit(3)) and (not digit(2)) and digit(1)) or
        ((not digit(3)) and digit(2) and (not digit(1))) or
        ((not digit(3)) and digit(1) and (not digit(0))) or 
        ((not digit(2)) and digit(3) and (not digit(1)));

    display(5) <= ((not digit(0)) and (not digit(2)) and (not digit(1))) or
        (digit(2) and (not digit(1)) and (not digit(3))) or
        (digit(2) and (not digit(3)) and (not digit(0))) or
        ((not digit(2)) and digit(3) and (not digit(1)));
    
    display(4) <= ((not digit(0)) and (not digit(2)) and (not digit(1))) or
        (digit(1) and (not digit(3)) and (not digit(0)));
    
    display(3) <= (digit(3) and (not digit(1)) and (not digit(2))) or
        (digit(1) and (not digit(2)) and (not digit(3))) or
        ((not digit(0)) and (not digit(3)) and digit(1)) or
        (digit(2) and (not digit(3)) and (not digit(1)) and digit(0)) or 
        ((not digit(0)) and (not digit(2)) and (not digit(1)));
    
    display(2) <= ((not digit(2)) and (not digit(1))) or
        ((not digit(3)) and digit(2)) or
        ((not digit(3)) and digit(0));
       
    display(1) <= ((not digit(3)) and (not digit(2))) or
        ((not digit(1)) and (not digit(2))) or
        ((not digit(3)) and digit(1) and digit(0));
    
    display(0) <= (digit(3) and digit(1)) or
        ((not digit(3)) and digit(2) and digit(0)) or
        (digit(3) and (not digit(1)) and (not digit(2))) or
        ((not digit(3)) and (not digit(0)) and (not digit(2)));
    
end Behavioral;