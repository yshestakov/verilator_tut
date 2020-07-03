#include <stdio.h>
#include <stdlib.h>
#include "verilated.h"
#include "Vstrobe.h"

#if !defined(WIDTH)
  #define WIDTH 12
#endif

void tick(Vstrobe *tb)
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
    Vstrobe *tb = new Vstrobe;
    last_led = tb->o_led;
    // Your logic here
    int tics = (1<<WIDTH) * 3;
    for(int k = 0; k < tics; k++) {
        // toogle the clock
        tick(tb);

        // Now let’s print the LEDs value
        // anytime it changes
        if (last_led != tb->o_led) {
            printf("k = 0o%05o, ", k);
            printf("led = %d\n", tb->o_led);
        }
        last_led = tb->o_led;
    }
}
