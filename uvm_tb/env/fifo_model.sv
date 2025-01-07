class fifo_model;

    local bit [DATA_WIDTH-1:0] q[$];
    
    local bit overflow = 0, underflow = 0;
    local int depth;

    function new (int depth);
        this.depth = depth;
    endfunction

    extern function bit [DATA_WIDTH-1:0] read();
    extern function void write(bit [DATA_WIDTH-1:0] data);
    extern function void reset();

    extern function bit is_full();
    extern function bit is_empty();
    extern function bit is_overflow();
    extern function bit is_underflow();
    extern function int size();

    extern function void print();
    extern function string convert2string();

endclass: fifo_model

function bit [DATA_WIDTH-1:0] fifo_model::read();
    bit [DATA_WIDTH-1:0] data = 0;
    overflow = 0;
    underflow = is_empty;
    if (!is_empty) data = q.pop_front();
    return data;
endfunction: read

function void fifo_model::write(bit [DATA_WIDTH-1:0] data);
    underflow = 0;
    overflow = is_full;
    if (!is_full) q.push_back(data);
endfunction: write

function void fifo_model::reset();
    q.delete();
    overflow = 0;
    underflow = 0;
endfunction: reset

function bit fifo_model::is_full();
    return size == depth;
endfunction: is_full

function bit fifo_model::is_empty();
    return size == 0;
endfunction: is_empty

function bit fifo_model::is_underflow();
    return underflow;
endfunction: is_underflow

function bit fifo_model::is_overflow();
    return overflow;
endfunction: is_overflow

function int fifo_model::size();
    return q.size();
endfunction: size

function void fifo_model::print();
    foreach (q[i])
        $write("%2h ", q[i]);
    $display();
endfunction: print

function string fifo_model::convert2string();
    return $sformatf("%p", q);
endfunction: convert2string