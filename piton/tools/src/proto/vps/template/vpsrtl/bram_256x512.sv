module bram_256x512 #(
        parameter DATA_WIDTH = 512,
        parameter ADDR_WIDTH = 8
    )(
        input   wire                  clka     ,
        input   wire                  ena      ,
        input   wire                  wea      ,
        input   wire [ADDR_WIDTH-1:0] addra    ,
        input   wire [DATA_WIDTH-1:0] dina     ,
        input   wire                  clkb     ,
        input   wire                  enb      ,
        input   wire [ADDR_WIDTH-1:0] addrb    ,
        output  reg  [DATA_WIDTH-1:0] doutb
    ); 

    localparam MEM_DEPTH = (1 << ADDR_WIDTH);
    reg [DATA_WIDTH-1:0] mem [MEM_DEPTH-1:0];
    initial $readmemh("./bram_map.hex", mem);

    always @(posedge clka) begin
       if ( ena && wea ) begin
           mem[addra] <= dina;
       end
    end
    
    always @(posedge clka) begin
        if ( enb ) begin
             doutb <= mem[addrb];
        end
    end
endmodule
