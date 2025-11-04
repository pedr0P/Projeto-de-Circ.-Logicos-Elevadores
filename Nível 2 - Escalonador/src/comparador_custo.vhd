LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY comparador_custo IS
    PORT (
        -- UMA ENTRADA PARA CADA ELEVADOR
        distancia_0_in      : IN  STD_LOGIC_VECTOR(4 DOWNTO 0) := (others => '0');
        distancia_1_in      : IN  STD_LOGIC_VECTOR(4 DOWNTO 0) := (others => '0');
        distancia_2_in      : IN  STD_LOGIC_VECTOR(4 DOWNTO 0) := (others => '0');
        
        custo_elev_0_in : IN  STD_LOGIC_VECTOR(1 DOWNTO 0) := (others => '0');
        custo_elev_1_in : IN  STD_LOGIC_VECTOR(1 DOWNTO 0) := (others => '0');
        custo_elev_2_in : IN  STD_LOGIC_VECTOR(1 DOWNTO 0) := (others => '0');
        
        -- SAÍDA: ÍNDICE DO ELEVADOR COM MENOR CUSTO
        elevador_vencedor_out : OUT STD_LOGIC_VECTOR(1 DOWNTO 0) := (others => '0') -- "00", "01" ou "10"
    );
END ENTITY comparador_custo;

ARCHITECTURE comportamental OF comparador_custo IS
BEGIN

    -- PROCESSO PURAMENTE COMBINACIONAL QUE REAGE A QUALQUER MUDANÇA NAS ENTRADAS
    PROCESS (distancia_0_in, distancia_1_in, distancia_2_in, 
             custo_elev_0_in, custo_elev_1_in, custo_elev_2_in)
             
        -- VARIÁVEIS LOCAIS PARA O CUSTO TOTAL
        VARIABLE custo_total_0 : STD_LOGIC_VECTOR(6 DOWNTO 0);
        VARIABLE custo_total_1 : STD_LOGIC_VECTOR(6 DOWNTO 0);
        VARIABLE custo_total_2 : STD_LOGIC_VECTOR(6 DOWNTO 0);
    BEGIN
        
        -- CALCULA O CUSTO TOTAL PARA CADA ELEVADOR E CONCATENA O CUSTO DE STATUS COM A DISTÂNCIA
        -- O CUSTO DE STATUS É MAIS IMPORTANTE, POR ISSO VEM PRIMEIRO
        custo_total_0 := custo_elev_0_in & distancia_0_in;
        custo_total_1 := custo_elev_1_in & distancia_1_in;
        custo_total_2 := custo_elev_2_in & distancia_2_in;

        -- COMPARA OS CUSTOS TOTAIS E ACHA O MENOR
        -- DÁ PRIORIDADE AO ELEVADOR 0 EM CASO DE EMPATE
        IF (custo_total_0 <= custo_total_1 AND custo_total_0 <= custo_total_2) THEN
            elevador_vencedor_out <= "00"; -- ELEVADOR 0 VENCE
            
        ELSIF (custo_total_1 <= custo_total_0 AND custo_total_1 <= custo_total_2) THEN
            elevador_vencedor_out <= "01"; -- ELEVADOR 1 VENCE
            
        ELSE
            elevador_vencedor_out <= "10"; -- ELEVADOR 2 VENCE
        END IF;

    END PROCESS;

END ARCHITECTURE comportamental;
