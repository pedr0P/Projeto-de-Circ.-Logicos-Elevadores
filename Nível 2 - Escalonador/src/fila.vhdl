library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Como funciona:
-- Adicione pelo data_in e wr_en = '1' (Se não estiver cheio)
-- Leia pelo data_out e rd_en = '1' (Se não estiver vazio)
entity fila is
    port (
             clk        : in STD_LOGIC;
             reset      : in STD_LOGIC;

             -- Up section
             up_queue   : in STD_LOGIC_VECTOR(4 downto 0);
             up_wr_en   : in STD_LOGIC;

             -- Down section
             down_queue : in STD_LOGIC_VECTOR(4 downto 0);
             down_wr_en : in STD_LOGIC;

             data_out : out STD_LOGIC_VECTOR(4 downto 0);
             data_dir : out STD_LOGIC
         );
end fila;

architecture rtl of fila is

    type ARR is array (0 to 31) of STD_LOGIC_VECTOR(4 downto 0);
    signal up_fila     : ARR;
    signal down_fila   : ARR;

    signal down_rd_ptr, down_wr_ptr : UNSIGNED(4 downto 0) := (others => '0');
    signal up_rd_ptr, up_wr_ptr : UNSIGNED(4 downto 0) := (others => '0');

    signal up_qnt      : UNSIGNED(4 downto 0) := (others => '0');
    signal down_qnt    : UNSIGNED(4 downto 0) := (others => '0');

    signal last_dir    : STD_LOGIC := '1';

begin
    process(clk)
    begin
        if rising_edge(clk) then
            if reset = '1' then
                up_wr_ptr <= (others => '0');
                up_rd_ptr <= (others => '0');
                down_wr_ptr <= (others => '0');
                down_rd_ptr <= (others => '0');
                data_out <= (others => '0');
            end if;

            -- Stop transmitting when not being read.
            data_out <= "00000";

            -- Write
            if (down_wr_en = '1' and down_qnt /= "11111") then
                down_fila(to_integer(down_wr_ptr)) <= down_queue;
                down_wr_ptr <= down_wr_ptr + 1;
                down_qnt <= down_qnt + 1;
            end if;
            -- Write
            if (up_wr_en = '1' and up_qnt /= "11111") then
                up_fila(to_integer(up_wr_ptr)) <= up_queue;
                up_wr_ptr <= up_wr_ptr + 1;
                up_qnt <= up_qnt + 1;
            end if;

        else if falling_edge(clk) then
            -- Always invert, using the opposite direction from last time;
            case last_dir is
                when '1' => 
                    -- Read
                    if (down_qnt /= "00000") then
                        down_rd_ptr <= down_rd_ptr + 1;
                        down_qnt <= down_qnt - 1;

                        data_out <= down_fila(to_integer(down_rd_ptr));
                        data_dir <= '0';
                    else if (up_qnt /= "00000") then
                        up_rd_ptr <= up_rd_ptr + 1;
                        data_out <= up_fila(to_integer(up_rd_ptr));
                        up_qnt <= up_qnt - 1; end if;
                        data_dir <= '1';
                    end if;
                    last_dir <= '0';
                when '0' =>
                    -- Read
                    if (up_qnt /= "00000") then
                        up_rd_ptr <= up_rd_ptr + 1;
                        data_out <= up_fila(to_integer(up_rd_ptr));
                        up_qnt <= up_qnt - 1;
                        data_dir <= '1';
                    else if (down_qnt /= "00000") then
                        down_rd_ptr <= down_rd_ptr + 1;
                        down_qnt <= down_qnt - 1;

                        data_out <= down_fila(to_integer(down_rd_ptr)); end if;
                        data_dir <= '0';
                    end if;
                    last_dir <= '1';
                when others => -- Do nothing..
            end case;
        end if;
    end if;
    end process;

    -- up_wempty <= '1' when up_rd_ptr = up_wr_ptr else '0';
    -- up_wfull  <= '1' when up_qnt = 31 else '0';
    --
    -- down_wempty <= '1' when down_rd_ptr = down_wr_ptr else '0';
    -- down_wfull  <= '1' when down_qnt = 31 else '0';
    --
    -- up_full <=  up_wfull;     down_full <= down_wfull;
    -- up_empty <= up_wempty;     down_empty <= down_wempty;

end rtl;
