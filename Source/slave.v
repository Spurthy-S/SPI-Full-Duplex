
module slave #(parameter SPI_MODE=1)
(
    input        sysclk,        
    input rst_n,
    input mosi,                 // Master Out Slave In
    input slave_clk,            // SPI clock from master (SCK)  
    input cs,                   // Chip Select (Active LOW)
    input [7:0] data_in,        // Data to transmit to master
    output reg miso,            // Master In Slave Out
    output reg transfer_done,
    output reg [7:0] data_out   // Data received from master
);



    //------------------------------------------------------------
    // SPI Mode decoding
    // SPI Modes:
    // Mode 0: CPOL=0, CPHA=0
    // Mode 1: CPOL=0, CPHA=1
    // Mode 2: CPOL=1, CPHA=0
    // Mode 3: CPOL=1, CPHA=1
    //------------------------------------------------------------
    
    
    
    wire cpol = (SPI_MODE==2)||(SPI_MODE==3);
    wire cpha = (SPI_MODE==1)||(SPI_MODE==3);

    localparam IDLE=0, TRANSFER=1, DONE=2;

    reg [1:0] state;
    reg [7:0] tx_reg, rx_reg;
    reg [2:0] bit_count;

    // sync clock
    reg [1:0] sck_sync;
    always @(posedge sysclk or negedge rst_n)
    begin
      if(!rst_n) 
        sck_sync<={2{cpol}};
      else 
        sck_sync<={sck_sync[0], slave_clk};
    end

    // Detect clock edges
    wire rising_edge  = (sck_sync==2'b01);
    wire falling_edge = (sck_sync==2'b10);

    wire leading_edge  = (cpol==0)? rising_edge  : falling_edge;
    wire trailing_edge = (cpol==0)? falling_edge : rising_edge;

    // CS detect
    reg cs_d;
    always @(posedge sysclk or negedge rst_n)
    begin
      if(!rst_n) 
        cs_d<=1;
      else 
        cs_d<=cs;
    end
  
    wire cs_falling = (cs_d==1 && cs==0);

    always @(posedge sysclk or negedge rst_n) 
    begin
      if(!rst_n) 
      begin
        state<=IDLE;
        miso<=0;
        tx_reg<=0;
        rx_reg<=0;
        bit_count<=7;
        data_out<=0;
        transfer_done<=0;
      end 
      else 
      begin
        transfer_done<=0;
        
        case(state)
        IDLE: begin
                if(!cs) 
                begin
                  tx_reg<=data_in;
                  rx_reg<=0;
                  bit_count<=7;
                  transfer_done<=0;
                  state<=TRANSFER;
                  if(!cpha)
                    miso<=data_in[7]; // preload
                end
              end
        TRANSFER: begin
                    if(cs) 
                      state<=IDLE;
                    else 
                    begin
                  
                      // SAMPLE
                      if((leading_edge && !cpha) || (trailing_edge && cpha)) 
                      begin
                        rx_reg <= {rx_reg[6:0], mosi};
                        if(bit_count==0)
                          state<=DONE;
                        else
                          bit_count<=bit_count-1;
                      end

                      // SHIFT
                      if((trailing_edge && !cpha) || (leading_edge && cpha)) 
                      begin
                        tx_reg <= {tx_reg[6:0],1'b0};
                        miso   <= tx_reg[7];
                      end
                    end
                  end

        DONE: begin
                data_out <= rx_reg;
                transfer_done <= 1;
                bit_count <= 7;
                tx_reg <= 0;
                rx_reg <= 0;
                state <= IDLE;
              end
        endcase
      end
    end
endmodule