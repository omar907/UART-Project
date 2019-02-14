library verilog;
use verilog.vl_types.all;
entity UART_Receiver is
    generic(
        idle            : vl_logic_vector(1 downto 0) := (Hi0, Hi0);
        receiving       : vl_logic_vector(1 downto 0) := (Hi0, Hi1);
        wait_stop       : vl_logic_vector(1 downto 0) := (Hi1, Hi0);
        stop            : vl_logic_vector(1 downto 0) := (Hi1, Hi1)
    );
    port(
        din             : in     vl_logic;
        dnum            : in     vl_logic;
        snum            : in     vl_logic;
        bd_rate         : in     vl_logic_vector(1 downto 0);
        par             : in     vl_logic_vector(1 downto 0);
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        data            : out    vl_logic_vector(7 downto 0);
        error           : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of idle : constant is 2;
    attribute mti_svvh_generic_type of receiving : constant is 2;
    attribute mti_svvh_generic_type of wait_stop : constant is 2;
    attribute mti_svvh_generic_type of stop : constant is 2;
end UART_Receiver;
