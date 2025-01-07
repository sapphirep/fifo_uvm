class fifo_seq1 extends fifo_base_seq;
    `uvm_object_utils(fifo_seq1)

    function new (string name = "fifo_seq1");
        super.new(name);
    endfunction

    task body();
        fifo_transaction tr = fifo_transaction::type_id::create("tr");
        repeat (2) reset(tr);
        write_until_full(tr);
        repeat (5) write(tr);
        read_until_empty(tr);
        repeat (5) read (tr);
        write_until_full(tr);
        read_until_empty(tr);
    endtask

endclass: fifo_seq1