-- uart.vhd: UART controller - receiving part
-- Author: Jana Veronika Moskvová
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-------------------------------------------------
entity UART_RX is
port(	
  CLK: 	    in std_logic;
	RST: 	    in std_logic;
	DIN: 	    in std_logic;
	DOUT: 	   out std_logic_vector(7 downto 0);
	DOUT_VLD: out std_logic
);
end UART_RX;  

-------------------------------------------------
architecture behavioral of UART_RX is
signal cnt : std_logic_vector(4 downto 0) := "00001";
signal cnt2 : std_logic_vector (3 downto 0) := "0000";
signal cnt3 : std_logic_vector (3 downto 0):="0000";
signal rx_enabled : std_logic := '0'; 
signal cnt_enabled : std_logic := '0';
signal data_valid : std_logic := '0';
begin
  FSM: entity work.uart_fsm(behavioral)
    port map (
        CLK 	    => CLK,
        RST 	    => RST,
        DIN 	    => DIN,
        CNT 	    => cnt,
        CNT2 	   => cnt2,
        CNT3     => cnt3, 
        RX_ENABLED => rx_enabled,
        CNT_ENABLED => cnt_enabled,
        DATA_VALID => data_valid
    );
  process (CLK) begin
      if rising_edge(CLK) then
          DOUT_VLD <= '0';
          if RST = '1' then
              DOUT <= "00000000";
          end if;
          if cnt_enabled = '1' then
              cnt <= cnt + "1";
          else 
              cnt <= "00001";
          end if;
          if cnt2 = "1000" then
              cnt3 <= cnt3 + "1";
          end if;
          if cnt3 = "1000" then
              DOUT_VLD <= '1';
              cnt2 <= "0000";
              cnt3 <= "0000";
          end if;
              if rx_enabled = '1' then
                  if cnt(4) = '1' then
                      cnt <= "00001";
                      case cnt2 is
                          when "0000" => DOUT(0) <= DIN;
                          when "0001" => DOUT(1) <= DIN; 
                          when "0010" => DOUT(2) <= DIN;
                          when "0011" => DOUT(3) <= DIN;
                          when "0100" => DOUT(4) <= DIN;
                          when "0101" => DOUT(5) <= DIN;
                          when "0110" => DOUT(6) <= DIN;
                          when "0111" => DOUT(7) <= DIN;
                          when others => null;
                      end case;
                      cnt2 <= cnt2 + "1";
                  end if;
              end if;
      end if;
  end process;
end behavioral;
