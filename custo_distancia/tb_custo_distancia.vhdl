-- 1. Bibliotecas
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- 2. Entidade do Testbench (sempre vazia)
entity tb_custo_distancia is
end entity tb_custo_distancia;

-- 3. Arquitetura de Teste
architecture test of tb_custo_distancia is
    -- Constante para o tempo de espera entre os testes
    constant C_DELAY : time := 10 ns;

    -- Declaração do componente que vamos testar (UUT - Unit Under Test)
    component custo_distancia is
        port (
            chamada_ativa : in  std_logic_vector(4 downto 0);
            floor_sensor  : in  std_logic_vector(4 downto 0);
            distancia     : out std_logic_vector(4 downto 0)
        );
    end component;

    -- Sinais ("fios") para conectar ao nosso componente
    signal s_chamada_ativa : std_logic_vector(4 downto 0) := (others => '0');
    signal s_floor_sensor  : std_logic_vector(4 downto 0) := (others => '0');
    signal s_distancia     : std_logic_vector(4 downto 0); -- Fio para observar a saída

begin

    -- Instanciação do Componente Sob Teste
    -- É aqui que conectamos os fios ao nosso componente 🔌
    UUT : component custo_distancia
        port map (
            chamada_ativa => s_chamada_ativa,
            floor_sensor  => s_floor_sensor,
            distancia     => s_distancia
        );

    -- Processo de Estímulo: O roteiro do nosso teste 📝
    stim_proc : process is
    begin
        report "Iniciando simulação do calculador de distância...";

        -- --- CENÁRIO 1: Chamada para andar superior ---
        report "Cenário 1: Chamada de 3 para 10.";
        s_floor_sensor  <= "00011"; -- Andar 3
        s_chamada_ativa <= "01010"; -- Andar 10
        wait for C_DELAY;
        -- CHECK: s_distancia deve ser "00111" (7)

        -- --- CENÁRIO 2: Chamada para andar inferior ---
        report "Cenário 2: Chamada de 12 para 5.";
        s_floor_sensor  <= "01100"; -- Andar 12
        s_chamada_ativa <= "00101"; -- Andar 5
        wait for C_DELAY;
        -- CHECK: s_distancia deve ser "00111" (7)

        -- --- CENÁRIO 3: Chamada para o andar atual ---
        report "Cenário 3: Chamada para o mesmo andar (8).";
        s_floor_sensor  <= "01000"; -- Andar 8
        s_chamada_ativa <= "01000"; -- Andar 8
        wait for C_DELAY;
        -- CHECK: s_distancia deve ser "00000" (0)

        -- --- CENÁRIO 4: Teste de Limites (distância máxima) ---
        report "Cenário 4: Distância máxima de 0 para 31.";
        s_floor_sensor  <= "00000"; -- Andar 0
        s_chamada_ativa <= "11111"; -- Andar 31
        wait for C_DELAY;
        -- CHECK: s_distancia deve ser "11111" (31)

        report "Simulação concluída.";
        wait; -- Pausa a simulação para sempre
    end process;

end architecture test;