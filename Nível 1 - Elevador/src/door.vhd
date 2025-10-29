library IEEE;
use IEEE.std_logic_1164.all;

entity door is
    port (
        signal moving           : in  STD_LOGIC_VECTOR(1 downto 0);
        signal door_open_closed : out STD_LOGIC                     
    );
end door;

-- Arquitetura comportamental
architecture comportamental of door is
begin
    -- A porta estará '1' (aberta) SOMENTE QUANDO moving = "00",
    -- caso contrário (else), ela estará '0' (fechada).
    
    door_open_closed <= '1' when moving = "00" else '0';

end comportamental;