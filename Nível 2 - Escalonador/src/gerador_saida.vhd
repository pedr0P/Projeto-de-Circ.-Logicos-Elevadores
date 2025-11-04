library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity gerador_saida is
    port (
             clk : in std_logic;
             -- entradas
             ENABLE                : in std_logic := '0';
             CHAMADA_ATIVA_IN      : in  std_logic_vector(4 downto 0) := (others => '0');
             DIRECAO_IN            : in  std_logic := '0'; -- 1 indica subir, 0 indica descer
             ELEVADOR_VENCEDOR_IN  : in  std_logic_vector(1 downto 0) := (others => '0');

             -- saídas para os controladores locais
             SOLICITE_0_OUT        : out std_logic_vector(4 downto 0) := (others => '0');
             SOLICITE_1_OUT        : out std_logic_vector(4 downto 0) := (others => '0');
             SOLICITE_2_OUT        : out std_logic_vector(4 downto 0) := (others => '0');
             DESCER_OUT            : out std_logic := '0';
             SOLICIT_ENABLE_OUT    : out std_logic := '0'
         );
end entity gerador_saida;

architecture COMPORTAMENTAL of gerador_saida is
begin

    -- processo combinacional que roteia as saídas
    process (clk)
    begin
        if rising_edge(clk) then
            if ENABLE = '1' then
                -- roteamento da chamada baseado no vencedor
                case ELEVADOR_VENCEDOR_IN is

                    when "00" => -- elevador 0 venceu
                        SOLICITE_0_OUT <= CHAMADA_ATIVA_IN; -- manda o andar para o elevador 0
                        SOLICITE_1_OUT <= (others => '0');
                        SOLICITE_2_OUT <= (others => '0');
                        DESCER_OUT  <= DIRECAO_IN;
                        SOLICIT_ENABLE_OUT <= '1';

                    when "01" => -- elevador 1 venceu
                        SOLICITE_0_OUT <= (others => '0');
                        SOLICITE_1_OUT <= CHAMADA_ATIVA_IN;
                        SOLICITE_2_OUT <= (others => '0');
                        DESCER_OUT  <= DIRECAO_IN;
                        SOLICIT_ENABLE_OUT <= '1';

                    when "10" => -- elevador 2 venceu
                        SOLICITE_0_OUT <= (others => '0');
                        SOLICITE_1_OUT <= (others => '0');
                        SOLICITE_2_OUT <= CHAMADA_ATIVA_IN;
                        DESCER_OUT  <= DIRECAO_IN;
                        SOLICIT_ENABLE_OUT <= '1';

                    when others => -- valores inválidos
                                   -- nenhum comando é enviado e os valores padrão são usados

                end case;
            else
                -- definição valores padrão
                -- por padrão, ninguém recebe a chamada.
                SOLICITE_0_OUT <= (others => '0');
                SOLICITE_1_OUT <= (others => '0');
                SOLICITE_2_OUT <= (others => '0');
                SOLICIT_ENABLE_OUT <= '0';
            end if;
        end if;
    end process;

end architecture COMPORTAMENTAL;
