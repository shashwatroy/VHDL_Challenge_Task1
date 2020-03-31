library ieee;
use ieee.std_logic_1164.all;
 

entity serdes_top_tb is
end serdes_top_tb;
 

architecture behavioral of serdes_top_tb is 

    component serdes_top
        port(
            clk_in      : in   std_logic;
            reset_ser   : in   std_logic;
            reset_deser : in   std_logic;
            depth_sel   : in   std_logic_vector (1  downto 0);
            data_in     : in   std_logic_vector (11 downto 0);
            data_out    : out  std_logic_vector (11 downto 0);
            clk_out     : out  std_logic;
            ready       : out  std_logic
            );

    end component;
    
    signal clk_in       : std_logic := '0';
    signal reset_ser    : std_logic := '0';
    signal reset_deser  : std_logic := '0';
    signal depth_sel    : std_logic_vector (1  downto 0) := (others => '0');
    signal data_in      : std_logic_vector (11 downto 0) := (others => '0');  
  
    signal data_out     : std_logic_vector (11 downto 0);
    signal clk_out      : std_logic;
    signal ready        : std_logic;

    constant clk_period : time := 10 ns;
 
begin
    
    uut: serdes_top 
    port map (
        clk_in      => clk_in,
        reset_ser   => reset_ser,
        reset_deser => reset_deser,
        depth_sel   => depth_sel,
        data_in     => data_in,
        data_out    => data_out,
        clk_out     => clk_out,
        ready       => ready
        );
     
    clk_in_process :process
    begin
        clk_in <= '0';
        wait for clk_period/2;
        
        clk_in <= '1';
        wait for clk_period/2;
   
    end process;
    
    data_send :process
        begin  
            wait until rising_edge(ready) and reset_ser = '0' and reset_deser = '0';
            data_in <= "101101101111";
            wait until rising_edge(ready) and reset_ser = '0' and reset_deser = '0';
            data_in <= "100001100011";
            wait until rising_edge(ready) and reset_ser = '0' and reset_deser = '0';
            data_in <= "101101101011";
            wait until rising_edge(ready) and reset_ser = '0' and reset_deser = '0';
            data_in <= "101001001000";
            wait until rising_edge(ready) and reset_ser = '0' and reset_deser = '0';
            data_in <= "101100000011";
            wait until rising_edge(ready) and reset_ser = '0' and reset_deser = '0';
            data_in <= "100101010011";
            wait until rising_edge(ready) and reset_ser = '0' and reset_deser = '0';
            data_in <= "100001101111";
            wait until rising_edge(ready) and reset_ser = '0' and reset_deser = '0';
            data_in <= "101001100011";
            wait until rising_edge(ready) and reset_ser = '0' and reset_deser = '0';
            data_in <= "100101101011";
            wait until rising_edge(ready) and reset_ser = '0' and reset_deser = '0';    
            data_in <= "101101101000";
            wait until rising_edge(ready) and reset_ser = '0' and reset_deser = '0';
            data_in <= "101000000011";
            wait until rising_edge(ready) and reset_ser = '0' and reset_deser = '0';
            data_in <= "111101010011";      
        
        end process;
        
    stim_proc: process
    begin
        

        reset_ser   <= '1';
        reset_deser <= '1';
        depth_sel   <= "00";
        wait for 650 ns; 
        
        reset_ser   <= '0';
        reset_deser <= '0';
        wait for 500 ns;
        
        reset_deser <= '1';
        depth_sel   <= "01";
        wait for 150 ns;
        
        reset_deser <= '0';
        wait for 500 ns;
        
        reset_ser   <= '1';
        depth_sel   <= "10";
        wait for 15 ns;
        
        reset_deser <= '1';
        wait for 150 ns;
        
        reset_ser   <= '0';
        wait for 20 ns;
        
        reset_deser <= '0';
        wait for 500 ns;
        
        reset_ser   <= '1';
        reset_deser <= '1';
        wait;
    
    end process;

end behavioral;
