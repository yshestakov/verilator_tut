// Verilog, PPS-II
// Can we get an LED to blink once per second?
// * After CLOCK_RATE_HZ clock edges, the counter will roll over  ̋ 
// * The divide by four above, on both numerator and
// * denominator, is just to keep this within 32-bit arithmetic
//    INCREMENT = (2**32)/CLOCK_RATE_HZ
// * This is called a fractional clock divider
//    - The division isn’t exact
//    - It’s often good enough
`default_nettype none

module pps2(i_clk, o_led);
    parameter CLOCK_RATE_HZ = 100;
    parameter N_BITS = $clog2(CLOCK_RATE_HZ)+5;
    parameter [N_BITS:0] INCREMENT = (1<<(N_BITS-1))/(CLOCK_RATE_HZ/4);

    input   wire i_clk;
    output  wire o_led;

    reg [N_BITS:0] counter;
    initial counter = 0;

    always  @(posedge i_clk)
        counter <= counter + INCREMENT;

    assign o_led = counter[N_BITS];

endmodule;
