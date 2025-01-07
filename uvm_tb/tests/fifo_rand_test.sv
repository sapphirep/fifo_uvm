class fifo_rand_test extends fifo_base_test;
    `uvm_component_utils(fifo_rand_test)

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase (uvm_phase phase);
        super.build_phase(phase);
        set_type_override_by_type(fifo_base_seq::get_type(), fifo_rand_seq::get_type());
    endfunction

endclass: fifo_rand_test