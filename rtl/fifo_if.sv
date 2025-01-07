interface fifo_if
(
    input bit clk
);
    import fifo_pkg::*;

    logic                  wr, rd;
    logic                  rst;
    logic [ADDR_WIDTH-1:0] trig_level;
    logic [DATA_WIDTH-1:0] wr_data, rd_data;
    logic [ADDR_WIDTH:0]   count;
    logic                  full, empty;
    logic                  overflow, underflow;
    logic                  thr_trig;
    logic                  reset;

    clocking driver_cb @(posedge clk);
        default input #1step output #2ns;
        input full, empty;
        input overflow, underflow;
        input rd_data;
        output rst;
        output wr, rd;
        output wr_data;
        output trig_level;
    endclocking

    clocking monitor_cb @(posedge clk);
        default input #1step output #2ns;
        input reset;  // sticky reset bit
        input wr, rd;
        input wr_data, rd_data;
        input full, empty;
        input overflow, underflow;
        input thr_trig;
    endclocking

    //----------------------------------------------------
    // Sticky reset bit used to capture asynchronous rst
    //----------------------------------------------------
    always_ff @(posedge clk, posedge rst)
    begin
        if (rst) reset <= 1'b1;
        else reset <= 1'b0;
    end

    modport FIFO_CTRL (input wr, rd, trig_level, clk, rst,
                       output count, full, empty, overflow, underflow, thr_trig);

    modport DRIVER  (clocking driver_cb, output rst);

    modport MONITOR (clocking monitor_cb);

endinterface
