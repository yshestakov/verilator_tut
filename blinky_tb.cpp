#include <stdio.h>
#include <stdlib.h>
#include "Vblinky.h"
#include "verilated.h"

void tick(Vblinky *tb)
{
    // The following eval() looks
    // redundant ... many of hours
    // of debugging reveal its not
    tb->eval();
    tb->i_clk = 1;
    tb->eval();
    tb->i_clk = 0;
    tb->eval();
}

int main(int argc, char **argv)
{
    // Call commandArgs first!
    // Verilated::commandArgs(argc, argv);
    VerilatedContext* contextp = new VerilatedContext;
    contextp->commandArgs(argc, argv);

    // Instantiate our design
    Vblinky *tb = new Vblinky{contextp};
    int last_led = tb->o_led;
    // Your logic here
    // Now run the design thru 5 timesteps
    for(int k = 0; k < (1<<12); k++) {
        // toogle the clock
        tick(tb);

        // Now let’s print the LEDs value
        // anytime it changes
        if (last_led != tb->o_led) {
            printf("k = %7d, ", k);
            printf("led = %d\n", tb->o_led);
        }
        last_led = tb->o_led;
    }
    delete tb;
    delete contextp;
}
