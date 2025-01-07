class fifo_rand_seq extends fifo_base_seq;
    `uvm_object_utils(fifo_rand_seq)
    
    function new (string name = "fifo_rand_seq");
        super.new(name);
    endfunction

    task body();
        fifo_transaction tr = fifo_transaction::type_id::create("tr");
        repeat (2) reset(tr);
        repeat (500) begin
            random_op(tr);
        end
    endtask

endclass: fifo_rand_seq