#!/usr/bin/make -f

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
		VERILATOR := /opt/local/bin/verilator
		VINC := /opt/local/share/verilator/include
		# if you run verilator with --trace
		# you have to use clang++
		# else g++ is OK
		CXX := clang++
	endif
endif

BINARIES:=thruwire blinky blinky_tr dimmer


out_dir/V%.cpp:		%.v
	$(VERILATOR) -Wall -cc $<


out_dir/Vblinky.cpp:	blinky.v

thruwire:	thruwire.v
	$(VERILATOR) -Wall -cc $<
	cd obj_dir && make -f Vthruwire.mk
	$(CXX) -I $(VINC) -I obj_dir/ \
		$(VINC)/verilated.cpp \
		$@_tb.cpp \
		obj_dir/Vthruwire__ALL.a \
		-o $@

blinky:	blinky.v
	$(VERILATOR) -Wall -cc $<
	cd obj_dir && make -f Vblinky.mk
	$(CXX) -I $(VINC) -I obj_dir/ \
		$(VINC)/verilated.cpp \
		$@_tb.cpp \
		obj_dir/Vblinky__ALL.a \
		-o $@

blinky_tr:	blinky.v
	$(VERILATOR) -Wall --trace -cc $<
	cd obj_dir && make -f Vblinky.mk
	$(CXX) -I $(VINC) -I obj_dir/ \
		$(VINC)/verilated.cpp \
    	$(VINC)/verilated_vcd_c.cpp \
		$@_tb.cpp \
		obj_dir/Vblinky__ALL.a \
		-o $@

dimmer:	dimmer.v
	$(VERILATOR) -Wall -cc $<
	cd obj_dir && make -f V$@.mk
	$(CXX) -I $(VINC) -I obj_dir/ \
		$(VINC)/verilated.cpp \
		$@_tb.cpp \
		obj_dir/V$@__ALL.a \
		-o $@

#	/opt/local/bin/verilator -Wall -cc $<

all: 	$(BINARIES)

clean:
	@rm -rf obj_dir/
	@rm -f *.vcd $(BINARIES)
