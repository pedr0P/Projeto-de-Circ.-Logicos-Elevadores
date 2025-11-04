library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Como funciona:
-- Adicione pelo data_in e wr_en = '1' (Se não estiver cheio)
-- Leia pelo data_out e rd_en = '1' (Se não estiver vazio)
entity call_disp is
    port ( 
           clk        : in STD_LOGIC := '0';

           data_in    : in STD_LOGIC_VECTOR(4 downto 0) := (others => '0'); -- Get from data_out
           data_dir   : in STD_LOGIC := '0'; -- Get from data_dir

           cham_ativa : out STD_LOGIC_VECTOR(4 downto 0) := (others => '0'); -- Pedido para algum elevador atender:
           direction  : out STD_LOGIC := '0' -- Get from data_direction
       );
end call_disp;

architecture rtl of call_disp is
    signal data_en     : STD_LOGIC := '0';
begin
    data_en <= '0' when (data_in = "00000") else '1';

    process(clk)
    begin
        if rising_edge(clk) then
            if data_en = '1' then
                cham_ativa <= data_in;
                direction <= data_dir;
            else if data_en = '0' then
                cham_ativa <= (others => '0'); end if;
            end if;
        end if;
    end process;
end rtl;

