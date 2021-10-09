// verilog
`default_nettype none
module led_walker(i_clk, o_led);
    input wire i_clk;
    output reg[7:0] o_led;

    reg [3:0] counter; 
    wire       dir; // 0 - left, 1 - right
    
    always @(posedge i_clk)
    begin
        if (counter == 4'hE)
        begin
            o_led <= 1;
            counter <= 1;
        end
        else
        begin
            counter <= counter + 1'b1;
            if (dir) 
                o_led <= { 1'b0, o_led[7:1] } ;
            else
                o_led <= { o_led[6:0], 1'b0 } ;
        end;
    end;
    assign  dir = counter[3];
    initial counter = 4'h1;
    initial o_led = 8'h1;
endmodule;
