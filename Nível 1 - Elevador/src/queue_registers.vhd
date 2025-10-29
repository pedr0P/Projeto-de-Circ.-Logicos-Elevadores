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

    Generate_Clear_Mask_Proc : process(current_floor, clear_command)
        variable v_clear_floor_int : integer range 0 to w-1;
    begin
        -- 1. Começa com a máscara padrão (não limpa nada)
        s_clear_mask <= (others => '1'); 
        
        -- 2. Se o comando de limpar estiver ativo...
        if clear_command = '1' then
            -- ...calcula o índice do andar a ser limpo...
            v_clear_floor_int := to_integer(unsigned(current_floor));
            -- ...e define o bit correspondente da máscara para '0'.
            s_clear_mask(v_clear_floor_int) <= '0'; 
        end if;
        -- (Se clear_command = '0', a máscara permanece toda em '1')
    end process Generate_Clear_Mask_Proc;

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