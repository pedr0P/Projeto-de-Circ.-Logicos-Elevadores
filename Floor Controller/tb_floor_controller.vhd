library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- 1. Entidade do Testbench (vazia)
entity tb_floor_controller is
end tb_floor_controller;

-- 2. Arquitetura de Teste
architecture test of tb_floor_controller is

    -- Constantes
    constant C_W : natural := 32;
    constant C_DELAY : time := 10 ns; -- Delay para propaga��o combinacional

    -- 3. Declara��o do Componente a ser Testado (CUT)
    -- (Copiado da sua nova entidade)
    component floor_controller is
        generic (w : natural := 32);
        port (
            signal floor_sensor : in STD_LOGIC_VECTOR(4 downto 0);
            signal dest_request : in STD_LOGIC_VECTOR(w-1 downto 0);
            signal solicit_enable : in STD_LOGIC; -- Nova porta
            signal solicit_floor : in STD_LOGIC_VECTOR(4 downto 0);
            signal solicit_dir : in STD_LOGIC;
            signal queue_down : out STD_LOGIC_VECTOR(w-1 downto 0);
            signal queue_up : out STD_LOGIC_VECTOR(w-1 downto 0)
        );
    end component;

    -- 4. Sinais para conectar ao CUT
    signal s_floor_sensor : STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
    signal s_dest_request : STD_LOGIC_VECTOR(C_W-1 downto 0) := (others => '0');
    signal s_solicit_enable : STD_LOGIC := '0'; -- Novo sinal
    signal s_solicit_floor : STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
    signal s_solicit_dir : STD_LOGIC := '0';
    
    -- Sinais de sa�da (wires)
    signal s_queue_down : STD_LOGIC_VECTOR(C_W-1 downto 0);
    signal s_queue_up : STD_LOGIC_VECTOR(C_W-1 downto 0);

begin

    -- 5. Instancia��o do Componente (Unit Under Test - UUT)
    UUT : component floor_controller
        generic map (
            w => C_W
        )
        port map (
            floor_sensor  => s_floor_sensor,
            dest_request  => s_dest_request,
            solicit_enable => s_solicit_enable, -- Conecta o novo sinal
            solicit_floor => s_solicit_floor,
            solicit_dir   => s_solicit_dir,
            queue_down    => s_queue_down,
            queue_up      => s_queue_up
        );

    -- 6. Processo de Est�mulo (onde os testes acontecem)
    stim_proc : process is
        -- Helper procedure para resetar as entradas
        procedure reset_inputs is
        begin
            s_dest_request  <= (others => '0');
            s_solicit_enable <= '0'; -- Define 'disable' como padr�o
            s_solicit_floor <= (others => '0');
            s_solicit_dir   <= '0';
            wait for C_DELAY; -- Espera a propaga��o
        end procedure;

    begin
        report "Iniciando simula��o do floor_controller...";

        -- --- CEN�RIO 1: Requisi��es Internas (SOLICIT DESABILITADO) ---
        report "Cen�rio 1: Requisi��es Internas";
        reset_inputs; -- s_solicit_enable agora � '0'
        
        s_floor_sensor <= "01010"; -- Andar 10

        -- Pressiona bot�es 5 (descer), 15 (subir) e 10 (atual)
        s_dest_request(5)  <= '1';
        s_dest_request(15) <= '1';
        s_dest_request(10) <= '1';
        
        wait for C_DELAY;
        -- CHECK: (Visualizar no GtkWave)
        -- s_queue_up(15)   deve ser '1'
        -- s_queue_down(5)  deve ser '1'
        -- s_queue_down(0)  DEVE SER '0' AGORA (CORRIGIDO)

        -- --- CEN�RIO 2: Solicita��es Externas (SOLICIT HABILITADO) ---
        report "Cen�rio 2: Solicita��es Externas";
        reset_inputs;
        s_floor_sensor <= "01010"; -- Andar 10

        -- Chamada externa para Descer no andar 5
        s_solicit_floor <= "00101"; -- Andar 5
        s_solicit_dir   <= '0';     -- 0 = Descer
        s_solicit_enable <= '1';    -- HABILITA a solicita��o
        wait for C_DELAY;
        -- CHECK: s_queue_down(5) deve ser '1'

        -- Chamada externa para Subir no andar 20
        reset_inputs; -- Limpa a chamada anterior
        s_floor_sensor <= "01010"; -- Andar 10
        s_solicit_floor <= "10100"; -- Andar 20
        s_solicit_dir   <= '1';     -- 1 = Subir
        s_solicit_enable <= '1';    -- HABILITA a solicita��o
        wait for C_DELAY;
        -- CHECK: s_queue_up(20) deve ser '1'

        -- --- CEN�RIO 3: Chamadas Combinadas ---
        report "Cen�rio 3: Chamadas Combinadas";
        reset_inputs;
        s_floor_sensor <= "01010"; -- Andar 10

        -- Interna: Andar 15 (Subir)
        s_dest_request(15) <= '1';
        
        -- Externa: Andar 20 (Subir)
        s_solicit_floor <= "10100"; -- Andar 20
        s_solicit_dir   <= '1';
        s_solicit_enable <= '1'; -- HABILITA a solicita��o
        wait for C_DELAY;
        -- CHECK: s_queue_up(15) deve ser '1' E s_queue_up(20) deve ser '1'

        -- --- CEN�RIO 4: Sensor de Andar Din�mico ---
        report "Cen�rio 4: Sensor de Andar Din�mico";
        reset_inputs; -- s_solicit_enable est� '0'
        
        -- Pedidos internos 5 (Baixo) e 15 (Cima) est�o ativos
        s_dest_request(5)  <= '1';
        s_dest_request(15) <= '1';

        -- Elevador est� no andar 10
        s_floor_sensor <= "01010";
        wait for C_DELAY;
        -- CHECK: s_queue_up(15) = '1', s_queue_down(5) = '1'

        -- Elevador "chega" ao andar 15
        s_floor_sensor <= "01111"; -- Andar 15
        wait for C_DELAY;
        -- CHECK: s_queue_up(15) deve ir para '0' (agora � o andar atual)
        -- CHECK: s_queue_down(5) deve permanecer '1'

        report "Simula��o conclu�da.";
        wait; -- Fim da simula��o
    end process;

end test;