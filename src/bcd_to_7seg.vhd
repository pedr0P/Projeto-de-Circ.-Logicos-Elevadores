LIBRARY ieee;
USE ieee.std_logic_1164.all;

-- este módulo converte um dígito BCD (4 bits) para um display de 7 segmentos
ENTITY bcd_to_7seg IS
    PORT (
        bcd_in  : IN  STD_LOGIC_VECTOR(3 DOWNTO 0); -- entrada (0000 - 1001)
        seg_out : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)  -- saída (a,b,c,d,e,f,g)
    );
END ENTITY bcd_to_7seg;

ARCHITECTURE comportamental OF bcd_to_7seg IS
BEGIN
    
    -- descrição da lógica do conversor
    WITH bcd_in SELECT
        seg_out <= "1111110" WHEN "0000", -- 0
                   "0110000" WHEN "0001", -- 1
                   "1101101" WHEN "0010", -- 2
                   "1111001" WHEN "0011", -- 3
                   "0110011" WHEN "0100", -- 4
                   "1011011" WHEN "0101", -- 5
                   "1011111" WHEN "0110", -- 6
                   "1110000" WHEN "0111", -- 7
                   "1111111" WHEN "1000", -- 8
                   "1111011" WHEN "1001", -- 9
                   "0000000" WHEN OTHERS; -- apagado

END ARCHITECTURE comportamental;