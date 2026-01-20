
module ALU #(
    parameter DATA_WIDTH = 4
) (
    input logic [2:0] sel_in,  // selecp op-code
    input logic signed [DATA_WIDTH-1:0] a_in,
    input logic signed [DATA_WIDTH-1:0] b_in,
    output logic signed [(2*DATA_WIDTH)-1:0] alu_out
);

  typedef enum logic [2:0] {
    ADD  = 3'b000,
    SUB  = 3'b001,
    MULT = 3'b010,
    AND  = 3'b011,
    OR   = 3'b100,
    XOR  = 3'b101
  } op_code;


  always_comb begin

    alu_out = '0;  // latch oluşumunu önle

    unique case (op_code'(sel_in))
      ADD:     alu_out = a_in + b_in;
      SUB:     alu_out = a_in - b_in;
      MULT:    alu_out = a_in * b_in;
      AND:     alu_out = a_in & b_in;
      OR:      alu_out = a_in | b_in;
      XOR:     alu_out = a_in ^ b_in;
      default: alu_out = '0;
    endcase

  end

endmodule
