// Verilog, PPS-I
// Can we get an LED to blink once per second?
// When CLOCK_RATE_HZ/2 ticks have passed, the LED will toggle
// * This structure is known as an integer clock divider  ̋ 
// * It offers an exact division
//
`default_nettype none

module pps1(i_clk, o_led);
    parameter CLOCK_RATE_HZ = 100;

    input   wire i_clk;
    output  reg  o_led;

    reg [$clog2(CLOCK_RATE_HZ):0] counter;
    initial counter = 0;

    always  @(posedge i_clk)
        if (counter >= CLOCK_RATE_HZ/2-1)
        begin
            counter <= 0;
            o_led <= !o_led;
        end
        else
            counter <= counter + 1'b1;

endmodule;
