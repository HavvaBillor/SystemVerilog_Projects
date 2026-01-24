module gray_code #(
    parameter DATA_WIDTH = 4
) (
    input logic clk,
    input logic rst_n,
    input logic gray_en,
    output logic [DATA_WIDTH-1:0] binary_out,
    output logic [DATA_WIDTH-1:0] gray_out
);


  logic [DATA_WIDTH-1:0] binary_reg;

  // Binary to Gray code conversion
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      binary_reg <= '0;
    end else if (gray_en) begin
      binary_reg <= binary_reg + 1;
    end
  end

  assign binary_out = binary_reg;
  assign gray_out   = binary_reg ^ (binary_reg >> 1);

endmodule
