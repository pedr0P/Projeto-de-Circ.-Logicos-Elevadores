library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity det_andar is
    port (
             clk   : in STD_LOGIC;
             reset : in STD_LOGIC;

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
        if reset = '1' then
            fso <= (others => '0');
        else if rising_edge(clk) then
            case mov is
                -- Parado:
                when "00" => fso <= fsi;

                -- Descendo:
                when "01" =>
                    if fsi /= "00000" then
                        fso <= STD_LOGIC_VECTOR(signed(fsi) - 1);
                    else
                        fso <= fsi;
                    end if;

                -- Subindo:
                when "10" => 
                    if fsi /= "11111" then
                        fso <= STD_LOGIC_VECTOR(signed(fsi) + 1);
                    else
                        fso <= fsi;
                    end if;
                -- Nunca deveria acontecer:
                when others => fso <= fsi;
            end case;
        end if;
    end if;
end process p_andar;
end rtl;

