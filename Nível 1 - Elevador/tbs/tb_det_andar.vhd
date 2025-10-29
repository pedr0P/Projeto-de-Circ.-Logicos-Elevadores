library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- 1. Entidade do Testbench (vazia)
entity tb_det_andar is
end tb_det_andar;

-- 2. Arquitetura de Teste
architecture test of tb_det_andar is
    -- Constante para o período do clock
    constant C_CLK_PERIOD : time := 20 ns;

    -- Sinais para conectar ao componente
    signal s_clk   : STD_LOGIC := '0';
    signal s_reset : STD_LOGIC := '0';
    -- s_fsi foi removido
    signal s_mov   : STD_LOGIC_VECTOR(1 downto 0) := "00";
    signal s_fso   : STD_LOGIC_VECTOR(4 downto 0);

    -- 3. Declaração do componente (CORRIGIDA)
    component det_andar
        port (
                 clk   : in STD_LOGIC;
                 reset : in STD_LOGIC;
                 -- fsi foi removido
                 mov   : in STD_LOGIC_VECTOR(1 downto 0);
                 fso   : out STD_LOGIC_VECTOR(4 downto 0)
             );
    end component;
begin
    -- 4. Instanciação do Componente (CORRIGIDA)
    UUT: det_andar
    port map (
                 clk   => s_clk,
                 reset => s_reset,
                 -- fsi foi removido
                 mov   => s_mov,
                 fso   => s_fso
             );

    -- 5. Processo Gerador de Clock (roda em paralelo)
    clk_gen_proc: process
    begin
        loop
            s_clk <= '0';
            wait for C_CLK_PERIOD / 2;
            s_clk <= '1';
            wait for C_CLK_PERIOD / 2;
        end loop;
    end process;

    -- 6. Processo de Estímulo (CORRIGIDO)
    -- (Não atribui mais 's_fsi', apenas 's_mov')
    stimulus: process
    begin
        report "Iniciando simulação do det_andar...";
        
        -- 1. Aplicar Reset
        report "Testando Reset...";
        s_reset <= '1';
        wait until rising_edge(s_clk);
        s_reset <= '0';
        wait until rising_edge(s_clk);
        -- CHECK (GtkWave): fso deve ser "00000" (0)

        -- 2. Teste Subindo
        report "Testando Subida (0 -> 1 -> 2)";
        s_mov <= "10"; -- Tenta Subir
        wait until rising_edge(s_clk);
        -- CHECK: fso deve ser "00001" (1)

        wait until rising_edge(s_clk);
        -- CHECK: fso deve ser "00010" (2)
        
        -- 3. Teste Parado
        report "Testando Parado (fica em 2)";
        s_mov <= "00"; -- Parado
        wait until rising_edge(s_clk);
        -- CHECK: fso deve ser "00010" (2)
        
        wait until rising_edge(s_clk);
        -- CHECK: fso deve permanecer "00010" (2)

        -- 4. Teste Descendo
        report "Testando Descida (2 -> 1 -> 0)";
        s_mov <= "01"; -- Descendo
        wait until rising_edge(s_clk);
        -- CHECK: fso deve ser "00001" (1)

        wait until rising_edge(s_clk);
        -- CHECK: fso deve ser "00000" (0)

        -- 5. Teste Limite Inferior
        report "Testando Limite Inferior (fica em 0)";
        s_mov <= "01"; -- Tenta Descer
        wait until rising_edge(s_clk);
        -- CHECK: fso deve permanecer "00000" (0)

        report "Simulação concluída.";
        wait;
    end process;
end test;