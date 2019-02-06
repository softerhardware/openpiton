`include "iop.h" 
`include "CommonConfig.h"
module anycore_decoder(
    input wire         clk,
    input wire         rst_n,

    input l15_transducer_ack,

    input [`ICACHE_BLOCK_ADDR_BITS-1:0] anycore_ic2mem_reqaddr,
    input                               anycore_ic2mem_reqvalid,

    input [`DCACHE_BLOCK_ADDR_BITS-1:0] anycore_dc2mem_ldaddr,
    input                               anycore_dc2mem_ldvalid,

    input [`DCACHE_ST_ADDR_BITS-1:0]    anycore_dc2mem_staddr,  
    input [`SIZE_DATA-1:0]              anycore_dc2mem_stdata,
    input [2:0]                         anycore_dc2mem_stsize,
    input                               anycore_dc2mem_stvalid,

    // outputs anycore uses                    
    output reg  [4:0]  anycoredecoder_l15_rqtype,
    output reg  [2:0]  anycoredecoder_l15_size,
    output reg         anycoredecoder_l15_val,
    output reg  [`PHY_ADDR_WIDTH-1:0] anycoredecoder_l15_address,
    output reg  [63:0] anycoredecoder_l15_data,
    output wire        anycoredecoder_l15_nc,


    // outputs anycore doesn't use                    
    output wire [0:0]  anycoredecoder_l15_threadid,
    output wire        anycoredecoder_l15_prefetch,
    output wire        anycoredecoder_l15_invalidate_cacheline,
    output wire        anycoredecoder_l15_blockstore,
    output wire        anycoredecoder_l15_blockinitstore,
    output wire [1:0]  anycoredecoder_l15_l1rplway,
    output wire [63:0] anycoredecoder_l15_data_next_entry,
    output wire [32:0] anycoredecoder_l15_csm_data
);

localparam STORE_IDLE = 1'b0;
localparam STORE_ACTIVE = 1'b1;

reg current_val;
reg prev_val;

reg store_reg;
reg store_next;

// Get full address that's 64 bits long since it's otherwise to icache
// block alignment
wire [63:0] anycore_imiss_full_addr = anycore_ic2mem_reqaddr << (64-`ICACHE_BLOCK_ADDR_BITS);
// Sign extend to 64 bits
wire [63:0] anycore_store_full_addr = {{((64-`DCACHE_ST_ADDR_BITS)-3){anycore_dc2mem_staddr[`DCACHE_ST_ADDR_BITS-1]}}, (anycore_dc2mem_staddr << 3)};

reg  [`PHY_ADDR_WIDTH-1:0] anycoredecoder_l15_address_next;
reg  [63:0] anycoredecoder_l15_data_next;
reg  [4:0]  anycoredecoder_l15_rqtype_next;
reg  [2:0]  anycoredecoder_l15_size_next;

always @ (posedge clk) begin
    if (!rst_n) begin
        store_reg <= STORE_IDLE;
    end
    else begin
        store_reg <= store_next;
    end
end

always @ * begin
    store_next = store_reg;
    if (anycore_dc2mem_stvalid) begin
        store_next = STORE_ACTIVE;
    end
    if (l15_transducer_ack) begin
        store_next = STORE_IDLE;
    end
end

always @ (posedge clk)
begin
    if (!rst_n) begin
        current_val <= 0;
        prev_val <= 0;
        anycoredecoder_l15_val <= 1'b0;
        anycoredecoder_l15_address <= `PHY_ADDR_WIDTH'b0;
        anycoredecoder_l15_data <= 64'b0;
        anycoredecoder_l15_rqtype <= 5'b0;
        anycoredecoder_l15_size <= 3'b0;
    end
    else begin
        current_val <= anycore_ic2mem_reqvalid | anycore_dc2mem_stvalid;
        prev_val <= current_val;
        anycoredecoder_l15_val <= anycore_ic2mem_reqvalid | anycore_dc2mem_stvalid | store_reg;
        anycoredecoder_l15_address <= anycoredecoder_l15_address_next;
        anycoredecoder_l15_data <= anycoredecoder_l15_data_next;
        anycoredecoder_l15_rqtype <= anycoredecoder_l15_rqtype_next;
        anycoredecoder_l15_size <= anycoredecoder_l15_size_next;
    end
end

// unused wires tie to zero
assign anycoredecoder_l15_threadid = 1'b0;
assign anycoredecoder_l15_prefetch = 1'b0;
assign anycoredecoder_l15_csm_data = 33'b0;
assign anycoredecoder_l15_data_next_entry = 64'b0;

assign anycoredecoder_l15_blockstore = 1'b0;
assign anycoredecoder_l15_blockinitstore = 1'b0;
// is this set when something in the l1 gets replaced?
assign anycoredecoder_l15_l1rplway = 2'b0;
// will anycore ever need to invalidate cachelines?
assign anycoredecoder_l15_invalidate_cacheline = 1'b0;

//assign anycoredecoder_l15_val = current_val && !prev_val;
//assign anycoredecoder_l15_val = anycore_ic2mem_reqvalid | anycore_dc2mem_stvalid | store_reg;

assign anycoredecoder_l15_nc = anycoredecoder_l15_address[`PHY_ADDR_WIDTH-1];

// set rqtype specific data
always @ * begin
if (anycore_ic2mem_reqvalid) begin
    // ifill operation
    anycoredecoder_l15_address_next = anycore_imiss_full_addr[`PHY_ADDR_WIDTH-1:0];
    anycoredecoder_l15_data_next = 64'b0;
    anycoredecoder_l15_rqtype_next = `IMISS_RQ;
    anycoredecoder_l15_size_next = `PCX_SZ_4B;
end
else if (anycore_dc2mem_stvalid) begin
    anycoredecoder_l15_address_next = anycore_store_full_addr[`PHY_ADDR_WIDTH-1:0];
    anycoredecoder_l15_data_next = anycore_dc2mem_stdata;
    anycoredecoder_l15_rqtype_next = `STORE_RQ;
    anycoredecoder_l15_size_next = anycore_dc2mem_stsize;
end
else if (store_reg == STORE_ACTIVE) begin
    anycoredecoder_l15_address_next = anycoredecoder_l15_address;
    anycoredecoder_l15_data_next = anycoredecoder_l15_data;
    anycoredecoder_l15_rqtype_next = anycoredecoder_l15_rqtype;
    anycoredecoder_l15_size_next = anycoredecoder_l15_size;
end
else begin
    anycoredecoder_l15_address_next = `PHY_ADDR_WIDTH'b0;
    anycoredecoder_l15_data_next = 64'b0;
    anycoredecoder_l15_rqtype_next = 5'b0;
    anycoredecoder_l15_size_next = 3'b0;
end
end
endmodule
