library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- 1. Entidade do Testbench (vazia)
entity tb_cost_calculator is
end tb_cost_calculator;

-- 2. Arquitetura de Teste
architecture test of tb_cost_calculator is

    -- Constantes
    constant C_W : natural := 32; -- Genérico correspondente
    constant C_DELAY : time := 10 ns; -- Delay para propagação combinacional

    -- 3. Declaração do Componente a ser Testado (CUT)
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
    
    -- Sinal de saída (wire)
    signal s_elevator_cost : STD_LOGIC_VECTOR(1 downto 0);

begin

    -- 5. Instanciação do Componente (Unit Under Test - UUT)
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

    -- 6. Processo de Estímulo (onde os testes acontecem)
    stim_proc : process is
    begin
        report "Iniciando simulação do cost_calculator...";

        -- --- CENÁRIO 1: Elevador PARADO ("00") ---
        -- Custo esperado: "01" (Bom)
        report "Cenário 1: Elevador Parado. Custo esperado = 01";
        s_moving <= "00";
        s_floor_sensor <= "00101"; -- Andar 5
        s_call_floor   <= "10000"; -- Andar 16
        s_direction    <= '1';
        wait for C_DELAY;
        -- CHECK: s_elevator_cost deve ser "01"

        -- --- CENÁRIO 2: Elevador SUBINDO ("10") ---
        report "Cenário 2: Elevador Subindo (Andar 10)...";
        s_moving <= "10";
        s_floor_sensor <= "01010"; -- Andar 10

        -- Sub-cenário 2a: Ótimo (Chamada para Subir, à frente)
        -- Custo esperado: "00" (Melhor)
        report "  2a: Chamada SUBIR (Andar 15). Custo esperado = 00";
        s_call_floor <= "01111"; -- Andar 15
        s_direction  <= '1';
        wait for C_DELAY;
        -- CHECK: s_elevator_cost deve ser "00"

        -- Sub-cenário 2b: Ruim (Chamada para Descer)
        -- Custo esperado: "10" (Ruim)
        report "  2b: Chamada DESCER (Andar 15). Custo esperado = 10";
        s_call_floor <= "01111"; -- Andar 15
        s_direction  <= '0';
        wait for C_DELAY;
        -- CHECK: s_elevator_cost deve ser "10"

        -- Sub-cenário 2c: Ruim (Chamada já passou)
        -- Custo esperado: "10" (Ruim)
        report "  2c: Chamada SUBIR (Andar 5). Custo esperado = 10";
        s_call_floor <= "00101"; -- Andar 5
        s_direction  <= '1';
        wait for C_DELAY;
        -- CHECK: s_elevator_cost deve ser "10"
        
        -- --- CENÁRIO 3: Elevador DESCENDO ("01") ---
        report "Cenário 3: Elevador Descendo (Andar 20)...";
        s_moving <= "01";
        s_floor_sensor <= "10100"; -- Andar 20

        -- Sub-cenário 3a: Ótimo (Chamada para Descer, à frente)
        -- Custo esperado: "00" (Melhor)
        report "  3a: Chamada DESCER (Andar 10). Custo esperado = 00";
        s_call_floor <= "01010"; -- Andar 10
        s_direction  <= '0';
        wait for C_DELAY;
        -- CHECK: s_elevator_cost deve ser "00"

        -- Sub-cenário 3b: Ruim (Chamada para Subir)
        -- Custo esperado: "10" (Ruim)
        report "  3b: Chamada SUBIR (Andar 10). Custo esperado = 10";
        s_call_floor <= "01010"; -- Andar 10
        s_direction  <= '1';
        wait for C_DELAY;
        -- CHECK: s_elevator_cost deve ser "10"

        -- Sub-cenário 3c: Ruim (Chamada já passou)
        -- Custo esperado: "10" (Ruim)
        report "  3c: Chamada DESCER (Andar 25). Custo esperado = 10";
        s_call_floor <= "11001"; -- Andar 25
        s_direction  <= '0';
        wait for C_DELAY;
        -- CHECK: s_elevator_cost deve ser "10"

        -- --- CENÁRIO 4: Estado Inválido ("11") ---
        -- Custo esperado: "11" (Inválido)
        report "Cenário 4: Estado Inválido. Custo esperado = 11";
        s_moving <= "11";
        wait for C_DELAY;
        -- CHECK: s_elevator_cost deve ser "11"
        
        report "Simulação concluída.";
        wait; -- Fim da simulação
    end process;

end test;