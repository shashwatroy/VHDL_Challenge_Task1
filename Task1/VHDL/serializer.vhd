library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;


entity serializer is
    port(
        clk_in       : in  std_logic;
        bit_clock    : in  std_logic;
        reset        : in  std_logic;  
        link_trained : in  std_logic;   
        depth_sel    : in  std_logic_vector (1  downto 0);    
        data_in      : in  std_logic_vector (11 downto 0);
        clk_out      : out std_logic := '0';           
        data_out     : out std_logic := '0';
        ready        : out std_logic := '0'  
        );

end serializer;


architecture rtl of serializer is
    
    constant test_pattern : std_logic_vector (11 downto 0) := "101110101111";
    
    signal shift_reg  : std_logic_vector (11 downto 0) := test_pattern;
    signal counter    : std_logic_vector (3  downto 0) := (others => '0');
    signal bit_depth  : std_logic_vector (3  downto 0) := (others => '0');
    signal ddr_bit    : std_logic_vector (1 downto 0);
    
    signal linked_buf : std_logic := '0'; 
    signal sync_rst   : std_logic := '0';

begin
    
    
    with depth_sel select bit_depth <=
        "0111" when "00",
        "1001" when "01",
        "1011" when "10",
        "0111" when others;
    
    
    clk_out  <= bit_clock;  
    
    
    sync_rst <= reset when rising_edge(clk_in);
    
     
    ddr_bit(0) <= shift_reg(11) when rising_edge(clk_in) and sync_rst = '0';
    ddr_bit(1) <= shift_reg(10) when falling_edge(clk_in) and sync_rst = '0';
    data_out   <= ddr_bit(1) when clk_in='1' and reset = '0' else ddr_bit(0);
    

    
    train_proc : process(clk_in)
    begin
        if rising_edge(clk_in) then
            if sync_rst = '1' then
                ready      <= '0';
                linked_buf <= '0';
            
            else
                if counter = bit_depth(3 downto 2) - '1' then
                    ready <= link_trained;
                    linked_buf <= link_trained;
                
                else
                    ready <= '0';
                
                end if;
            end if;
         end if;
    end process;

    timing_proc : process(clk_in)
    begin
        if rising_edge(clk_in)then
            if sync_rst ='1' then
                counter <= (others => '0');
            
            else
                if counter = bit_depth(3 downto 1) then
                    counter <= (others => '0'); 
                
                else
                    counter <= counter + 1;
                
                end if;
            end if;
        end if;
    end process;

    data_out_proc : process(clk_in)
    begin
        if falling_edge(clk_in) then
            if sync_rst ='1' then
                shift_reg <= test_pattern;
            
            elsif counter = "0000" then
                if linked_buf='1' then
                    shift_reg <= data_in;
                
                else 
                    shift_reg <= test_pattern;
                
                end if;
            else
                shift_reg(11 downto 2) <= shift_reg(9 downto 0); 
            
            end if;
        end if;
    end process;

end rtl;

