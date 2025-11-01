library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_nivel_2 is
    end tb_nivel_2;

architecture behavior of tb_nivel_2 is
    -- Entradas de Controle e Sensor
    signal clk   : STD_LOGIC;
    signal reset : STD_LOGIC;
    -- Entradas:
    -- Dest_request:
    signal um_destino : STD_LOGIC_VECTOR(4 downto 0);
    signal dois_destino : STD_LOGIC_VECTOR(4 downto 0);
    signal tres_destino : STD_LOGIC_VECTOR(4 downto 0);
    -- Queues:
    signal up_queue : STD_LOGIC_VECTOR(4 downto 0);
    signal up_queue_en : STD_LOGIC;
    signal down_queue : STD_LOGIC_VECTOR(4 downto 0);
    signal down_queue_en : STD_LOGIC;
    -- Floor_sensor:
    signal um_floor_sensor: STD_LOGIC_VECTOR(4 downto 0);
    signal dois_floor_sensor: STD_LOGIC_VECTOR(4 downto 0);
    signal tres_floor_sensor: STD_LOGIC_VECTOR(4 downto 0);
    -- Moving:
    signal um_moving : STD_LOGIC_VECTOR(1 downto 0);
    signal dois_moving : STD_LOGIC_VECTOR(1 downto 0);
    signal tres_moving : STD_LOGIC_VECTOR(1 downto 0);
    -- Saídas
    -- Solicit_floor
    signal um_solicit_floor : STD_LOGIC_VECTOR(4 downto 0);
    signal dois_solicit_floor : STD_LOGIC_VECTOR(4 downto 0);
    signal tres_solicit_floor : STD_LOGIC_VECTOR(4 downto 0);
    -- Solicit_dir
    signal solicit_dir : STD_LOGIC_VECTOR(2 downto 0);
    -- Solicit_enable
    signal solicit_en : STD_LOGIC;

    component nivel_2
        port (
             -- Entradas de Controle e Sensor
                 clk   : in STD_LOGIC;
                 reset : in STD_LOGIC;
             -- Entradas:
                 -- Dest_request:
                 um_destino : in STD_LOGIC_VECTOR(4 downto 0);
                 dois_destino : in STD_LOGIC_VECTOR(4 downto 0);
                 tres_destino : in STD_LOGIC_VECTOR(4 downto 0);
                 -- Queues:
                 up_queue : in STD_LOGIC_VECTOR(4 downto 0);
                 up_queue_en : in STD_LOGIC;
                 down_queue : in STD_LOGIC_VECTOR(4 downto 0);
                 down_queue_en : in STD_LOGIC;
                 -- Floor_sensor:
                 um_floor_sensor: in STD_LOGIC_VECTOR(4 downto 0);
                 dois_floor_sensor: in STD_LOGIC_VECTOR(4 downto 0);
                 tres_floor_sensor: in STD_LOGIC_VECTOR(4 downto 0);
                 -- Moving:
                 um_moving : in STD_LOGIC_VECTOR(1 downto 0);
                 dois_moving : in STD_LOGIC_VECTOR(1 downto 0);
                 tres_moving : in STD_LOGIC_VECTOR(1 downto 0);
             -- Saídas
                 -- Solicit_floor
                 um_solicit_floor : out STD_LOGIC_VECTOR(4 downto 0);
                 dois_solicit_floor : out STD_LOGIC_VECTOR(4 downto 0);
                 tres_solicit_floor : out STD_LOGIC_VECTOR(4 downto 0);
                 -- Solicit_dir
                 solicit_dir : out STD_LOGIC_VECTOR(2 downto 0);
                 -- Solicit_enable
                 solicit_en : out STD_LOGIC
         );   
    end component;
    
begin
    UUT : nivel_2
     port map(
        clk => clk,
        reset => reset,
        um_destino => um_destino,
        dois_destino => dois_destino,
        tres_destino => tres_destino,
        up_queue => up_queue,
        up_queue_en => up_queue_en,
        down_queue => down_queue,
        down_queue_en => down_queue_en,
        um_floor_sensor => um_floor_sensor,
        dois_floor_sensor => dois_floor_sensor,
        tres_floor_sensor => tres_floor_sensor,
        um_moving => um_moving,
        dois_moving => dois_moving,
        tres_moving => tres_moving,
        um_solicit_floor => um_solicit_floor,
        dois_solicit_floor => dois_solicit_floor,
        tres_solicit_floor => tres_solicit_floor,
        solicit_dir => solicit_dir,
        solicit_en => solicit_en
    );
    stimulus: process is
    begin
        um_floor_sensor <= std_logic_vector(to_unsigned(0, 5));
        um_moving <= "10";
        dois_floor_sensor <= std_logic_vector(to_unsigned(0, 5));
        dois_moving <= "00";
        tres_floor_sensor <= std_logic_vector(to_unsigned(27, 5));
        tres_moving <= "00";

        clk <= '0'; wait for 10 ns; clk <= '1';
        up_queue <= std_logic_vector(to_unsigned(30, 5)); up_queue_en <= '1';
        -- down_queue <= std_logic_vector(to_unsigned(27, 5)); down_queue_en <= '1';
        wait for 10 ns;

        clk <= '0'; wait for 10 ns; clk <= '1';
        up_queue_en <= '0'; down_queue_en <= '0';
        wait for 10 ns;

        clk <= '0'; wait for 10 ns; clk <= '1'; wait for 10 ns;
        clk <= '0'; wait for 10 ns; clk <= '1'; wait for 10 ns;

        wait;
    end process;
end behavior;
