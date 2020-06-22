#!/bin/bash
if [ $# -eq 0 ]; then
    echo "Usage: $0 module_tb.cpp" >&2
    exit 1
fi
VFN=$1
if [ ! -f "$VFN" ] ; then
    echo "$VFN: is not a file" >&2
    exit 2
fi
BASEFN=${VFN%.cpp}
BASEFN=${BASEFN%_tb*}
#CXX=g++
#CXX=/opt/local/bin/g++-mp-9
CXX=/opt/local/bin/clang++-mp-9.0
VINC=/opt/local/share/verilator/include
$CXX -I $VINC \
    -I obj_dir/ \
    $VINC/verilated.cpp \
    $VINC/verilated_vcd_c.cpp \
    $VFN \
    obj_dir/V${BASEFN}__ALL.a \
    -o $BASEFN
