library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity VendingMachine_TB is
end entity VendingMachine_TB;

architecture Behavioral of VendingMachine_TB is
    -- Component declaration for DUT
    component VendingMachine is
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
    end component VendingMachine;

    -- Signals for testbench
    signal clk : std_logic := '0';
    signal reset : std_logic := '1';
    signal P1 : std_logic := '0';
    signal P2 : std_logic := '0';
    signal P3 : std_logic := '0';
    signal P4 : std_logic := '0';
    signal LED1 : std_logic;
    signal LED2 : std_logic;
    signal LED3 : std_logic;
    signal LED4 : std_logic;
    signal buzzer : std_logic;
    signal anode : std_logic_vector(3 downto 0);
    signal led_out : std_logic_vector(6 downto 0);
    constant PERIOD : time := 10ns;

begin
    -- Instantiate the DUT
    dut: VendingMachine
        port map (
            clk => clk,
            reset => reset,
            P1 => P1,
            P2 => P2,
            P3 => P3,
            P4 => P4,
            LED1 => LED1,
            LED2 => LED2,
            LED3 => LED3,
            LED4 => LED4,
            buzzer => buzzer,
            anode => anode,
            led_out => led_out
        );

    -- Clock process
    clk_process: process
    begin
            clk <= '0';
            wait for PERIOD / 2;
            clk <= '1';
            wait for PERIOD / 2;
 
    end process clk_process;

    -- Stimulus process
    stimulus_process: process
    begin
        -- Reset the vending machine
        reset <= '1';
        P1 <= '0';
        P2 <= '0';
        P3 <= '0';
        P4 <= '0';
       wait for PERIOD;
        reset <= '0';
     wait for PERIOD;
         P2 <= '1';
         P1 <= '1';
         wait for PERIOD*100000000;
         P2 <= '0';
         P1 <= '0';
         wait for PERIOD*100000000;
         P4 <= '1';
         wait for PERIOD*100000000;
         P4 <= '0';
          wait for PERIOD*100000000;
        P1 <= '1';
        P2 <= '1';
        P3 <= '1';
        P4 <= '1';
        wait for PERIOD*100000000;
         P1 <= '0';
        P2 <= '0';
        P3 <= '0';
        P4 <= '0';
        
   
        -- End of simulation
        wait;
    end process stimulus_process;

end architecture Behavioral;
