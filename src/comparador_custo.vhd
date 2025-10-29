LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY comparador_custo IS
    PORT (
        -- uma entrada para cada elevador
        distancia_0_in      : IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
        distancia_1_in      : IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
        distancia_2_in      : IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
        
        custo_elev_0_in : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
        custo_elev_1_in : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
        custo_elev_2_in : IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
        
        -- saída: índice do elevador com menor custo
        elevador_vencedor_out : OUT STD_LOGIC_VECTOR(1 DOWNTO 0) -- "00", "01" ou "10"
    );
END ENTITY comparador_custo;

ARCHITECTURE comportamental OF comparador_custo IS
BEGIN

    -- processo puramente combinacional que reage a qualquer mudança nas entradas
    PROCESS (distancia_0_in, distancia_1_in, distancia_2_in, 
             custo_elev_0_in, custo_elev_1_in, custo_elev_2_in)
             
        -- variáveis locais para o custo total
        VARIABLE custo_total_0 : STD_LOGIC_VECTOR(6 DOWNTO 0);
        VARIABLE custo_total_1 : STD_LOGIC_VECTOR(6 DOWNTO 0);
        VARIABLE custo_total_2 : STD_LOGIC_VECTOR(6 DOWNTO 0);
    BEGIN
        
        -- calcula o custo total para cada elevador e concatena o custo de status com a distância
        -- o custo de status é mais importante, por isso vem primeiro
        custo_total_0 := custo_elev_0_in & distancia_0_in;
        custo_total_1 := custo_elev_1_in & distancia_1_in;
        custo_total_2 := custo_elev_2_in & distancia_2_in;

        -- compara os custos totais e acha o menor
        -- dá prioridade ao elevador 0 em caso de empate
        IF (custo_total_0 <= custo_total_1 AND custo_total_0 <= custo_total_2) THEN
            elevador_vencedor_out <= "00"; -- elevador 0 vence
            
        ELSIF (custo_total_1 <= custo_total_0 AND custo_total_1 <= custo_total_2) THEN
            elevador_vencedor_out <= "01"; -- elevador 1 vence
            
        ELSE
            elevador_vencedor_out <= "10"; -- elevador 2 vence
        END IF;

    END PROCESS;

END ARCHITECTURE comportamental;