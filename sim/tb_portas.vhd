LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY tb_portas IS
END ENTITY tb_portas;

ARCHITECTURE test OF tb_portas IS
    
    CONSTANT CLK_PERIOD : TIME := 10 ns;

    -- componente a ser testado
    COMPONENT portas IS
        PORT (
            clk              : IN STD_LOGIC;
            reset            : IN STD_LOGIC;
            door_open_cmd    : IN STD_LOGIC;
            door_close_cmd   : IN STD_LOGIC;
            moving           : IN STD_LOGIC_VECTOR(0 TO 1);
            door_open_closed : OUT STD_LOGIC;
            debug_state_o    : OUT STD_LOGIC
        );
    END COMPONENT portas;

    -- sinais de estímulo e observação
    SIGNAL s_clk              : STD_LOGIC := '0';
    SIGNAL s_reset            : STD_LOGIC;
    SIGNAL s_door_open_cmd    : STD_LOGIC;
    SIGNAL s_door_close_cmd   : STD_LOGIC;
    SIGNAL s_moving           : STD_LOGIC_VECTOR(0 TO 1);
    SIGNAL s_door_open_closed : STD_LOGIC;
    SIGNAL s_debug_state      : STD_LOGIC;

BEGIN

    -- instanciação do UUT
    UUT : portas
    PORT MAP(
        clk              => s_clk,
        reset            => s_reset,
        door_open_cmd    => s_door_open_cmd,
        door_close_cmd   => s_door_close_cmd,
        moving           => s_moving,
        door_open_closed => s_door_open_closed,
        debug_state_o    => s_debug_state 
    );

    -- gerador de clock
    s_clk <= NOT s_clk AFTER CLK_PERIOD / 2;

    -- processo de estímulo
    PROCESS
    BEGIN
        REPORT "Iniciando teste do modulo Portas";
        
        -- reset inicial
        s_reset <= '1';
        s_door_open_cmd <= '0';
        s_door_close_cmd <= '0';
        s_moving <= "00";
        WAIT FOR CLK_PERIOD * 2;
        s_reset <= '0';
        WAIT FOR CLK_PERIOD;
        -- o estado agora é ST_FECHADA, s_debug_state = 0

        -- teste 1: abrir porta parado
        REPORT "TESTE 1: comando de abrir";
        s_door_open_cmd <= '1';
        WAIT FOR CLK_PERIOD; -- comando dado
        s_door_open_cmd <= '0';
        
        -- no próximo ciclo de clock, a porta já deve estar aberta
        WAIT FOR CLK_PERIOD; 
        ASSERT s_door_open_closed = '1'
            REPORT "Porta nao abriu" SEVERITY error;
        REPORT "Porta esta aberta";

        -- teste 2: comando de fechar porta
        REPORT "TESTE 2: comando de fechar";
        s_door_close_cmd <= '1';
        WAIT FOR CLK_PERIOD;
        s_door_close_cmd <= '0';

        -- no próximo ciclo, a porta já deve estar fechada
        WAIT FOR CLK_PERIOD;
        ASSERT s_door_open_closed = '0'
            REPORT "Porta nao fechou" SEVERITY error;
        REPORT "Porta esta FECHADA";

        -- ----- teste 3: tentar abrir em movimento
        REPORT "TESTE 3: comando de abrir em movimento";
        s_moving <= "01"; -- simulando subida
        WAIT FOR CLK_PERIOD;
        
        s_door_open_cmd <= '1';
        WAIT FOR CLK_PERIOD;
        s_door_open_cmd <= '0';
        
        WAIT FOR CLK_PERIOD * 3; -- espera alguns ciclos
        ASSERT s_door_open_closed = '0'
            REPORT "Porta abriu em movimento" SEVERITY failure;
        REPORT "Porta permaneceu fechada";
        s_moving <= "00"; -- para o elevador
        WAIT FOR CLK_PERIOD;

        -- -teste 4: fechamento de segurança por movimento
        REPORT "TESTE 4: fechamento de segurança por movimento";
        -- abre a porta primeiro
        s_door_open_cmd <= '1';
        WAIT FOR CLK_PERIOD * 2; s_door_open_cmd <= '0';
        WAIT FOR CLK_PERIOD;
        ASSERT s_door_open_closed = '1' REPORT "Porta esta aberta para o teste 4";

        -- começa a mover
        s_moving <= "10"; -- simulando descida
        WAIT FOR CLK_PERIOD;
        
        -- no próximo ciclo, a porta deve ter fechado
        ASSERT s_door_open_closed = '0'
            REPORT " Porta nao fechou ao mover" SEVERITY failure;
        REPORT "Porta fechou automaticamente ao mover";
        s_moving <= "00";
        WAIT FOR CLK_PERIOD;

        REPORT "Teste do modulo Portas concluido";
        WAIT;
    END PROCESS;

END ARCHITECTURE test;