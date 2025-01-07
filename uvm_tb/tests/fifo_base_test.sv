class fifo_base_test extends uvm_test;
    `uvm_component_utils(fifo_base_test)

    fifo_env env;

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    virtual function void build_phase (uvm_phase phase);
        super.build_phase(phase);
        env = fifo_env::type_id::create("env", this);
    endfunction

    virtual function void end_of_elaboration_phase (uvm_phase phase);
        uvm_factory factory = uvm_factory::get();
        super.end_of_elaboration_phase(phase);
        this.print();
        factory.print();
    endfunction

    virtual task run_phase (uvm_phase phase);
        fifo_base_seq seq = fifo_base_seq::type_id::create("seq");
        phase.raise_objection(this);
        seq.start(env.agt.sqr);
        phase.drop_objection(this);
    endtask

endclass: fifo_base_test