module l15_anycoreencoder(
    input wire          clk,
    input wire          rst_n,
    
    input wire          l15_anycoreencoder_val,
    input wire [3:0]    l15_anycoreencoder_returntype,
    input wire          l15_anycoreencoder_l2miss,
    input wire [1:0]    l15_anycoreencoder_error,
    input wire          l15_anycoreencoder_noncacheable,
    input wire          l15_anycoreencoder_atomic,
    input wire [`L15_THREADID_MASK]    l15_anycoreencoder_threadid,
    input wire          l15_anycoreencoder_prefetch,
    input wire          l15_anycoreencoder_f4b,
    input wire [63:0]  l15_anycoreencoder_data_0,
    input wire [63:0]  l15_anycoreencoder_data_1,
    input wire [63:0]  l15_anycoreencoder_data_2,
    input wire [63:0]  l15_anycoreencoder_data_3,
    input wire          l15_anycoreencoder_inval_icache_all_way,
    input wire          l15_anycoreencoder_inval_dcache_all_way,
    input wire [`L15_PADDR_MASK]   l15_anycoreencoder_address,
    input wire [15:4]   l15_anycoreencoder_inval_address_15_4,
    input wire          l15_anycoreencoder_cross_invalidate,
    input wire [1:0]    l15_anycoreencoder_cross_invalidate_way,
    input wire          l15_anycoreencoder_inval_dcache_inval,
    input wire          l15_anycoreencoder_inval_icache_inval,
    input wire [1:0]    l15_anycoreencoder_inval_way,
    input wire          l15_anycoreencoder_blockinitstore,
  
    output              anycoreencoder_l15_req_ack,

    output [`ICACHE_TAG_BITS-1:0]           anycore_mem2ic_tag,
    output [`ICACHE_INDEX_BITS-1:0]         anycore_mem2ic_index,
    output [`ICACHE_BITS_IN_LINE-1:0]   anycore_mem2ic_data,
    output reg                              anycore_mem2ic_respvalid,

    output [`DCACHE_TAG_BITS-1:0]       anycore_mem2dc_ldtag,
    output [`DCACHE_INDEX_BITS-1:0]     anycore_mem2dc_ldindex,
    output [`DCACHE_BITS_IN_LINE-1:0]   anycore_mem2dc_lddata,
    output                              anycore_mem2dc_ldvalid,

    input                               anycore_dc2mem_stvalid,
    output reg                          anycore_mem2dc_stcomplete,
    output                              anycore_mem2dc_ststall,

    output reg          anycore_int
);

//`define STATE_NORMAL 1'b0
//`define STATE_SECONDHALF 1'b1
//
localparam STORE_IDLE = 1'b0;
localparam STORE_ACTIVE = 1'b1;

//reg state;
//reg state_next;

reg store_reg;
reg store_next;

wire [63:0] l15_anycoreencoder_address_sext;

wire [63:0] l15_anycoreencoder_data_0_swap = {l15_anycoreencoder_data_0[7:0], l15_anycoreencoder_data_0[15:8], l15_anycoreencoder_data_0[23:16], l15_anycoreencoder_data_0[31:24], l15_anycoreencoder_data_0[39:32], l15_anycoreencoder_data_0[47:40], l15_anycoreencoder_data_0[55:48], l15_anycoreencoder_data_0[63:56]};
wire [63:0] l15_anycoreencoder_data_1_swap = {l15_anycoreencoder_data_1[7:0], l15_anycoreencoder_data_1[15:8], l15_anycoreencoder_data_1[23:16], l15_anycoreencoder_data_1[31:24], l15_anycoreencoder_data_1[39:32], l15_anycoreencoder_data_1[47:40], l15_anycoreencoder_data_1[55:48], l15_anycoreencoder_data_1[63:56]};
wire [63:0] l15_anycoreencoder_data_2_swap = {l15_anycoreencoder_data_2[7:0], l15_anycoreencoder_data_2[15:8], l15_anycoreencoder_data_2[23:16], l15_anycoreencoder_data_2[31:24], l15_anycoreencoder_data_2[39:32], l15_anycoreencoder_data_2[47:40], l15_anycoreencoder_data_2[55:48], l15_anycoreencoder_data_2[63:56]};
wire [63:0] l15_anycoreencoder_data_3_swap = {l15_anycoreencoder_data_3[7:0], l15_anycoreencoder_data_3[15:8], l15_anycoreencoder_data_3[23:16], l15_anycoreencoder_data_3[31:24], l15_anycoreencoder_data_3[39:32], l15_anycoreencoder_data_3[47:40], l15_anycoreencoder_data_3[55:48], l15_anycoreencoder_data_3[63:56]};

