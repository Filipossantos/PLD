library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity VendingMachine is
    port (
        clk : in std_logic;
        reset : in std_logic;
        P1 : in std_logic; 
        P2 : in std_logic;
        P3 : in std_logic;
        P4 : in std_logic;
        LCD_RS : out std_logic;
        LCD_E : out std_logic;
        data : out STD_LOGIC_VECTOR (7 downto 0);
        buzzer : out std_logic;
        anode : out std_logic_vector(3 downto 0);
	    led_out : out std_logic_vector(6 downto 0)
    );
end entity VendingMachine;

architecture Behavioral of VendingMachine is
    type arr is array (1 to 22) of std_logic_vector(7 downto 0);
    constant data_rom: arr := (X"38",X"0C",X"06",X"01",X"C0",X"30", X"31", X"32", X"33", X"34", X"35", X"36", X"37", X"38", X"39",X"41", X"42", X"43", X"44", X"45", X"46", X"47");
    signal en_timing : integer range  0 to 100000;
    signal data_pos: integer range  1 to 22;
    type State is (IDLE, SELECT_DRINK, PAYMENT, INVALID_PIN, DISPENSING);
    signal current_state, next_state : State;
    signal counter_start, counter_reset : std_logic := '0';
    signal counter : integer range 0 to 1000000000 := 0;
  
    signal drink_selected : integer range 0 to 4;
    signal pin_entered : std_logic_vector(3 downto 0);
    signal payment_successful : std_logic;
    signal buzzer_trigger : std_logic;
    signal led_bcd : std_logic_vector(3 downto 0);
	signal number : std_logic_vector(15 downto 0) := "0100001100100001";

begin
  
    vending_machine: process (clk, reset)
    begin
        if reset = '1' then
        
            current_state <= IDLE;
            drink_selected <= 0;
            pin_entered <= (others => '0');
            payment_successful <= '0';
            buzzer_trigger <= '0';
            anode <= "0000";
            buzzer <= '0';

        elsif rising_edge(clk) then
          
            current_state <= next_state;
            en_timing <= en_timing +1;
            if en_timing <= 50000 then
            LCD_E <= '1';
            data <= data_rom(data_pos)(7 downto 0);
            elsif en_timing > 50000 and en_timing < 100000 then
            LCD_E <= '0';
            elsif en_timing = 100000 then
            en_timing <= 0;
            end if;
            if data_pos <= 5 then
            LCD_RS <= '0';
            elsif data_pos > 5 then
            LCD_RS <= '1';
            end if;
            
            if data_pos = 22 then
                data_pos <= 5;
            end if;
            case current_state is
                when IDLE =>
                    if P1 = '1'AND P2='1' AND P3='0' AND P4='0' then
                    counter_start <='1';
                        buzzer <='0';
                        drink_selected <= 0;
                        next_state <= SELECT_DRINK;
                   else
                        next_state <= IDLE;
                    end if;

                when SELECT_DRINK =>
                       -- lcd pokazuje napis koszt napoju:
                 
                    if P1 = '1' AND P2='0' AND P3='0' AND P4='0' then
                        next_state <= PAYMENT;
                        drink_selected <= 1;
                        -- led pokazuje koszt napoju 1
                       anode <= "1110";
			           led_bcd <= number(3 downto 0);
                    elsif P1 = '0' AND P2='1' AND P3='0'AND P4='0' then
                        next_state <= PAYMENT;
                        drink_selected <= 2;
                         -- led pokazuje koszt napoju 2
                         anode <= "1101";
			             led_bcd <= number(7 downto 4);
                    elsif P1 = '0' AND P2='0' AND P3='1' AND P4='0' then
                        next_state <= PAYMENT;
                        drink_selected <= 3;
                         -- led pokazuje koszt napoju 3
                         anode <= "1011";
			             led_bcd <= number(11 downto 8);
                    elsif P1 = '0' AND P2='0' AND P3='0' AND P4='1' then
                        next_state <= PAYMENT;
                        drink_selected <= 4;
                         -- led pokazuje koszt napoju 4
                         anode <= "0111";
			             led_bcd <= number(15 downto 12);
			        elsif P1 = '0' AND P2='0' AND P3='0' AND P4='0' then
                        next_state <= SELECT_DRINK;    
                    else
                        next_state <= IDLE;
                    end if;
          

                when PAYMENT =>
               
                    if P1 = '1' AND P2='1' AND P3='1' AND P4='1' then
                        next_state <= DISPENSING;
                        payment_successful <= '1';
                        -- lcd pokazuje platnosc udana
                    else 
                    next_state <= INVALID_PIN;
                    end if;
                  
                when DISPENSING =>
                        next_state <= IDLE;
                        counter_reset <= '1';
                        -- lcd pokazuje nalewanie
                    LCD_RS<='1';
                when INVALID_PIN =>
                        -- lcd pokazuje niepoprawny pin
                        next_state <= IDLE;
                        buzzer <= '1';

        
            end case;

          
        end if;
    end process vending_machine;
    
process (led_bcd)
	begin
		case led_bcd is
			when "0000" => led_out <= "1000000"; -- 0
			when "0001" => led_out <= "1111001"; -- 1
			when "0010" => led_out <= "0100100"; -- 2
			when "0011" => led_out <= "0110000"; -- 3
			when "0100" => led_out <= "0011001"; -- 4
			when "0101" => led_out <= "0010010"; -- 5
			when "0110" => led_out <= "0000010"; -- 6
			when "0111" => led_out <= "1111000"; -- 7
			when "1000" => led_out <= "0000000"; -- 8
			when "1001" => led_out <= "0010000"; -- 9
			when others => led_out <= "1111111";
		end case;
end process;

 process(clk, reset, counter)
	begin
	if rising_edge(clk) then
		if (counter_start = '1') then
			counter <= counter +1;
		end if;
		if (counter_reset = '1') then
			counter <= 0;
		end if;
		end if;
end process;
  

end architecture Behavioral;
