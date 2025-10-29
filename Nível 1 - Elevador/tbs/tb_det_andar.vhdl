library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_det_andar is
    end tb_det_andar;

architecture behavior of tb_det_andar is
    signal clk   : STD_LOGIC;
    signal reset : STD_LOGIC;
    signal fsi   : STD_LOGIC_VECTOR(4 downto 0);
    signal mov   : STD_LOGIC_VECTOR(1 downto 0);
    signal fso   : STD_LOGIC_VECTOR(4 downto 0);

    component det_andar
        port (
                 clk   : in STD_LOGIC;
                 reset : in STD_LOGIC;
                 fsi   : in STD_LOGIC_VECTOR(4 downto 0);
                 mov   : in STD_LOGIC_VECTOR(1 downto 0);
                 fso   : out STD_LOGIC_VECTOR(4 downto 0)
             );
    end component;
begin
    uut: det_andar
    port map (
                 clk => clk,
                 reset => reset,
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
        clk <= '0'; wait for 10 ns; clk <= '1';
        fsi <= "11111"; mov <= "10";
        wait for 10 ns;

        clk <= '0'; wait for 10 ns; clk <= '1';
        fsi <= "11111"; mov <= "01";
        wait for 10 ns;

        -- No térreo:
        clk <= '0'; wait for 10 ns; clk <= '1';
        fsi <= "00000"; mov <= "01";
        wait for 10 ns;

        clk <= '0'; wait for 10 ns; clk <= '1';
        fsi <= "00000"; mov <= "10";
        wait for 10 ns;

        -- Qualquer outro Andar
        clk <= '0'; wait for 10 ns; clk <= '1';
        fsi <= "00100"; mov <= "00"; wait for 10 ns;
        wait for 10 ns;

        clk <= '0'; wait for 10 ns; clk <= '1';
        fsi <= "00100"; mov <= "10"; wait for 10 ns;
        wait for 10 ns;

        clk <= '0'; wait for 10 ns; clk <= '1';
        fsi <= "00100"; mov <= "01"; wait for 10 ns;
        wait for 10 ns;

        clk <= '0'; wait for 10 ns; clk <= '1';
        reset <= '1'; wait for 10 ns;
        wait for 10 ns;
        wait;
    end process;
end behavior;

