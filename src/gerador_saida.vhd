LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY gerador_saida IS
    PORT (
        -- entradas
        chamada_ativa_in      : IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
        direcao_in            : IN  STD_LOGIC; -- 1 indica subir, 0 indica descer
        elevador_vencedor_in  : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
        
        -- saídas para os controladores locais
        solicite_0_out        : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
        solicite_1_out        : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
        solicite_2_out        : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
        descer_out            : OUT STD_LOGIC_VECTOR(0 TO 2);
        solicit_enable_out    : OUT STD_LOGIC;
        
        -- saídas para os registradores de limpeza
        limpar_andar_out      : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
        limpar_direcao_out    : OUT STD_LOGIC;
        limpar_enable_out     : OUT STD_LOGIC
    );
END ENTITY gerador_saida;

ARCHITECTURE comportamental OF gerador_saida IS
BEGIN

    -- processo combinacional que roteia as saídas
    PROCESS (chamada_ativa_in, direcao_in, elevador_vencedor_in)
    BEGIN
        
        -- definição valores padrão
        -- por padrão, ninguém recebe a chamada.
        solicite_0_out <= (OTHERS => '0');
        solicite_1_out <= (OTHERS => '0');
        solicite_2_out <= (OTHERS => '0');
        descer_out     <= "000";
        solicit_enable_out <= '0';
        limpar_enable_out  <= '0';
        
        
        -- roteamento da chamada baseado no vencedor
        CASE elevador_vencedor_in IS
        
            WHEN "00" => -- elevador 0 venceu
                solicite_0_out <= chamada_ativa_in; -- manda o andar para o elevador 0
                descer_out(0)  <= NOT direcao_in;   -- quando direcao_in for (subida), retorna 0
                solicit_enable_out <= '1';
                limpar_enable_out  <= '1';

            WHEN "01" => -- elevador 1 venceu
                solicite_1_out <= chamada_ativa_in;
                descer_out(1)  <= NOT direcao_in;
                solicit_enable_out <= '1';
                limpar_enable_out  <= '1';

            WHEN "10" => -- elevador 2 venceu
                solicite_2_out <= chamada_ativa_in;
                descer_out(2)  <= NOT direcao_in;
                solicit_enable_out <= '1';
                limpar_enable_out  <= '1';
                
            WHEN OTHERS => -- valores inválidos
                -- nenhum comando é enviado e os valores padrão são usados
                NULL; 
                
        END CASE;

        -- definição das saídas de limpeza
        -- elas sempre passam a chamada ativa, mas os registradores só devem usá-las se limpar_enable_out for 1
        limpar_andar_out   <= chamada_ativa_in;
        limpar_direcao_out <= direcao_in;
        
    END PROCESS;

END ARCHITECTURE comportamental;