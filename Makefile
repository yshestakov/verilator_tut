#!/usr/bin/make -f

BINARIES:=thruwire blinky blinky_tr dimmer dimmer_tr strobe pps1 pps2 led_walker.elf led_wb.elf
VOPTS:=--cc --exe --build -Wall

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
		VERILATOR := verilator
		# VINC := /opt/local/share/verilator/include
		VINC := ${HOME}/Applications/oss-cad-suite/share/verilator/include
		#!!! if you run verilator with --trace
		#    you have to use clang++  else g++ is OK
	endif
endif



out_dir/V%.cpp:		%.v
	$(VERILATOR) -Wall -cc $<

all: 	$(BINARIES)

# out_dir/Vblinky.cpp:	blinky.v

thruwire:	thruwire.v thruwire_tb.cpp
	# bin/build.sh -o $@ $^
	$(VERILATOR) $(VOPTS) -o ../$@ $^

blinky:	blinky.v blinky_tb.cpp
	# bin/build.sh -o $@ $^
	$(VERILATOR) $(VOPTS) -o ../$@ $^

blinky_tr:	blinky.v blinky_tr_tb.cpp
	# bin/build.sh -T -o $@ $^
	$(VERILATOR) $(VOPTS) --trace -o ../$@ $^

dimmer:	dimmer.v dimmer_tb.cpp
	# bin/build.sh -T -GWIDTH=26 -o $@ $^
	$(VERILATOR) $(VOPTS) -o ../$@ -GWIDTH=26  $^

dimmer_tr:	dimmer.v dimmer_tr_tb.cpp
	# bin/build.sh -T -GWIDTH=26 -o $@ $^
	$(VERILATOR) $(VOPTS) --trace -o ../$@ -GWIDTH=26  $^

strobe:	strobe.v strobe_tb.cpp
	# bin/build.sh -GWIDTH=8 -o $@ $^
	$(VERILATOR) $(VOPTS) --trace -o ../$@ -GWIDTH=8  $^

pps1:	pps1.v pps1_tb.cpp
	# bin/build.sh -o $@ $^
	$(VERILATOR) $(VOPTS) -o ../$@ $^

pps2:	pps2.v pps2_tb.cpp
	# bin/build.sh -o $@ $^
	$(VERILATOR) $(VOPTS) -o ../$@ $^

stretch: stretch.v stretch_tr_tb.cpp
	# bin/build.sh -T -GWIDTH=8 -o $@ $^
	$(VERILATOR) $(VOPTS) --trace -GWIDTH=8 -o ../$@ $^

tooslow: tooslow.v tooslow_tr_tb.cpp
	# bin/build.sh -T -GNBITS=32 -o $@ $^
	$(VERILATOR) $(VOPTS) --trace -o ../$@ -GNBITS=32 $^

led_walker.elf:	led_walker.v led_walker_tb.cpp
	# bin/build.sh -T -o $@ $^
	$(VERILATOR) $(VOPTS) --trace -o ../$@ $^

led_wb.elf:	led_wb.v led_wb_tb.cpp
	# bin/build.sh -T -o $@ $^
	$(VERILATOR) $(VOPTS) --trace -o ../$@ $^

clean:
	@rm -rf obj_dir/
	@rm -f *.vcd $(BINARIES)
	@rm -rf led_walker/ led_wb/
