library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity det_andar is
    port (
             clk   : in STD_LOGIC;
             reset : in STD_LOGIC; -- '1' para resetar
             
             mov   : in STD_LOGIC_VECTOR(1 downto 0);

             fso   : out STD_LOGIC_VECTOR(4 downto 0) -- A sa�da do andar atual
         );
end det_andar;

architecture comportamental of det_andar is

    -- Este � o registrador interno que ARMAZENA o andar atual
    signal current_floor_reg : STD_LOGIC_VECTOR(4 downto 0) := (others => '0');

begin
    
    -- Processo s�ncrono padr�o (contador)
    p_andar : process(clk, reset) -- Lista de sensibilidade corrigida
        variable v_floor_int : integer range 0 to 31;
    begin
    
        -- 1. L�gica de Reset (ass�ncrono)
        if reset = '1' then
            current_floor_reg <= (others => '0'); -- Reseta para o andar 0
            
        -- 2. L�gica de Clock (S�ncrona)
        elsif rising_edge(clk) then
        
            -- Converte o valor ATUAL do registrador para um inteiro
            v_floor_int := to_integer(unsigned(current_floor_reg));
            
            case mov is
                -- Parado:
                when "00" =>
                    current_floor_reg <= current_floor_reg; -- Mant�m o valor atual

                -- Descendo:
                when "01" =>
                    if v_floor_int > 0 then -- Compara��o de inteiros
                        -- Calcula o novo valor e converte de volta para vetor
                        current_floor_reg <= std_logic_vector(to_unsigned(v_floor_int - 1, 5));
                    else
                        current_floor_reg <= current_floor_reg; -- J� est� no 0, n�o faz nada
                    end if;

                -- Subindo:
                when "10" => 
                    if v_floor_int < 31 then -- Compara��o de inteiros
                        -- Calcula o novo valor e converte de volta para vetor
                        current_floor_reg <= std_logic_vector(to_unsigned(v_floor_int + 1, 5));
                    else
                        current_floor_reg <= current_floor_reg; -- J� est� no 31, n�o faz nada
                    end if;
            
                -- Nunca deveria acontecer:
                when others =>
                    current_floor_reg <= current_floor_reg;
            end case;
            
        end if;
    end process p_andar;

    -- Conecta o registrador interno � porta de sa�da
    fso <= current_floor_reg;
    
end comportamental;