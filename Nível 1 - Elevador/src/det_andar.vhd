library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity det_andar is
    port (
             clk   : in STD_LOGIC;
             reset : in STD_LOGIC; -- '1' para resetar
             
             mov   : in STD_LOGIC_VECTOR(1 downto 0);

             fso   : out STD_LOGIC_VECTOR(4 downto 0) -- A saída do andar atual
         );
end det_andar;

architecture comportamental of det_andar is

    -- Este é o registrador interno que ARMAZENA o andar atual
    signal current_floor_reg : STD_LOGIC_VECTOR(4 downto 0) := (others => '0');

begin
    
    -- Processo síncrono padrão (contador)
    p_andar : process(clk, reset) -- Lista de sensibilidade corrigida
        variable v_floor_int : integer range 0 to 31;
    begin
    
        -- 1. Lógica de Reset (assíncrono)
        if reset = '1' then
            current_floor_reg <= (others => '0'); -- Reseta para o andar 0
            
        -- 2. Lógica de Clock (Síncrona)
        elsif rising_edge(clk) then
        
            -- Converte o valor ATUAL do registrador para um inteiro
            v_floor_int := to_integer(unsigned(current_floor_reg));
            
            case mov is
                -- Parado:
                when "00" =>
                    current_floor_reg <= current_floor_reg; -- Mantém o valor atual

                -- Descendo:
                when "01" =>
                    if v_floor_int > 0 then -- Comparação de inteiros
                        -- Calcula o novo valor e converte de volta para vetor
                        current_floor_reg <= std_logic_vector(to_unsigned(v_floor_int - 1, 5));
                    else
                        current_floor_reg <= current_floor_reg; -- Já está no 0, não faz nada
                    end if;

                -- Subindo:
                when "10" => 
                    if v_floor_int < 31 then -- Comparação de inteiros
                        -- Calcula o novo valor e converte de volta para vetor
                        current_floor_reg <= std_logic_vector(to_unsigned(v_floor_int + 1, 5));
                    else
                        current_floor_reg <= current_floor_reg; -- Já está no 31, não faz nada
                    end if;
            
                -- Nunca deveria acontecer:
                when others =>
                    current_floor_reg <= current_floor_reg;
            end case;
            
        end if;
    end process p_andar;

    -- Conecta o registrador interno à porta de saída
    fso <= current_floor_reg;
    
end comportamental;