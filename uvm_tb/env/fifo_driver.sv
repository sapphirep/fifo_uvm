`define DRIVER_CB vif.DRIVER.driver_cb

class fifo_driver extends uvm_driver #(fifo_transaction);
    `uvm_component_utils(fifo_driver)

    virtual fifo_if vif;

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    extern task initialize_dut ();
    extern task reset_dut (fifo_transaction tr, output fifo_transaction rsp);
    extern task drive_dut (fifo_transaction tr, output fifo_transaction rsp);

    function void build_phase (uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db #(virtual fifo_if)::get(null, "*","vif", vif))
            `uvm_fatal("DRV_ERR", "Failed to get vif!");
    endfunction
    
    task run_phase (uvm_phase phase);
        fifo_transaction tr, rsp;

        super.run_phase(phase);
        initialize_dut();
        forever begin
            seq_item_port.get_next_item(tr);

            if (tr.rst == 1)
                reset_dut(tr, rsp);
            else
                drive_dut(tr, rsp);

            rsp.set_id_info(tr);
            seq_item_port.item_done(rsp);
        end
    endtask

endclass: fifo_driver

task fifo_driver::initialize_dut ();
    vif.rd <= 0;
    vif.wr <= 0;
    vif.wr_data <= 0;
    vif.rst <= 0;
    vif.trig_level <= FIFO_TRIG_THRESHOLD;
endtask: initialize_dut

task fifo_driver::reset_dut (fifo_transaction tr, output fifo_transaction rsp);
    fifo_transaction resp = fifo_transaction::type_id::create("resp");

    @ (`DRIVER_CB);
    `DRIVER_CB.rst <= 1;
    @ (`DRIVER_CB);
    `DRIVER_CB.rst <= 0;
    
    // Set response for the sequence
    rsp = resp;
endtask: reset_dut

task fifo_driver::drive_dut (fifo_transaction tr, output fifo_transaction rsp);
    fifo_transaction resp = fifo_transaction::type_id::create("resp");
    bit rd = 0, wr = 0;
    
    if (tr.op == READ || tr.op == READ_WRITE)
        rd = 1;
    if (tr.op == WRITE || tr.op == READ_WRITE)
        wr = 1;

    @ (`DRIVER_CB);
    `DRIVER_CB.wr <= wr;
    `DRIVER_CB.rd <= rd;
    `DRIVER_CB.wr_data <= tr.wr_data;
    
    @ (`DRIVER_CB);
    `DRIVER_CB.wr <= 1'b0;
    `DRIVER_CB.rd <= 1'b0;

    // Wait till DUT output is valid
    @ (`DRIVER_CB);
    resp.full      = `DRIVER_CB.full;
    resp.empty     = `DRIVER_CB.empty;
    resp.overflow  = `DRIVER_CB.overflow;
    resp.underflow = `DRIVER_CB.underflow;
    resp.rd_data   = `DRIVER_CB.rd_data;

    // Set response for the sequence
    rsp = resp;

endtask: drive_dut