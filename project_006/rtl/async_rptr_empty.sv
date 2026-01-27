module async_rptr_empty #(
    parameter ADDR_WIDTH = 4
) (
    input logic rclk,
    input logic rrst_n,
    input logic r_en,
    input logic [ADDR_WIDTH:0] rg2_wptr,  // register write pointer (gray)
    output logic empty,
    output logic [ADDR_WIDTH:0] r_ptr,  // out to sync gray pointer
    output logic [ADDR_WIDTH-1:0] r_addr  // out to ram binary adres
);

  logic [ADDR_WIDTH:0] rbin;  // binary counter
  logic [ADDR_WIDTH:0] rbin_next;
  logic [ADDR_WIDTH:0] r_ptr_next;
  logic                empty_val;

  assign rbin_next = rbin + (r_en & !empty);  // if fifo is not empty when we are reading => rbin + 1 = rbin_next
  assign r_ptr_next = (rbin_next >> 1) ^ rbin_next;  // gray code of rbin_next

  assign r_addr = rbin[ADDR_WIDTH-1:0];  // ram only binary

  always_ff @(posedge rclk or negedge rrst_n) begin
    if (!rrst_n) begin
      r_ptr <= '0;
      rbin  <= '0;
    end else begin
      rbin  <= rbin_next;
      r_ptr <= r_ptr_next;
    end
  end

  assign empty_val = (r_ptr_next == rg2_wptr);  // for latency 

  always_ff @(posedge rclk or negedge rrst_n) begin
    if (!rrst_n) begin
      empty <= 1'b1;
    end else begin
      empty <= empty_val;
    end
  end


endmodule
