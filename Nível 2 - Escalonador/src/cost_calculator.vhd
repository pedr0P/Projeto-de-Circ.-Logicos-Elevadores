library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity cost_calculator is
      generic (w : natural := 32);
      port (
            signal call_floor : in STD_LOGIC_VECTOR(4 downto 0);
            signal direction : in STD_LOGIC;                          -- 1 para subir e 0 para descer
            signal floor_sensor : in STD_LOGIC_VECTOR(4 downto 0);
            signal moving : in STD_LOGIC_VECTOR(1 downto 0);          -- 00 - parado, 10 - subindo, 01 - descendo
            signal elevator_cost : out STD_LOGIC_VECTOR(1 downto 0)   -- 00 (melhor), 01 (bom), 10 (ruim), 11 (inválido)
      );   
end cost_calculator;

architecture comportamental of cost_calculator is
begin
      process(call_floor, direction, floor_sensor, moving)
            variable v_current_floor_int : integer range 0 to w-1;
            variable v_call_floor_int : integer range 0 to w-1;

      begin            
            v_current_floor_int := to_integer(unsigned(floor_sensor));
            v_call_floor_int := to_integer(unsigned(call_floor));
            
            -- Valor padrão (Custo Inválido)
            elevator_cost <= "11";

            case moving is
                when "00" =>
                    elevator_cost <= "01"; 

                when "10" =>
                    if (direction = '1') and (v_call_floor_int > v_current_floor_int) then
                        elevator_cost <= "00";
                    else
                        elevator_cost <= "10";
                    end if;

                when "01" =>
                    if (direction = '0') and (v_call_floor_int < v_current_floor_int) then
                        elevator_cost <= "00";
                    else
                        elevator_cost <= "10";
                    end if;
            
                when others =>
                    elevator_cost <= "11";

            end case;
      end process;

end comportamental;