library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity nivel_2 is
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
end nivel_2;

architecture estrutural of nivel_2 is
    -- DECLARAÇÃO DOS COMPONENTES
    -- FILA:
    component fila is
        port (
             clk        : in STD_LOGIC;
             reset      : in STD_LOGIC;
             -- Up section
                -- in:
                 -- 000up_queue
                        up_queue   : in STD_LOGIC_VECTOR(4 downto 0);
                 -- 000up_queue_en
                        up_wr_en   : in STD_LOGIC;
                -- out:
             -- Down section
                -- in:
                 -- 000down_queue
                        down_queue : in STD_LOGIC_VECTOR(4 downto 0);
                 -- 000down_queue_en
                        down_wr_en : in STD_LOGIC;
                -- out:
             -- Data section: (For the call Dispatcher)
                 data_out : out STD_LOGIC_VECTOR(4 downto 0);
                 data_dir : out STD_LOGIC
             );
    end component;
    signal data_out : STD_LOGIC_VECTOR(4 downto 0); signal data_dir : STD_LOGIC;
    -- Call Dispatcher:
    component call_disp
        port (
                 clk        : in STD_LOGIC;
             -- In:
                 -- 00data_out
                        data_in    : in STD_LOGIC_VECTOR(4 downto 0); -- Get from data_out
                 -- 00data_dir
                        data_dir : in STD_LOGIC;
             -- Out:
                 cham_ativa : out STD_LOGIC_VECTOR(4 downto 0); -- Pedido para algum elevador atender:
                 direction  : out STD_LOGIC -- Get from data_direction
             );
    end component;
    signal cham_ativa : STD_LOGIC_VECTOR(4 downto 0); signal direction  : STD_LOGIC;
    -- Cost_calculator:
    component Cost_calculator is
        port (
                 -- 00cham_ativa
                     call_floor : in STD_LOGIC_VECTOR(4 downto 0);
                 -- 00data_dir
                     direction : in STD_LOGIC;                          -- 1 para subir e 0 para descer
                 -- 00one_floor_sensor or 00two_floor_sensor or 00tres_floor_sensor
                     floor_sensor : in STD_LOGIC_VECTOR(4 downto 0);
                 -- 00one_moving or 00two_moving or 00tres_moving
                     moving : in STD_LOGIC_VECTOR(1 downto 0);          -- 00 - parado, 10 - subindo, 01 - descendo
                 enable : out STD_LOGIC;
                 elevator_cost : out STD_LOGIC_VECTOR(1 downto 0)   -- 00 (melhor), 01 (bom), 10 (ruim), 11 (inválido)
             );
    end component;
    signal um_elevator_cost : STD_LOGIC_VECTOR(1 downto 0); signal dois_elevator_cost : STD_LOGIC_VECTOR(1 downto 0); signal tres_elevator_cost : STD_LOGIC_VECTOR(1 downto 0); signal enable : STD_LOGIC;
    -- Custo_distância:
    component custo_distancia is
        port (
                 -- 00cham_ativa
                     chamada_ativa : in std_logic_vector(4 downto 0);
                 -- 00one_floor_sensor or 00two_floor_sensor or 00tres_floor_sensor
                 floor_sensor : in std_logic_vector(4 downto 0);
                 distancia : out std_logic_vector(4 downto 0)
             );
    end component;
    signal um_distancia : STD_LOGIC_VECTOR(4 downto 0); signal dois_distancia : STD_LOGIC_VECTOR(4 downto 0); signal tres_distancia : STD_LOGIC_VECTOR(4 downto 0);
    -- Comparador_custo:
    component comparador_custo is
        port (
        -- uma entrada para cada elevador
                 -- 00um_distancia
                     DISTANCIA_0_IN      : in  std_logic_vector(4 downto 0);
                 -- 00dois_distancia
                     DISTANCIA_1_IN      : in  std_logic_vector(4 downto 0);
                 -- 00tres_distancia
                     DISTANCIA_2_IN      : in  std_logic_vector(4 downto 0);

                 -- 00um_elevator_cost
                     CUSTO_ELEV_0_IN : in  std_logic_vector(1 downto 0);
                 -- 00dois_elevator_cost
                     CUSTO_ELEV_1_IN : in  std_logic_vector(1 downto 0);
                 -- 00tres_elevator_cost
                     CUSTO_ELEV_2_IN : in  std_logic_vector(1 downto 0);

                 -- saída: índice do elevador com menor custo
                 ELEVADOR_VENCEDOR_OUT : out std_logic_vector(1 downto 0) -- "00", "01" OU "10"
             );
    end component;
    signal ELEVADOR_VENCEDOR_OUT : std_logic_vector(1 downto 0);
    -- Gerador
    component gerador_saida is
        port (
                 -- entradas
                 -- 00enable
                     ENABLE                : in std_logic;
                 -- 00cham_ativa
                     CHAMADA_ATIVA_IN      : in  std_logic_vector(4 downto 0);
                 -- 00direction
                     DIRECAO_IN            : in  std_logic; -- 1 indica subir, 0 indica descer
                 ELEVADOR_VENCEDOR_IN  : in  std_logic_vector(1 downto 0);

                 -- saídas para os controladores locais
                 -- 00um_solicit_floor
                     SOLICITE_0_OUT        : out std_logic_vector(4 downto 0);
                 -- 00dois_solicit_floor
                     SOLICITE_1_OUT        : out std_logic_vector(4 downto 0);
                 -- 00tres_solicit_floor
                     SOLICITE_2_OUT        : out std_logic_vector(4 downto 0);
                 -- 00solicit_dir
                     DESCER_OUT            : out std_logic_vector(0 to 2);
                 -- 00solicit_en
                 SOLICIT_ENABLE_OUT    : out std_logic
             );
    end component;
