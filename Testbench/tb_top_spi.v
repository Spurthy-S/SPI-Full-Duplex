`timescale 1ns/1ps

module tb_top_spi;

    reg sysclk;
    reg rst_n;
    reg start;

    reg [7:0] data_in_master;
    reg [7:0] data_in_slave;

    wire [7:0] data_out_master;
    wire [7:0] data_out_slave;
    wire transfer_done_master;
    wire transfer_done_slave;

    // DUT
    top_spi dut (
        .sysclk(sysclk),
        .rst_n(rst_n),
        .start(start),
        .data_in_master(data_in_master),
        .data_in_slave(data_in_slave),
        .data_out_master(data_out_master),
        .data_out_slave(data_out_slave),
        .transfer_done_master(transfer_done_master),
        .transfer_done_slave(transfer_done_slave)
    );

    // clock
    always #5 sysclk = ~sysclk;

    // task: single transfer
    task spi_transfer(input [7:0] m_in, input [7:0] s_in);
    begin
      $display("M_in=%h | S_in=%h",m_in,s_in);
      data_in_master = m_in;
      data_in_slave  = s_in;

      @(posedge sysclk);
        start = 1;
        
      @(posedge transfer_done_master);
      @(posedge transfer_done_slave);
      #20;

      $display("M_in=%h M_out=%h | S_in=%h S_out=%h",m_in, data_out_master,s_in, data_out_slave);
    end
    endtask

    initial 
    begin
      sysclk = 0;
      rst_n = 0;
      start = 0;
      data_in_master = 0;
      data_in_slave = 0;
      #20 rst_n = 1;
      
      // test vectors
        spi_transfer(8'h55, 8'hAA);
        spi_transfer(8'hAA, 8'h55);
        spi_transfer(8'hFF, 8'h00);
        spi_transfer(8'h0F, 8'hF0);

      // random tests
        repeat(5) begin
            spi_transfer($random, $random);
        end

        $finish;
    end

endmodule