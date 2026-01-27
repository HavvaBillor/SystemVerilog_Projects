module async_sync_ptr #(
    parameter ADDR_WIDTH = 4
) (
    input logic clk,
    input logic rst_n,
    input logic [ADDR_WIDTH:0] ptr_in,
    output logic [ADDR_WIDTH:0] ptr_out
);
  logic [ADDR_WIDTH:0] ptr_out_0;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      ptr_out_0 <= '0;
      ptr_out   <= '0;
    end else begin
      ptr_out_0 <= ptr_in;
      ptr_out   <= ptr_out_0;
    end
  end

endmodule
