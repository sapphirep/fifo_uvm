class fifo_agent extends uvm_agent;
    `uvm_component_utils(fifo_agent)

    fifo_monitor   mon;
    fifo_driver    drv;
    fifo_sequencer sqr;

    uvm_analysis_port #(fifo_transaction) analysis_port;

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase (uvm_phase phase);
        super.build_phase(phase);
        if (is_active) begin
            drv = fifo_driver::type_id::create("drv", this);
            sqr = fifo_sequencer::type_id::create("sqr", this);
        end
        mon = fifo_monitor::type_id::create("mon", this);
        analysis_port = new("analysis_port", this);
    endfunction

    function void connect_phase (uvm_phase phase);
        super.connect_phase(phase);
        if (is_active)
            drv.seq_item_port.connect(sqr.seq_item_export);
        mon.analysis_port.connect(analysis_port);
    endfunction

endclass: fifo_agent