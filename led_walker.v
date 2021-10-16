// verilog
//`default_nettype none
`ifndef CLK_RATE_HZ
`define CLK_RATE_HZ 10
`endif

module led_walker(i_clk, o_led);
    input wire i_clk;
    output reg[7:0] o_led;

    reg [3:0] index; 
    wire      dir; // 0 - left, 1 - right
    reg [7:0] wait_cnt; // wait counter
    /* verilator lint_on  UNUSED */
    reg       stb; // strobe
    
    always @(posedge i_clk)
    begin
        if (wait_cnt == 0)
            wait_cnt <= `CLK_RATE_HZ-1;
        else
            wait_cnt <= wait_cnt - 1'b1;
    end
    always @(posedge i_clk)
    begin
        stb <= 1'b0;
        if (wait_cnt == 0)
            stb <= 1'b1;
    end
    always @(posedge i_clk)
        if (stb)
        begin
            if (index == 4'hE)
            begin
                o_led <= 1;
                index <= 1;
            end
            else
            begin
                index <= index + 1'b1;
                if (dir) 
                    o_led <= { 1'b0, o_led[7:1] } ;
                else
                    o_led <= { o_led[6:0], 1'b0 } ;
            end;
        end


    assign  dir = index[3];
    initial index = 4'h1;
    initial o_led = 8'h1;
    initial wait_cnt = 8'h0;
    initial stb = 0;

    `ifdef FORMAL
    always @(posedge i_clk) begin
        assert(index <= 4'hE);
    end
    always @(posedge i_clk) begin
        assert(stb == (wait_cnt == 0));
        //assert(wait_cnt <= `CLK_RATE_HZ - 1);
    end
    `endif
endmodule

