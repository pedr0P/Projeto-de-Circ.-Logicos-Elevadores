library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- 1. Entidade do Testbench (vazia)
entity tb_cost_calculator is
end tb_cost_calculator;

-- 2. Arquitetura de Teste
architecture test of tb_cost_calculator is

    -- Constantes
    constant C_W : natural := 32; -- Gen�rico correspondente
    constant C_DELAY : time := 10 ns; -- Delay para propaga��o combinacional

    -- 3. Declara��o do Componente a ser Testado (CUT)
    component cost_calculator is
        generic (w : natural := 32);
        port (
            signal call_floor : in STD_LOGIC_VECTOR(4 downto 0);
            signal direction : in STD_LOGIC;
            signal floor_sensor : in STD_LOGIC_VECTOR(4 downto 0);
            signal moving : in STD_LOGIC_VECTOR(1 downto 0);
            signal elevator_cost : out STD_LOGIC_VECTOR(1 downto 0)
        );
    end component;

    -- 4. Sinais para conectar ao CUT
    signal s_call_floor : STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
    signal s_direction : STD_LOGIC := '0';
    signal s_floor_sensor : STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
    signal s_moving : STD_LOGIC_VECTOR(1 downto 0) := (others => '0');
    
    -- Sinal de sa�da (wire)
    signal s_elevator_cost : STD_LOGIC_VECTOR(1 downto 0);

begin

    -- 5. Instancia��o do Componente (Unit Under Test - UUT)
    UUT : component cost_calculator
        generic map (
            w => C_W
        )
        port map (
            call_floor    => s_call_floor,
            direction     => s_direction,
            floor_sensor  => s_floor_sensor,
            moving        => s_moving,
            elevator_cost => s_elevator_cost
        );

    -- 6. Processo de Est�mulo (onde os testes acontecem)
    stim_proc : process is
    begin
        report "Iniciando simula��o do cost_calculator...";

        -- --- CEN�RIO 1: Elevador PARADO ("00") ---
        -- Custo esperado: "01" (Bom)
        report "Cen�rio 1: Elevador Parado. Custo esperado = 01";
        s_moving <= "00";
        s_floor_sensor <= "00101"; -- Andar 5
        s_call_floor   <= "10000"; -- Andar 16
        s_direction    <= '1';
        wait for C_DELAY;
        -- CHECK: s_elevator_cost deve ser "01"

        -- --- CEN�RIO 2: Elevador SUBINDO ("10") ---
        report "Cen�rio 2: Elevador Subindo (Andar 10)...";
        s_moving <= "10";
        s_floor_sensor <= "01010"; -- Andar 10

        -- Sub-cen�rio 2a: �timo (Chamada para Subir, � frente)
        -- Custo esperado: "00" (Melhor)
        report "  2a: Chamada SUBIR (Andar 15). Custo esperado = 00";
        s_call_floor <= "01111"; -- Andar 15
        s_direction  <= '1';
        wait for C_DELAY;
        -- CHECK: s_elevator_cost deve ser "00"

        -- Sub-cen�rio 2b: Ruim (Chamada para Descer)
        -- Custo esperado: "10" (Ruim)
        report "  2b: Chamada DESCER (Andar 15). Custo esperado = 10";
        s_call_floor <= "01111"; -- Andar 15
        s_direction  <= '0';
        wait for C_DELAY;
        -- CHECK: s_elevator_cost deve ser "10"

        -- Sub-cen�rio 2c: Ruim (Chamada j� passou)
        -- Custo esperado: "10" (Ruim)
        report "  2c: Chamada SUBIR (Andar 5). Custo esperado = 10";
        s_call_floor <= "00101"; -- Andar 5
        s_direction  <= '1';
        wait for C_DELAY;
        -- CHECK: s_elevator_cost deve ser "10"
        
        -- --- CEN�RIO 3: Elevador DESCENDO ("01") ---
        report "Cen�rio 3: Elevador Descendo (Andar 20)...";
        s_moving <= "01";
        s_floor_sensor <= "10100"; -- Andar 20

        -- Sub-cen�rio 3a: �timo (Chamada para Descer, � frente)
        -- Custo esperado: "00" (Melhor)
        report "  3a: Chamada DESCER (Andar 10). Custo esperado = 00";
        s_call_floor <= "01010"; -- Andar 10
        s_direction  <= '0';
        wait for C_DELAY;
        -- CHECK: s_elevator_cost deve ser "00"

        -- Sub-cen�rio 3b: Ruim (Chamada para Subir)
        -- Custo esperado: "10" (Ruim)
        report "  3b: Chamada SUBIR (Andar 10). Custo esperado = 10";
        s_call_floor <= "01010"; -- Andar 10
        s_direction  <= '1';
        wait for C_DELAY;
        -- CHECK: s_elevator_cost deve ser "10"

        -- Sub-cen�rio 3c: Ruim (Chamada j� passou)
        -- Custo esperado: "10" (Ruim)
        report "  3c: Chamada DESCER (Andar 25). Custo esperado = 10";
        s_call_floor <= "11001"; -- Andar 25
        s_direction  <= '0';
        wait for C_DELAY;
        -- CHECK: s_elevator_cost deve ser "10"

        -- --- CEN�RIO 4: Estado Inv�lido ("11") ---
        -- Custo esperado: "11" (Inv�lido)
        report "Cen�rio 4: Estado Inv�lido. Custo esperado = 11";
        s_moving <= "11";
        wait for C_DELAY;
        -- CHECK: s_elevator_cost deve ser "11"
        
        report "Simula��o conclu�da.";
        wait; -- Fim da simula��o
    end process;

end test;