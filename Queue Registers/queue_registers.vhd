library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity queue_registers is
    generic (w : natural := 32);
    port (
        -- Sinais de Controle
        signal clk   : in STD_LOGIC;
        signal reset : in STD_LOGIC; -- '1' para resetar

        signal new_requests_up   : in STD_LOGIC_VECTOR(w-1 downto 0);
        signal new_requests_down : in STD_LOGIC_VECTOR(w-1 downto 0);

        signal clear_command : in STD_LOGIC; -- '1' para limpar o andar atual
        signal current_floor : in STD_LOGIC_VECTOR(4 downto 0); -- O andar a ser limpo

        signal queue_up   : out STD_LOGIC_VECTOR(w-1 downto 0);
        signal queue_down : out STD_LOGIC_VECTOR(w-1 downto 0)
    );
end queue_registers;

architecture comportamental of queue_registers is
    signal s_queue_up   : STD_LOGIC_VECTOR(w-1 downto 0) := (others => '0');
    signal s_queue_down : STD_LOGIC_VECTOR(w-1 downto 0) := (others => '0');
    
    signal s_clear_mask : STD_LOGIC_VECTOR(w-1 downto 0);
    
begin

    -- Lógica Combinacional: Cria uma máscara de "NÃO LIMPE"
    -- que só tem um '0' no andar atual, e apenas se o comando 'clear' estiver ativo.
    s_clear_mask <= (others => '1'); -- Padrão: não limpa nada
    s_clear_mask(to_integer(unsigned(current_floor))) <= NOT clear_command; -- Se clear='1', máscara vira '0' no andar

    process(clk, reset)
    begin
        if reset = '1' then
            s_queue_up   <= (others => '0');
            s_queue_down <= (others => '0');
            
        elsif rising_edge(clk) then
        
            -- LÓGICA PRINCIPAL:
            -- 1. Pega o valor antigo (s_queue_up)
            -- 2. Adiciona (OR) qualquer nova chamada (new_requests_up_i)
            -- 3. Remove (AND) qualquer chamada a ser limpa (s_clear_mask)
            
            s_queue_up <= (s_queue_up OR new_requests_up) AND s_clear_mask;
            s_queue_down <= (s_queue_down OR new_requests_down) AND s_clear_mask;
            
        end if;
    end process;
    
    queue_up   <= s_queue_up;
    queue_down <= s_queue_down;

end comportamental;