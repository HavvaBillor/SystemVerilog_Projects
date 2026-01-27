module async_wptr_full #(
    parameter ADDR_WIDTH = 4
) (
    input logic wclk,
    input logic wrst_n,
    input logic w_en,
    input logic [ADDR_WIDTH:0] wg2_rptr,  // register read pointer (gray)
    output logic full,
    output logic [ADDR_WIDTH:0] w_ptr,  // out to sync gray pointer
    output logic [ADDR_WIDTH-1:0] w_addr  // out to ram binary adres
);

  logic [ADDR_WIDTH:0] wbin;  // binary counter
  logic [ADDR_WIDTH:0] wbin_next;
  logic [ADDR_WIDTH:0] w_ptr_next;
  logic                full_val;

  assign wbin_next = wbin + (w_en & !full);  // if fifo is not full when we are writing => wbin_next = wbin + 1;
  assign w_ptr_next = (wbin_next >> 1) ^ wbin_next;  // gray code of wbin_next

  assign w_addr = wbin[ADDR_WIDTH-1:0];  // ram only binary

  always_ff @(posedge wclk or negedge wrst_n) begin
    if (!wrst_n) begin
      w_ptr <= '0;
      wbin  <= '0;
    end else begin
      wbin  <= wbin_next;
      w_ptr <= w_ptr_next;
    end
  end

  assign full_val = (w_ptr_next == {~wg2_rptr[ADDR_WIDTH:ADDR_WIDTH-1], wg2_rptr[ADDR_WIDTH-2:0]});


  always_ff @(posedge wclk or negedge wrst_n) begin
    if (!wrst_n) begin
      full <= 1'b0;
    end else begin
      full <= full_val;
    end
  end

endmodule
