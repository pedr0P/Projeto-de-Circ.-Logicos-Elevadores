library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_call_disp is
    end tb_call_disp;

architecture behavior of tb_call_disp is
    signal clk          : STD_LOGIC;
    signal reset        : STD_LOGIC;

    signal cham_ativa   : STD_LOGIC_VECTOR(4 downto 0); -- Pedido para algum elevador atender:
    signal cham_en      : STD_LOGIC;
    signal direction    : STD_LOGIC; -- Get from data_direction

    signal data_dir     : STD_LOGIC;
    signal data_out     : STD_LOGIC_VECTOR(4 downto 0);

    -- Up section
    signal up_queue     : STD_LOGIC_VECTOR(4 downto 0);
    signal up_rd_en     : STD_LOGIC;
    signal up_wr_en     : STD_LOGIC;
    signal up_empty     : STD_LOGIC;
    signal up_full      : STD_LOGIC;
    -- Down section
    signal down_queue   : STD_LOGIC_VECTOR(4 downto 0);
    signal down_rd_en   : STD_LOGIC;
    signal down_wr_en   : STD_LOGIC;
    signal down_empty   : STD_LOGIC;
    signal down_full    : STD_LOGIC;

    component call_disp
        port (
                 clk        : in STD_LOGIC;
                 cham_ativa : out STD_LOGIC_VECTOR(4 downto 0); -- Pedido para algum elevador atender:
                 cham_en    : out STD_LOGIC;
                 direction  : out STD_LOGIC; -- Get from data_direction

                 data_in    : in STD_LOGIC_VECTOR(4 downto 0); -- Get from data_out
                 data_dir   : in STD_LOGIC
             );
    end component;
    component fila is
        port (
                 clk        : in STD_LOGIC;
                 reset      : in STD_LOGIC;
                 -- Up section
                 up_queue   : in STD_LOGIC_VECTOR(4 downto 0);
                 up_rd_en   : in STD_LOGIC;
                 up_wr_en   : in STD_LOGIC;
                 up_empty   : out STD_LOGIC;
                 up_full    : out STD_LOGIC;
                 -- Down section
                 down_queue : in STD_LOGIC_VECTOR(4 downto 0);
                 down_rd_en : in STD_LOGIC;
                 down_wr_en : in STD_LOGIC;
                 down_empty : out STD_LOGIC;
                 down_full  : out STD_LOGIC;
                 -- Data
                 data_out   : out STD_LOGIC_VECTOR(4 downto 0);
                 data_dir   : out STD_LOGIC
             );
    end component;
begin
    uut: call_disp
    port map(
                clk => clk,
                cham_ativa => cham_ativa,
                cham_en => cham_en,
                direction => direction,
                data_in => data_out,
                data_dir => data_dir
            );
    au: fila
    port map(
                clk => clk,
                reset => reset,
                up_queue => up_queue,
                up_rd_en => up_rd_en,
                up_wr_en => up_wr_en,
                up_empty => up_empty,
                up_full => up_full,
                down_queue => down_queue,
                down_rd_en => down_rd_en,
                down_wr_en => down_wr_en,
                down_empty => down_empty,
                down_full => down_full,
                data_out => data_out,
                data_dir => data_dir
            );
    stimulus: process
    begin
        -- Write
        clk <= '0'; wait for 10 ns; clk <= '1';
        up_rd_en <= '0'; up_wr_en <= '1'; up_queue <= "00001";
        down_rd_en <= '0'; down_wr_en <= '0';
        wait for 10 ns;

        clk <= '0'; wait for 10 ns; clk <= '1';
        up_rd_en <= '0'; up_wr_en <= '0';
        down_rd_en <= '0'; down_wr_en <= '1'; down_queue <= "00010";
        wait for 10 ns;

        -- Read
        clk <= '0'; wait for 10 ns; clk <= '1';
        up_rd_en <= '1'; up_wr_en <= '0';
        down_rd_en <= '0'; down_wr_en <= '0';
        wait for 10 ns;

        clk <= '0'; wait for 10 ns; clk <= '1';
        up_rd_en <= '0'; up_wr_en <= '0';
        down_rd_en <= '1'; down_wr_en <= '0';
        wait for 10 ns;

        wait;
    end process;
end behavior;
