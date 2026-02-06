module alu (
    input  logic        clk,
    input  logic        rst_n,
    input  logic [15:0] num1,
    input  logic [15:0] num2,
    input  logic [ 1:0] op_code,
    input  logic        start,
    output logic [31:0] result,
    output logic        is_division,
    output logic        done
);

  typedef enum logic [1:0] {
    IDLE,
    CALC,
    DIVIDE,
    FINISH
  } state_t;
  state_t next_state, current_state;

  logic [31:0] acc, next_acc;
  logic [31:0] quot, next_quot;
  logic [5:0] count, next_count;
  logic [31:0] res_reg, next_res;
  logic is_div_reg, next_is_div;



  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      current_state <= IDLE;
      acc           <= '0;
      quot          <= '0;
      count         <= '0;
      res_reg       <= '0;
      is_div_reg    <= 1'b0;
    end else begin
      current_state <= next_state;
      acc           <= next_acc;
      quot          <= next_quot;
      count         <= next_count;
      res_reg       <= next_res;
      is_div_reg    <= next_is_div;
    end
  end

  always_comb begin
    // Default atamalar (Latch oluşmasını önler, mevcut değeri korur)
    next_state  = current_state;
    next_acc    = acc;
    next_quot   = quot;
    next_count  = count;
    next_res    = res_reg;
    next_is_div = is_div_reg;

    case (current_state)
      IDLE: begin
        if (start) begin
          if (op_code == 2'b11) begin
            next_is_div = 1'b1;
            next_quot   = num1 * 10; // Scaling
            next_acc    = '0;
            next_count  = 6'd32;
            next_state  = DIVIDE;
          end else begin
            next_is_div = 1'b0;
            next_state  = CALC;
          end
        end
      end

      CALC: begin
        case (op_code)
          2'b00:   next_res = num1 + num2;
          2'b01:   next_res = num1 - num2;
          2'b10:   next_res = num1 * num2;
          default: next_res = '0;
        endcase
        next_state = FINISH;
      end

      DIVIDE: begin
        // Shift-Subtract iterasyonu (Ara kablolar üzerinden hesapla)
        logic [63:0] combined_shift;
        combined_shift = {acc, quot} << 1;

        next_acc = combined_shift[63:32];
        next_quot = combined_shift[31:0];

        if (next_acc >= {16'b0, num2}) begin
          next_acc = next_acc - num2;
          next_quot[0] = 1'b1;
        end

        if (count == 1) begin
          next_res   = next_quot;
          next_state = FINISH;
        end else begin
          next_count = count - 1;
        end
      end

      FINISH: begin
        next_state = IDLE;
      end
    endcase
  end

  assign result      = res_reg;
  assign is_division = is_div_reg;
  assign done        = (current_state == FINISH);
endmodule
