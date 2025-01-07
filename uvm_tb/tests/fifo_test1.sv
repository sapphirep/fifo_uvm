class fifo_test1 extends fifo_base_test;
    `uvm_component_utils(fifo_test1)

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase (uvm_phase phase);
        super.build_phase(phase);
        set_type_override_by_type(fifo_base_seq::get_type(), fifo_seq1::get_type());
    endfunction

endclass: fifo_test1