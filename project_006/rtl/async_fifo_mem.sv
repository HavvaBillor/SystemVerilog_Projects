module async_fifo_mem #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4
) (
    input logic wclk,
    input logic wclk_en,
    input logic [ADDR_WIDTH-1:0] w_addr,
    input logic [ADDR_WIDTH-1:0] r_addr,
    input logic [DATA_WIDTH-1:0] w_data,
    output logic [DATA_WIDTH-1:0] r_data
);




`ifdef VENDORRAM
  // instantiation of a vendor's dual-port RAM
`else

  logic [DATA_WIDTH-1:0] fifo_mem[0 : (1<<ADDR_WIDTH)-1];  // [0 : (1<<ADDR_WIDTH)-1] fifo depth = 2^addr_width 

  assign r_data = fifo_mem[r_addr];

  always_ff @(posedge wclk) begin
    if (wclk_en) begin
      fifo_mem[w_addr] <= w_data;
    end
  end

`endif



endmodule
