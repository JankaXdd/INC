-- uart_fsm.vhd: UART controller - finite state machine
-- Author: Jana Veronika Moskvová
--
library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------
entity UART_FSM is
port(
   CLK : in std_logic;
   RST : in std_logic;
   DIN : in std_logic;
   CNT : in std_logic_vector(4 downto 0);
   CNT2 : in std_logic_vector (3 downto 0);
   CNT3 : in std_logic_vector (3 downto 0);
   RX_ENABLED : out std_logic;
   CNT_ENABLED : out std_logic;
   DATA_VALID : out std_logic
   );
end entity UART_FSM;

-------------------------------------------------
architecture behavioral of UART_FSM is
type TYPE_STATE is (START_WAIT, BIT_WAIT, DATA_READ, STOP_BIT_WAIT, VALID_DATA);
signal SIGNAL_STATE : TYPE_STATE := START_WAIT;
begin
  RX_ENABLED <= '1' when SIGNAL_STATE = DATA_READ else '0';
  CNT_ENABLED <= '1' when SIGNAL_STATE = BIT_WAIT or SIGNAL_STATE = DATA_READ else '0';
  DATA_VALID <= '1' when SIGNAL_STATE = VALID_DATA else '0';
  process (CLK) begin
    if rising_edge(CLK) then
      if RST = '1' then
        SIGNAL_STATE <= START_WAIT;
      else 
        case SIGNAL_STATE is
          when START_WAIT => if DIN = '0' then
                                SIGNAL_STATE <= BIT_WAIT;
                             end if; 
          when BIT_WAIT => if CNT = "10110" then 
                                SIGNAL_STATE <= DATA_READ;
                           end if;
          when DATA_READ => if CNT2 = "1000" then
                              SIGNAL_STATE <=  STOP_BIT_WAIT;
                            end if;
          when STOP_BIT_WAIT => if CNT3 = "1000" then
                                  SIGNAL_STATE <= VALID_DATA;
                                end if;
          when VALID_DATA => SIGNAL_STATE <= START_WAIT;
                            
          when others => null;
                                
        end case;
      end if; 
     end if;
  end process; 
end behavioral;
