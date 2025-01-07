`define MONITOR_CB vif.MONITOR.monitor_cb

class fifo_monitor extends uvm_monitor;
    `uvm_component_utils(fifo_monitor)

    uvm_analysis_port #(fifo_transaction) analysis_port;
    virtual fifo_if vif;

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase (uvm_phase phase);
        analysis_port = new("analysis_port", this);
        if(!uvm_config_db #(virtual fifo_if)::get(null, "*","vif", vif))
            `uvm_fatal("MON", "Failed to get VIF")
    endfunction

    task run_phase (uvm_phase phase);
        fifo_transaction tr;
        
        super.run_phase(phase);
        forever begin
            tr = fifo_transaction::type_id::create("tr");
            //---------------------------------------------
            // Sample DUT synchronous inputs on posedge clk.
            // DUT inputs should have been valid for most
            // of the previous clock cycle
            //---------------------------------------------         
            if (!$isunknown(vif.wr) && !$isunknown(vif.rd))
                $cast(tr.op, {vif.wr, vif.rd});
            
            tr.wr_data = vif.wr_data;

            //---------------------------------------------
            // Wait for posdege clk and sample outputs #1step
            // before.
            //---------------------------------------------
            @ (`MONITOR_CB);
            tr.rd_data   = `MONITOR_CB.rd_data;
            tr.full      = `MONITOR_CB.full;
            tr.empty     = `MONITOR_CB.empty;
            tr.overflow  = `MONITOR_CB.overflow;
            tr.underflow = `MONITOR_CB.underflow;
            tr.thr_trig  = `MONITOR_CB.thr_trig;

            //---------------------------------------------
            // Sample the sticky-bit reset
            //---------------------------------------------
            if (`MONITOR_CB.reset) tr.rst = 1'b1;

            if (tr.op != NOP || tr.rst)
                analysis_port.write(tr);
        end
    endtask

endclass: fifo_monitor