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
        signal moving : out STD_LOGIC_VECTOR(1 downto 0)
    );   
end nivel_1_elevador;

architecture estrutural of nivel_1_elevador is
    -- DECLARAÇÃO DOS COMPONENTES
    component det_andar is
        port (
            fsi : in STD_LOGIC_VECTOR(4 downto 0);
            mov : in BIT_VECTOR(1 downto 0);
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

    signal floor_sensor
end estrutural;