LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY portas IS
    PORT (
        -- sinais de controle globais
        clk   : IN STD_LOGIC;
        reset : IN STD_LOGIC;

        -- comandos do controlador principal
        door_open_cmd  : IN STD_LOGIC; -- manda o comando de abrir quando igual a 1
        door_close_cmd : IN STD_LOGIC; -- manda o comando de fechar quando igual a 1

        -- sinal que indica se o elevador está se movendo
        moving : IN STD_LOGIC_VECTOR(0 TO 1); -- 01 e 10 indicam movimento

        -- saída de status
        door_open_closed : OUT STD_LOGIC; -- 1 indica porta aberta e 0 indica porta fechada

        -- saída de depuração (para analisar o estado no GTKWave)
        debug_state_o : OUT STD_LOGIC -- 1 indica porta aberta, 0 indica porta fechada
    );
END ENTITY portas;

ARCHITECTURE fsm OF portas IS

    -- definição dos dois estados da FSM
    TYPE T_STATE IS (ST_FECHADA, ST_ABERTA);

    -- sinais internos
    SIGNAL current_state, next_state : T_STATE;
    SIGNAL elevador_movendo        : STD_LOGIC;

BEGIN

    -- lógica de segurança que converte moving para um único bit
    elevador_movendo <= '1' WHEN moving = "01" OR moving = "10" ELSE '0';

    -- saída de depuração (para analisar o estado no GTKWave)
    debug_state_o <= '1' WHEN current_state = ST_ABERTA ELSE '0';

    -- PROCESSO 1: registro de estado (memória da FSM)
    -- guarda o estado atual da porta
    PROCESS (clk, reset)
    BEGIN
        IF (reset = '1') THEN
            current_state <= ST_FECHADA; -- estado inicial
        ELSIF (rising_edge(clk)) THEN
            current_state <= next_state; -- atualiza o estado
        END IF;
    END PROCESS;

    -- PROCESSO 2: lógica combinacional (cérebro da FSM)
    -- decide qual será o próximo estado e qual é a saída
    PROCESS (current_state, door_open_cmd, door_close_cmd, elevador_movendo)
    BEGIN
        next_state <= current_state; -- fica no mesmo estado por padrão
        door_open_closed <= '0';     -- fechada por padrão

        CASE current_state IS
            
            WHEN ST_FECHADA =>
                door_open_closed <= '0';
                
                -- se receber comando para abrir e o elevador estiver parado
                IF (door_open_cmd = '1' AND elevador_movendo = '0') THEN
                    next_state <= ST_ABERTA; -- abre no próximo clock
                END IF;

            WHEN ST_ABERTA =>
                door_open_closed <= '1';
                
                -- se receber comando para fechar ou se o elevador começar a mover
                IF (door_close_cmd = '1' OR elevador_movendo = '1') THEN
                    next_state <= ST_FECHADA; -- fecha no próximo clock
                END IF;
                
        END CASE;
    END PROCESS;

END ARCHITECTURE fsm;