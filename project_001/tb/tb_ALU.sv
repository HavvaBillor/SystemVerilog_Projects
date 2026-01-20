module tb_ALU;

  // testbench parameter
  localparam DATA_WIDTH = 4;

  // Testbench signals
  logic        [               2:0] sel_in;
  logic signed [    DATA_WIDTH-1:0] a_in;
  logic signed [    DATA_WIDTH-1:0] b_in;
  logic signed [(2*DATA_WIDTH)-1:0] alu_out;
  logic                             clk;

  // Instantiation
  ALU #(
      .DATA_WIDTH(DATA_WIDTH)
  ) alu_inst (
      .sel_in (sel_in),
      .a_in   (a_in),
      .b_in   (b_in),
      .alu_out(alu_out)
  );

  initial begin
    clk = 0;
  end
  always #10ns clk = ~clk;

  function logic signed [(2*DATA_WIDTH)-1:0] expected_alu(input logic [2:0] sel_in, input logic signed [DATA_WIDTH-1:0] a_in, input logic signed [DATA_WIDTH-1:0] b_in);
    unique case (sel_in)
      3'b000:  return a_in + b_in;
      3'b001:  return a_in - b_in;
      3'b010:  return a_in * b_in;
      3'b011:  return a_in & b_in;
      3'b100:  return a_in | b_in;
      3'b101:  return a_in + b_in;
      default: return '0;
    endcase
  endfunction

  task check_operation(input logic [2:0] op_code);
    logic signed [(2*DATA_WIDTH)-1:0] result;

    // rastgele veri üretimi
    a_in   = $urandom;
    b_in   = $urandom;
    sel_in = op_code;

    @(posedge clk);
    #1ns;
    result = expected_alu(op_code, a_in, b_in);

    if (alu_out !== result) begin
      $error("ERROR! Op_code:%b A:%0d B:%0d, Expected:%0d Received:%0d", op_code, a_in, b_in, result, alu_out);
    end else begin
      $info("INFO: Op_code:%b A:%0d B:%0d, Result:%0d ", op_code, a_in, b_in, alu_out);
    end
  endtask


  // Test Scenario
  initial begin

    @(posedge clk);

    $info("INFO: ALU Testbench Started...");

    for (int i = 0; i < 5; ++i) begin
      repeat (10) begin
        check_operation(i[2:0]);
      end
    end

    #100ns;
    $info("INFO: ALU Test Finished Successfully!");
    $finish;

  end

endmodule
