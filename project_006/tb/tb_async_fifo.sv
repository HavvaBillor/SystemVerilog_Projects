`timescale 1ns / 1ps

module tb_async_fifo;

  localparam DATA_WIDTH = 8;  // for counter_based and shift fifo, it is used 6
  localparam ADDR_WIDTH = 4;

  logic                   wclk;
  logic                   rclk;
  logic                   wrst_n;
  logic                   rrst_n;
  logic                   w_en;
  logic                   r_en;
  logic [DATA_WIDTH -1:0] w_data;
  logic [ DATA_WIDTH-1:0] r_data;
  logic                   empty;
  logic                   full;


  async_fifo_top #(
      .DATA_WIDTH(DATA_WIDTH),
      .ADDR_WIDTH(ADDR_WIDTH)
  ) async_fifo (
      .*
  );


  // write clk 100MHz
  initial begin
    wclk = 0;
  end
  always #5ns wclk = ~wclk;

  // read clk 40MHz
  initial begin
    rclk = 0;
  end
  always #12.5ns rclk = ~rclk;

  logic [7:0] test_data_array[] = {'h1, 'h2, 'h3, 'h4, 'h5, 'h6, 'h7, 'h8, 'h9, 'h10, 'h11, 'h12, 'h13, 'h14, 'h15, 'h16, 'h17};
  logic [7:0] my_que         [$                                                                                                 ];

  task write_fifo(input logic [7:0] data);
    @(negedge wclk);
    w_data <= data;
    w_en   <= 1'b1;
    @(posedge wclk);
    if (full) begin
      $warning("WARNING!: You attempted to write data when FIFO was FULL");
    end else begin
      my_que.push_back(data);
      $info("INFO: [WRITE] Data: %h is written", data);
    end
    w_en <= 1'b0;
  endtask

  task read_fifo();
    logic [7:0] expected_data;
    @(negedge rclk);

    if (my_que.size() == 0) begin

      if (!empty) begin
        $error("ERROR! QUE is empty but FIFO is NOT!");
      end else begin
        $warning("WARNING! You attempted to read data when FIFO and QUE were empty");
      end

    end else begin
      // latency tolerans
      while (empty) begin
        @(posedge rclk);
      end

      expected_data = my_que.pop_front();
      if (r_data !== expected_data) begin
        $error("ERROR! Expected data: %h Received data: %h", expected_data, r_data);
      end else begin
        $info("INFO: Successful reading: %h", r_data);
      end
    end

    r_en <= 1'b1;
    @(posedge rclk);
    #1;
    r_en <= 1'b0;

  endtask

  initial begin

    wrst_n <= 1'b0;
    rrst_n <= 1'b0;
    r_en   <= 1'b0;
    w_en   <= 1'b0;
    w_data <= '0;
    #100ns;
    wrst_n <= 1'b1;
    rrst_n <= 1'b1;
    #20ns;

    $info("--- TEST SCENARIO IS STARTED ---\n");
    $info("-------------------------------------------------------------------------\n");
    $info("TEST 1: Reading data when FIFO is empty----------------------------------\n");
    read_fifo();
    #20;

    $info("----------------------------------------------------------------------- \n");
    $info("TEST 2: Writing data and testing overflow-------------------------------\n");
    for (int i = 0; i < test_data_array.size(); ++i) begin
      write_fifo(test_data_array[i]);
    end
    #100;

    $info("--------------------------------------------------------------------------- \n");
    $info("TEST 3: Reading data------------------------------------------------------- \n");
    for (int i = 0; i < test_data_array.size(); ++i) begin
      read_fifo();
    end

    $info("------------------------------------------------------------------------------ \n");
    $info("TEST 4: Simultaneous Read & Write--------------------------------------------- \n");

    write_fifo(8'hA1);
    write_fifo(8'hA2);
    #20ns;

    fork
      write_fifo(8'hA3);
      read_fifo();
    join
    #20ns;

    while (my_que.size() > 0) begin
      read_fifo();
    end

    $info("\n -------------------- TESTS FINISHED SUCCESSFULLY -----------------------");
    #100;
    $finish;

  end


endmodule


/*
# ** Info: --- TEST SCENARIO IS STARTED ---
#    Time: 120 ns  Scope: tb_async_fifo File: tb/tb_async_fifo.sv Line: 102
# ** Info: -------------------------------------------------------------------------
#    Time: 120 ns  Scope: tb_async_fifo File: tb/tb_async_fifo.sv Line: 103
# ** Info: TEST 1: Reading data when FIFO is empty----------------------------------
#    Time: 120 ns  Scope: tb_async_fifo File: tb/tb_async_fifo.sv Line: 104
# ** Warning: WARNING! You attempted to read data when FIFO and QUE were empty
#    Time: 125 ns  Scope: tb_async_fifo.read_fifo File: tb/tb_async_fifo.sv Line: 66
# ** Info: -----------------------------------------------------------------------
#    Time: 158500 ps  Scope: tb_async_fifo File: tb/tb_async_fifo.sv Line: 108
# ** Info: TEST 2: Writing data and testing overflow-------------------------------
#    Time: 158500 ps  Scope: tb_async_fifo File: tb/tb_async_fifo.sv Line: 109
# ** Info: INFO: [WRITE] Data: 01 is written
#    Time: 165 ns  Scope: tb_async_fifo.write_fifo File: tb/tb_async_fifo.sv Line: 52
# ** Info: INFO: [WRITE] Data: 02 is written
#    Time: 175 ns  Scope: tb_async_fifo.write_fifo File: tb/tb_async_fifo.sv Line: 52
# ** Info: INFO: [WRITE] Data: 03 is written
#    Time: 185 ns  Scope: tb_async_fifo.write_fifo File: tb/tb_async_fifo.sv Line: 52
# ** Info: INFO: [WRITE] Data: 04 is written
#    Time: 195 ns  Scope: tb_async_fifo.write_fifo File: tb/tb_async_fifo.sv Line: 52
# ** Info: INFO: [WRITE] Data: 05 is written
#    Time: 205 ns  Scope: tb_async_fifo.write_fifo File: tb/tb_async_fifo.sv Line: 52
# ** Info: INFO: [WRITE] Data: 06 is written
#    Time: 215 ns  Scope: tb_async_fifo.write_fifo File: tb/tb_async_fifo.sv Line: 52
# ** Info: INFO: [WRITE] Data: 07 is written
#    Time: 225 ns  Scope: tb_async_fifo.write_fifo File: tb/tb_async_fifo.sv Line: 52
# ** Info: INFO: [WRITE] Data: 08 is written
#    Time: 235 ns  Scope: tb_async_fifo.write_fifo File: tb/tb_async_fifo.sv Line: 52
# ** Info: INFO: [WRITE] Data: 09 is written
#    Time: 245 ns  Scope: tb_async_fifo.write_fifo File: tb/tb_async_fifo.sv Line: 52
# ** Info: INFO: [WRITE] Data: 10 is written
#    Time: 255 ns  Scope: tb_async_fifo.write_fifo File: tb/tb_async_fifo.sv Line: 52
# ** Info: INFO: [WRITE] Data: 11 is written
#    Time: 265 ns  Scope: tb_async_fifo.write_fifo File: tb/tb_async_fifo.sv Line: 52
# ** Info: INFO: [WRITE] Data: 12 is written
#    Time: 275 ns  Scope: tb_async_fifo.write_fifo File: tb/tb_async_fifo.sv Line: 52
# ** Info: INFO: [WRITE] Data: 13 is written
#    Time: 285 ns  Scope: tb_async_fifo.write_fifo File: tb/tb_async_fifo.sv Line: 52
# ** Info: INFO: [WRITE] Data: 14 is written
#    Time: 295 ns  Scope: tb_async_fifo.write_fifo File: tb/tb_async_fifo.sv Line: 52
# ** Info: INFO: [WRITE] Data: 15 is written
#    Time: 305 ns  Scope: tb_async_fifo.write_fifo File: tb/tb_async_fifo.sv Line: 52
# ** Info: INFO: [WRITE] Data: 16 is written
#    Time: 315 ns  Scope: tb_async_fifo.write_fifo File: tb/tb_async_fifo.sv Line: 52
# ** Warning: WARNING!: You attempted to write data when FIFO was FULL
#    Time: 325 ns  Scope: tb_async_fifo.write_fifo File: tb/tb_async_fifo.sv Line: 49
# ** Info: ---------------------------------------------------------------------------
#    Time: 425 ns  Scope: tb_async_fifo File: tb/tb_async_fifo.sv Line: 115
# ** Info: TEST 3: Reading data-------------------------------------------------------
#    Time: 425 ns  Scope: tb_async_fifo File: tb/tb_async_fifo.sv Line: 116
# ** Info: INFO: Successful reading: 01
#    Time: 425 ns  Scope: tb_async_fifo.read_fifo File: tb/tb_async_fifo.sv Line: 79
# ** Info: INFO: Successful reading: 02
#    Time: 450 ns  Scope: tb_async_fifo.read_fifo File: tb/tb_async_fifo.sv Line: 79
# ** Info: INFO: Successful reading: 03
#    Time: 475 ns  Scope: tb_async_fifo.read_fifo File: tb/tb_async_fifo.sv Line: 79
# ** Info: INFO: Successful reading: 04
#    Time: 500 ns  Scope: tb_async_fifo.read_fifo File: tb/tb_async_fifo.sv Line: 79
# ** Info: INFO: Successful reading: 05
#    Time: 525 ns  Scope: tb_async_fifo.read_fifo File: tb/tb_async_fifo.sv Line: 79
# ** Info: INFO: Successful reading: 06
#    Time: 550 ns  Scope: tb_async_fifo.read_fifo File: tb/tb_async_fifo.sv Line: 79
# ** Info: INFO: Successful reading: 07
#    Time: 575 ns  Scope: tb_async_fifo.read_fifo File: tb/tb_async_fifo.sv Line: 79
# ** Info: INFO: Successful reading: 08
#    Time: 600 ns  Scope: tb_async_fifo.read_fifo File: tb/tb_async_fifo.sv Line: 79
# ** Info: INFO: Successful reading: 09
#    Time: 625 ns  Scope: tb_async_fifo.read_fifo File: tb/tb_async_fifo.sv Line: 79
# ** Info: INFO: Successful reading: 10
#    Time: 650 ns  Scope: tb_async_fifo.read_fifo File: tb/tb_async_fifo.sv Line: 79
# ** Info: INFO: Successful reading: 11
#    Time: 675 ns  Scope: tb_async_fifo.read_fifo File: tb/tb_async_fifo.sv Line: 79
# ** Info: INFO: Successful reading: 12
#    Time: 700 ns  Scope: tb_async_fifo.read_fifo File: tb/tb_async_fifo.sv Line: 79
# ** Info: INFO: Successful reading: 13
#    Time: 725 ns  Scope: tb_async_fifo.read_fifo File: tb/tb_async_fifo.sv Line: 79
# ** Info: INFO: Successful reading: 14
#    Time: 750 ns  Scope: tb_async_fifo.read_fifo File: tb/tb_async_fifo.sv Line: 79
# ** Info: INFO: Successful reading: 15
#    Time: 775 ns  Scope: tb_async_fifo.read_fifo File: tb/tb_async_fifo.sv Line: 79
# ** Info: INFO: Successful reading: 16
#    Time: 800 ns  Scope: tb_async_fifo.read_fifo File: tb/tb_async_fifo.sv Line: 79
# ** Warning: WARNING! You attempted to read data when FIFO and QUE were empty
#    Time: 825 ns  Scope: tb_async_fifo.read_fifo File: tb/tb_async_fifo.sv Line: 66
# ** Info: ------------------------------------------------------------------------------
#    Time: 838500 ps  Scope: tb_async_fifo File: tb/tb_async_fifo.sv Line: 121
# ** Info: TEST 4: Simultaneous Read & Write---------------------------------------------
#    Time: 838500 ps  Scope: tb_async_fifo File: tb/tb_async_fifo.sv Line: 122
# ** Info: INFO: [WRITE] Data: a1 is written
#    Time: 845 ns  Scope: tb_async_fifo.write_fifo File: tb/tb_async_fifo.sv Line: 52
# ** Info: INFO: [WRITE] Data: a2 is written
#    Time: 855 ns  Scope: tb_async_fifo.write_fifo File: tb/tb_async_fifo.sv Line: 52
# ** Info: INFO: [WRITE] Data: a3 is written
#    Time: 885 ns  Scope: tb_async_fifo.write_fifo File: tb/tb_async_fifo.sv Line: 52
# ** Info: INFO: Successful reading: a1
#    Time: 937500 ps  Scope: tb_async_fifo.read_fifo File: tb/tb_async_fifo.sv Line: 79
# ** Info: INFO: Successful reading: a2
#    Time: 1 us  Scope: tb_async_fifo.read_fifo File: tb/tb_async_fifo.sv Line: 79
# ** Info: INFO: Successful reading: a3
#    Time: 1025 ns  Scope: tb_async_fifo.read_fifo File: tb/tb_async_fifo.sv Line: 79
# ** Info: 
#  -------------------- TESTS FINISHED SUCCESSFULLY -----------------------
#    Time: 1038500 ps  Scope: tb_async_fifo File: tb/tb_async_fifo.sv Line: 138
# ** Note: $finish    : tb/tb_async_fifo.sv(140)
#    Time: 1138500 ps  Iteration: 0  Instance: /tb_async_fifo
# End time: 18:33:42 on Jan 27,2026, Elapsed time: 0:00:01
# Errors: 0, Warnings: 3

*/
