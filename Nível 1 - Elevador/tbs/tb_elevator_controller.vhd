library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- 1. Entidade do Testbench (vazia)
entity tb_elevator_controller is
end tb_elevator_controller;

-- 2. Arquitetura de Teste
architecture test of tb_elevator_controller is

    -- Constantes do Testbench
    constant C_W           : natural := 32;
    constant C_CLK_PERIOD  : time := 10 ns; -- Período do clock (100 MHz)
    constant C_WAIT_CYCLES : time := C_CLK_PERIOD * 5; -- Tempo de espera entre movimentos

    -- 3. Declaração do Componente a ser Testado (CUT)
    component elevator_controller is
        generic (w : natural := 32);
        port (
            signal clk   : in STD_LOGIC;
            signal reset : in STD_LOGIC;
            signal floor_sensor : in STD_LOGIC_VECTOR(4 downto 0);
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

    -- 4. Sinais para conectar ao CUT
    signal s_clk   : STD_LOGIC := '0';
    signal s_reset : STD_LOGIC := '0';
    signal s_floor_sensor : STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
    signal s_queue_up : STD_LOGIC_VECTOR(C_W-1 downto 0) := (others => '0');
    signal s_queue_down : STD_LOGIC_VECTOR(C_W-1 downto 0) := (others => '0');
    
    -- Sinais de saída (wires)
    signal s_move_up : STD_LOGIC;
    signal s_move_down : STD_LOGIC;
    signal s_motor_enable : STD_LOGIC;
    signal s_brake : STD_LOGIC;
    signal s_clear_command : STD_LOGIC;
    signal s_current_floor : STD_LOGIC_VECTOR(4 downto 0);

begin

    -- 5. Instanciação do Componente (Unit Under Test - UUT)
    UUT : component elevator_controller
        generic map (
            w => C_W
        )
        port map (
            clk           => s_clk,
            reset         => s_reset,
            floor_sensor  => s_floor_sensor,
            queue_up      => s_queue_up,
            queue_down    => s_queue_down,
            move_up       => s_move_up,
            move_down     => s_move_down,
            motor_enable  => s_motor_enable,
            brake         => s_brake,
            clear_command => s_clear_command,
            current_floor => s_current_floor
        );

    -- 6. Processo Gerador de Clock
    clk_gen_proc : process
    begin
        loop
            s_clk <= '0';
            wait for C_CLK_PERIOD / 2;
            s_clk <= '1';
            wait for C_CLK_PERIOD / 2;
        end loop;
    end process;

    -- 7. Processo de Estímulo (onde os testes acontecem)
    stim_proc : process is
        -- Helper procedure para simular o movimento
        procedure wait_and_move (floor_num : integer) is
        begin
            wait until rising_edge(s_clk);
            wait for C_WAIT_CYCLES; -- Espera alguns ciclos no mesmo andar
            s_floor_sensor <= std_logic_vector(to_unsigned(floor_num, 5));
        end procedure;
    
    begin
        report "Iniciando simulação do elevator_controller...";

        -- --- CENÁRIO 1: Reset do Sistema ---
        report "Cenário 1: Resetando o sistema.";
        s_reset <= '1';
        wait for C_CLK_PERIOD * 2;
        s_reset <= '0';
        wait until rising_edge(s_clk);
        
        -- CHECK: (No GTKWave) s_brake deve ser '1', outros motores '0'

        -- --- CENÁRIO 2: Chamada para SUBIR ---
        report "Cenário 2: Chamada para Subir (Andar 15)";
        
        -- Elevador está parado no andar 10
        s_floor_sensor <= "01010"; 
        
        -- Adiciona uma chamada para o andar 15
        s_queue_up(15) <= '1';
        wait until rising_edge(s_clk);
        
        -- O elevador deve entrar em MOVING_UP
        -- CHECK: s_move_up = '1', s_brake = '0'
        
        s_queue_up(15) <= '0'; -- Simula o botão sendo solto (a fila real faria isso)

        -- Simula o movimento do sensor (andar por andar)
        report "  Movendo: 11..12..13..14..15";
        wait_and_move(11);
        wait_and_move(12);
        wait_and_move(13);
        wait_and_move(14);
        wait_and_move(15); -- Chegou!
        
        -- Espera o próximo ciclo de clock para a FSM processar a chegada
        wait until rising_edge(s_clk); 
        
        -- CHECK: O elevador deve voltar ao IDLE.
        -- s_move_up = '0', s_brake = '1'
        -- s_clear_command = '1' (por 1 ciclo!)
        -- s_current_floor = "01111" (15)

        wait for C_CLK_PERIOD * 5; -- Espera para ver o clear_command voltar a '0'

        -- --- CENÁRIO 3: Chamada para DESCER ---
        report "Cenário 3: Chamada para Descer (Andar 5)";
        
        -- Elevador está parado no andar 10
        s_floor_sensor <= "01010"; 
        s_queue_down(5) <= '1';
        wait until rising_edge(s_clk);
        
        -- O elevador deve entrar em MOVING_DOWN
        -- CHECK: s_move_down = '1', s_brake = '0'
        
        s_queue_down(5) <= '0'; 

        -- Simula o movimento do sensor (andar por andar)
        report "  Movendo: 9..8..7..6..5";
        wait_and_move(9);
        wait_and_move(8);
        wait_and_move(7);
        wait_and_move(6);
        wait_and_move(5); -- Chegou!

        wait until rising_edge(s_clk); 
        
        -- CHECK: O elevador deve voltar ao IDLE.
        -- s_move_down = '0', s_brake = '1'
        -- s_clear_command = '1' (por 1 ciclo!)
        -- s_current_floor = "00101" (5)

        report "Simulação concluída.";
        wait; -- Fim da simulação
    end process;

end test;