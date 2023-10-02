#include <stdio.h>
#include <stdlib.h>
#include "verilated.h"
#include "verilated_vcd_c.h"
#include "Vblinky.h"

void tick(int tickcount, Vblinky *tb, VerilatedVcdC* tfp)
{
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
}

int main(int argc, char **argv)
{
    unsigned tickcount = 0;
    int last_led;
    printf("blinky_tb started\n");
    // Call commandArgs first!
    // Verilated::commandArgs(argc, argv);
    VerilatedContext* contextp = new VerilatedContext;
    contextp->commandArgs(argc, argv);

    // Instantiate our design
    Vblinky *tb = new Vblinky{contextp};
    // Generate a trace
    Verilated::traceEverOn(true);
    VerilatedVcdC* tfp = new VerilatedVcdC;
    tb->trace(tfp, 99);
    tfp->open("blinkytrace.vcd");

    last_led = tb->o_led;
    // Your logic here
    // Now run the design thru 5 timesteps
    for(int k = 0; k < (1<<12); k++) {
        // toogle the clock
        tick(++tickcount, tb, tfp);

        // Now let’s print the LEDs value
        // anytime it changes
        if (last_led != tb->o_led) {
            printf("k = %7d, ", k);
            printf("led = %d\n", tb->o_led);
        }
        last_led = tb->o_led;
    }
    delete contextp;
}