begin
    -- INSTANCIAÇÃO DOS COMPONENTES (CONEXÃO DOS FIOS)
    U_Fila: fila
    port map(
                clk => clk,
                reset => reset,
                up_queue => up_queue,
                up_wr_en => up_queue_en,
                down_queue => down_queue,
                down_wr_en => down_queue_en,
                data_out => data_out,
                data_dir => data_dir
            );
    U_Call_Disp: call_disp
    port map(
                clk => clk,
                data_in => data_out,
                data_dir => data_dir,
                cham_ativa => cham_ativa,
                direction => direction
            );

    U_Cost_calculator_um: Cost_calculator
    port map(
                call_floor => cham_ativa,
                direction => direction,
                floor_sensor => um_floor_sensor,
                moving => um_moving,
                elevator_cost => um_elevator_cost,
                enable => enable
            );
    U_Cost_calculator_dois: Cost_calculator
    port map(
                call_floor => cham_ativa,
                direction => direction,
                floor_sensor => dois_floor_sensor,
                moving => dois_moving,
                elevator_cost => dois_elevator_cost,
                enable => enable
            );
    U_Cost_calculator_tres: Cost_calculator
    port map(
                call_floor => cham_ativa,
                direction => direction,
                floor_sensor => tres_floor_sensor,
                moving => tres_moving,
                elevator_cost => tres_elevator_cost,
                enable => enable
            );

    U_Custo_distancia_um: custo_distancia
    port map(
                chamada_ativa => cham_ativa,
                floor_sensor => um_floor_sensor,
                distancia => um_distancia
            );
    U_Custo_distancia_dois: custo_distancia
    port map(
                chamada_ativa => cham_ativa,
                floor_sensor => dois_floor_sensor,
                distancia => dois_distancia
            );
    U_Custo_distancia_tres: custo_distancia
    port map(
                chamada_ativa => cham_ativa,
                floor_sensor => tres_floor_sensor,
                distancia => tres_distancia
            );

    U_comparador_custo: comparador_custo
    port map(
                DISTANCIA_0_IN => um_distancia,
                DISTANCIA_1_IN => dois_distancia,
                DISTANCIA_2_IN => tres_distancia,
                CUSTO_ELEV_0_IN => um_elevator_cost,
                CUSTO_ELEV_1_IN => dois_elevator_cost,
                CUSTO_ELEV_2_IN => tres_elevator_cost,
                ELEVADOR_VENCEDOR_OUT => ELEVADOR_VENCEDOR_OUT
            );

    U_Gerador_saida: GERADOR_SAIDA
    port map(
                ENABLE => ENABLE,
                CHAMADA_ATIVA_IN => cham_ativa,
                DIRECAO_IN => direction,
                ELEVADOR_VENCEDOR_IN => ELEVADOR_VENCEDOR_OUT,
                SOLICITE_0_OUT => um_solicit_floor,
                SOLICITE_1_OUT => dois_solicit_floor,
                SOLICITE_2_OUT => tres_solicit_floor,
                DESCER_OUT => solicit_dir,
                SOLICIT_ENABLE_OUT => solicit_en
            );

end estrutural;
