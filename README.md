# Introduction

This repository contains a code I wrote (copy-pasted) from the following
tutorial:

"Verilog, Formal Verification and Verilator Beginner's Tutorial"
    http://zipcpu.com/tutorial/


I ran code on MacOS having Verilator installed from MacPorts.
Also, I tried to edit/compile code from VS Code IDE.

# Workflow

1. Create a simple Verilog module like thruwire

2. Generate C/C++ Code by Verilog module

        $ verilator -Wall -cc ${file}

You will get a set of `Vthruwire*` files generated into `obj_dir`

3. Build C/C++ library generated at previous step:

        $ cd obj_dir && make -f V${fileBasenameNoExtension}.mk

In result you will get `Vthruwire__ALL.a` -- static C/C++ librry

4. Write a test-bench in C/C++ using Verilator API, save it into `thruwire.cpp`

5. Compile test-bench code `thruwire.cpp` with static C/C++ library stored in `obj_dir/`

        $ clang++ -O2 -I/opt/local/share/verilator/include -Iobj_dir/ \
                /opt/local/share/verilator/include/verilated.cpp \
                ${file} \
                obj_dir/V${fileBasenameNoExtension}__ALL.a \
                -o ${fileDirname}/${fileBasenameNoExtension}

# Compile with trace

1. Generate C/C++ Code by Verilog module with trace support

        $ verilator -Wall --trace -cc ${file}

2. Build C/C++ library generated at previous step, 
   but it depends on clang++, i.e. doesn't compile by g++

        $ cd obj_dir && make -f V${fileBasenameNoExtension}.mk

3. Write a test bench C/C++ code with trace to VCD, compile it

        $ clang++ -O2 -I/opt/local/share/verilator/include -Iobj_dir/ \
                /opt/local/share/verilator/include/verilated.cpp \
                /opt/local/share/verilator/include/verilated_vcd_c.cpp \
                ${file} \
                obj_dir/V${fileBasenameNoExtension}__ALL.a \
                -o ${fileDirname}/${fileBasenameNoExtension}

BTW, Apple clang++ failed to compile

