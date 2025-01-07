class fifo_coverage extends uvm_subscriber #(fifo_transaction);
    `uvm_component_utils(fifo_coverage)

    fifo_transaction tr = fifo_transaction::type_id::create("tr");

    covergroup fifo_operation;
        op: coverpoint tr.op {
            bins read = { READ };
            bins write = { WRITE };
            bins read_write = { READ_WRITE };
        }
    endgroup

    covergroup fifo_status;
        full:      coverpoint tr.full;
        empty:     coverpoint tr.empty;
        overflow:  coverpoint tr.overflow;
        underflow: coverpoint tr.underflow;
        threshold: coverpoint tr.thr_trig;
    endgroup

    function new (string name, uvm_component parent);
        super.new(name, parent);
        fifo_operation = new();
        fifo_status = new();
    endfunction

    function void build_phase (uvm_phase phase);
        super.build_phase(phase);
        analysis_export = new("analysis_export", this);
    endfunction

    function void write (fifo_transaction t);
        tr.copy(t);
        fifo_operation.sample();
        fifo_status.sample();
    endfunction

endclass: fifo_coverage