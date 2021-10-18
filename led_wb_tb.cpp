#include <stdio.h>
#include <stdlib.h>
#include "verilated.h"
#include "verilated_vcd_c.h"
#include "Vled_wb.h"

#define TOUT_TICKS 200

class MyTB {
    public:
        int             tickcount;
        Vled_wb         *tb;
        VerilatedVcdC   *tfp;

        MyTB(Vled_wb* _tb, VerilatedVcdC* _tfp) : tickcount(0), tb(_tb), tfp(_tfp) {}
        void        tick(void);

        uint16_t    wb_read(uint16_t a);
        void        wb_write(uint16_t a, uint16_t v);
};

void MyTB::tick()
{
    ++tickcount;
    // The following eval() looks
    // redundant ... many of hours
    // of debugging reveal its not
    tb->eval();
    if (tfp) // dump 2ns before the tick
        tfp->dump(tickcount * 10 - 2);
    tb->i_clk = 1;
    tb->eval();
    if (tfp) // tick every 10 ns
        tfp->dump(tickcount * 10);
    tb->i_clk = 0;
    tb->eval();
    if (tfp) {
        // Trailing edge dump
        tfp->dump(tickcount * 10 + 5);
        tfp->flush();
    }
    if (tickcount >= TOUT_TICKS) {
        printf("\nled_wb_tb timed out in %d ticks\n", tickcount);
        exit(1);
    }
    putchar('.');
}

uint16_t MyTB::wb_read(uint16_t a)
{
    tb->i_cyc = tb->i_stb = 1;
    tb->i_we = 0; tb->eval();
    tb->i_addr = a;
    // make the read WB request
    while (tb->o_stall) {
        tick();
    }
    tick();
    tb->i_stb = 0;
    // wait for o_ack
    while(!tb->o_ack)
        tick();
    // idle the bus
    tb->i_cyc = 0;
    tb->eval();
    return tb->o_data;
}

void    MyTB::wb_write(uint16_t a, uint16_t v)
{
    tb->i_cyc = tb->i_stb = 1;
    tb->i_we = 1;
    // tb->eval();
    tb->i_addr = a;
    tb->i_data = v;
    // make the write WB request
    while (!tb->o_ack) 
        tick();
    tick();
    // idle the bus
    tb->i_stb = tb->i_cyc = 0;
    tb->i_we = 0;
    tb->eval();
}

int main(int argc, char **argv)
{
    printf("led_wb_tb started\n");
    // Call commandArgs first!
    Verilated::commandArgs(argc, argv);

    // Instantiate our design
    Vled_wb *tb = new Vled_wb;
    // Generate a trace
    Verilated::traceEverOn(true);
    VerilatedVcdC* tfp = new VerilatedVcdC;
    tb->trace(tfp, 99);
    tfp->open("led_wb.vcd");
    MyTB    *t  = new MyTB(tb, tfp);

    // Your logic here
    printf("Initial state is: 0x%04x\n", t->wb_read(0));
    for(int cyc = 0; cyc < 2; cyc++) {
        // wait 5 ticks
        for(int k=0; k<5; k++)
            t->tick();
        // start LED cyclinkg
        t->wb_write(0, 0);
        t->tick();
        // loop over WB transaction
        uint16_t    state, last_state = 0;
        uint8_t     last_led = 0;
        while ((state = t->wb_read(0))!=0) {
            if (state != last_state || tb->o_led != last_led) {
                printf("(tick %3d)(state %d)(o_led %02x)\n", t->tickcount, state, tb->o_led);
            }
            t->tick();
            last_state = state;
            last_led = tb->o_led;
        }
    }
    printf("led_wb_tb done in %d ticks\n", t->tickcount);
    t->tick();
}
