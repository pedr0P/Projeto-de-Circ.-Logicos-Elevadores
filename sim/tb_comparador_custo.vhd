LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY tb_comparador_custo IS
END ENTITY tb_comparador_custo;

ARCHITECTURE test OF tb_comparador_custo IS
    
    -- componente a ser testado
    COMPONENT comparador_custo IS
        PORT (
            distancia_0_in      : IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
            distancia_1_in      : IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
            distancia_2_in      : IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
            custo_elev_0_in : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
            custo_elev_1_in : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
            custo_elev_2_in : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
            elevador_vencedor_out : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
        );
    END COMPONENT comparador_custo;

    -- sinais de estímulo
    SIGNAL s_distancia_0 : STD_LOGIC_VECTOR(4 DOWNTO 0);
    SIGNAL s_distancia_1 : STD_LOGIC_VECTOR(4 DOWNTO 0);
    SIGNAL s_distancia_2 : STD_LOGIC_VECTOR(4 DOWNTO 0);
    SIGNAL s_custo_0     : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL s_custo_1     : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL s_custo_2     : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL s_vencedor    : STD_LOGIC_VECTOR(1 DOWNTO 0);

BEGIN

    -- instanciação do UUT
    UUT : comparador_custo
    PORT MAP (
        distancia_0_in      => s_distancia_0,
        distancia_1_in      => s_distancia_1,
        distancia_2_in      => s_distancia_2,
        custo_elev_0_in => s_custo_0,
        custo_elev_1_in => s_custo_1,
        custo_elev_2_in => s_custo_2,
        elevador_vencedor_out => s_vencedor
    );

    -- processo de estímulo
    PROCESS
    BEGIN
        REPORT "Iniciando teste do modulo Comparador de Custo";

        -- cenário 1: elevador 1 tem o menor custo
        REPORT "CENARIO 1: elevador 1 deve vencer";
        s_custo_0 <= "01"; s_distancia_0 <= "00101"; -- custo total = 37
        s_custo_1 <= "00"; s_distancia_1 <= "00010"; -- custo total = 2
        s_custo_2 <= "10"; s_distancia_2 <= "11111"; -- custo total = 95
        WAIT FOR 10 ns;
        ASSERT s_vencedor = "01" 
            REPORT "Elevador 1 devia vencer" SEVERITY error;

        -- cenário 2: elevador 0 vence por empate
        REPORT "CENARIO 2: elevador 0 deve vencer";
        s_custo_0 <= "00"; s_distancia_0 <= "00010"; -- custo total = 2
        s_custo_1 <= "00"; s_distancia_1 <= "00010"; -- custo total = 2
        s_custo_2 <= "10"; s_distancia_2 <= "11111"; -- custo total = 95
        WAIT FOR 10 ns;
        ASSERT s_vencedor = "00" 
            REPORT "Elevador 0 devia vencer" SEVERITY error;

        -- cenário 3: elevador 2 vence
        REPORT "CENARIO 3: elevador 2 deve vencer";
        s_custo_0 <= "11"; s_distancia_0 <= "00101"; -- custo total = 101
        s_custo_1 <= "10"; s_distancia_1 <= "00010"; -- custo total = 66
        s_custo_2 <= "00"; s_distancia_2 <= "11111"; -- custo total = 31
        WAIT FOR 10 ns;
        ASSERT s_vencedor = "10" 
            REPORT "Elevador 2 devia vencer" SEVERITY error;

        REPORT "Teste do modulo Comparador de Custo concluido";
        WAIT;
    END PROCESS;

END ARCHITECTURE test;