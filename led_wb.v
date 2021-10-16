// verilog
`default_nettype none

module led_wb(i_clk, i_cyc, i_stb, i_we, i_addr, i_data, o_stall, o_ack, o_data, o_led);
    // Wishbone interface
    /* verilator lint_off UNUSED */
    input wire      i_cyc;
    /* verilator lint_on  UNUSED */
    input wire      i_clk, i_stb, i_we;
    input wire [15:0]   i_addr;
    /* verilator lint_off UNUSED */
    input wire [15:0]   i_data;
    /* verilator lint_on  UNUSED */
    output wire     o_stall;
    output reg      o_ack;
    output wire [15:0]  o_data;
    output reg [7:0]    o_led;
    // -----------------

    wire            tx_begin = (i_stb)&&(i_we)&&(!busy)&&(i_addr==0); 
    reg [3:0]       index; 
    wire            dir; // 0 - left, 1 - right
    wire            busy = (index != 0);
    /* verilator lint_on  UNUSED */
    
    initial o_ack = 1'b0;
    always @(posedge i_clk) begin
        if (tx_begin)
        begin // start the counter
            o_led <= 1;
            index <= 1;
            o_ack <= 1'b1;
        end
        else if ((i_stb)&&(!i_we)&&(i_addr==0)) // read request?
            o_ack <= 1'b1;
        else
            o_ack <= 1'b0;
    end
    always @(posedge i_clk) begin
        if (index == 4'hF)
        begin
            index <= 0; // goes to IDLE
            o_led <= 0;
        end
        else if (index != 0)
        begin
            // count and shift
            index <= index + 1'b1;
            if (dir) 
                o_led <= { 1'b0, o_led[7:1] } ;
            else
                o_led <= { o_led[6:0], 1'b0 } ;
        end;
    end

    assign  o_stall = (busy)&&(i_we);
    assign  o_data  = { 12'h0, index }; // { 8'h0, o_led };
    assign  dir = index[3];

    initial index = 4'h0; // index reflects state
    initial o_led = 8'h0; // initially we're dark

    `ifdef FORMAL
        initial i_cyc = 1'b0;
        initial i_addr = 0;
        initial i_data = 0;
        initial i_we = 1'b0;
        initial i_stb = 1'b0;
    //--
    always @(posedge i_clk) begin
        assert(index <= 4'hF);
    end
    always @(posedge i_clk) begin
        if (i_cyc)
            assert(o_ack == (index == 4'hF));
    end
    always @(posedge i_clk) begin
        assert(o_stall == (index != 0));
    end
    always @(posedge i_clk) begin
        assert(tx_begin == ((i_stb)&&(!o_stall)));
    end
    always @(posedge i_clk) begin
        if (i_stb) 
            assert(i_cyc == 1'b1);
    end
    `endif // FORMAL
endmodule

