package fifo_test_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"
    
    import fifo_pkg::*;

    typedef enum { NOP, READ, WRITE, READ_WRITE } fifo_op_e;

    parameter CLK_CYCLE = 10ns;
  
    `include "fifo_transaction.sv"
    `include "fifo_sequencer.sv"
    `include "fifo_sequences.svh"
    `include "fifo_coverage.sv"
    `include "fifo_model.sv"
    `include "fifo_scoreboard.sv"
    `include "fifo_driver.sv"
    `include "fifo_monitor.sv"
    `include "fifo_agent.sv"
    `include "fifo_env.sv"
    `include "fifo_tests.svh"

endpackage: fifo_test_pkg
