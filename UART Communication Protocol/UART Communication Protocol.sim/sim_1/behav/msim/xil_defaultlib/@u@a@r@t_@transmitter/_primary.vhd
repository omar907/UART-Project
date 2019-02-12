library verilog;
use verilog.vl_types.all;
entity UART_Transmitter is
    generic(
        idle            : vl_logic_vector(1 downto 0) := (Hi0, Hi0);
        sending         : vl_logic_vector(1 downto 0) := (Hi0, Hi1);
        stop            : vl_logic_vector(1 downto 0) := (Hi1, Hi0);
        transition      : vl_logic_vector(1 downto 0) := (Hi1, Hi1)
    );
    port(
        dout            : out    vl_logic;
        data            : in     vl_logic_vector(7 downto 0);
        start           : in     vl_logic;
        dnum            : in     vl_logic;
        snum            : in     vl_logic;
        bd_rate         : in     vl_logic_vector(1 downto 0);
        par             : in     vl_logic_vector(1 downto 0);
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        en              : in     vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of idle : constant is 2;
    attribute mti_svvh_generic_type of sending : constant is 2;
    attribute mti_svvh_generic_type of stop : constant is 2;
    attribute mti_svvh_generic_type of transition : constant is 2;
end UART_Transmitter;
