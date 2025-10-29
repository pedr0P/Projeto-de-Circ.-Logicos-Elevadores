library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity elevator_controller is
    generic (w : natural := 32);
    port (
        signal clk   : in STD_LOGIC;
        signal reset : in STD_LOGIC; -- '1' para resetar

        signal floor_sensor : in STD_LOGIC_VECTOR(4 downto 0);     -- data inputs
        signal queue_up : in STD_LOGIC_VECTOR(w-1 downto 0);
        signal queue_down : in STD_LOGIC_VECTOR(w-1 downto 0);

        signal move_up : out STD_LOGIC;    
        signal move_down : out STD_LOGIC;
        signal motor_enable : out STD_LOGIC;
        signal brake : out STD_LOGIC;

        signal clear_command : out STD_LOGIC;
        signal current_floor : out STD_LOGIC_VECTOR(4 downto 0)
    );   
end elevator_controller;

architecture comportamental of elevator_controller is
    type T_STATE is (IDLE, MOVING_UP, MOVING_DOWN);
    signal current_state : T_STATE := IDLE;
    signal target_floor : integer range 0 to w-1 := 0;

begin
    process(clk, reset)
        variable v_current_floor_int : integer range 0 to w-1;
        variable v_next_floor_int : integer range 0 to w-1;
        variable v_there_is_call_up : std_logic;
        variable v_there_is_call_down : std_logic;

    begin
        v_current_floor_int := to_integer(unsigned(floor_sensor));
        v_there_is_call_up := '0';
        v_there_is_call_down := '0';

        -- LÓGICA DE RESET (Inicialização)
        -- Esta é a inicialização principal.
        -- Se o reset estiver ativo ('1'), força o estado 'ocioso'
        -- e desliga todos os motores.
        if reset = '1' then
            current_state <= IDLE;
            
            move_up       <= '0';
            move_down     <= '0'; 
            motor_enable  <= '0';
            brake         <= '1'; -- Ativa o freio (estado seguro)

            clear_command <= '0';
            current_floor <= (others => '0');
            
        -- O que acontece a cada subida do clock
        elsif rising_edge(clk) then

            clear_command <= '0';

            case current_state is
            
                when IDLE =>
                    move_up       <= '0';
                    move_down     <= '0';
                    motor_enable  <= '0';
                    brake         <= '1';
                    
                    -- Lógica para decidir se deve se mover
                    for i in v_current_floor_int downto 0 loop
                        if queue_down(i) = '1' then
                            v_there_is_call_down := '1';
                            v_next_floor_int := i;

                            exit;
                        end if;
                    end loop;

                    if v_there_is_call_down = '0' then
                        for i in v_current_floor_int to w-1 loop
                            if queue_up(i) = '1' then
                                v_there_is_call_up := '1';
                                v_next_floor_int := i;

                                exit;
                            end if;
                        end loop;
                    end if;

                    if v_there_is_call_down = '1' then
                        current_state <= MOVING_DOWN;
                        target_floor <= v_next_floor_int;
                    elsif v_there_is_call_up = '1' then
                        current_state <= MOVING_UP;
                        target_floor <= v_next_floor_int;
                    else
                        current_state <= IDLE;
                    end if;

                when MOVING_UP =>
                    move_up       <= '1';
                    move_down     <= '0';
                    motor_enable  <= '1';
                    brake         <= '0';
                    
                    if v_current_floor_int = target_floor then
                        current_state <= IDLE;

                        clear_command <= '1';
                        current_floor <= STD_LOGIC_VECTOR(to_unsigned(target_floor, 5));
                    else
                        current_state <= MOVING_UP;
                    end if;
                    
                when MOVING_DOWN =>
                    move_up       <= '0';
                    move_down     <= '1';
                    motor_enable  <= '1';
                    brake         <= '0';
                    
                    if v_current_floor_int = target_floor then
                        current_state <= IDLE;

                        clear_command <= '1';
                        current_floor <= STD_LOGIC_VECTOR(to_unsigned(target_floor, 5));
                    else
                        current_state <= MOVING_DOWN;
                    end if;
            
            end case;
        end if;
    end process;

end comportamental;