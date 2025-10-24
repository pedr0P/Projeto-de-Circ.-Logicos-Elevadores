library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_det_andar is
    end tb_det_andar;

architecture behavior of tb_det_andar is
    signal fsi : STD_LOGIC_VECTOR(4 downto 0) := "00000";
    signal mov : BIT_VECTOR(1 downto 0) := "00";
    signal fso : STD_LOGIC_VECTOR(4 downto 0);

    -- Instantiate the design under test (DUT)
    component det_andar
        port (
                 fsi : in STD_LOGIC_VECTOR(4 downto 0);
                 mov : in BIT_VECTOR(1 downto 0);
                 fso : out STD_LOGIC_VECTOR(4 downto 0)
             );
    end component;
begin
    -- Instantiate the DUT
    uut: det_andar
    port map (
                 fsi => fsi,
                 mov => mov,
                 fso => fso
             );

    -- Test process
    stimulus: process
    begin
        -- Apply test vectors to inputs
        fsi <= "00000"; mov <= "00"; wait for 10 ns;
        fsi <= "00001"; mov <= "01"; wait for 10 ns;
        fsi <= "00001"; mov <= "10"; wait for 10 ns;
        fsi <= "00011"; mov <= "01"; wait for 10 ns;
        fsi <= "00010"; mov <= "00"; wait for 10 ns;
        fsi <= "00010"; mov <= "10"; wait for 10 ns;

        -- End simulation
        wait;
    end process;
end behavior;

