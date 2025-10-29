library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_det_andar is
    end tb_det_andar;

architecture behavior of tb_det_andar is
    signal fsi : STD_LOGIC_VECTOR(4 downto 0);
    signal mov : BIT_VECTOR(1 downto 0);
    signal fso : STD_LOGIC_VECTOR(4 downto 0);

    component det_andar
        port (
                 fsi : in STD_LOGIC_VECTOR(4 downto 0);
                 mov : in BIT_VECTOR(1 downto 0);
                 fso : out STD_LOGIC_VECTOR(4 downto 0)
             );
    end component;
begin
    uut: det_andar
    port map (
                 fsi => fsi,
                 mov => mov,
                 fso => fso
             );

    stimulus: process
    begin
        -- mov:
        --     00 := Stopped
        --     01 := Moving Down
        --     10 := Moving Up
        --     11 := Never should happen

        -- No último andar:
        fsi <= "11111"; mov <= "10"; wait for 10 ns;
        fsi <= "11111"; mov <= "01"; wait for 10 ns;

        -- No térreo:
        fsi <= "00000"; mov <= "01"; wait for 10 ns;
        fsi <= "00000"; mov <= "10"; wait for 10 ns;

        -- Qualquer outro Andar
        fsi <= "00100"; mov <= "00"; wait for 10 ns;
        fsi <= "00100"; mov <= "10"; wait for 10 ns;
        fsi <= "00100"; mov <= "01"; wait for 10 ns;
        wait;
    end process;
end behavior;

