class fifo_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(fifo_scoreboard)

    uvm_analysis_imp #(fifo_transaction, fifo_scoreboard) analysis_export;
    fifo_transaction tr = fifo_transaction::type_id::create("tr");

    fifo_model fifo;
    int err_cnt = 0;

    function new (string name, uvm_component parent);
        super.new(name, parent);
        fifo = new(FIFO_DEPTH);
    endfunction

    extern function void build_phase  (uvm_phase phase);
    extern function void report_phase (uvm_phase phase);

    extern function void check_write_fifo (fifo_transaction tr);
    extern function void check_read_fifo  (fifo_transaction tr);
    extern function void check_read_write_fifo (fifo_transaction tr);
    extern function void check_stat_flags (fifo_transaction tr);
    
    function void write (fifo_transaction t);
        tr.copy(t);

        if (tr.rst)
            fifo.reset();
        else begin
            case (tr.op)
                NOP:;
                READ: check_read_fifo(tr);
                WRITE: check_write_fifo(tr);
                READ_WRITE: check_read_write_fifo(tr);
            endcase
            check_stat_flags(tr);
        end
    endfunction

endclass: fifo_scoreboard


function void fifo_scoreboard::build_phase (uvm_phase phase);
        super.build_phase(phase);
        analysis_export = new("analysis_export", this);
endfunction: build_phase


function void fifo_scoreboard::check_read_fifo (fifo_transaction tr);
    bit [DATA_WIDTH-1:0] data;
    data = fifo.read();

    if (!fifo.is_empty && (data != tr.rd_data)) begin
        `uvm_info("SCB_ERR", $sformatf("Incorrect data read from FIFO. Expected:%2h, Received:%2h", data, tr.rd_data), UVM_LOW)
        err_cnt++;
    end
endfunction: check_read_fifo


function void fifo_scoreboard::check_write_fifo (fifo_transaction tr);
    fifo.write(tr.wr_data);  
endfunction: check_write_fifo


function void fifo_scoreboard::check_read_write_fifo (fifo_transaction tr);
    if (fifo.is_full)
        check_read_fifo(tr);
    else if (fifo.is_empty)
        check_write_fifo(tr);
    else begin
        check_read_fifo(tr);
        check_write_fifo(tr);
    end
endfunction: check_read_write_fifo


function void fifo_scoreboard::check_stat_flags (fifo_transaction tr);
    if (tr.full != fifo.is_full) begin
        `uvm_info("SCB_ERR", $sformatf("Incorrect FULL flag. Expected:%0b, Received:%0b", fifo.is_full, tr.full), UVM_LOW)
        err_cnt++;
    end

    if (tr.empty != fifo.is_empty) begin
        `uvm_info("SCB_ERR", $sformatf("Incorrect EMPTY flag. Expected:%0b, Received:%0b", fifo.is_empty, tr.empty), UVM_LOW)
        err_cnt++;
    end

    if (tr.overflow != fifo.is_overflow) begin
        `uvm_info("SCB_ERR", $sformatf("Incorrect OVERFLOW flag. Expected:%0b, Received:%0b", fifo.is_overflow, tr.overflow), UVM_LOW)
        err_cnt++;
    end

    if (tr.underflow != fifo.is_underflow) begin
        `uvm_info("SCB_ERR", $sformatf("Incorrect UNDERFLOW flag. Expected:%0b, Received:%0b", fifo.is_underflow, tr.underflow), UVM_LOW)
        err_cnt++;
    end
endfunction: check_stat_flags


function void fifo_scoreboard::report_phase (uvm_phase phase);
    if (err_cnt == 0)
        `uvm_info("SCB_RESULT=PASS", "Test completed with no errors!", UVM_LOW)
    else
        `uvm_info("SCB_RESULT=FAIL", $sformatf("Test failed with %2d errors!", err_cnt), UVM_LOW)
endfunction: report_phase