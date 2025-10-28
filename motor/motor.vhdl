library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity motor is
    port (
        -- Entradas
        move_up : in std_logic; -- subir
        move_down : in std_logic; -- descer
        motor_enable : in std_logic; -- motor parado ou nao
        brake : in std_logic; -- freio (redundante, mas bom para fins de clareza)

        -- Saída
        moving : out std_logic_vector (1 downto 0) -- 00 parado, 01 descendo, 10 subindo
    );
end entity motor;

architecture comportamental of motor is
begin
    moving <= "10" when motor_enable = '1' and move_up = '1' else
              "01" when motor_enable = '1' and move_down = '1' else
              "00";
end architecture comportamental;