library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


entity deserializer is
    port( 
        clk_in       : in  std_logic;     
        reset        : in  std_logic; 
        data_in      : in  std_logic;                       
        depth_sel    : in  std_logic_vector (1  downto 0);      
        data_out     : out std_logic_vector (11 downto 0) := (others => '0');
        clk_out      : out std_logic := '0';            
        link_trained : out std_logic := '0' 
        ); 

end deserializer;


architecture rtl of deserializer is

    constant test_pattern : std_logic_vector (11 downto 0) := "101110101111";
    
    signal shift_reg : std_logic_vector (11 downto 0) := (others => '0');
    signal counter   : std_logic_vector (3  downto 0) := (others => '0');
    signal clk_en    : std_logic_vector (2  downto 0) := (others => '0');
    signal ddr_bit   : std_logic_vector (2  downto 0);
    
    signal linked    : std_logic := '0'; 
    signal clk_gen   : std_logic := '0';
    signal sync_rst  : std_logic := '0';
    
    signal bit_depth : natural;

begin
    
    with depth_sel select bit_depth <= 
        7  when "00",
        9  when "01",
        11 when "10",
        7  when others;
    
    sync_rst <= reset when rising_edge(clk_in);
    
    ddr_bit(2) <= data_in    when clk_in = '0' and reset = '0';
    ddr_bit(1) <= data_in    when falling_edge(clk_in) and sync_rst = '0';
    ddr_bit(0) <= ddr_bit(2) when falling_edge(clk_in) and sync_rst = '0';
    
    link_trained <= linked; 
    
    clk_gen <= '1' when counter >= ("1" & depth_sel(1)) else '0';
    clk_out <= clk_gen and clk_en(2) when rising_edge(clk_in);


    timing_proc : process(clk_in) 
    begin
        if rising_edge(clk_in) then
            if sync_rst = '1' then
                counter <= (others => '0');
                linked  <= '0';
                clk_en  <= "000";
            
            else
                if shift_reg(bit_depth downto 0) = test_pattern(11 downto 11-bit_depth) 
                   and linked = '0' then  
                    linked  <= '1';
                    counter <= "0001";   
                
                elsif counter = (depth_sel + "011") then 
                    counter   <= (others => '0');
                    clk_en(0) <= linked;     
                    clk_en(1) <= clk_en(0);   
                    clk_en(2) <= clk_en(1);  
                
                else      
                    counter <= counter + 1;

                end if;
            end if;
        end if;
    end process;

    data_out_proc : process(clk_in) 
    begin
        if rising_edge(clk_in) then
            if sync_rst = '1'  then
                shift_reg <= (others => '0');
                data_out  <= (others => '0');
            
            else
                shift_reg(bit_depth downto 2) <= shift_reg(bit_depth-2 downto 0);
                
                shift_reg(1) <= ddr_bit(0);  
                shift_reg(0) <= ddr_bit(1); 
                
                if counter = "0000" and clk_en(2) = '1' then 
                    data_out <= shift_reg(11 downto 0);
                
                end if;
            end if;
        end if;
    end process;

end rtl;

