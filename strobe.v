// verilog
module strobe(i_clk, o_led);
    input wire i_clk;
    output wire o_led;
    parameter WIDTH=12;

    reg [WIDTH-1:0] counter; 
    
    always @(posedge i_clk)
        counter<=counter+ 1'b1;

    assign o_led = &counter[WIDTH-1:WIDTH-2];
endmodule;
