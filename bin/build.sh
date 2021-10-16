#!/bin/bash
# generate C++ code by Verilog with trace
# compile module and corresponding test-bench
VERILATOR=$(type -path verilator)
if [ -z "$VERILATOR" ] ; then
    echo "verilator is not in \$PATH" >&2
    exit 1
fi
VPREFIX=${VERILATOR%/bin/verilator}

case $(uname -s) in
    Darwin)
        CXX=/opt/local/bin/clang++-mp-10
        ;;
    Linux)
        CXX=clang++
        ;;
esac
VINC=$VPREFIX/share/verilator/include
export CXX

VLTRFILES=$VINC/verilated.cpp 
while getopts "G:o:hT" arg; do
    case $arg in
    h)
        echo "Usage: $0 [-o exec_name] module.v module_tb.cpp" >&2
        ;;
    o)
        EXEFN=$OPTARG
        ;;
    G)
        VOPT="$VOPT -G$OPTARG"
        COPT="$COPT -D$OPTARG"
        ;;
    T)
        VOPT="$VOPT --trace"
        VLTRFILES="$VLTRFILES $VINC/verilated_vcd_c.cpp"
        ;;
  esac
done
shift $((OPTIND-1))
if [ $# -lt 2 ]; then
    echo "Usage: $0 module.v module_tb.cpp [exec_name]" >&2
    exit 1
fi
VFN=$1
[[ $VFN =~ .v$ ]]
if [ $? -ne 0 -o ! -e $VFN ] ; then
   echo "$VFN: not a Verilog file" >&2
   exit 2
fi
shift
BASEFN=$(basename $VFN |sed -e 's/\.v$//')
TBFN=$1
[[ $TBFN =~ tb.cpp$ ]]
if [ $? -ne 0 ] ; then
    echo "$VFN: not a c++ file" >&2
    exit 3
fi
if [ -z "$EXEFN" ] ; then
    EXEFN=$BASEFN
fi
set -e
ALIB=obj_dir/V${BASEFN}__ALL.a
set -x
if [ ! -e $ALIB -o $VFN -nt $ALIB ] ; then
    $VERILATOR $VOPT -Wall -cc $VFN
    (cd obj_dir && make -f V${BASEFN}.mk)
fi
$CXX $COPT -I $VINC \
    -I obj_dir/ \
    $VLTRFILES \
    $TBFN \
    $ALIB \
    -o $EXEFN
