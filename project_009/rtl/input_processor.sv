module input_processor #(
    parameter DATA_WIDTH = 8
) (
    input  logic                   clk,
    input  logic                   rst_n,
    input  logic [DATA_WIDTH -1:0] rx_data_in,
    input  logic                   rx_empty_in,
    output logic                   rx_ren_o,
    output logic [           15:0] num1_o,
    output logic [           15:0] num2_o,
    output logic [            1:0] operator_o,
    output logic                   start_calc_o
);

  // ASCII 0 = 8'h30,,,, ASCII 9= 8'h39
  logic is_digit;
  assign is_digit = (rx_data_in >= 8'h30 && rx_data_in <= 8'h39);

  logic [15:0] current_num;
  logic [15:0] n1_reg, n2_reg;
  logic [1:0] op_reg;

  typedef enum logic [1:0] {
    IDLE,
    GET_NUM1,
    GET_NUM2,
    START_ALU
  } state_t;
  state_t next_state, current_state;

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      current_state <= IDLE;
    end else begin
      current_state <= next_state;
    end
  end

  always_comb begin
    next_state = current_state;
    rx_ren_o = 1'b0;
    start_calc_o = 1'b0;

    case (current_state)
      IDLE: begin
        if (!rx_empty_in) begin
          rx_ren_o   = 1'b1;
          next_state = GET_NUM1;
        end
      end
      GET_NUM1: begin
        if (!rx_empty_in) begin
          rx_ren_o = 1'b1;
          if (!is_digit) next_state = GET_NUM2;
        end
      end
      GET_NUM2: begin
        if (!rx_empty_in) begin
          rx_ren_o = 1'b1;
          if (!is_digit) begin
            next_state = START_ALU;
          end
        end
      end
      START_ALU: begin
        rx_ren_o = 1'b0;
        start_calc_o = 1'b1;
        next_state = IDLE;
      end
      default: next_state = IDLE;
    endcase
  end

  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      n1_reg <= '0;
      n2_reg <= '0;
      op_reg <= '0;
      current_num <= '0;
    end else begin

      case (current_state)
        IDLE: begin
          current_num <= '0;
          if (!rx_empty_in && rx_ren_o && is_digit) begin
            current_num <= (current_num * 10) + (rx_data_in - 8'h30);

          end
        end
        GET_NUM1: begin
          if (rx_ren_o) begin
            if (is_digit) begin
              current_num <= (current_num * 10) + (rx_data_in - 8'h30);
            end else begin
              n1_reg <= current_num;
              current_num <= '0;
              case (rx_data_in)
                8'h2B: op_reg <= 2'b00;  // '+'
                8'h2D: op_reg <= 2'b01;  // '-'
                8'h2A: op_reg <= 2'b10;  // '*'
                8'h2F: op_reg <= 2'b11;  // '/'
              endcase
            end
          end
        end
        GET_NUM2: begin
          if (rx_ren_o) begin
            if (is_digit) begin
              current_num <= (current_num * 10) + (rx_data_in - 8'h30);
            end else begin
              n2_reg <= current_num;
              current_num <= '0;
            end
          end
        end
      endcase
    end
  end

  assign num1_o     = n1_reg;
  assign num2_o     = n2_reg;
  assign operator_o = op_reg;


endmodule
