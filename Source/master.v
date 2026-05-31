module master #(
    parameter SPI_MODE = 1,
    parameter CLK_DIV  = 4
)(
    input sysclk,
    input rst_n,
    input miso,                // Master In Slave Out
    input start,               // Start signal for transaction
    input [7:0] data_in,
    output slave_clk,          // SPI clock output (SCK)
    output reg [7:0] data_out,
    output reg mosi,           // Master Out Slave In
    output reg cs,             // Chip Select (Active LOW)
    output reg transfer_done
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
    reg sck;
    reg sck_d;
    
    
    assign slave_clk = sck;
    
    function integer clog2;
      input integer value;
      integer i;
      begin
        clog2 = 0;
        for (i = value - 1; i > 0; i = i >> 1)
            clog2 = clog2 + 1;
      end
    endfunction

    // clock divider
    localparam DIV_W = (CLK_DIV<=1)?1:clog2(CLK_DIV);
    reg [DIV_W-1:0] clk_div;
    wire sck_en = (clk_div==CLK_DIV-1);

    always @(posedge sysclk or negedge rst_n)
    begin
      if(!rst_n) 
        clk_div<=0;
      else if(state==TRANSFER)
        clk_div<= sck_en?0:clk_div+1;
      else clk_div<=0;
    end

    // edge detect    
    always @(posedge sysclk or negedge rst_n)
    begin
      if(!rst_n) 
        sck_d<=cpol;
      else if(sck_en) 
        sck_d<=sck;
    end

    wire leading_edge  = sck_en && (sck_d==cpol) && (sck!=cpol);
    wire trailing_edge = sck_en && (sck_d!=cpol) && (sck==cpol);

    always @(posedge sysclk or negedge rst_n) 
    begin
      if(!rst_n)
      begin
        state<=IDLE;
        cs<=1;
        sck<=cpol;
        mosi<=0;
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
                cs<=1;
                sck<=cpol;                
                if(start) 
                begin
                  cs<=0;
                  tx_reg<=data_in;
                  rx_reg<=0;
                  bit_count<=7;
                  state<=TRANSFER;
                  if(!cpha)
                    mosi<=data_in[7]; // preload for CPHA=0
                end
              end
        TRANSFER: begin
                    if(sck_en) 
                    begin
                      sck <= ~sck;
                    
                      // SAMPLE
                      if((leading_edge && !cpha) || (trailing_edge && cpha)) 
                      begin
                        rx_reg <= {rx_reg[6:0], miso};
                        if(bit_count==0)
                          state<=DONE;
                        else
                          bit_count<=bit_count-1;
                      end

                      // SHIFT
                      if((trailing_edge && !cpha) || (leading_edge && cpha)) 
                      begin
                        tx_reg <= {tx_reg[6:0],1'b0};
                        mosi   <= tx_reg[7];
                      end
                  end
                end

        DONE: begin
                cs<=1;
                sck<=cpol;
                data_out<=rx_reg;
                transfer_done<=1;
                clk_div <= 0; 
                state<=IDLE;
              end

        endcase
    
      end
    end
endmodule