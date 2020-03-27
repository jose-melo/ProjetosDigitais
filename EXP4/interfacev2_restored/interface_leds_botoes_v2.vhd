library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

entity interface_leds_botoes_v2 is
    port (
        clock    : in  std_logic;
        reset    : in  std_logic;
        iniciar  : in  std_logic;
        resposta : in  std_logic;
        ligado   : out std_logic;
        estimulo : out std_logic;
        pulso    : out std_logic;
        erro     : out std_logic;
        pronto   : out std_logic;
        estado   : out STD_LOGIC_VECTOR(3 downto 0);
        db_clock    : out STD_LOGIC;    -- sinais
        db_erro     : out STD_LOGIC;    -- de
        db_estimulo : out STD_LOGIC     -- depuração
);
end interface_leds_botoes_v2;

architecture arch of interface_leds_botoes_v2 is
    component contador_modm is
        generic (
            constant M: integer := 256  -- valor default do modulo do contador
        );
        port (
            clock, zera, conta: in std_logic;
            Q: out std_logic_vector (natural(ceil(log2(real(M))))-1 downto 0);
            fim: out std_logic
        );
    end component contador_modm;
    component latch_sr is
        port (
            s, r: in  std_logic;
            q:    out std_logic
        );
    end component latch_sr;
    component interface_FSM_v4 is
        port (
            clock, reset         : in  STD_LOGIC;
            iniciar, resposta    : in  STD_LOGIC;
            contagem_inicial     : in  STD_LOGIC;  -- fim da contagem do contador inicial
            erro_sin             : out STD_LOGIC;
            estimulo_sin, ligado : out STD_LOGIC;
            zera_ci              : out STD_LOGIC;  -- sinais de saída para o
            conta_ci             : out STD_LOGIC;  -- contador inicial
            pronto               : out STD_LOGIC;  -- sinal que define fim do processo, por erro_sin ou não
            estado               : out STD_LOGIC_VECTOR(3 downto 0);
            db_clock             : out STD_LOGIC;  -- sinais
            db_erro_sin          : out STD_LOGIC;  -- de
            db_estimulo_sin      : out STD_LOGIC  -- depuração
            
        );
    end component interface_FSM_v4;
  
    signal iniciar_estimulo : std_logic;                        -- 1 quando o contador inicial terminar sua contagem
    signal zera_cont_inicial, inicia_cont_inicial : std_logic;  -- sinais de controle do contador inicial
    signal ligado_intermediario, estimulo_intermediario, erro_intermediario : std_logic;
    signal latch_out : std_logic;                               -- saida do latch
	 signal reset_interno : std_logic;
	 
begin
    CONT_INICIO: contador_modm
        generic map (M => 10)
        port map (clock, zera_cont_inicial, inicia_cont_inicial, open, iniciar_estimulo);

		  
	 reset_interno <= resposta or reset;
    LATCH: latch_sr port map (reset_interno, estimulo_intermediario, pulso);

  
    FSM: interface_FSM_v4
        port map (
            clock, reset, iniciar, resposta, iniciar_estimulo,  -- inputs
            erro_intermediario, estimulo_intermediario, ligado_intermediario, zera_cont_inicial, inicia_cont_inicial, pronto, estado, open, open);

    erro <= erro_intermediario;
	 estimulo <= estimulo_intermediario;
	 ligado <= ligado_intermediario;
	 
	 
    -- depuração
    db_clock <= clock;
    db_erro <= erro_intermediario;
    db_estimulo <= estimulo_intermediario;
end architecture;
