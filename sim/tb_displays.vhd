LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

-- a entidade de testbench é sempre vazia
ENTITY tb_displays IS
END ENTITY tb_displays;

ARCHITECTURE test OF tb_displays IS

    -- declarar o componente que queremos testar
    COMPONENT displays IS
        PORT (
            floor_sensor : IN  STD_LOGIC_VECTOR(4 DOWNTO 0);
            seg7_D1      : OUT STD_LOGIC_VECTOR(6 DOWNTO 0);
            seg7_D2      : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
        );
    END COMPONENT displays;

    -- sinais de estímuloe observação
    SIGNAL s_floor_sensor : STD_LOGIC_VECTOR(4 DOWNTO 0) := (OTHERS => '0');
    SIGNAL s_seg7_D1      : STD_LOGIC_VECTOR(6 DOWNTO 0);
    SIGNAL s_seg7_D2      : STD_LOGIC_VECTOR(6 DOWNTO 0);

BEGIN

    -- instanciação do componente UUT (Unit Under Test)
    UUT : displays
    PORT MAP(
        floor_sensor => s_floor_sensor,
        seg7_D1      => s_seg7_D1,
        seg7_D2      => s_seg7_D2
    );

    -- processo de estímulo
    PROCESS
    BEGIN
        REPORT "Iniciando teste do modulo Displays";

        -- cenário 1: andar 0
        s_floor_sensor <= "00000"; -- 0
        WAIT FOR 10 ns;

        -- cenário 2: andar 9
        s_floor_sensor <= "01001"; -- 9
        WAIT FOR 10 ns;

        -- cenário 3: andar 10
        s_floor_sensor <= "01010"; -- 10
        WAIT FOR 10 ns;

        -- cenário 4: andar 25
        s_floor_sensor <= "11001"; -- 25
        WAIT FOR 10 ns;

        -- cenário 5: andar 31
        s_floor_sensor <= "11111"; -- 31
        WAIT FOR 10 ns;
        
        REPORT "Teste do modulo Displays concluido";
        WAIT; -- fim da simulação
    END PROCESS;

END ARCHITECTURE test;