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
    clk_process : process
    begin
        clk <= '0';
        wait for 10 ns;
        clk <= '1';
        wait for 10 ns;
    end process;

    -- Testes:
    stimulus: process
    begin
        -- Reset inicial
        reset <= '1';
        wait for 10 ns;
        reset <= '0';

        -- Caso 1: Pedir subida no andar 2 (Quem deve ganhar é o elevador 1)
        up_queue <= "00010"; -- Andar 2 (subindo)
        up_queue_en <= '1';
        down_queue <= "00000";
        down_queue_en <= '0';
        um_floor_sensor <= "00010";   -- Elevador 1 está no andar 2
        dois_floor_sensor <= "00000"; -- Elevador 2 no andar 0
        tres_floor_sensor <= "00000"; -- Elevador 3 no andar 0
        um_moving <= "00";   -- Elevador 1 está parado
        dois_moving <= "00"; -- Elevador 2 está parado
        tres_moving <= "00"; -- Elevador 3 está parado

        wait for 20 ns;
        up_queue_en <= '0';
        down_queue_en <= '0';
        wait for 20 ns;
        
        -- Caso 2: Pedir
        -- Test case 2: Pedir descida no andar 10 (ganhador: elevador 3)
        up_queue <= "00000";
        up_queue_en <= '0';
        down_queue <= "01010"; -- Andar floor 10 (descendo)
        down_queue_en <= '1';
        um_floor_sensor <= "00001";   -- Elevador 1 está no andar 1
        dois_floor_sensor <= "00010"; -- Elevador 2 no andar 2
        tres_floor_sensor <= "01011"; -- Elevador 3 no andar 11
        um_moving <= "00";   -- Elevador 1 está parado
        dois_moving <= "10"; -- Elevador 2 está subindo
        tres_moving <= "01"; -- Elevador 3 está descendo

        wait for 20 ns;
        up_queue_en <= '0';
        down_queue_en <= '0';
        wait for 20 ns;

        -- Test case 3: Nenhum pedido (ganhador: ninguém)
        up_queue <= "00000";
        up_queue_en <= '0';
        down_queue <= "00000";
        down_queue_en <= '0';
        um_floor_sensor <= "00000";
        dois_floor_sensor <= "00000";
        tres_floor_sensor <= "00000";
        um_moving <= "00";
        dois_moving <= "00";
        tres_moving <= "00";

        wait for 20 ns;
        up_queue_en <= '0';
        down_queue_en <= '0';
        wait for 20 ns;

        -- Caso 3: Pedir subida no andar 10 e descida no andar 4. (ganhador:)
        up_queue <= "00010"; -- Andar 2 (subindo)
        up_queue_en <= '1';
        down_queue <= "00000";
        down_queue_en <= '0';
        um_floor_sensor <= "01001";   -- Elevador 1 está no andar 9
        dois_floor_sensor <= "00000"; -- Elevador 2 no andar 0
        tres_floor_sensor <= "00101"; -- Elevador 3 no andar 5
        um_moving <= "10";   -- Elevador 1 está subindo
        dois_moving <= "00"; -- Elevador 2 está parado
        tres_moving <= "01"; -- Elevador 3 está descendo

        wait for 20 ns;
        up_queue_en <= '0';
        down_queue_en <= '0';
        wait for 20 ns;

        -- End of simulation
        wait;
    end process;

end behavior;

