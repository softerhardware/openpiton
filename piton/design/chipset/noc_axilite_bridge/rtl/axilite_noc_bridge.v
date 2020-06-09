`include "define.tmp.h"

module axilite_noc_bridge (
    input  wire                                   clk,
    input  wire                                   rst,

    input wire                                    noc2_valid_in,
    input wire [`NOC_DATA_WIDTH-1:0]              noc2_data_in,
    output                                        noc2_ready_out,

    output  					                  noc2_valid_out,
    output [`NOC_DATA_WIDTH-1:0] 		          noc2_data_out,
    input wire 					                  noc2_ready_in,
   
    input wire 					                  noc3_valid_in,
    input wire [`NOC_DATA_WIDTH-1:0] 		      noc3_data_in,
    output       				                  noc3_ready_out,

    output   					                  noc3_valid_out,
    output [`NOC_DATA_WIDTH-1:0]     		      noc3_data_out,
    input wire      			                  noc3_ready_in,

    input wire [`MSG_SRC_CHIPID_WIDTH-1:0]        src_chipid,
    input wire [`MSG_SRC_X_WIDTH-1:0]             src_xpos,
    input wire [`MSG_SRC_Y_WIDTH-1:0]             src_ypos,
    input wire [`MSG_SRC_FBITS_WIDTH-1:0]         src_fbits,

    input wire [`MSG_DST_CHIPID_WIDTH-1:0]        dest_chipid,
    input wire [`MSG_DST_X_WIDTH-1:0]             dest_xpos,
    input wire [`MSG_DST_Y_WIDTH-1:0]             dest_ypos,
    input wire [`MSG_DST_FBITS_WIDTH-1:0]         dest_fbits,

    // AXI Write Address Channel Signals
    input  wire  [`C_M_AXI_LITE_ADDR_WIDTH-1:0]   m_axi_awaddr,
    input  wire                                   m_axi_awvalid,
    output wire                                   m_axi_awready,

    // AXI Write Data Channel Signals
    input  wire  [`C_M_AXI_LITE_DATA_WIDTH-1:0]   m_axi_wdata,
    input  wire  [`C_M_AXI_LITE_DATA_WIDTH/8-1:0] m_axi_wstrb,
    input  wire                                   m_axi_wvalid,
    output wire                                   m_axi_wready,

    // AXI Read Address Channel Signals
    input  wire  [`C_M_AXI_LITE_ADDR_WIDTH-1:0]   m_axi_araddr,
    input  wire                                   m_axi_arvalid,
    output wire                                   m_axi_arready,

    // AXI Read Data Channel Signals
    output  reg [`C_M_AXI_LITE_DATA_WIDTH-1:0]    m_axi_rdata,
    output  reg [`C_M_AXI_LITE_RESP_WIDTH-1:0]    m_axi_rresp,
    output  reg                                   m_axi_rvalid,
    input  wire                                   m_axi_rready,

    // AXI Write Response Channel Signals
    output  reg [`C_M_AXI_LITE_RESP_WIDTH-1:0]    m_axi_bresp,
    output  reg                                   m_axi_bvalid,
    input  wire                                   m_axi_bready
);

// States for Incoming Piton Messages
`define MSG_STATE_INVALID    3'd0 // Invalid Message
`define MSG_STATE_HEADER_0   3'd1 // Header 0
`define MSG_STATE_HEADER_1   3'd2 // Header 1
`define MSG_STATE_HEADER_2   3'd3 // Header 2
`define MSG_STATE_DATA       3'd4 // Data Lines

`define MSG_TYPE_INVAL       2'd0 // Invalid Message
`define MSG_TYPE_LOAD        2'd1 // Load Request
`define MSG_TYPE_STORE       2'd2 // Store Request

/* flit fields */
reg [`C_M_AXI_LITE_ADDR_WIDTH-1:0]      address;

reg [`MSG_LENGTH_WIDTH-1:0]             msg_length;
reg [`MSG_TYPE_WIDTH-1:0]               msg_type;
reg [`MSG_MSHRID_WIDTH-1:0]             msg_mshrid;
reg [`MSG_OPTIONS_1]                    msg_options_1;
reg [`MSG_OPTIONS_2_]                   msg_options_2;
reg [`MSG_OPTIONS_3_]                   msg_options_3;
reg [`MSG_OPTIONS_4]                    msg_options_4;

