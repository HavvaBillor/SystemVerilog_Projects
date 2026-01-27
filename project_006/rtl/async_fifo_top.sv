module async_fifo_top #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4
) (
    input logic wclk,
    input logic rclk,
    input logic wrst_n,
    input logic rrst_n,
    input logic w_en,
    input logic r_en,
    input logic [DATA_WIDTH -1:0] w_data,
    output logic [DATA_WIDTH-1:0] r_data,
    output logic empty,
    output logic full
);


  logic [ADDR_WIDTH -1:0] w_addr, r_addr;  // ram only binary
  logic [ADDR_WIDTH:0] wptr_i, wptr_o, rptr_i, rptr_o;
  logic wclk_en;
  assign wclk_en = (w_en && !full);


  // instantiate modules

  async_sync_ptr #(
      .ADDR_WIDTH(ADDR_WIDTH)
  ) read_2_write (
      .clk    (wclk),
      .rst_n  (wrst_n),
      .ptr_in (rptr_i),
      .ptr_out(rptr_o)
  );

  async_sync_ptr #(
      .ADDR_WIDTH(ADDR_WIDTH)
  ) write_2_read (
      .clk    (rclk),
      .rst_n  (rrst_n),
      .ptr_in (wptr_i),
      .ptr_out(wptr_o)
  );

  async_fifo_mem #(
      .DATA_WIDTH(DATA_WIDTH),
      .ADDR_WIDTH(ADDR_WIDTH)
  ) fifo_mem (
      .wclk   (wclk),
      .wclk_en(wclk_en),
      .w_addr (w_addr),
      .r_addr (r_addr),
      .w_data (w_data),
      .r_data (r_data)
  );

  async_rptr_empty #(
      .ADDR_WIDTH(ADDR_WIDTH)
  ) rptr_empty (
      .rclk    (rclk),
      .rrst_n  (rrst_n),
      .r_en    (r_en),
      .rg2_wptr(wptr_o),
      .empty   (empty),
      .r_ptr   (rptr_i),
      .r_addr  (r_addr)
  );

  async_wptr_full #(
      .ADDR_WIDTH(ADDR_WIDTH)
  ) wptr_full (
      .wclk    (wclk),
      .wrst_n  (wrst_n),
      .w_en    (w_en),
      .wg2_rptr(rptr_o),
      .full    (full),
      .w_ptr   (wptr_i),
      .w_addr  (w_addr)
  );


endmodule
