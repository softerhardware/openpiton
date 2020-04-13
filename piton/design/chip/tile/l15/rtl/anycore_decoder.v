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

reg current_val;
reg prev_val;

// Get full address that's 64 bits long since it's otherwise to icache
// block alignment
wire [63:0] anycore_imiss_full_addr = anycore_ic2mem_reqaddr << (64-`ICACHE_BLOCK_ADDR_BITS);
// Sign extend to 64 bits
wire [63:0] anycore_store_full_addr = {{((64-`DCACHE_ST_ADDR_BITS)-3){anycore_dc2mem_staddr[`DCACHE_ST_ADDR_BITS-1]}}, (anycore_dc2mem_staddr << 3)};
// Sign extend to 64 bits
wire [63:0] anycore_load_full_addr = {{((64-`DCACHE_BLOCK_ADDR_BITS)-4){anycore_dc2mem_ldaddr[`DCACHE_BLOCK_ADDR_BITS-1]}}, (anycore_dc2mem_ldaddr << 4)};

wire [63:0] anycore_dc2mem_stdata_flipped = {anycore_dc2mem_stdata[7:0], anycore_dc2mem_stdata[15:8], anycore_dc2mem_stdata[23:16], anycore_dc2mem_stdata[31:24], anycore_dc2mem_stdata[39:32], anycore_dc2mem_stdata[47:40], anycore_dc2mem_stdata[55:48], anycore_dc2mem_stdata[63:56]};
//wire [63:0] anycore_dc2mem_stdata_flipped = anycore_dc2mem_stdata;

// Status of different requests
localparam IDLE = 2'd0;
localparam ARRIVE = 2'd1;
localparam ISSUE = 2'd2;

// "next" is wire
reg [1:0] store_reg;
reg [1:0] store_next;
reg [63:0]    			  anycore_store_full_addr_buf;  
reg [63:0]    			  anycore_store_full_addr_buf_next;  
reg [`SIZE_DATA-1:0]              anycore_dc2mem_stdata_flipped_buf;
reg [`SIZE_DATA-1:0]              anycore_dc2mem_stdata_flipped_buf_next;
reg [2:0]                         anycore_dc2mem_stsize_buf;
reg [2:0]                         anycore_dc2mem_stsize_buf_next;

reg [1:0] load_reg;
reg [1:0] load_next;
reg [63:0] 			  anycore_load_full_addr_buf;
reg [63:0] 			  anycore_load_full_addr_buf_next;

reg [1:0] imiss_reg;
reg [1:0] imiss_next;
reg [63:0] 			  anycore_imiss_full_addr_buf;
reg [63:0] 			  anycore_imiss_full_addr_buf_next;

reg  [`PHY_ADDR_WIDTH-1:0] anycoredecoder_l15_address_next;
reg  [63:0] anycoredecoder_l15_data_next;
reg  [4:0]  anycoredecoder_l15_rqtype_next;
reg  [2:0]  anycoredecoder_l15_size_next;

// internal states
always @ (posedge clk) begin
    if (!rst_n) begin
        store_reg <= IDLE;
        load_reg <= IDLE;
        imiss_reg <= IDLE;
	anycore_store_full_addr_buf <= 64'b0;
	anycore_dc2mem_stdata_flipped_buf   <= {`SIZE_DATA{1'b0}};
	anycore_dc2mem_stsize_buf   <= 3'b0;
	anycore_load_full_addr_buf  <= 64'b0;
	anycore_imiss_full_addr_buf  <= 64'b0;
    end
    else begin
        store_reg <= store_next;
        load_reg <= load_next;
        imiss_reg <= imiss_next;
	anycore_store_full_addr_buf <= anycore_store_full_addr_buf_next;
	anycore_dc2mem_stdata_flipped_buf   <= anycore_dc2mem_stdata_flipped_buf_next;
	anycore_dc2mem_stsize_buf   <= anycore_dc2mem_stsize_buf_next;
	anycore_load_full_addr_buf  <= anycore_load_full_addr_buf_next;
	anycore_imiss_full_addr_buf  <= anycore_imiss_full_addr_buf_next;
    end
end

always @ * begin
    store_next = store_reg;
    load_next = load_reg;
    imiss_next = imiss_reg;
    anycore_store_full_addr_buf_next = anycore_store_full_addr_buf;
    anycore_dc2mem_stdata_flipped_buf_next   = anycore_dc2mem_stdata_flipped_buf;
    anycore_dc2mem_stsize_buf_next   = anycore_dc2mem_stsize_buf;
    anycore_load_full_addr_buf_next  = anycore_load_full_addr_buf;
    anycore_imiss_full_addr_buf_next  = anycore_imiss_full_addr_buf;
    // L15 gets a request
    if (l15_transducer_ack) begin
        store_next = (store_reg == ISSUE) ? IDLE : store_reg;
        load_next = (load_reg == ISSUE) ? IDLE: load_reg;
        imiss_next = (imiss_reg == ISSUE) ? IDLE: imiss_reg;
    end
    // New requests arrive
    if (anycore_dc2mem_stvalid) begin
        store_next = ARRIVE;
	anycore_store_full_addr_buf_next = anycore_store_full_addr;
        anycore_dc2mem_stdata_flipped_buf_next   = anycore_dc2mem_stdata_flipped;
        anycore_dc2mem_stsize_buf_next   = anycore_dc2mem_stsize;
    end
    if (anycore_dc2mem_ldvalid) begin
        load_next = ARRIVE;
        anycore_load_full_addr_buf_next  = anycore_load_full_addr;
    end
    if (anycore_ic2mem_reqvalid) begin
        imiss_next = ARRIVE;
        anycore_imiss_full_addr_buf_next  = anycore_imiss_full_addr;
    end
    // Issue and deal with arrive at the same time
    // Imiss > Load > Store
    if (imiss_next == ARRIVE) begin
        imiss_next = ((store_reg != ISSUE) && (load_reg != ISSUE)) ? ISSUE : ARRIVE;
    end
    else begin
	if (load_next == ARRIVE) begin
            load_next = ((store_reg != ISSUE) && (imiss_reg != ISSUE)) ? ISSUE : ARRIVE;
	end
	else begin
	    if (store_next == ARRIVE) begin
                store_next = ((load_reg != ISSUE) && (imiss_reg != ISSUE)) ? ISSUE : ARRIVE;
	    end
	end
    end

    // set rqtype specific data
    if (imiss_next == ISSUE) begin
        // ifill operation
        // need bypass if reg == IDLE
        anycoredecoder_l15_address_next = (imiss_reg == IDLE) ? anycore_imiss_full_addr_buf_next[`PHY_ADDR_WIDTH-1:0]
							      : anycore_imiss_full_addr_buf[`PHY_ADDR_WIDTH-1:0];
        anycoredecoder_l15_data_next = 64'b0;
        anycoredecoder_l15_rqtype_next = `IMISS_RQ;
        anycoredecoder_l15_size_next = `PCX_SZ_4B;
    end
    else if (load_next == ISSUE) begin
        anycoredecoder_l15_address_next = (load_reg == IDLE) ? anycore_load_full_addr_buf_next[`PHY_ADDR_WIDTH-1:0]
							     : anycore_load_full_addr_buf[`PHY_ADDR_WIDTH-1:0];
        anycoredecoder_l15_data_next = 64'b0;
        anycoredecoder_l15_rqtype_next = `LOAD_RQ;
        anycoredecoder_l15_size_next = `PCX_SZ_16B;
    end
    else if(store_next == ISSUE) begin
        anycoredecoder_l15_address_next = (store_reg == IDLE) ? anycore_store_full_addr_buf_next[`PHY_ADDR_WIDTH-1:0]
							      : anycore_store_full_addr_buf[`PHY_ADDR_WIDTH-1:0];
        anycoredecoder_l15_data_next = (store_reg == IDLE) ? anycore_dc2mem_stdata_flipped_buf_next  //anycore_dc2mem_stdata;
							   : anycore_dc2mem_stdata_flipped_buf;
        anycoredecoder_l15_rqtype_next = `STORE_RQ;
        anycoredecoder_l15_size_next = (store_reg == IDLE) ? anycore_dc2mem_stsize_buf_next
							   : anycore_dc2mem_stsize_buf;
    end
    else  begin
        anycoredecoder_l15_address_next = `PHY_ADDR_WIDTH'b0;
        anycoredecoder_l15_data_next = 64'b0;
        anycoredecoder_l15_rqtype_next = 5'b0;
        anycoredecoder_l15_size_next = 3'b0;
    end


end

// outputs
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
        current_val <= anycore_ic2mem_reqvalid | anycore_dc2mem_stvalid | anycore_dc2mem_ldvalid;
        prev_val <= current_val;
        anycoredecoder_l15_val <= (imiss_next == ISSUE) | (load_next == ISSUE) | (store_next == ISSUE);
	//anycore_ic2mem_reqvalid | anycore_dc2mem_ldvalid | anycore_dc2mem_stvalid | store_next;//anycore_dc2mem_stvalid | anycore_dc2mem_ldvalid | store_reg;// | load_reg;
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

/*always @ * begin
if (imiss_next == ISSUE) begin
    // ifill operation
    anycoredecoder_l15_address_next = anycore_imiss_full_addr[`PHY_ADDR_WIDTH-1:0];
    anycoredecoder_l15_data_next = 64'b0;
    anycoredecoder_l15_rqtype_next = `IMISS_RQ;
    anycoredecoder_l15_size_next = `PCX_SZ_4B;
end
else if (anycore_dc2mem_stvalid) begin
    anycoredecoder_l15_address_next = anycore_store_full_addr[`PHY_ADDR_WIDTH-1:0];
    anycoredecoder_l15_data_next = anycore_dc2mem_stdata_flipped;//anycore_dc2mem_stdata;
    anycoredecoder_l15_rqtype_next = `STORE_RQ;
    anycoredecoder_l15_size_next = anycore_dc2mem_stsize;
end
else if (store_reg == STORE_ACTIVE) begin
    anycoredecoder_l15_address_next = anycoredecoder_l15_address;
    anycoredecoder_l15_data_next = anycoredecoder_l15_data;
    anycoredecoder_l15_rqtype_next = anycoredecoder_l15_rqtype;
    anycoredecoder_l15_size_next = anycoredecoder_l15_size;
end
// load
else if (anycore_dc2mem_ldvalid) begin
    anycoredecoder_l15_address_next =  anycore_load_full_addr[`PHY_ADDR_WIDTH-1:0];
    anycoredecoder_l15_data_next = 64'b0;
    anycoredecoder_l15_rqtype_next = `LOAD_RQ;
    anycoredecoder_l15_size_next = `PCX_SZ_4B;
end
else if (load_reg == LOAD_ACTIVE) begin
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
*/
endmodule