reg [`MSG_LENGTH_WIDTH-1:0]             axi2noc_msg_counter;
wire                                    axi2noc_msg_type_store;
wire                                    axi2noc_msg_type_load;
wire [1:0]                              axi2noc_msg_type;
wire                                    axi_valid_ready;
reg [2:0]                               flit_state;
reg [2:0]                               flit_state_next;
reg                                     flit_ready;
reg [`NOC_DATA_WIDTH-1:0]               flit;
reg [`NOC_DATA_WIDTH-1:0]               noc_data;

wire                                    type_fifo_wval;
wire                                    type_fifo_full;
wire [1:0]                              type_fifo_wdata;
wire                                    type_fifo_empty;
wire [1:0]                              type_fifo_out;
reg                                     type_fifo_ren;

wire                                    awaddr_fifo_wval;
wire                                    awaddr_fifo_full;
wire [`C_M_AXI_LITE_ADDR_WIDTH-1:0]     awaddr_fifo_wdata;
wire                                    awaddr_fifo_empty;
wire [`C_M_AXI_LITE_ADDR_WIDTH-1:0]     awaddr_fifo_out;
reg                                     awaddr_fifo_ren;

wire                                    wdata_fifo_wval;
wire                                    wdata_fifo_full;
wire [`C_M_AXI_LITE_ADDR_WIDTH-1:0]     wdata_fifo_wdata;
wire                                    wdata_fifo_empty;
wire [`C_M_AXI_LITE_ADDR_WIDTH-1:0]     wdata_fifo_out;
reg                                     wdata_fifo_ren;

wire                                    araddr_fifo_wval;
wire                                    araddr_fifo_full;
wire [`C_M_AXI_LITE_ADDR_WIDTH-1:0]     araddr_fifo_wdata;
wire                                    araddr_fifo_empty;
wire [`C_M_AXI_LITE_ADDR_WIDTH-1:0]     araddr_fifo_out;
reg                                     araddr_fifo_ren;


/* Dump store addr and data to file. */
integer file;
initial begin
    file = $fopen("axilite_noc.log", "w");
end

always @(posedge clk)
begin
    if (awaddr_fifo_ren)
    begin
        $fwrite(file, "awaddr-fifo %064x\n", awaddr_fifo_out);
        $fflush(file);
    end
    if (wdata_fifo_ren)
    begin
        $fwrite(file, "wdata-fifo %064x\n", wdata_fifo_out);
        $fflush(file);
    end
    if (araddr_fifo_ren)
    begin
        $fwrite(file, "araddr-fifo %064x\n", araddr_fifo_out);
        $fflush(file);
    end
    /*if (noc2_valid_out && noc2_ready_in) begin
        $fwrite(file, "bridge-write-data %064x\n", noc2_data_out);
        $fflush(file);
    end */
end

/******** Where the magic happens ********/
assign write_channel_ready = !awaddr_fifo_full && !wdata_fifo_full;
assign m_axi_awready = write_channel_ready;
assign m_axi_wready = write_channel_ready;
assign m_axi_arready = !araddr_fifo_full;

assign axi2noc_msg_type_store = m_axi_awvalid && m_axi_wvalid;
assign axi2noc_msg_type_load = m_axi_arvalid;
assign axi2noc_msg_type = (axi2noc_msg_type_store) ? `MSG_TYPE_STORE :
                            (axi2noc_msg_type_load) ? `MSG_TYPE_LOAD :
                                                        `MSG_TYPE_INVAL;

/* fifo for storing packet type */
sync_fifo #(
	.DSIZE(2),
	.ASIZE(5),
	.MEMSIZE(16) // should be 2 ^ (ASIZE-1)
) type_fifo (
	.rdata(type_fifo_out),
	.empty(type_fifo_empty),
	.clk(clk),
	.ren(type_fifo_ren),
	.wdata(type_fifo_wdata),
	.full(type_fifo_full),
	.wval(type_fifo_wval),
	.reset(rst)
);

