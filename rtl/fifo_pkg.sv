package fifo_pkg;

    parameter DATA_WIDTH          = 8;
    parameter FIFO_DEPTH          = 16;
    parameter ADDR_WIDTH          = $clog2(FIFO_DEPTH);
    parameter FIFO_TRIG_THRESHOLD = 14;

endpackage