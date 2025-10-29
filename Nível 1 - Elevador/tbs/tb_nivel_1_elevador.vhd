library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- 1. Entidade do Testbench (vazia)
entity tb_nivel_1_elevador is
end tb_nivel_1_elevador;

-- 2. Arquitetura de Teste
architecture test of tb_nivel_1_elevador is

    -- Constantes do Testbench
    constant C_W           : natural := 32;
    constant C_CLK_PERIOD  : time := 10 ns; -- Período do clock (100 MHz)

    -- 3. Declaração do Componente a ser Testado (UUT)
    component nivel_1_elevador is
        generic (w : natural := 32);
        port (
            -- Entradas de Controle e Sensor
            signal clk   : in STD_LOGIC;
            signal reset : in STD_LOGIC;
            
            -- Entradas de Chamadas
            signal dest_request : in STD_LOGIC_VECTOR(w-1 downto 0);
            signal solicit_enable : in STD_LOGIC;
            signal solicit_floor : in STD_LOGIC_VECTOR(4 downto 0);
            signal solicit_dir : in STD_LOGIC;
            
            -- Saídas
            signal seg7_D0: out STD_LOGIC_VECTOR(6 downto 0);    
            signal seg7_D1: out STD_LOGIC_VECTOR(6 downto 0);    
            signal door_open_closed : out STD_LOGIC;
            signal moving : out STD_LOGIC_VECTOR(1 downto 0)
        );   
    end component;

    -- 4. Sinais para conectar ao UUT
    signal s_clk   : STD_LOGIC := '0';
    signal s_reset : STD_LOGIC := '0';
    signal s_dest_request : STD_LOGIC_VECTOR(C_W-1 downto 0) := (others => '0');
    signal s_solicit_enable : STD_LOGIC := '0';
    signal s_solicit_floor : STD_LOGIC_VECTOR(4 downto 0) := (others => '0');
    signal s_solicit_dir : STD_LOGIC := '0';
    
    -- Sinais de saída (wires)
    signal s_seg7_D0 : STD_LOGIC_VECTOR(6 downto 0);
    signal s_seg7_D1 : STD_LOGIC_VECTOR(6 downto 0);
    signal s_door_open_closed : STD_LOGIC;
    signal s_moving : STD_LOGIC_VECTOR(1 downto 0);

    signal sim_finished : BOOLEAN := false; -- Sinal para parar o clock

begin

    -- 5. Instanciação do Componente (Unit Under Test)
    UUT : component nivel_1_elevador
        generic map ( w => C_W )
        port map (
            clk            => s_clk,
            reset          => s_reset,
            dest_request   => s_dest_request,
            solicit_enable => s_solicit_enable,
            solicit_floor  => s_solicit_floor,
            solicit_dir    => s_solicit_dir,
            seg7_D0        => s_seg7_D0,
            seg7_D1        => s_seg7_D1,
            door_open_closed => s_door_open_closed,
            moving         => s_moving
        );

    -- 6. Processo Gerador de Clock
    clk_gen_proc : process
    begin
        while not sim_finished loop 
            s_clk <= '0';
            wait for C_CLK_PERIOD / 2;
            s_clk <= '1';
            wait for C_CLK_PERIOD / 2;
        end loop;
        wait;
    end process;

    -- 7. Processo de Estímulo (Simula o Usuário e o Escalonador)
    stim_proc : process is
    begin
        report "Iniciando simulação do nivel_1_elevador...";

        -- --- CENÁRIO 1: Reset do Sistema ---
        report "Cenário 1: Resetando o sistema.";
        s_reset <= '1';
        wait for C_CLK_PERIOD * 2;
        s_reset <= '0';
        wait until rising_edge(s_clk);
        
        -- CHECK (GTKWave): 'moving' deve ser "00", 'door_open_closed' = '1'
        -- 'seg7_D0' e 'seg7_D1' devem mostrar '0'.

        -- --- CENÁRIO 2: Chamada INTERNA (Usuário) ---
        report "Cenário 2: Chamada interna para o andar 5.";
        
        -- Simula o usuário apertando o botão do andar 5
        s_dest_request(5) <= '1';
        wait until rising_edge(s_clk);
        s_dest_request(5) <= '0'; -- Solta o botão
        
        -- Espera o elevador começar a se mover
        wait until s_moving = "10";
        report "  ...Elevador subindo para o 5...";
        
        -- CHECK (GTKWave): 'moving' = "10", 'door_open_closed' = '0'
        
        -- Espera o elevador parar
        wait until s_moving = "00";
        report "  ...Elevador chegou no andar 5!";
        
        -- CHECK (GTKWave): 'moving' = "00", 'door_open_closed' = '1'
        -- 'seg7_D0' deve mostrar '5'.
        
        wait for C_CLK_PERIOD * 10; -- Espera um tempo

        -- --- CENÁRIO 3: Chamada EXTERNA (Escalonador) ---
        report "Cenário 3: Chamada externa para o andar 2 (Descendo).";
        
        -- Simula o Escalonador enviando uma ordem
        s_solicit_enable <= '1';
        s_solicit_floor  <= "00010"; -- Andar 2
        s_solicit_dir    <= '0';     -- 0 = Descer
        
        wait until rising_edge(s_clk);
        s_solicit_enable <= '0'; -- Comando enviado
        
        -- Espera o elevador começar a se mover
        wait until s_moving = "01";
        report "  ...Elevador descendo para o 2...";
        
        -- CHECK (GTKWave): 'moving' = "01", 'door_open_closed' = '0'
        
        -- Espera o elevador parar
        wait until s_moving = "00";
        report "  ...Elevador chegou no andar 2!";
        
        -- CHECK (GTKWave): 'moving' = "00", 'door_open_closed' = '1'
        -- 'seg7_D0' deve mostrar '2'.

        report "Simulação concluída.";
        
        sim_finished <= true; 
        -- Espera para sempre (impede que stim_proc reinicie)
        wait;
    end process;

end test;