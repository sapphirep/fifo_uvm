UVM_VERBOSITY = UVM_LOW

# Change this to your UVM package path
UVM_HOME = /change/to/your/path

# Files declaration
RTL = ../rtl/fifo_pkg.sv \
	  ../rtl/fifo_if.sv \
	  ../rtl/fifo.sv

TB_FILES = ../uvm_tb/fifo_test_pkg.sv \
           ../uvm_tb/fifo_tb.sv

ASSERT_FILES = ../assertion/fifo_assert.sv \
			   ../assertion/bindfiles.sv 

# Directory declaration
RTL_DIR = +incdir+../rtl
TB_DIR  = +incdir+../uvm_tb+../uvm_tb/env+../uvm_tb/sequences+../uvm_tb/tests
ASSERT_DIR = +incdir+../assertion

# Default test name for run_test
UVM_TESTNAME = fifo_rand_test

# VCS related commands
VCS = vcs
VCS_OPTS = -full64 -sverilog -timescale=1ns/1ns +vpi +v2k
UVM_OPTS = +incdir+$(UVM_HOME)/src \
                   $(UVM_HOME)/src/uvm.sv \
                   $(UVM_HOME)/src/dpi/uvm_dpi.cc -CFLAGS -DVCS

INCDIRS = $(RTL_DIR) \
		  $(ASSERT_DIR) \
          $(TB_DIR)

SRC_FILES_WITH_ASSERTION = $(RTL) \
			               $(ASSERT_FILES) \
                           $(TB_FILES)

SRC_FILES_NO_ASSERTION = $(RTL) \
                         $(TB_FILES)

.PHONY: vcs_std vcs_no_assert run_test run_test1 run_test2 run_rand_test vcs_urg clean

all: vcs_std run_test vcs_urg 

vcs_std:
	$(VCS) $(VCS_OPTS) $(UVM_OPTS) $(INCDIRS) $(SRC_FILES_WITH_ASSERTION)

vcs_no_assert:
	$(VCS) $(VCS_OPTS) $(UVM_OPTS) $(INCDIRS) $(SRC_FILES_NO_ASSERTION)

run_test:
	./simv +UVM_TESTNAME=$(UVM_TESTNAME) +UVM_VERBOSITY=$(UVM_VERBOSITY) +UVM_NO_RELNOTES

run_test1:
	./simv +UVM_TESTNAME=fifo_test1 +UVM_VERBOSITY=$(UVM_VERBOSITY) +UVM_NO_RELNOTES

run_test2:
	./simv +UVM_TESTNAME=fifo_test2 +UVM_VERBOSITY=$(UVM_VERBOSITY) +UVM_NO_RELNOTES

run_rand_test:
	./simv +UVM_TESTNAME=fifo_rand_test +UVM_VERBOSITY=$(UVM_VERBOSITY) +UVM_NO_RELNOTES

vcs_urg:
	urg -dir simv.vdb

clean:
	rm -rf *~ core csrc simv* vc_hdrs.h ucli.key urg* *.log dump* DVE*