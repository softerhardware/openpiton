module afifo_w64_d128_std (rst,rd_clk, wr_clk,din, dout, wr_en, rd_en,full, empty); 
    input               rd_clk;
    input               wr_clk;
    input               rst;
    input               wr_en;
    input               rd_en;
    input       [63:0]  din;
    output reg  [63:0]  dout; 
    output              full;
    output              empty ;

    reg [7:0]  Count = 0; 
    reg [63:0] FIFO [0:127]; 
    reg [7:0]  readCounter = 0, writeCounter = 0;

    wire EMPTY,FULL; 

    assign EMPTY = (Count==0)? 1'b1:1'b0; 
    assign FULL = (Count==127)? 1'b1:1'b0;
    assign full = FULL ;
    assign empty = EMPTY;

    always @ (posedge wr_clk) begin 
        if (rst) begin 
            writeCounter = 0;
        end
        else if (wr_en && Count<128) begin
            FIFO[writeCounter]  = din; 
            writeCounter = writeCounter+1; 
        end 
        if (writeCounter==128) writeCounter=0; 
    end

    always @ (posedge rd_clk) begin
        if (rst) begin
           readCounter = 0;
           dout= 64'd0 ;
        end
        else if ( rd_en && Count!=0) begin 
           dout= FIFO[readCounter];
           readCounter = readCounter+1;
        end
        if (readCounter==128) readCounter=0; 
        if (readCounter > writeCounter) Count= 8'd128-readCounter + writeCounter; 
        else if (writeCounter >= readCounter) Count=writeCounter-readCounter; 
    end 
endmodule
