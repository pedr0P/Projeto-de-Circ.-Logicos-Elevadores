library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity floor_controller is
      generic (w : natural := 32);
      port (
            signal floor_sensor : in STD_LOGIC_VECTOR(4 downto 0);     -- data inputs
            signal dest_request : in STD_LOGIC_VECTOR(w-1 downto 0);     -- data inputs
            signal solicit_enable : in STD_LOGIC;
            signal solicit_floor : in STD_LOGIC_VECTOR(4 downto 0);     -- selector
            signal solicit_dir : in STD_LOGIC;                          -- 1 para subir e 0 para descer
            signal queue_down : out STD_LOGIC_VECTOR(w-1 downto 0);
            signal queue_up : out STD_LOGIC_VECTOR(w-1 downto 0)
      );   
end floor_controller;

architecture comportamental of floor_controller is
begin
      process(floor_sensor, dest_request, solicit_floor, solicit_dir)
            variable v_current_floor_int : integer range 0 to w-1;
            variable v_solicit_floor_int : integer range 0 to w-1;
            
            variable v_internal_up : STD_LOGIC_VECTOR(w-1 downto 0);
            variable v_internal_down : STD_LOGIC_VECTOR(w-1 downto 0);
            variable v_external_up : STD_LOGIC_VECTOR(w-1 downto 0);
            variable v_external_down : STD_LOGIC_VECTOR(w-1 downto 0);

      begin
            v_internal_up   := (others => '0');
            v_internal_down := (others => '0');
            v_external_up   := (others => '0');
            v_external_down := (others => '0');
            queue_up        <= (others => '0');
            queue_down      <= (others => '0');

            v_current_floor_int := to_integer(unsigned(floor_sensor));
            v_solicit_floor_int := to_integer(unsigned(solicit_floor));

            for i in 0 to w-1 loop
                  if dest_request(i) = '1' then
                        if i > v_current_floor_int then
                              v_internal_up(i) := '1'; -- É um pedido para subir
                        elsif i < v_current_floor_int then
                              v_internal_down(i) := '1'; -- É um pedido para descer
                        end if;
                  end if;
            end loop;

            if solicit_enable = '1' then
                  if solicit_dir = '1' then
                        v_external_up(v_solicit_floor_int) := '1';
                  else
                        v_external_down(v_solicit_floor_int) := '1';
                  end if;
            end if;
      
            queue_up   <= v_internal_up   OR v_external_up;
            queue_down <= v_internal_down OR v_external_down;
      end process;

end comportamental;