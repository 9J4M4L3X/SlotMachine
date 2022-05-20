library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity max_equal is 
    port(
        en0      : in std_logic;
        en1      : in std_logic;
        en2      : in std_logic;
        en3      : in std_logic;
        
        cnt3    : in unsigned(3 downto 0);
        cnt2    : in unsigned(3 downto 0);
        cnt1    : in unsigned(3 downto 0);
        cnt0    : in unsigned(3 downto 0);
        
        max     : out std_logic_vector(3 downto 0)
    );
end max_equal;

architecture Behavioral of max_equal is
    type ARR is array (3 downto 0) of unsigned(3 downto 0);
begin 
    --compares inputs and generates maximum number of same numbers in an array of 4 numbers
    FindMax: process(en0, en1, en2, en3, cnt3, cnt2, cnt1, cnt0) is
        constant max_num : unsigned(3 downto 0) := "1001";--max valid output of counter module
        variable max_temporary : unsigned(5 downto 0);
        variable max_repeating_element : unsigned(3 downto 0);
        variable max_number_of_repeat : unsigned(3 downto 0);
        variable counter : integer range 0 to 4 := 0; 
		variable cnt_array : ARR;--help array
    begin
       if ((en0 = '1') and (en1 = '1') and (en2 = '1') and (en3 = '1')) then
			--if all enable signals are active counters have stopped counting and have a stable output
            
			--initialize array of 4 numbers read from outputs of 4 counters
            cnt_array(0) := cnt0;
            cnt_array(1) := cnt1;
            cnt_array(2) := cnt2;
            cnt_array(3) := cnt3;
           
            counter := 0;
            
            --add range to elements of array according to the number of repeat of elements
            while (counter <= 3) loop
                cnt_array(to_integer(cnt_array(counter) mod max_num)) := 
                cnt_array(to_integer(cnt_array(counter) mod max_num)) + max_num;    
                counter := counter + 1;
            end loop;
            
            max_temporary := resize(cnt_array(0), max_temporary'length); --initialize referent max value with the first element of array
            max_repeating_element := (others => '0');--used to store index of element with max value, that index is the value of the most repeated element
            
            counter := 0;
            
            --finds the maximum element in a modified array
            --index of it is the element which is repeating the most
            while (counter <= 3) loop
                if (cnt_array(counter) > max_temporary) then
                    max_temporary := resize(cnt_array(counter), max_temporary'length);
                    max_repeating_element := to_unsigned(counter, max_repeating_element'length);
                end if;
                counter := counter + 1;
            end loop;
           
            counter := 0;
            
            --counts number of occasions of found element
            while (counter <= 3) loop
                
                if (cnt_array(counter) = max_repeating_element) then
                    max_number_of_repeat := max_number_of_repeat + 1;
                end if;
                
                counter := counter + 1;
                
            end loop;
            
            max <= std_logic_vector(max_number_of_repeat);--output signal(maximum number of occasions of numbers from counter outputs)
        else
            max <= "0000";--keeps output zero while counters are counting
        end if;
        
    end process;

end architecture Behavioral;

