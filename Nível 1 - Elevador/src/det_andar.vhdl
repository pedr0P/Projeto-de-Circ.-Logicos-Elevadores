library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD_UNSIGNED.ALL;

entity det_andar is
    port (
             clk : in STD_LOGIC;

             fsi : in STD_LOGIC_VECTOR(4 downto 0);
             mov : in STD_LOGIC_VECTOR(1 downto 0);

             fso : out STD_LOGIC_VECTOR(4 downto 0)
         );
end det_andar;

architecture rtl of det_andar is
begin
    -- Recebe duas informações:
    -- Floor_sensor[0..4] (fsi := floor_sensor_in)
    -- Moving[0..1] (mov)

    -- Devolve:
    -- Floor_sensor[0..4] (fso := floor_sensor_out)

    p_andar : process(clk, fsi, mov)
    begin
        if rising_edge(clk) then
            case mov is
            -- Parado:
                when "00" => fso <= fsi;

            -- Descendo:
                when "01" =>
                    if fsi /= 0 then
                        fso <= fsi - 1;
                    else
                        fso <= fsi;
                    end if;

            -- Subindo:
                when "10" => 
                    if fsi /= 31 then
                        fso <= fsi + 1;
                    else
                        fso <= fsi;
                    end if;
            -- Nunca deveria acontecer:
                when "11" => fso <= fsi;
            end case;
        end if;
    end process p_andar;
end rtl;

