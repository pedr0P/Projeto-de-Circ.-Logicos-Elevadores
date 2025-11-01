library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_filla is
    end tb_filla;

architecture behavior of tb_filla is
    signal clk        : STD_LOGIC;
    signal reset      : STD_LOGIC;
    signal data_out   : STD_LOGIC_VECTOR(4 downto 0);
    signal data_dir   : STD_LOGIC;

    -- Up section
    signal up_queue   : STD_LOGIC_VECTOR(4 downto 0);
    signal up_wr_en   : STD_LOGIC;
    signal up_empty   : STD_LOGIC;
    signal up_full    : STD_LOGIC;

    -- Down section
    signal down_queue : STD_LOGIC_VECTOR(4 downto 0);
    signal down_wr_en : STD_LOGIC;
    signal down_empty : STD_LOGIC;
    signal down_full  : STD_LOGIC;
    component fila
        port (
                 clk        : in STD_LOGIC;
                 reset      : in STD_LOGIC;
                 data_out   : out STD_LOGIC_VECTOR(4 downto 0);
                 data_dir   : out STD_LOGIC;

                 up_queue   : in STD_LOGIC_VECTOR(4 downto 0);
                 up_wr_en   : in STD_LOGIC;
                 up_empty   : out STD_LOGIC;
                 up_full    : out STD_LOGIC;

                 down_queue : in STD_LOGIC_VECTOR(4 downto 0);
                 down_wr_en : in STD_LOGIC;
                 down_empty : out STD_LOGIC;
                 down_full  : out STD_LOGIC
             );
    end component;
begin
    uut: fila
    port map(
                clk => clk,
                reset => reset,
                data_out => data_out,
                data_dir => data_dir,

                up_queue => up_queue,
                up_wr_en => up_wr_en,
                up_empty => up_empty,
                up_full => up_full,

                down_queue => down_queue,
                down_wr_en => down_wr_en,
                down_empty => down_empty,
                down_full => down_full
            );
    stimulus : process is
    begin
        clk <= '0'; wait for 10 ns;
        down_queue <= std_logic_vector(to_unsigned(7, 5));
        down_wr_en <= '1';
        up_queue <= std_logic_vector(to_unsigned(8, 5));
        up_wr_en <= '1';
        clk <= '1'; wait for 10 ns;

        clk <= '0'; wait for 10 ns;
        down_queue <= std_logic_vector(to_unsigned(22, 5));
        down_wr_en <= '1';
        up_queue <= std_logic_vector(to_unsigned(23, 5));
        up_wr_en <= '1';
        clk <= '1'; wait for 10 ns;

        clk <= '0'; wait for 10 ns;
        down_queue <= std_logic_vector(to_unsigned(25, 5));
        down_wr_en <= '1';
        up_queue <= std_logic_vector(to_unsigned(26, 5));
        up_wr_en <= '1';
        clk <= '1'; wait for 10 ns;

        clk <= '0'; wait for 10 ns; down_wr_en <= '0'; up_wr_en <= '0'; clk <= '1'; wait for 10 ns;
        clk <= '0'; wait for 10 ns; down_wr_en <= '0'; up_wr_en <= '0'; clk <= '1'; wait for 10 ns;
        clk <= '0'; wait for 10 ns; down_wr_en <= '0'; up_wr_en <= '0'; clk <= '1'; wait for 10 ns;
        clk <= '0'; wait for 10 ns; down_wr_en <= '0'; up_wr_en <= '0'; clk <= '1'; wait for 10 ns;
        clk <= '0'; wait for 10 ns; down_wr_en <= '0'; up_wr_en <= '0'; clk <= '1'; wait for 10 ns;
        clk <= '0'; wait for 10 ns; down_wr_en <= '0'; up_wr_en <= '0'; clk <= '1'; wait for 10 ns;
        wait;
    end process;
end behavior;

