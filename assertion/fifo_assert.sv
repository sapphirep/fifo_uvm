`define rd_ptr fifo.ctrl.rd_ptr
`define wr_ptr fifo.ctrl.wr_ptr
`define cnt    fifo.ctrl.count

module fifo_assert (fifo_if vif);

    // ---------------------------------------------------------------
    // 1. Check reset
    // ---------------------------------------------------------------
    sequence rst_seq;
        (`rd_ptr == 0) && (`wr_ptr == 0) && (`cnt == 0) 
            && (vif.empty) && (!vif.full)
            && (!vif.overflow) && (!vif.underflow)
            && (!vif.thr_trig);
    endsequence: rst_seq

    property fifo_reset;
        @(posedge vif.clk) vif.rst |-> rst_seq;
    endproperty: fifo_reset

    aRst: assert property(fifo_reset) else $display($time,, "Reset assertion failed!");
    cRst: cover  property(fifo_reset); // $display($time,, "Reset assertion passed!");


    // ---------------------------------------------------------------
    // 2. Check fifo empty is asserted when cnt = 0.
    // ---------------------------------------------------------------
    property fifo_empty;
        @(posedge vif.clk) disable iff (vif.rst)
            (`cnt == 0) |-> vif.empty;
    endproperty: fifo_empty
    
    aEmpty: assert property(fifo_empty) else $display($time,, "FIFO is not empty when count = 0!");
    cEmpty: cover  property(fifo_empty); // $display($time,, "FIFO empty assertion passed!");


    // ---------------------------------------------------------------
    // 3. Check fifo empty flag is de-asserted when cnt becomes non-zero.
    // ---------------------------------------------------------------
    property fifo_not_empty;
        @(posedge vif.clk) disable iff (vif.rst) 
            ($past(`cnt) == 0) && (`cnt == 1) |-> $fell(vif.empty);
    endproperty: fifo_not_empty
    
    aNotEmpty: assert property(fifo_not_empty) else $display($time,, "FIFO is empty when count = 1!");
    cNotEmpty: cover  property(fifo_not_empty); // $display($time,, "FIFO not empty assertion passed!");


    // ---------------------------------------------------------------
    // 4. Check fifo full flag is asserted when cnt = FIFO_DEPTH.
    // ---------------------------------------------------------------
    property fifo_full;
        @(posedge vif.clk) disable iff (vif.rst) 
            (`cnt == FIFO_DEPTH) |-> vif.full;
    endproperty: fifo_full
    
    aFull: assert property(fifo_full) else $display($time,, "FIFO is not full when count = FIFO_DEPTH!");
    cFull: cover  property(fifo_full); // $display($time,, "FIFO full assertion passed!"); 


    // ---------------------------------------------------------------
    // 5. Check fifo full flag is de-asserted when cnt becomes smaller 
    // than FIFO_DEPTH.
    // ---------------------------------------------------------------
    property fifo_not_full;
        @(posedge vif.clk) disable iff (vif.rst) 
            ($past(`cnt) == FIFO_DEPTH) && (`cnt == FIFO_DEPTH - 1) |-> $fell(vif.full);
    endproperty: fifo_not_full
    
    aNotFull: assert property(fifo_not_full) else $display($time,, "FIFO is full when count = FIFO_DEPTH - 1!");
    cNotFull: cover  property(fifo_not_full); // $display($time,, "FIFO not full assertion passed!"); 


    // ---------------------------------------------------------------
    // 6. Check when fifo is full, writing to it without reading 
    // causes overflow. Also wr_ptr should not change during overflow.
    // ---------------------------------------------------------------
    sequence stable_wr_ptr_during_overflow;
        $stable(`wr_ptr) within (vif.overflow[*1:$] ##1 !vif.overflow);
    endsequence;

    property fifo_overflow;
        @(posedge vif.clk) disable iff (vif.rst) 
            (vif.full && vif.wr && !vif.rd) |-> ##1 vif.overflow ##0 stable_wr_ptr_during_overflow;
    endproperty: fifo_overflow

    aOverflow: assert property(fifo_overflow) else $display($time,, "FIFO overflow assertion failed!");
    cOverflow: cover  property(fifo_overflow); // $display($time,, "FIFO overflow assertion passed!");


    // ---------------------------------------------------------------
    // 7. Check when fifo is empty, reading from it without writing 
    // causes underflow. Also rd_ptr should not change during underflow.
    // ---------------------------------------------------------------
    sequence stable_rd_ptr_during_underflow;
        $stable(`rd_ptr) within (vif.underflow[*1:$] ##1 !vif.underflow);
    endsequence;
    
    property fifo_underflow;
        @(posedge vif.clk) disable iff (vif.rst)
            (vif.empty && vif.rd && !vif.wr) |-> ##1 vif.underflow ##0 stable_rd_ptr_during_underflow;
    endproperty: fifo_underflow

    aUnderflow: assert property(fifo_underflow) else $display($time,, "FIFO underflow assertion failed!");
    cUnderflow: cover  property(fifo_underflow); //$display($time,, "FIFO underflow assertion passed!");


    // ---------------------------------------------------------------
    // 8. Check threshold trigger is asserted when cnt >= threshold
    // trigger level.
    // ---------------------------------------------------------------
    property fifo_thresh_trig_assert;
        @(posedge vif.clk) disable iff (vif.rst) 
            (`cnt >= vif.trig_level) |-> vif.thr_trig;
    endproperty: fifo_thresh_trig_assert

    aThreshTrigAssert: assert property(fifo_thresh_trig_assert) else $display($time,, "FIFO threshold trigger assertion failed!");
    cThreshTrigAssert: cover  property(fifo_thresh_trig_assert); // $display($time,, "FIFO threshold trigger assertion passed!");


    // ---------------------------------------------------------------
    // 9. Check threshold trigger is deasserted when cnt < threshold
    // trigger level.
    // ---------------------------------------------------------------
    property fifo_thresh_trig_deassert;
        @(posedge vif.clk) disable iff (vif.rst) 
            ($past(`cnt) == vif.trig_level) && (`cnt == vif.trig_level - 1) |-> $fell(vif.thr_trig);
    endproperty: fifo_thresh_trig_deassert

    aThreshTrigDeAssert: assert property(fifo_thresh_trig_deassert) else $display($time,, "FIFO threshold trigger de-assertion failed!");
    cThreshTrigDeAssert: cover  property(fifo_thresh_trig_deassert); // $display($time,, "FIFO threshold trigger de-assertion passed!");

endmodule: fifo_assert