#include <stdio.h>
#include <stdlib.h>
#include "verilated.h"
#include "Vthruwire.h"

int main(int argc, char **argv) {
    // Call commandArgs first!
    Verilated::commandArgs(argc, argv);

    // Instantiate our design
    Vthruwire *tb = new Vthruwire;
    // Your logic here
    // Now run the design thru 5 timesteps
    for(int k = 0; k < 20; k++) {
        // We’ll set the switch input
        // to the LSB of our step
        tb->i_sw = k & 0x1ff;
        tb->eval();

        // Now let’s print our results
        printf("k = %2d, ", k);
        printf("sw = %03x, ", tb->i_sw);
        printf("led = %03x\n", tb->o_led);
    }
}