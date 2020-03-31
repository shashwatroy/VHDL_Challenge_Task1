library ieee;
use ieee.std_logic_1164.all;

library unisim;
use unisim.vcomponents.all;


entity serdes_top is
    port( 
        clk_in      : in  std_logic;                  
        reset_ser   : in  std_logic;    
        reset_deser : in  std_logic;    
        depth_sel   : in  std_logic_vector (1  downto 0); 
        data_in     : in  std_logic_vector (11 downto 0);
        data_out    : out std_logic_vector (11 downto 0) := (others => '0');
        clk_out     : out std_logic := '0';                
        ready       : out std_logic := '0' 
        );

end serdes_top;


architecture rtl of serdes_top is

    component serializer
        port(
            clk_in       : in  std_logic;
            bit_clock    : in  std_logic;
            reset        : in  std_logic;
            link_trained : in  std_logic;
            depth_sel    : in  std_logic_vector (1  downto 0);
            data_in      : in  std_logic_vector (11 downto 0);
            clk_out      : out std_logic;
            data_out     : out std_logic;
            ready        : out std_logic
            );

    end component;
   
    component deserializer
        port(
            clk_in       : in  std_logic;
            reset        : in  std_logic;
            data_in      : in  std_logic;
            depth_sel    : in  std_logic_vector (1  downto 0);
            data_out     : out std_logic_vector (11 downto 0);
            clk_out      : out std_logic;
            link_trained : out std_logic
            );
    
    end component;
  
 
    signal link_trained : std_logic;
    signal data_out_buf : std_logic;
    signal clk_out_buf  : std_logic;
    signal clk_in_bufg  : std_logic;
    signal clk_fb_out   : std_logic;
    signal clk_fb_in    : std_logic;
    signal clk_out_0    : std_logic;
    signal clk_out_1    : std_logic;
    signal rst_ser      : std_logic;
    signal rst_deser    : std_logic;
    signal pll_locked   : std_logic;

begin
    
    clk_fb_in <= clk_fb_out;  
    rst_ser   <= reset_ser or not pll_locked;
    rst_deser <= reset_deser or not pll_locked;
 
    
    bufg_inst : bufg
    port map(
        o => clk_in_bufg, 
        i => clk_in   
        );

    
    plle2_base_inst : plle2_base
    generic map (
        bandwidth => "optimized", 

        clkfbout_mult  => 9, 
        clkfbout_phase => 0.0,
        clkin1_period  => 10.0,       

        clkout0_divide => 3, 
        clkout1_divide => 3, 

        clkout0_duty_cycle => 0.5,          
        clkout1_duty_cycle => 0.5,
        
        clkout0_phase => 0.0,        
        clkout1_phase => -75.0,  
        divclk_divide => 1,          
        
        ref_jitter1  => 0.0,         
        startup_wait => "false"  
        )

    port map (
        clkout0   => clk_out_0, 
        clkout1   => clk_out_1, 
        clkfbout  => clk_fb_out,
        locked    => pll_locked,
        clkin1    => clk_in_bufg,
        pwrdwn    => '0',
        rst       => '0',
        clkfbin => clk_fb_in 
        );

    
    ser_inst : serializer
    port map (
        clk_in       => clk_out_0,
        bit_clock    => clk_out_1,
        reset        => rst_ser,
        link_trained => link_trained,
        depth_sel    => depth_sel,
        data_in      => data_in,
        clk_out      => clk_out_buf,
        data_out     => data_out_buf,
        ready        => ready
        );

    
    deser_inst : deserializer
    port map (
        clk_in       => clk_out_buf,
        reset        => rst_deser,
        data_in      => data_out_buf,
        depth_sel    => depth_sel,
        data_out     => data_out,
        clk_out      => clk_out,
        link_trained => link_trained
        );

end rtl;

