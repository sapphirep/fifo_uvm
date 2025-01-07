`ifndef RANDOMIZE_FAIL
`define RANDOMIZE_FAIL \
    `uvm_fatal("SEQ", "Sequence randomization failed!")
`endif

class fifo_base_seq extends uvm_sequence #(fifo_transaction);
    `uvm_object_utils(fifo_base_seq)

    fifo_transaction rsp = fifo_transaction::type_id::create("rsp");

    function new (string name = "fifo_base_seq");
        super.new(name);
    endfunction

    extern virtual task reset      (fifo_transaction tr); // FIFO reset
    extern virtual task write      (fifo_transaction tr); // Write to FIFO
    extern virtual task read       (fifo_transaction tr); // Read from FIFO
    extern virtual task read_write (fifo_transaction tr); // Read from and write to FIFO
    extern virtual task random_op  (fifo_transaction tr); // Random operation: write, read, read_write

    extern virtual task write_until_full (fifo_transaction tr); // Keep writing to FIFO until full
    extern virtual task read_until_empty (fifo_transaction tr); // Keep reading from FIFO until empty

    virtual task body();
        super.body();
    endtask

endclass: fifo_base_seq

task fifo_base_seq::reset (fifo_transaction tr);
    if(!(tr.randomize() with {rst == 1'b1;})) `RANDOMIZE_FAIL
    start_item(tr);
    finish_item(tr);
    get_response(rsp);
    `uvm_info("SEQ RESET RSP", rsp.convert2string(), UVM_DEBUG)
endtask: reset

task fifo_base_seq::write (fifo_transaction tr);
    if(!(tr.randomize() with {op == WRITE; rst == 1'b0;})) `RANDOMIZE_FAIL
    tr.rst = 1'b0;
    start_item(tr);
    finish_item(tr);
    get_response(rsp);
    `uvm_info("SEQ WR RSP", rsp.convert2string(), UVM_DEBUG)
endtask: write

task fifo_base_seq::read (fifo_transaction tr);
    if(!(tr.randomize() with {op == READ; rst == 1'b0;})) `RANDOMIZE_FAIL
    tr.rst = 1'b0;
    start_item(tr);
    finish_item(tr);
    get_response(rsp);
    `uvm_info("SEQ RD RSP", rsp.convert2string(), UVM_DEBUG)
endtask: read

task fifo_base_seq::read_write (fifo_transaction tr);
    if(!(tr.randomize() with {op == READ_WRITE; rst == 1'b0;})) `RANDOMIZE_FAIL
    tr.rst = 1'b0;
    start_item(tr);
    finish_item(tr);
    get_response(rsp);
    `uvm_info("SEQ RD&WR RSP", rsp.convert2string(), UVM_DEBUG)
endtask: read_write

task fifo_base_seq::random_op (fifo_transaction tr);
    if(!(tr.randomize() with {rst == 1'b0;})) `RANDOMIZE_FAIL
    tr.rst = 1'b0;
    `uvm_info("SEQ RAND SEQ", $sformatf("Generated tr: %s", tr.convert2string()), UVM_DEBUG)
    start_item(tr);
    finish_item(tr);
    get_response(rsp);
    `uvm_info("SEQ RAND RSP", rsp.convert2string(), UVM_DEBUG)
endtask: random_op

task fifo_base_seq::write_until_full (fifo_transaction tr);
    `uvm_info("SEQ", "Write until full...", UVM_DEBUG)
    while (!rsp.full) write(tr);
endtask: write_until_full

task fifo_base_seq::read_until_empty (fifo_transaction tr);
    `uvm_info("SEQ", "Read until empty...", UVM_DEBUG)
    while (!rsp.empty) read(tr);
endtask: read_until_empty