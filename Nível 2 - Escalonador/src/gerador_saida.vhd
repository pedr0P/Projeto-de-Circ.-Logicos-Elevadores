library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity GERADOR_SAIDA is
    port (
        -- entradas
        ENABLE                : in std_logic;
        CHAMADA_ATIVA_IN      : in  std_logic_vector(4 downto 0);
        DIRECAO_IN            : in  std_logic; -- 1 indica subir, 0 indica descer
        ELEVADOR_VENCEDOR_IN  : in  std_logic_vector(1 downto 0);
        
        -- saídas para os controladores locais
        SOLICITE_0_OUT        : out std_logic_vector(4 downto 0);
        SOLICITE_1_OUT        : out std_logic_vector(4 downto 0);
        SOLICITE_2_OUT        : out std_logic_vector(4 downto 0);
        DESCER_OUT            : out std_logic_vector(0 to 2);
        SOLICIT_ENABLE_OUT    : out std_logic
    );
end entity GERADOR_SAIDA;

architecture COMPORTAMENTAL of GERADOR_SAIDA is
begin

    -- processo combinacional que roteia as saídas
    process (CHAMADA_ATIVA_IN, DIRECAO_IN, ELEVADOR_VENCEDOR_IN)
    begin

        -- definição valores padrão
        -- por padrão, ninguém recebe a chamada.
        SOLICITE_0_OUT <= (others => '0');
        SOLICITE_1_OUT <= (others => '0');
        SOLICITE_2_OUT <= (others => '0');
        DESCER_OUT     <= "000";
        SOLICIT_ENABLE_OUT <= '0';

        if ENABLE = '1' then

        -- roteamento da chamada baseado no vencedor
            case ELEVADOR_VENCEDOR_IN is

                when "00" => -- elevador 0 venceu
                    SOLICITE_0_OUT <= CHAMADA_ATIVA_IN; -- manda o andar para o elevador 0
                    DESCER_OUT(0)  <= not DIRECAO_IN;   -- quando direcao_in for (subida), retorna 0
                    SOLICIT_ENABLE_OUT <= '1';

                when "01" => -- elevador 1 venceu
                    SOLICITE_1_OUT <= CHAMADA_ATIVA_IN;
                    DESCER_OUT(1)  <= not DIRECAO_IN;
                    SOLICIT_ENABLE_OUT <= '1';

                when "10" => -- elevador 2 venceu
                    SOLICITE_2_OUT <= CHAMADA_ATIVA_IN;
                    DESCER_OUT(2)  <= not DIRECAO_IN;
                    SOLICIT_ENABLE_OUT <= '1';

                when others => -- valores inválidos
                               -- nenhum comando é enviado e os valores padrão são usados
                    null; 

            end case;
        end if;
    end process;

end architecture COMPORTAMENTAL;
