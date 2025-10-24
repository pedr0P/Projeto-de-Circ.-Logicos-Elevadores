library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity det_andar is
    -- `i0`, `i1`, and the carry-in `ci` are inputs of the adder.
    -- `s` is the sum output, `co` is the carry-out.
    port (
             fsi : in STD_LOGIC_VECTOR(4 downto 0);
             mov : in BIT_VECTOR(1 downto 0);

             fso : out STD_LOGIC_VECTOR(4 downto 0)
         );
end det_andar;

architecture rtl of det_andar is
begin
    -- Recebe duas informações:
    -- Floor_sensor[0..4]
    -- Devolve:
    -- Floor_sensor[0..4]
    --  Compute the sum.

    p_andar : process(fsi, mov)
    begin
        case mov is
            when "00" => fso <= fsi;
            when "01" =>
                if fsi /= 0 then
                    fso <= fsi - 1;
                else
                    fso <= fsi;
                end if;
            when "10" => 
                if fsi /= 32 then
                    fso <= fsi + 1;
                else
                    fso <= fsi;
                end if;
            when "11" => fso <= fsi;
        end case;
    end process p_andar;
end rtl;

