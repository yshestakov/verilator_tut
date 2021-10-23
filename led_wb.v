// verilog
//`default_nettype none
`ifndef CLK_RATE_HZ
`define CLK_RATE_HZ 4
`endif

module led_wb(i_clk, i_cyc, i_stb, i_we, i_addr, i_data, o_stall, o_ack, o_data);
    // Wishbone interface
    /* verilator lint_off UNUSED */
    input wire      i_cyc;
    /* verilator lint_on  UNUSED */
    input wire      i_clk, i_stb, i_we;
    /* verilator lint_off UNUSED */
    input wire [15:0]   i_addr;
    input wire [15:0]   i_data;
    /* verilator lint_on  UNUSED */
    output wire     o_stall;
    output reg      o_ack;
    output wire [15:0]  o_data;
    reg [7:0]    o_led;
    // -----------------

    reg [3:0]       index;
    wire            dir; // 0 - left, 1 - right
    wire            busy;
    reg [7:0]       wait_cnt; // wait counter
    reg             stb; // strobe on wait_cnt == 0;
    /* verilator lint_off UNUSED */
    reg     f_past_valid;
    /* verilator lint_on  UNUSED */
    initial f_past_valid = 1'b0;
    always @(posedge i_clk)
        f_past_valid <= 1'b1;

    initial o_ack = 1'b0;
    always @(posedge i_clk)
        o_ack <= (i_stb)&&(!o_stall);

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

    // reg             tx_begin;
    wire    tx_begin;
    assign  tx_begin = (i_stb && i_we && (!o_stall));
    always @(posedge i_clk) begin
        // tx_begin <= (i_stb && i_we && (!o_stall) && (i_addr==0));
        //if (tx_begin && stb)
        if (tx_begin)
        begin // start the counter
            o_led <= 1;
            index <= 1;
            wait_cnt <= `CLK_RATE_HZ-2;
            stb <= 1'b0;
        end
    end
    always @(posedge i_clk) begin
        if (stb)
        begin
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
            end
        end
    end

    assign  busy = (index != 0);
    assign  o_stall = (busy)&&(i_we);
    assign  o_data  = { 4'h0, index, o_led};
    assign  dir = index[3];

    initial index = 4'h0; // index reflects state
    initial o_led = 8'h0; // initially we're dark

    `ifdef FORMAL
        initial i_clk = 1'b0;
        initial i_cyc = 1'b0;
        initial i_addr = 0;
        initial i_data = 0;
        initial i_we = 1'b0;
        initial i_stb = 1'b0;
    //--
    always @(*)
        assert(index <= 4'hF);
    always @(*)
        assert(o_stall == (index != 0));
    always @(posedge i_clk)
        if (i_cyc)
            assert(o_ack == (index == 4'hF));
    always @(posedge i_clk)
        assert(tx_begin == ((i_stb)&&(!o_stall)));
    always @(posedge i_clk)
        if (i_stb)
            assert(i_cyc);
    always @(posedge i_clk)
        if ((f_past_valid) && $past(i_stb) && $past(i_we) && $past(!o_stall))
        begin
            assert(index == 1'b1);
            assert(busy);
        end
    always @(posedge i_clk)
        if ((f_past_valid) && $past(busy) && $past(index<4'hF))
        begin
            assert(index == $past(index)+1);
        end
    // bus assertions
    // a) it should be IDLE initially
    initial assume(!i_cyc);
    // b) i_stb is only allowed if i_cyc
    always @(*)
        if (!i_cyc)
            assume(!i_stb);
    // c) when i_cyc goes high, so too does i_stb
    always @(posedge i_clk)
        if ( (!$past(i_cyc)) && (i_cyc))
            assume(i_stb);
    // d) if request is stalled
    always @(posedge i_clk)
        if ((f_past_valid) && $past(i_stb) && $past(o_stall))
        begin
            assume(i_stb);
            assume(i_we == $past(i_we));
            assume(i_addr == $past(i_addr));
            if (i_we)
                assume(i_data == $past(i_data));
        end
    // d) o_ack should be set
    always @(posedge i_clk)
        if ((f_past_valid) && $past(i_stb) && $past(!o_stall))
        begin
            assert(o_ack);
        end
    // cover && $past

    always @(posedge i_clk)
        if (f_past_valid)
        begin
            cover((!busy) && $past(busy));
        end

    // clock divider
    always @(posedge i_clk) begin
        if (f_past_valid)
        begin
            if ($past(wait_cnt)==0)
            begin
                assert(stb);
                assert(wait_cnt==`CLK_RATE_HZ-1);
            end
            else
                assert(!stb);
        end
    end

    `endif // FORMAL
endmodule

