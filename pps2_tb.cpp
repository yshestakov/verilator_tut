#include <stdio.h>
#include <stdlib.h>
#include "verilated.h"
#include "Vpps2.h"

void tick(Vpps2 *tb)
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
    int last_led ;
    // Call commandArgs first!
    Verilated::commandArgs(argc, argv);

    // Instantiate our design
    Vpps2 *tb = new Vpps2;
    last_led = tb->o_led;
    // Your logic here
    for(int k = 0; k < (1<<10); k++) {
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
}
