library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity nivel_1_elevador is
    generic (w : natural := 32);
    port (
        -- Entradas de Controle e Sensor
        signal clk   : in STD_LOGIC;
        signal reset : in STD_LOGIC;
        
        -- Entradas de Chamadas
        signal dest_request : in STD_LOGIC_VECTOR(w-1 downto 0);     -- Botões internos
        signal solicit_enable : in STD_LOGIC;                      -- Do Escalonador
        signal solicit_floor : in STD_LOGIC_VECTOR(4 downto 0);     -- Do Escalonador
        signal solicit_dir : in STD_LOGIC;                          -- Do Escalonador
        
        -- Saídas
        signal seg7_D0: out STD_LOGIC_VECTOR(6 downto 0);    
        signal seg7_D1: out STD_LOGIC_VECTOR(6 downto 0);    
        signal door_open_closed : out STD_LOGIC;
        signal moving : out STD_LOGIC_VECTOR(1 downto 0);
        signal o_floor_sensor : out STD_LOGIC_VECTOR(4 downto 0)
    );   
end nivel_1_elevador;

architecture estrutural of nivel_1_elevador is
    -- DECLARAÇÃO DOS COMPONENTES
    component det_andar is
        port (
            clk   : in STD_LOGIC;
            reset : in STD_LOGIC;

            mov : in STD_LOGIC_VECTOR(1 downto 0);
            fso : out STD_LOGIC_VECTOR(4 downto 0)
        );
    end component;

    component displays is
        port (
            floor_sensor : in  STD_LOGIC_VECTOR(4 downto 0); -- entrada do sensor de andar (0 - 31)
            seg7_D0      : out STD_LOGIC_VECTOR(6 downto 0); -- saída da unidade
            seg7_D1      : out STD_LOGIC_VECTOR(6 downto 0)  -- saida da dezena
        );
    end component;

    component door is
        port (
            signal moving           : in  STD_LOGIC_VECTOR(1 downto 0);
            signal door_open_closed : out STD_LOGIC                     
        );
    end component;

    component floor_controller is
        generic (w : natural := 32);
        port (
            signal floor_sensor : in STD_LOGIC_VECTOR(4 downto 0);     -- data inputs
            signal dest_request : in STD_LOGIC_VECTOR(w-1 downto 0);     -- data inputs
            
            signal solicit_enable : in STD_LOGIC;
            signal solicit_floor : in STD_LOGIC_VECTOR(4 downto 0);     -- selector
            signal solicit_dir : in STD_LOGIC;                          -- 1 para subir e 0 para descer
            
            signal queue_down : out STD_LOGIC_VECTOR(w-1 downto 0);
            signal queue_up : out STD_LOGIC_VECTOR(w-1 downto 0)
        );   
    end component;

    component queue_registers is
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
    end component;

    component elevator_controller is
        generic (w : natural := 32);
        port (
            signal clk   : in STD_LOGIC;
            signal reset : in STD_LOGIC; -- '1' para resetar

            signal floor_sensor : in STD_LOGIC_VECTOR(4 downto 0);     -- data inputs
            signal queue_up : in STD_LOGIC_VECTOR(w-1 downto 0);
            signal queue_down : in STD_LOGIC_VECTOR(w-1 downto 0);

            signal move_up : out STD_LOGIC;    
            signal move_down : out STD_LOGIC;
            signal motor_enable : out STD_LOGIC;
            signal brake : out STD_LOGIC;

            signal clear_command : out STD_LOGIC;
            signal current_floor : out STD_LOGIC_VECTOR(4 downto 0)
        );   
    end component;

    component motor is
        port (
            -- Entradas
            move_up : in std_logic; -- subir
            move_down : in std_logic; -- descer
            motor_enable : in std_logic; -- motor parado ou nao
            brake : in std_logic; -- freio (redundante, mas bom para fins de clareza)

            -- SaÃ­da
            moving : out std_logic_vector (1 downto 0) -- 00 parado, 01 descendo, 10 subindo
        );
    end component;

    -- SINAIS INTERNOS (FIOS)

    signal s_floor_sensor : STD_LOGIC_VECTOR(4 downto 0);

    signal s_new_requests_up   : STD_LOGIC_VECTOR(w-1 downto 0);
    signal s_new_requests_down : STD_LOGIC_VECTOR(w-1 downto 0);

    signal s_queue_up   : STD_LOGIC_VECTOR(w-1 downto 0);
    signal s_queue_down : STD_LOGIC_VECTOR(w-1 downto 0);

    signal s_clear_command : STD_LOGIC;
    signal s_current_floor : STD_LOGIC_VECTOR(4 downto 0);
    
    signal s_move_up     : STD_LOGIC;
    signal s_move_down   : STD_LOGIC;
    signal s_motor_enable : STD_LOGIC;
    signal s_brake       : STD_LOGIC;

    signal s_moving : STD_LOGIC_VECTOR(1 downto 0);

