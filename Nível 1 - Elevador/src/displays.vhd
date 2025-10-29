LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY displays IS
    PORT (
        floor_sensor : IN  STD_LOGIC_VECTOR(4 DOWNTO 0); -- entrada do sensor de andar (0 - 31)
        seg7_D0      : OUT STD_LOGIC_VECTOR(6 DOWNTO 0); -- saída da unidade
        seg7_D1      : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)  -- saída da dezena
    );
END ENTITY displays;

ARCHITECTURE estrutural OF displays IS

    -- declaração do componente bcd_to_7seg
    COMPONENT bcd_to_7seg IS
        PORT (
            bcd_in  : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
            seg_out : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)
        );
    END COMPONENT bcd_to_7seg;

    -- declaração dos sinais internos
    SIGNAL s_bcd_dezena  : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL s_bcd_unidade : STD_LOGIC_VECTOR(3 DOWNTO 0);

BEGIN

    -- calcula os valores para os sinais internos
    PROCESS (floor_sensor)
        VARIABLE andar_int : INTEGER RANGE 0 TO 31;
        VARIABLE dezena    : INTEGER RANGE 0 TO 9;
        VARIABLE unidade   : INTEGER RANGE 0 TO 9;
    BEGIN
        andar_int := TO_INTEGER(UNSIGNED(floor_sensor));
        dezena := andar_int / 10;
        unidade := andar_int MOD 10;

        -- converte os inteiros de volta para vetores BCD
        s_bcd_dezena  <= STD_LOGIC_VECTOR(TO_UNSIGNED(dezena, 4));
        s_bcd_unidade <= STD_LOGIC_VECTOR(TO_UNSIGNED(unidade, 4));
        
    END PROCESS;

    -- instanciação dos componentes
    
    U1_DEZENA : bcd_to_7seg
    PORT MAP (
        bcd_in  => s_bcd_dezena,  -- fio da dezena
        seg_out => seg7_D1        -- saída para o display da dezena
    );

    U2_UNIDADE : bcd_to_7seg
    PORT MAP (
        bcd_in  => s_bcd_unidade, -- fio da unidade
        seg_out => seg7_D0        -- saída para o display da unidade
    );

END ARCHITECTURE estrutural;