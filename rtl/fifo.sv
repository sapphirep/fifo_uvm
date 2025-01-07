import fifo_pkg::*;

module fifo (fifo_if vif);

    logic [ADDR_WIDTH-1:0] wr_addr, rd_addr;
    logic reg_wr_en, reg_rd_en;

    assign reg_wr_en = vif.wr & ~vif.full;
    assign reg_rd_en = vif.rd * ~vif.empty;

    // FIFO controller
    fifo_ctrl ctrl (.vif, .wr_addr, .rd_addr);

    // Regfile
    reg_file #(.ADDR_WIDTH(ADDR_WIDTH), .SIZE(FIFO_DEPTH))
        regs (.wr_en(reg_wr_en), .rd_en(reg_rd_en), .clk(vif.clk), .rst(vif.rst), .wr_addr(wr_addr), 
              .rd_addr(rd_addr), .wr_data(vif.wr_data), .rd_data(vif.rd_data));

endmodule: fifo


// Fifo Controller
module fifo_ctrl
(
    fifo_if.FIFO_CTRL vif, 
    output logic [ADDR_WIDTH-1:0] wr_addr, rd_addr
);

    logic [ADDR_WIDTH-1:0] wr_ptr, wr_ptr_next;
    logic [ADDR_WIDTH-1:0] rd_ptr, rd_ptr_next;
    logic [ADDR_WIDTH:0]   count, count_next;
    logic                  full, full_next;
    logic                  empty, empty_next;
    logic                  overflow, overflow_next;
    logic                  underflow, underflow_next;

    // State registers
    always_ff @(posedge vif.clk, posedge vif.rst) 
    begin
        if (vif.rst) 
        begin
            wr_ptr    <= 0;
            rd_ptr    <= 0;
            count     <= 0;
            full      <= 1'b0;
            empty     <= 1'b1;
            overflow  <= 1'b0;
            underflow <= 1'b0;
        end
        else 
        begin
            wr_ptr    <= wr_ptr_next;
            rd_ptr    <= rd_ptr_next;
            count     <= count_next;
            full      <= full_next;
            empty     <= empty_next;
            overflow  <= overflow_next;
            underflow <= underflow_next;
        end
    end

    // Next-state logic
    always_comb
    begin
        wr_ptr_next    = wr_ptr;
        rd_ptr_next    = rd_ptr;
        count_next     = count;

        full_next      = full;
        empty_next     = empty;
        overflow_next  = overflow;
        underflow_next = underflow;

        case({vif.wr, vif.rd})
            2'b01:
            begin
                // Read if not empty
                if (!empty) begin
                    rd_ptr_next = rd_ptr + 1;
                    full_next = 1'b0;
                    empty_next = (rd_ptr_next == wr_ptr);
                    count_next = count - 1;
                end
                underflow_next = empty;
                overflow_next  = 1'b0;
            end

            2'b10:
            begin
                // Write if not full
                if (!full) begin
                    wr_ptr_next = wr_ptr + 1;
                    full_next = (wr_ptr_next == rd_ptr);
                    empty_next = 1'b0;
                    count_next = count + 1;
                end
                overflow_next  = full;
                underflow_next = 1'b0;
            end

            2'b11:
            begin
                // Read and write
                if (full) begin
                    rd_ptr_next   = rd_ptr + 1;
                    count_next    = count - 1;
                    full_next     = 1'b0;
                    overflow_next = 1'b0;
                end
                else if (empty) begin
                    wr_ptr_next    = wr_ptr + 1;
                    count_next     = count + 1;
                    empty_next     = 1'b0;
                    underflow_next = 1'b0;
                end
                else begin
                    rd_ptr_next = rd_ptr + 1;
                    wr_ptr_next = wr_ptr + 1;
                end
            end
            
            default: ; // NOP
        endcase
    end

    // Output logic
    assign wr_addr = wr_ptr;
    assign rd_addr = rd_ptr;
    
    assign vif.count = count;
    assign vif.full  = full;
    assign vif.empty = empty;
    assign vif.underflow = underflow;
    assign vif.overflow  = overflow;
    assign vif.thr_trig  = (count >= vif.trig_level);

endmodule: fifo_ctrl


// Fifo memory
module reg_file
#(parameter DATA_WIDTH = 8, SIZE = 16, ADDR_WIDTH = $clog2(SIZE))
(
    input  logic                  wr_en, rd_en,
    input  logic                  clk,
    input  logic                  rst,
    input  logic [ADDR_WIDTH-1:0] wr_addr, rd_addr,
    input  logic [DATA_WIDTH-1:0] wr_data,
    output logic [DATA_WIDTH-1:0] rd_data
);
    logic [DATA_WIDTH-1:0] dreg[SIZE];

    always_ff @(posedge clk, posedge rst)
    begin
        if (rst) 
            foreach (dreg[i])
                dreg[i] <= 0;
        else
            if (wr_en) dreg[wr_addr] <= wr_data;
            if (rd_en) rd_data <= dreg[rd_addr];
    end

endmodule: reg_file