//always @ (posedge clk) begin
//    if (!rst_n) begin
//        state <= `STATE_NORMAL;
//    end
//    else begin
//        state <= state_next;
//    end
//end

always @ (posedge clk) begin
    if (!rst_n) begin
        store_reg <= STORE_IDLE;
    end
    else begin
        store_reg <= store_next;
    end
end

assign anycore_mem2dc_ststall = (store_reg == STORE_ACTIVE) | anycore_dc2mem_stvalid;

assign l15_anycoreencoder_address_sext = {{24{l15_anycoreencoder_address[`PHY_ADDR_WIDTH-1]}}, l15_anycoreencoder_address};
assign anycoreencoder_l15_req_ack = l15_anycoreencoder_val;

assign anycore_mem2ic_tag = l15_anycoreencoder_address_sext[63:64-`ICACHE_TAG_BITS];
assign anycore_mem2ic_index = l15_anycoreencoder_address_sext[64-`ICACHE_TAG_BITS-1:64-`ICACHE_TAG_BITS-`ICACHE_INDEX_BITS];
assign anycore_mem2ic_data[`ICACHE_BITS_IN_LINE-1:0] = {l15_anycoreencoder_data_3_swap, l15_anycoreencoder_data_2_swap, l15_anycoreencoder_data_1_swap, l15_anycoreencoder_data_0_swap};

// keep track of whether we have received the wakeup interrupt
reg int_recv;
always @ (posedge clk) begin
    if (!rst_n) begin
        anycore_int <= 1'b0;
    end
    else if (int_recv) begin
        anycore_int <= 1'b1;
    end
    else if (anycore_int) begin
        anycore_int <= 1'b0;
    end
end

always @ * begin
    store_next = store_reg;
    if (anycore_dc2mem_stvalid) begin
        store_next = STORE_ACTIVE;
    end
    if (anycore_mem2dc_stcomplete) begin
        store_next = STORE_IDLE;
    end
end
   
always @ * begin
    //state_next = `STATE_NORMAL;
    anycore_mem2ic_respvalid = 1'b0;
    anycore_mem2dc_stcomplete = 1'b0;
    int_recv = 1'b0;
    if (l15_anycoreencoder_val) begin
        case(l15_anycoreencoder_returntype)
        `INT_RET: begin
            if (l15_anycoreencoder_data_0[17:16] == 2'b01) begin
                int_recv = 1'b1;
            end
            else begin
                int_recv = 1'b0;
            end
        end
        `IFILL_RET: begin
            anycore_mem2ic_respvalid = 1'b1;
        end
        `ST_ACK: begin
            anycore_mem2dc_stcomplete = 1'b1;
        end
        default: begin
            int_recv = 1'b0;
        end
        endcase 
    end
end

always @(posedge clk) begin
    if (anycore_mem2ic_respvalid) begin
        $display("anycore_mem2ic_data: %h", anycore_mem2ic_data);
        $display("l15_anycoreencoder_data_3: %h", l15_anycoreencoder_data_3);
        $display("l15_anycoreencoder_data_2: %h", l15_anycoreencoder_data_2);
        $display("l15_anycoreencoder_data_1: %h", l15_anycoreencoder_data_1);
        $display("l15_anycoreencoder_data_0: %h", l15_anycoreencoder_data_0);
    end
end
    
endmodule // l15_anycoreencoder
