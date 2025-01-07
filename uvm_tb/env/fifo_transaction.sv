class fifo_transaction extends uvm_sequence_item;
    `uvm_object_utils(fifo_transaction)

    rand fifo_op_e op;
    rand bit [DATA_WIDTH-1:0] wr_data;
    rand bit rst;

    bit full, empty;
    bit overflow, underflow;
    bit thr_trig;
    bit [DATA_WIDTH-1:0] rd_data;

    constraint op_dist {
        op dist { READ := 4, WRITE := 4, READ_WRITE := 2 };
    }

    function new (string name = "fifo_transaction");
        super.new(name);
    endfunction

    function void do_copy (uvm_object rhs);
        fifo_transaction tr;
        if (!$cast(tr, rhs))
            `uvm_error("TRX", "Failed to copy! Incompatible type.")

        rst       = tr.rst;
        op        = tr.op;
        wr_data   = tr.wr_data;
        full      = tr.full;
        empty     = tr.empty;
        overflow  = tr.overflow;
        underflow = tr.underflow;
        thr_trig  = tr.thr_trig;
        rd_data   = tr.rd_data;
    endfunction

    function string convert2string();
        return $sformatf("RST:%0b, OP:%0s, WR_DATA:%2h, RD_DATA:%2h, FULL:%0b, EMPTY:%0b, OVERFLOW:%0b, UNDERFLOW:%0b, THR_TRIG:%0b", 
                           rst, op.name(), wr_data, rd_data, full, empty, overflow, underflow, thr_trig);
    endfunction

endclass: fifo_transaction