assign type_fifo_wval = (axi2noc_msg_type_store ||axi2noc_msg_type_load) && !type_fifo_full;
assign type_fifo_wdata = (axi2noc_msg_type_store) ? `MSG_TYPE_STORE :
                            (axi2noc_msg_type_load) ? `MSG_TYPE_LOAD : `MSG_TYPE_INVAL;
assign type_fifo_ren = (flit_state_next == `MSG_STATE_INVALID) && !type_fifo_empty;


/* fifo for storing addresses */
sync_fifo #(
	.DSIZE(`C_M_AXI_LITE_ADDR_WIDTH),
	.ASIZE(5),
	.MEMSIZE(16) // should be 2 ^ (ASIZE-1)
) awaddr_fifo (
	.rdata(awaddr_fifo_out),
	.empty(awaddr_fifo_empty),
	.clk(clk),
	.ren(awaddr_fifo_ren),
	.wdata(awaddr_fifo_wdata),
	.full(awaddr_fifo_full),
	.wval(awaddr_fifo_wval),
	.reset(rst)
);

assign awaddr_fifo_wval = m_axi_awvalid && write_channel_ready;// && noc2_ready_in;
assign awaddr_fifo_wdata = m_axi_awaddr;
assign awaddr_fifo_ren = (flit_state == `MSG_STATE_HEADER_0 && !awaddr_fifo_empty);


/* fifo for wdata */
sync_fifo #(
	.DSIZE(`NOC_DATA_WIDTH),
	.ASIZE(5),
	.MEMSIZE(16) // should be 2 ^ (ASIZE-1)    
) waddr_fifo (
	.rdata(wdata_fifo_out),
	.empty(wdata_fifo_empty),
	.clk(clk),
	.ren(wdata_fifo_ren),
	.wdata(wdata_fifo_wdata),
	.full(wdata_fifo_full),
	.wval(wdata_fifo_wval),
	.reset(rst)
);

assign wdata_fifo_wval = m_axi_wvalid && write_channel_ready;// && noc2_ready_in;
assign wdata_fifo_wdata = m_axi_wdata;
assign wdata_fifo_ren = (flit_state == `MSG_STATE_HEADER_2 && !wdata_fifo_empty);


/* fifo for read addr */
sync_fifo #(
	.DSIZE(`C_M_AXI_LITE_ADDR_WIDTH),
	.ASIZE(5),
	.MEMSIZE(16) // should be 2 ^ (ASIZE-1)    
) raddr_fifo (
	.rdata(araddr_fifo_out),
	.empty(araddr_fifo_empty),
	.clk(clk),
	.ren(araddr_fifo_ren),
	.wdata(araddr_fifo_wdata),
	.full(araddr_fifo_full),
	.wval(araddr_fifo_wval),
	.reset(rst)
);

assign araddr_fifo_wval = m_axi_arvalid && noc2_ready_in && ~araddr_fifo_full;
assign araddr_fifo_wdata = m_axi_araddr;
assign araddr_fifo_ren = (flit_state == `MSG_STATE_HEADER_0 && !araddr_fifo_empty);


/* start the state machine when fifo is not empty and noc is ready 
* We need to toggle between address and data fifos.
*/
wire                                    fifo_has_packet;

assign fifo_has_packet = (type_fifo_out == `MSG_TYPE_STORE) ? (!awaddr_fifo_empty && !wdata_fifo_empty) :
                        (type_fifo_out == `MSG_TYPE_LOAD) ? !araddr_fifo_empty : 1'b0;

