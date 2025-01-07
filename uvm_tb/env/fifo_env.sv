class fifo_env extends uvm_env;
    `uvm_component_utils(fifo_env)

    fifo_agent agt;
    fifo_scoreboard scb;
    fifo_coverage cvg;

    function new (string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase (uvm_phase phase);
        super.build_phase(phase);
        agt = fifo_agent::type_id::create("agt", this);
        scb = fifo_scoreboard::type_id::create("scb", this);
        cvg = fifo_coverage::type_id::create("cvg", this);
    endfunction

    function void connect_phase (uvm_phase phase);
        super.connect_phase(phase);
        agt.analysis_port.connect(scb.analysis_export);
        agt.analysis_port.connect(cvg.analysis_export);
    endfunction
    
endclass: fifo_env