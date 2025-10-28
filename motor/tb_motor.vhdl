-- 1. Bibliotecas
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- 2. Entidade do Testbench (sempre vazia)
entity tb_motor is
end entity tb_motor;

-- 3. Arquitetura de Teste
architecture test of tb_motor is
    -- Constante para o tempo de espera entre os testes
    constant C_DELAY : time := 10 ns;

    -- Declaração do componente que vamos testar
    component motor is
        port (
            move_up      : in  std_logic;
            move_down    : in  std_logic;
            motor_enable : in  std_logic;
            brake        : in  std_logic;
            moving       : out std_logic_vector(1 downto 0)
        );
    end component;

    -- Sinais ("fios") para conectar ao nosso componente
    signal s_move_up      : std_logic := '0';
    signal s_move_down    : std_logic := '0';
    signal s_motor_enable : std_logic := '0';
    signal s_brake        : std_logic := '0';
    signal s_moving       : std_logic_vector(1 downto 0); -- Fio para observar a saída

begin

    -- Instanciação do Componente Sob Teste (Unit Under Test - UUT)
    -- É aqui que "colocamos o chip na bancada de testes" 🔌
    UUT : component motor
        port map (
            move_up      => s_move_up,
            move_down    => s_move_down,
            motor_enable => s_motor_enable,
            brake        => s_brake,
            moving       => s_moving
        );

    -- Processo de Estímulo: O roteiro do nosso teste 📝
    stim_proc : process is
    begin
        report "Iniciando simulação do motor...";

        -- --- CENÁRIO 1: Motor Desabilitado ---
        report "Cenário 1: Motor desabilitado, deve ficar parado.";
        s_motor_enable <= '0';
        s_move_up      <= '1'; -- Tenta subir, mas deve ser ignorado
        wait for C_DELAY;
        -- CHECK: s_moving deve ser "00"

        -- --- CENÁRIO 2: Motor Habilitado - Subindo ---
        report "Cenário 2: Habilitado e movendo para cima.";
        s_motor_enable <= '1';
        s_move_up      <= '1';
        s_move_down    <= '0';
        s_brake        <= '0';
        wait for C_DELAY;
        -- CHECK: s_moving deve ser "10"

        -- --- CENÁRIO 3: Motor Habilitado - Descendo ---
        report "Cenário 3: Habilitado e movendo para baixo.";
        s_motor_enable <= '1';
        s_move_up      <= '0';
        s_move_down    <= '1';
        s_brake        <= '0';
        wait for C_DELAY;
        -- CHECK: s_moving deve ser "01"

        -- --- CENÁRIO 4: Motor Habilitado - Freando ---
        report "Cenário 4: Habilitado, mas freando.";
        s_motor_enable <= '1';
        s_move_up      <= '0';
        s_move_down    <= '0';
        s_brake        <= '1'; -- Sinaliza a intenção de frear
        wait for C_DELAY;
        -- CHECK: s_moving deve ser "00"
        
        -- --- CENÁRIO 5: Transição de Subir para Parar ---
        report "Cenário 5: Transição de Subir para Parar.";
        s_move_up      <= '0'; -- Mantém motor_enable='1', move_down='0', brake='0'
        wait for C_DELAY;
        -- CHECK: s_moving deve voltar para "00"

        report "Simulação concluída.";
        wait; -- Pausa a simulação para sempre
    end process;

end architecture test;