library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity tb_nivel_2 is
end tb_nivel_2;

architecture behavior of tb_nivel_2 is
    signal clk               : STD_LOGIC := '0';
    signal reset             : STD_LOGIC := '0';

    -- Inputs
    signal up_queue          : STD_LOGIC_VECTOR(4 downto 0);
    signal up_queue_en       : STD_LOGIC := '0';
    signal down_queue        : STD_LOGIC_VECTOR(4 downto 0);
    signal down_queue_en     : STD_LOGIC := '0';
    
    signal um_floor_sensor   : STD_LOGIC_VECTOR(4 downto 0);
    signal dois_floor_sensor : STD_LOGIC_VECTOR(4 downto 0);
    signal tres_floor_sensor : STD_LOGIC_VECTOR(4 downto 0);
    
    signal um_moving         : STD_LOGIC_VECTOR(1 downto 0);
    signal dois_moving       : STD_LOGIC_VECTOR(1 downto 0);
    signal tres_moving       : STD_LOGIC_VECTOR(1 downto 0);
    
    -- Outputs
    signal um_solicit_floor  : STD_LOGIC_VECTOR(4 downto 0);
    signal dois_solicit_floor: STD_LOGIC_VECTOR(4 downto 0);
    signal tres_solicit_floor: STD_LOGIC_VECTOR(4 downto 0);
    
    signal solicit_dir       : STD_LOGIC;
    signal solicit_en        : STD_LOGIC;
    
    component nivel_2
        port (
             -- Entradas de Controle e Sensor
                 clk   : in STD_LOGIC;
                 reset : in STD_LOGIC;
             -- Entradas:
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
                 solicit_dir : out STD_LOGIC;
                 -- Solicit_enable
                 solicit_en : out STD_LOGIC
         );   
    end component;
    signal sim_finished : BOOLEAN := false;

begin

    -- Instantiate the design under test (DUT)
    UUT: nivel_2
        port map (
            clk => clk,
            reset => reset,
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

    -- Geração de Clock
    clk_gen_proc : process
    begin
        while not sim_finished loop 
            clk <= '0';
            wait for 10 ns;
            clk <= '1';
            wait for 10 ns;
        end loop;
        wait;
    end process;

    -- Testes:
    stimulus: process
    begin
        -- Chamada Concorrente
        up_queue <= "01000";
        up_queue_en <= '1';
        down_queue <= "00010";
        down_queue_en <= '1';
        um_floor_sensor <= "11100";
        dois_floor_sensor <= "11100";
        tres_floor_sensor <= "11100";
        um_moving <= "01";
        dois_moving <= "00";
        tres_moving <= "10";

        wait for 20 ns;
        up_queue_en <= '0';
        down_queue_en <= '0';
        wait for 20 ns;

        wait for 20 ns;
        up_queue_en <= '0';
        down_queue_en <= '0';
        wait for 20 ns;

        wait for 20 ns;
        up_queue_en <= '0';
        down_queue_en <= '0';
        wait for 20 ns;

        sim_finished <= true;
        -- End of simulation
        wait;
    end process;

end behavior;
