
module uart #(
    parameter CLK_FREQ   = 50_000_000,
    parameter BAUD_RATE  = 115_200,
    parameter DATA_WIDTH = 8,
    parameter FIFO_DEPTH = 16
) (
    input  logic        clk_i,
    input  logic        rst_ni,
    input  logic        stb_i,       // bus strobe sinyali
    input  logic [ 1:0] adr_i,       // register address
    input  logic [ 3:0] byte_sel_i,  // select byte
    input  logic        we_i,        // write enable
    input  logic [31:0] data_i,      // received data
    output logic [31:0] data_o,      // transmitted data
    input  logic        uart_rx_i,   // input uart rx
    output logic        uart_tx_o    // output uart tx
);

  localparam BAUD_DIV = (CLK_FREQ / BAUD_RATE);

  logic                     rx_empty_o;
  logic                     tx_empty_o;
  logic                     rx_full_o;
  logic                     tx_full_o;
  logic                     tx_wen;  // tx write enable
  logic                     rx_ren;  // rx read enable
  logic                     tx_en_reg;  // tx comm. enable
  logic                     rx_en_reg;  // rx comm. enable
  logic [DATA_WIDTH -1 : 0] dout_o;  // rx fifo out
  logic [             31:0] rdata;
  logic                     rx_frame_error;
  logic                     rd_state;


  uart_tx #(
      .CLK_FREQ  (CLK_FREQ),
      .BAUD_RATE (BAUD_RATE),
      .DATA_WIDTH(DATA_WIDTH),
      .FIFO_DEPTH(FIFO_DEPTH)
  ) tx_dut (
      .clk_i   (clk_i),
      .rst_ni  (rst_ni),
      .tx_en_i (tx_en_reg),
      .tx_wen_i(tx_wen),
      .din_i   (data_i[DATA_WIDTH-1:0]),
      .empty_o (tx_empty_o),
      .full_o  (tx_full_o),
      .tx_bit_o(uart_tx_o)

  );

  uart_rx #(
      .CLK_FREQ  (CLK_FREQ),
      .BAUD_RATE (BAUD_RATE),
      .DATA_WIDTH(DATA_WIDTH),
      .FIFO_DEPTH(FIFO_DEPTH)
  ) rx_dut (
      .clk_i   (clk_i),
      .rst_ni  (rst_ni),
      .rx_en_i (rx_en_reg),
      .rx_ren_i(rx_ren),
      .rx_bit_i(uart_rx_i),
      .dout_o  (dout_o),
      .empty_o (rx_empty_o),
      .full_o  (rx_full_o)
  );

  typedef enum logic [1:0] {
    UART_BAUD_ADDR   = 2'b00,
    UART_CTRL_ADDR   = 2'b01,
    UART_STATUS_ADDR = 2'b10,
    UART_DATA_ADDR   = 2'b11
  } uart_reg_e;

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      tx_en_reg <= 1'b0;
      rx_en_reg <= 1'b0;
    end else if (stb_i && we_i) begin
      unique case (adr_i)
        UART_CTRL_ADDR: begin
          if (byte_sel_i[0]) begin
            tx_en_reg <= data_i[0];
            rx_en_reg <= data_i[1];
          end
        end
        default: ;
      endcase
    end
  end

  always_comb begin
    tx_wen = 1'b0;
    rx_ren = 1'b0;

    if (stb_i) begin
      case (adr_i)
        UART_DATA_ADDR: begin
          if (we_i) begin
            tx_wen = ~tx_full_o;
          end else begin
            rx_ren = ~rx_empty_o;
          end
        end
        default: ;
      endcase
    end
  end

  always_ff @(posedge clk_i or negedge rst_ni) begin
    if (!rst_ni) begin
      rdata    <= '0;
      rd_state <= '0;
    end else begin
      rd_state <= stb_i && adr_i == UART_DATA_ADDR && !we_i;
      if (stb_i) begin
        unique case (adr_i)
          UART_BAUD_ADDR:   rdata <= 32'(BAUD_DIV);
          UART_CTRL_ADDR:   rdata <= {30'b0, rx_en_reg, tx_en_reg};
          UART_STATUS_ADDR: rdata <= {27'b0, rx_frame_error, rx_empty_o, rx_full_o, tx_empty_o, tx_full_o};
          default:          rdata <= '0;
        endcase
      end
    end
  end

  assign data_o = rd_state ? {{(32 - DATA_WIDTH) {1'b0}}, dout_o} : rdata;


endmodule
