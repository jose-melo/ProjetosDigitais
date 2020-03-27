library IEEE;
use IEEE.std_logic_1164.all;

entity Interface_FSM_v4 is
    port (
        clock, reset         : in  STD_LOGIC;
        iniciar, resposta    : in  STD_LOGIC;
        contagem_inicial     : in  STD_LOGIC;   -- fim da contagem do contador inicial
        erro_sin             : out STD_LOGIC;
        estimulo_sin, ligado : out STD_LOGIC;
        zera_ci              : out STD_LOGIC;   -- sinais de saída para o
        conta_ci             : out STD_LOGIC;   -- contador inicial
        pronto               : out STD_LOGIC;   -- sinal que define fim do processo, por erro_sin ou não
        estado               : out STD_LOGIC_VECTOR(3 downto 0);
        db_clock             : out STD_LOGIC;   -- sinais
        db_erro_sin          : out STD_LOGIC;   -- de
        db_estimulo_sin      : out STD_LOGIC    -- depuração
    );
end Interface_FSM_v4;

architecture controlador_arch of Interface_FSM_v4 is
    type tipo_Estado is (INICIAL, CONTANDO, ERRO, ESTIMULO, ESPERA, FIM);
    signal Ereg, Eprox: tipo_Estado;
begin

    -- mudanca de estado
    process (clock, reset)
    begin
        if reset = '1' then
            Ereg <= INICIAL;
        elsif clock'event and clock = '1' then
            Ereg <= Eprox;
        end if;
    end process;

    -- logica de proximo estado
    process (iniciar, resposta, contagem_inicial, Ereg)
    begin
        case Ereg is
            when INICIAL => if iniciar = '0' then   Eprox <= INICIAL;
                            else                    Eprox <= CONTANDO;
                            end if;

            when CONTANDO => if contagem_inicial = '1' then Eprox <= ESTIMULO;
                             elsif resposta = '0'      then Eprox <= CONTANDO;
                             else                           Eprox <= ERRO;
                             end if;

            when ESTIMULO => if resposta = '1' then  Eprox <= ESPERA;
                             else                    Eprox <= ESTIMULO;
                             end if;

            when ESPERA =>  Eprox <= FIM;

            when FIM => if jogar = '0' then Eprox <= FIM;
                            else Eprox <= CONTANDO;
                            end if;

            when ERRO =>    Eprox <= ERRO;

            when others =>  Eprox <= INICIAL;
        end case;
    end process;

    -- sinais de controle ativos em alto
    with Ereg select
        erro_sin  <= '1' when ERRO,
                     '0' when others;
	with Ereg select
        db_erro_sin  <= '1' when ERRO,
                     '0' when others;
    with Ereg select
        estimulo_sin <= '1' when ESTIMULO,
                        '0' when others;
	 with Ereg select
        db_estimulo_sin <= '1' when ESTIMULO,
                        '0' when others;
    with Ereg select
        ligado <= '1' when CONTANDO | ESTIMULO | ESPERA,
                  '0' when others;
    with Ereg select
        zera_ci <= '1' when INICIAL | FIM,
                   '0' when others;
    with Ereg select
        conta_ci <= '1' when CONTANDO,
                    '0' when others;
    with Ereg select
        pronto <= '1' when FIM | ERRO,
                  '0' when others;
    with Ereg select
        estado  <=  "0000" when INICIAL,
                    "0001" when CONTANDO,
                    "0010" when ESTIMULO,
                    "0100" when ESPERA,
                    "1000" when FIM,
                    "1111" when ERRO,
                    "1100" when others;

    -- sinais de depuração
    db_clock <= clock;

end controlador_arch;
