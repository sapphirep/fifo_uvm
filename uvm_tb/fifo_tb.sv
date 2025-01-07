module fifo_tb;
    
    import uvm_pkg::*;
    `include "uvm_macros.svh"
    
    import fifo_test_pkg::*;

    logic     clk = 0;
    
    fifo_if vif (clk);
    fifo    dut (vif);

    // Clock generation
    always #(CLK_CYCLE/2) clk = ~clk;

    initial begin
        $dumpfile("fifo_test.vcd");
        $dumpvars(0, fifo_tb);
    end

    initial begin
        uvm_config_db #(virtual fifo_if)::set(null, "*", "vif", vif);
        run_test();
    end

endmodule: fifo_tb;
