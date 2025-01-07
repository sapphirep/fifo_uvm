class fifo_seq2 extends fifo_base_seq;
    `uvm_object_utils(fifo_seq2)

    function new (string name = "fifo_seq2");
        super.new(name);
    endfunction

    task body();
        fifo_transaction tr = fifo_transaction::type_id::create("tr");
        repeat (2) reset(tr);
        write_until_full(tr);
        repeat (20) read_write(tr);
        read_until_empty(tr);
        repeat (10) read(tr);
        repeat (10) write(tr);
        
        repeat (5) reset(tr);
        repeat (20) read_write(tr);
        read_until_empty(tr);
        repeat (20) read_write(tr);

        repeat (1) reset(tr);
        write_until_full(tr);
        read_until_empty(tr);
    endtask

endclass: fifo_seq2