begin

    -- INSTANCIAÇÃO DOS COMPONENTES (CONEXÃO DOS FIOS)

    -- U1: O Classificador de Chamadas (Combinacional)
    U_Floor_Controller : component floor_controller
        generic map ( w => w )
        port map (
            floor_sensor   => s_floor_sensor,
            dest_request   => dest_request,
            solicit_enable => solicit_enable,
            solicit_floor  => solicit_floor,
            solicit_dir    => solicit_dir,
            queue_up       => s_new_requests_up,  -- Saída para Fio 1
            queue_down     => s_new_requests_down -- Saída para Fio 1
        );

    -- U2: A Memória das Filas (Sequencial)
    U_Queue_Registers : component queue_registers
        generic map ( w => w )
        port map (
            clk   => clk,
            reset => reset,
            new_requests_up   => s_new_requests_up,   -- Entrada do Fio 1
            new_requests_down => s_new_requests_down, -- Entrada do Fio 1
            clear_command => s_clear_command, -- Entrada do Fio 3
            current_floor => s_current_floor, -- Entrada do Fio 3
            queue_up      => s_queue_up,      -- Saída para Fio 2
            queue_down    => s_queue_down     -- Saída para Fio 2
        );

    -- U3: A FSM Principal (Sequencial)
    U_Elevator_Controller : component elevator_controller
        generic map ( w => w )
        port map (
            clk   => clk,
            reset => reset,
            floor_sensor => s_floor_sensor, -- Entrada do Fio 0
            queue_up     => s_queue_up,     -- Entrada do Fio 2
            queue_down   => s_queue_down,   -- Entrada do Fio 2
            move_up      => s_move_up,      -- Saída para Fio 4
            move_down    => s_move_down,    -- Saída para Fio 4
            motor_enable => s_motor_enable, -- Saída para Fio 4
            brake        => s_brake,        -- Saída para Fio 4
            clear_command => s_clear_command, -- Saída para Fio 3
            current_floor => s_current_floor  -- Saída para Fio 3
        );

    -- U4: O Motor (Combinacional)
    U_Motor : component motor
        port map (
            move_up      => s_move_up,      -- Entrada do Fio 4
            move_down    => s_move_down,    -- Entrada do Fio 4
            motor_enable => s_motor_enable, -- Entrada do Fio 4
            brake        => s_brake,        -- Entrada do Fio 4
            moving       => s_moving        -- Saída para Fio 5
        );

    -- U5: O Detector/Contador de Andar (Sequencial)
    U_Floor_Detector : component det_andar
        port map (
            clk   => clk,
            reset => reset,
            
            mov   => s_moving,         -- Entrada do Fio 5
            fso   => s_floor_sensor    -- Saída para Fio 0
        );

    -- U6: O Controlador da Porta (Combinacional)
    U_Door : component door
        port map (
            moving           => s_moving,           -- Entrada do Fio 5
            door_open_closed => door_open_closed    -- Saída direta para porta do Top-Level
        );

    -- U7: O Decodificador do Display (Combinacional)
    U_Displays : component displays
        port map (
            floor_sensor => s_floor_sensor, -- Entrada do Fio 0
            seg7_D0      => seg7_D0,        -- Saída direta para porta do Top-Level
            seg7_D1      => seg7_D1         -- Saída direta para porta do Top-Level
        );

    -- LIGAÇÃO FINAL DAS SAÍDAS
    -- Conecta o fio interno 's_moving' à porta de saída 'moving'
    moving <= s_moving;
    o_floor_sensor <= s_floor_sensor;
end estrutural;
