#!/usr/bin/make -f

BINARIES:=thruwire blinky blinky_tr dimmer dimmer_tr strobe pps1 pps2
VOPTS:=-Wall -cc

ifeq ($(OS),Windows_NT)
	CCFLAGS += -D WIN32
	CXX := clang++
else
	UNAME_S := $(shell uname -s)
	ifeq ($(UNAME_S),Linux)
		VERILATOR := verilator
		CXX := clang++
		VINC := /usr/share/verilator/include
	endif
	ifeq ($(UNAME_S),Darwin)
		#CXXFLAGS += -std=c++14
		VERILATOR := /opt/local/bin/verilator
		# CXX := /opt/local/bin/clang++-mp-10
		VINC := /opt/local/share/verilator/include
		# if you run verilator with --trace
		# you have to use clang++
		# else g++ is OK
	endif
endif



out_dir/V%.cpp:		%.v
	$(VERILATOR) $(VOPTS) $<

all: 	$(BINARIES)

out_dir/Vblinky.cpp:	blinky.v

thruwire:	thruwire.v thruwire_tb.cpp
	bin/build.sh -o $@ $^ 

blinky:	blinky.v blinky_tb.cpp
	bin/build.sh -o $@ $^ 

blinky_tr:	blinky.v blinky_tr_tb.cpp
	bin/build.sh -T -o $@ $^ 

dimmer:	dimmer.v dimmer_tb.cpp
	bin/build.sh -GWIDTH=26 -o $@ $^ 

dimmer_tr:	dimmer.v dimmer_tr_tb.cpp
	bin/build.sh -T -GWIDTH=26 -o $@ $^ 

strobe:	strobe.v strobe_tb.cpp
	bin/build.sh -GWIDTH=8 -o $@ $^ 

pps1:	pps1.v pps1_tb.cpp
	bin/build.sh -o $@ $^ 

pps2:	pps2.v pps2_tb.cpp
	bin/build.sh -o $@ $^ 

clean:
	@rm -rf obj_dir/
	@rm -f *.vcd $(BINARIES)
