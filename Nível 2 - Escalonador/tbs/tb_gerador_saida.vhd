LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY TB_GERADOR_SAIDA IS
END ENTITY TB_GERADOR_SAIDA;

ARCHITECTURE test OF TB_GERADOR_SAIDA IS

    -- componente a ser testado
    COMPONENT GERADOR_SAIDA IS
        PORT (
            enable                : IN  STD_LOGIC;
            chamada_ativa_in      : IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
            direcao_in            : IN  STD_LOGIC;
            elevador_vencedor_in  : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
            solicite_0_out        : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
            solicite_1_out        : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
            solicite_2_out        : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
            descer_out            : OUT STD_LOGIC_VECTOR(0 TO 2);
            solicit_enable_out    : OUT STD_LOGIC
        );
    END COMPONENT GERADOR_SAIDA;
    
    -- sinais de estímulo e observação
    SIGNAL s_enable        : STD_LOGIC;
    SIGNAL s_chamada_ativa : STD_LOGIC_VECTOR(4 DOWNTO 0);
    SIGNAL s_direcao       : STD_LOGIC;
    SIGNAL s_vencedor      : STD_LOGIC_VECTOR(1 DOWNTO 0);
    SIGNAL s_solicite_0    : STD_LOGIC_VECTOR(4 DOWNTO 0);
    SIGNAL s_solicite_1    : STD_LOGIC_VECTOR(4 DOWNTO 0);
    SIGNAL s_solicite_2    : STD_LOGIC_VECTOR(4 DOWNTO 0);
    SIGNAL s_descer        : STD_LOGIC_VECTOR(0 TO 2);
    SIGNAL s_solicit_enable: STD_LOGIC;

BEGIN

    -- instanciação do UUT
    UUT : GERADOR_SAIDA
    PORT MAP (
        enable                => s_enable,
        chamada_ativa_in      => s_chamada_ativa,
        direcao_in            => s_direcao,
        elevador_vencedor_in  => s_vencedor,
        solicite_0_out        => s_solicite_0,
        solicite_1_out        => s_solicite_1,
        solicite_2_out        => s_solicite_2,
        descer_out            => s_descer,
        solicit_enable_out    => s_solicit_enable
    );

    -- processo de Estímulo
    PROCESS
    BEGIN
        REPORT "Iniciando teste do modulo Gerador de Saida";
        
        s_enable <= '1';
        -- cenário 1: elevador 2 vence, chamada para subir no andar 25
        REPORT "CENARIO 1: elevador 2, subir no andar 25";
        s_chamada_ativa <= "11001"; -- andar 25
        s_direcao       <= '1';     -- 1 indica subida
        s_vencedor      <= "10";     -- elevador 2
        WAIT FOR 10 ns;
        -- verifica se o andar foi enviado só para o elevador 2
        ASSERT s_solicite_0 = "00000" AND s_solicite_1 = "00000" AND s_solicite_2 = "11001"
            REPORT "Andar nao foi para o elevador 2" SEVERITY error;
        -- verifica a direção (NOT '1' = '0'. '000' porque só o bit 2 importa)
        ASSERT s_descer = "000" 
            REPORT "Direcao incorreta" SEVERITY error;

        -- cenário 2: elevador 0 vence, chamada para descer no andar 5
        REPORT "CENARIO 2: elevador 0, descer no andar 5";
        s_chamada_ativa <= "00101"; -- andar 5
        s_direcao       <= '0';     -- 0 indica descida
        s_vencedor      <= "00";     -- elevador 0
        WAIT FOR 10 ns;
        -- verifica se o andar foi só para o elevador 0
        ASSERT s_solicite_0 = "00101" AND s_solicite_1 = "00000" AND s_solicite_2 = "00000"
            REPORT "Andar nao foi para o elevador 0" SEVERITY error;
        -- verifica a direção
        ASSERT s_descer = "100" 
            REPORT "Direcao incorreta" SEVERITY error;

        -- cenário 3: ninguém vence
        REPORT "CENARIO 3: ninguém vence";
        s_chamada_ativa <= "11111";
        s_direcao       <= '1';
        s_vencedor      <= "11"; -- inválido
        WAIT FOR 10 ns;
        -- verifica se nenhum elevador recebeu a chamada
        ASSERT s_solicite_0 = "00000" AND s_solicite_1 = "00000" AND s_solicite_2 = "00000"
            REPORT "Solicite nao esta zerado" SEVERITY error;

        REPORT "Teste do modulo Gerador de Saida concluido";
        WAIT;
    END PROCESS;

END ARCHITECTURE test;
