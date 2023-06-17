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
        LED1 : out std_logic;
        LED2 : out std_logic;
        LED3 : out std_logic;
        LED4 : out std_logic;
        buzzer : out std_logic;
        anode : out std_logic_vector(3 downto 0);
	    led_out : out std_logic_vector(6 downto 0)
    );
end entity VendingMachine;

architecture Behavioral of VendingMachine is

    type State is (IDLE, SELECT_DRINK, PAYMENT, INVALID_PIN, DISPENSING);
    signal current_state, next_state : State;
    type seg_state is (state0, state1, state2, state3, state4, state5, state6);
    signal stan,stan_nast : seg_state;

    signal counter_start, counter_reset : std_logic := '0';
    signal counter : integer range 0 to 1000000000 := 0;
    signal counter_start2, counter_reset2 : std_logic := '0';
    signal counter2 : integer range 0 to 1000000000 := 0;
    signal drink_selected : integer range 0 to 4;
    signal led_bcd : std_logic_vector(3 downto 0):= "0000";
	signal number : std_logic_vector(15 downto 0) := "0100001100100001";
    type STANY2 is (stabilny, opoznienie, niestabilny);
    signal stan3, stan_nast3 : STANY2;
signal licznik_start, licznik_zeruj : std_logic :='0';
signal licznik : std_logic_vector(26 downto 0):="000000000000000000000000000";
begin
  
    vending_machine: process (clk, reset)
    begin
        if reset = '1' then
        
            current_state <= IDLE;
            drink_selected <= 0;
            buzzer <= '0';
           
           
        elsif rising_edge(clk) then
          current_state <= next_state;
          stan3 <= stan_nast3;
             
            case current_state is
                when IDLE =>
                        buzzer <='0';
                        drink_selected <= 0;
                    if P1 = '1'AND P2='1' AND P3='0' AND P4='0' then
                        next_state <= SELECT_DRINK;
                   else
                        next_state <= IDLE;
                    end if;

                when SELECT_DRINK =>
                
                counter_reset <='0';
                  counter_start <= '1';
                if counter >=0 AND counter < 200000000 then
                current_state <= SELECT_DRINK;
           else
                 if counter < 700000000 AND counter >= 100000000 then
              
                
                    if P1 = '1'  then
                        next_state <= PAYMENT;
                        drink_selected <= 1;
                        counter_reset <='1';
                      
                        -- led pokazuje koszt napoju 1
                  stan<=state0;
                    elsif  P2='1' then
                        current_state <= PAYMENT;
                        drink_selected <= 2;
                  
                         -- led pokazuje koszt napoju 2
                         counter_reset <='1';
                  stan<=state1;
                    elsif  P3='1'  then
                        current_state <= PAYMENT;
                        drink_selected <= 3;
                    
                         -- led pokazuje koszt napoju 3
                         counter_reset <='1';
                  stan<=state2;
                    elsif  P4='1' then
                        next_state <= PAYMENT;
                        drink_selected <= 4;
                    
                         -- led pokazuje koszt napoju 4
                         counter_reset <='1';
                  stan<=state3;
                end if;
                  else 
                  current_state <= IDLE;
                   end if;
                  end if;
                    
                when PAYMENT =>
                counter_reset <='0';
                  counter_start <= '1';
                if counter >=0 AND counter < 200000000 then
                current_state <= PAYMENT;
           else
                 if counter < 700000000 AND counter >= 100000000 then
                current_state <= PAYMENT;
                if P1 = '1'AND P2='1' AND P3='1' AND P4='1' then
                    current_state <= DISPENSING;
                    counter_reset <='1';
                    else 
                    current_state <= INVALID_PIN;
                    end if;
                else 
                    counter_reset <='1';
                    next_state <= IDLE;
             end if;
                  end if;
                when DISPENSING =>
              
                counter_start <= '1';
                if counter >=0 AND counter < 300000000 then
                current_state <= DISPENSING;
            counter_start2<='1';
             stan <= state4;
                if rising_edge(clk) then
                if counter2 >= 50000000 then
                stan <= stan_nast;
              end if;
            end if;
                   else
                        next_state <= IDLE;
                        counter_reset <= '1';
                   end if;
                when INVALID_PIN =>
                counter_start <= '1';
                   if counter >=0 AND counter < 200000000 then
                        buzzer <= '1';
                        else
                        next_state <= IDLE;
                   end if;   
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
process(clk, reset, counter2, stan)
	begin
	if rising_edge(clk) then
		if (counter_start2 = '1') then
			counter2 <= counter2 +1;
			
		end if;
		if (counter_reset2 = '1') then
			counter2 <= 0;
		end if;
		end if;
end process;

  process(stan)
begin

    case stan is
        when state0 =>
           anode <= "0111"; 
            led_bcd <= number(15 downto 12); -- lewa strona 1
         
        when state1 =>
           anode <= "0111";
             led_bcd <= number(11 downto 8); -- lewa strona 2
          
        when state2 =>
          anode <= "0111";
             led_bcd <= number(7 downto 4);  -- lewa strona 3
          
        when state3 =>
           anode <= "0111";
            led_bcd <= number(3 downto 0);   -- lewa strona 4
            when state4 =>
           anode <= "1110"; 
            led_bcd <= number(15 downto 12); -- prawa strona 1
            stan_nast <= state5;
        when state5 =>
           anode <= "1101";
             led_bcd <= number(11 downto 8); -- prawa strona 2
            stan_nast <= state6;
        when state6 =>
          anode <= "1011";
             led_bcd <= number(7 downto 4);  -- prawa strona 3
            stan_nast <= state4;
        when others =>
             anode <= "1111"; 
    end case;
  
end process;
process(stan3, P1, P2, P3, P4 , licznik)
   begin
   
stan_nast3<= stan3;
licznik_start <='0';
licznik_zeruj <='0';

case stan3 is

	when stabilny =>
	if P1 = '1' OR P2 = '1' OR P3 = '1' OR P4 = '1' then
	stan_nast3 <= opoznienie;
	else
	stan_nast3 <= stabilny;
	end if;

	when opoznienie =>
	if (P1 = '1' OR P2 = '1' OR P3 = '1' OR P4 = '1') then
		licznik_start <= '1';
		if (licznik >= 2000000) then
		licznik_zeruj <= '1';
		stan_nast3 <= niestabilny;
		end if;
		else
		stan_nast3 <= stabilny;
	end if;

	when niestabilny =>
	licznik_start <= '1';
	if (licznik >= 100000000) then
	licznik_zeruj <='1';
	stan_nast3 <= stabilny;
	end if;
	
	when others =>
   stan_nast3 <= stabilny;

end case;

end process;
LED1 <= '1' when stan3 = niestabilny else '0';
LED2 <= '1' when stan3 = niestabilny else '0';
LED3 <= '1' when stan3 = niestabilny else '0';
LED4 <= '1' when stan3 = niestabilny else '0';
  liczenie:process(clk, reset, licznik)
	begin
	if rising_edge(clk) then
		if (licznik_start = '1') then
			licznik <= licznik + 1;
		end if;
		if (licznik_zeruj = '1') then
			licznik <= "000000000000000000000000000";
		end if;
	end if;
end process liczenie;
end architecture Behavioral;
