library IEEE;
use IEEE.std_logic_1164.all;

entity medidor_largura is
	port(
		clock, reset : in std_logic;
		liga, sinal : in std_logic;
		display0 : out std_logic_vector(6 downto 0); --digito 0
		display1 : out std_logic_vector(6 downto 0); --digito 1
		display5 : out std_logic_vector(6 downto 0); --estado
		fim : out std_logic;
		pronto : out std_logic;
		db_largura : out std_logic_vector(7 downto 0);
		db_clock : out std_logic;
		db_zeraCont : out std_logic;
		db_contacont : out std_logic
	);
end medidor_largura;


architecture medidor_largura_arch of medidor_largura is	
	
	component controlador is
   		port ( 
			clock, reset		: in  STD_LOGIC;
        	liga, sinal			:  in  STD_LOGIC;
          	zeraCont, contaCont	: out STD_LOGIC;
         	pronto				: out STD_LOGIC;
          	estado				: out STD_LOGIC_VECTOR(3 downto 0)
        );
	end component controlador;

	component contador8bits is
   		port (
        	clock : in  std_logic;
        	zera  : in  std_logic;
       		conta : in  std_logic;
        	Q     : out std_logic_vector (7 downto 0);
       		rco   : out std_logic 
  		 );
	end component contador8bits;	

	component hexa7seg is
   		port (
        	hexa : in std_logic_vector(3 downto 0);
        	sseg : out std_logic_vector(6 downto 0)
    	);
	end component hexa7seg;

	signal zera_interno, conta_interno : std_logic;
	signal zera_inv : std_logic;
	signal display5_interno : std_logic_vector(3 downto 0);
	signal display0_interno, display1_interno: std_logic_vector(3 downto 0);
	signal display_interno: std_logic_vector(7 downto 0);

begin
	
	UC: component controlador port map(clock, reset, liga, sinal, zera_interno, conta_interno, pronto, display5_interno);
	DIS_EST: component hexa7seg port map(display5_interno, display5); 

	zera_inv <= not zera_interno;

	CONT: component contador8bits port map(clock, zera_inv, conta_interno, display_interno, fim);

	display0_interno <= display_interno(3 downto 0);
	display1_interno <= display_interno(7 downto 4);

	DIS1: component hexa7seg port map(display1_interno, display1);
	DIS0: component hexa7seg port map(display0_interno, display0);

	db_largura <= display_interno;
	db_clock <= clock;
	db_zeraCont <= zera_interno;
	db_contacont <= conta_interno;
	
end architecture medidor_largura_arch;




