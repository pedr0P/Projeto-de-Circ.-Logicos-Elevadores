library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.ALL;

entity custo_distancia is
    port (
        chamada_ativa : in std_logic_vector(4 downto 0) := (others => '0');
        floor_sensor : in std_logic_vector(4 downto 0) := (others => '0');
        distancia : out std_logic_vector(4 downto 0) := (others => '0') 
    );
end entity custo_distancia;

architecture comportamental of custo_distancia is
begin
    p_calc_dist : process(chamada_ativa, floor_sensor)
    begin
        if (chamada_ativa /= "00000") then
            if chamada_ativa >= floor_sensor then
                distancia <= std_logic_vector(unsigned(chamada_ativa) - unsigned(floor_sensor));
            else
                distancia <= std_logic_vector(unsigned(floor_sensor) - unsigned(chamada_ativa));
            end if;
        end if;
    end process p_calc_dist;
end architecture;
