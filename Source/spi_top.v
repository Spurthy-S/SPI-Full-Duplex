module top_spi(
    input sysclk,
    input rst_n,
    input start,

    input [7:0] data_in_master,
    input [7:0] data_in_slave,

    output [7:0] data_out_master,
    output [7:0] data_out_slave,
    output transfer_done_master,
    output transfer_done_slave
);

    wire mosi, miso, slave_clk, cs;

    master m1 (
        .sysclk(sysclk),
        .rst_n(rst_n),
        .miso(miso),
        .start(start),
        .data_in(data_in_master),
        .slave_clk(slave_clk),
        .data_out(data_out_master),
        .mosi(mosi),
        .cs(cs),        
        .transfer_done(transfer_done_master)
    );

    slave s1 (
        .sysclk(sysclk),
        .rst_n(rst_n),  
        .mosi(mosi),
        .slave_clk(slave_clk),
        .cs(cs),
        .data_in(data_in_slave),
        .miso(miso),      
        .transfer_done(transfer_done_slave),
        .data_out(data_out_slave)
    );

endmodule