/* This just ensures that even if fifo_has_packet is true and 
flit_state_next is processing a header-state, it doesn't reset to
MSG_STATE_HEADER_0. One reason to have this is because the FIFOs are FWFT*/                        
assign is_prev_processing = (flit_state == `MSG_STATE_HEADER_0) ||
                            (flit_state == `MSG_STATE_HEADER_1) ||
                            (flit_state == `MSG_STATE_HEADER_2);

always @(*)
begin
    if (noc2_ready_in) begin
        case (type_fifo_out)
            `MSG_TYPE_STORE: begin
                flit_state_next = (flit_state == `MSG_STATE_HEADER_0) ? `MSG_STATE_HEADER_1 :
                                (flit_state == `MSG_STATE_HEADER_1) ? `MSG_STATE_HEADER_2 :
                                (flit_state == `MSG_STATE_HEADER_2) ? `MSG_STATE_DATA :
                                (flit_state == `MSG_STATE_DATA) ? `MSG_STATE_INVALID :
                                (fifo_has_packet && flit_state == `MSG_STATE_INVALID) ?
                                         `MSG_STATE_HEADER_0 : `MSG_STATE_INVALID;
            end

            `MSG_TYPE_LOAD: begin
                flit_state_next = (flit_state == `MSG_STATE_HEADER_0) ? `MSG_STATE_HEADER_1 :
                                (flit_state == `MSG_STATE_HEADER_1) ? `MSG_STATE_HEADER_2 :
                                (flit_state == `MSG_STATE_DATA) ? `MSG_STATE_INVALID :
                                (fifo_has_packet && flit_state == `MSG_STATE_INVALID) ?
                                         `MSG_STATE_HEADER_0 : `MSG_STATE_INVALID;
            end

            default: begin
                flit_state_next = `MSG_STATE_INVALID;
            end

        endcase
    end
end

always @(posedge clk)
begin
    if (rst) begin
        flit_state <= `MSG_STATE_INVALID;
    end
    else begin
//        if (flit_state != flit_state_next) begin
//            $display("axilite_noc_bridge: flit_state == %x", flit_state);
//        end
        flit_state <= flit_state_next;
    end
end

/* set defaults for the flit */
always @(*)
begin
    case (type_fifo_out)
        `MSG_TYPE_STORE: begin
            msg_type = `MSG_TYPE_NC_STORE_REQ; // axilite peripheral is writing to the memory?
            msg_length = 2'd3; // 2 extra headers + 1 data
        end

        `MSG_TYPE_LOAD: begin
            msg_type = `MSG_TYPE_NC_LOAD_REQ; // axilite peripheral is reading from the memory?
            msg_length = 2'd2; // only 2 extra headers
        end
        
        default: begin
            msg_length = 2'b0;
        end
    endcase
end

always @(*)
begin
    flit[`NOC_DATA_WIDTH-1:0] = {`NOC_DATA_WIDTH{1'b0}};
    msg_mshrid = {`MSG_MSHRID_WIDTH{1'b0}};
    msg_options_1 = {`MSG_OPTIONS_1_WIDTH{1'b0}};
    msg_options_2 = 16'b0;
    msg_options_3 = 30'b0;
    case (flit_state)
        `MSG_STATE_HEADER_0: begin
            flit[`MSG_DST_CHIPID] = dest_chipid;
            flit[`MSG_DST_X] = dest_xpos;
            flit[`MSG_DST_Y] = dest_ypos;
            flit[`MSG_DST_FBITS] = dest_fbits; // towards memory?
            flit[`MSG_LENGTH] = msg_length;
            flit[`MSG_TYPE] = msg_type;
            flit[`MSG_MSHRID] = msg_mshrid;
            flit[`MSG_OPTIONS_1] = msg_options_1;
            flit_ready = 1'b1;

            //flit[`NOC_DATA_WIDTH-1:0] = 64'habcdabcdabcdabcd;
        end

        `MSG_STATE_HEADER_1: begin
            flit[`MSG_ADDR_] = {{`MSG_ADDR_WIDTH-`PHY_ADDR_WIDTH{1'b0}}, awaddr_fifo_out[`PHY_ADDR_WIDTH-1:0]};
            flit[`MSG_OPTIONS_2_] = msg_options_2;
            flit[`MSG_DATA_SIZE_] = `MSG_DATA_SIZE_1B;
            flit_ready = 1'b1;
        end

        `MSG_STATE_HEADER_2: begin
            flit[`MSG_SRC_CHIPID_] = src_chipid;
            flit[`MSG_SRC_X_] = src_xpos;
            flit[`MSG_SRC_Y_] = src_ypos;
            flit[`MSG_SRC_FBITS_] = src_fbits;
            flit[`MSG_OPTIONS_3_] = msg_options_3;
            flit_ready = 1'b1;
        end

        `MSG_STATE_DATA: begin
            flit[`NOC_DATA_WIDTH-1:0] = wdata_fifo_out;
            flit_ready = 1'b1;
        end

        default: begin
            flit[`NOC_DATA_WIDTH-1:0] = {`NOC_DATA_WIDTH{1'b0}};
            flit_ready = 1'b0;
        end
    endcase
end

assign noc2_valid_out = flit_ready;
assign noc2_data_out = flit;

endmodule
