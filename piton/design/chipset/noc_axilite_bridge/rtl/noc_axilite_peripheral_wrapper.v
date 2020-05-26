`include "define.tmp.h"

module noc_axilite_peripheral_wrapper(
    input wire                                    clk,
    input wire                                    rst_n,

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
    input wire      			                  noc3_ready_in 
);

wire                                         reset;
wire [`C_M_AXI_LITE_ADDR_WIDTH-1:0]          axi_awaddr;
wire                                         axi_awvalid;
wire                                         axi_awready;
wire [`NOC_DATA_WIDTH-1:0]                   axi_wdata;
wire                                         axi_wvalid;
wire                                         axi_wready;
wire [`C_M_AXI_LITE_ADDR_WIDTH-1:0]          axi_araddr;
wire                                         axi_arvalid;
wire                                         axi_arready;

wire [`MSG_SRC_CHIPID_WIDTH-1:0]             src_chipid;
wire [`MSG_SRC_X_WIDTH-1:0]                  src_xpos;
wire [`MSG_SRC_Y_WIDTH-1:0]                  src_ypos;
wire [`MSG_SRC_FBITS_WIDTH-1:0]              src_fbits;

wire [`MSG_DST_CHIPID_WIDTH-1:0]             dest_chipid;
wire [`MSG_DST_X_WIDTH-1:0]                  dest_xpos;
wire [`MSG_DST_Y_WIDTH-1:0]                  dest_ypos;
wire [`MSG_DST_FBITS_WIDTH-1:0]              dest_fbits;

assign reset = ~rst_n;

axilite_master_test #(
    .AXILITE_ADDR_WIDTH(`C_M_AXI_LITE_ADDR_WIDTH),
    .AXILITE_DATA_WIDTH(`NOC_DATA_WIDTH)
) axilite_master (
    .clk(clk),
    .rst(reset),
    .m_axi_awaddr(axi_awaddr),
    .m_axi_awvalid(axi_awvalid),
    .m_axi_awready(axi_awready),
    .m_axi_wdata(axi_wdata),
    .m_axi_wvalid(axi_wvalid),
    .m_axi_wready(axi_wready),
    .m_axi_araddr(axi_araddr),
    .m_axi_arvalid(axi_arvalid),
    .m_axi_arready(axi_arready)
);


assign dest_chipid = {14{1'b1}};
assign dest_xpos = {8{1'b0}};
assign dest_ypos = {8{1'b0}};
assign dest_fbits = `NOC_FBITS_MEM; // {`FINAL_BITS{1'b1}};
assign src_chipid = {14{1'b1}};
assign src_xpos = {8{1'b0}};
assign src_ypos = {8{1'b0}};
assign src_fbits = {`FINAL_BITS{1'b1}}; //`NOC_FBITS_L2; // don't think it matters here, right?

axilite_noc_bridge axilite_noc_bridge (
    .clk                    (clk),
    .rst                    (reset),

    .noc2_valid_in          (noc2_valid_in),
    .noc2_data_in           (noc2_data_in),
    .noc2_ready_out         (noc2_ready_out),

    .noc2_valid_out         (noc2_valid_out),
    .noc2_data_out          (noc2_data_out),
    .noc2_ready_in          (noc2_ready_in),

    .noc3_valid_in          (noc3_valid_in),
    .noc3_data_in           (noc3_data_in),
    .noc3_ready_out         (noc3_ready_out),

    .noc3_valid_out         (noc3_valid_out),
    .noc3_data_out          (noc3_data_out),
    .noc3_ready_in          (noc3_ready_in),

    .src_chipid             (src_chipid),
    .src_xpos               (src_xpos),
    .src_ypos               (src_ypos),
    .src_fbits              (src_fbits),

    .dest_chipid            (dest_chipid),
    .dest_xpos              (dest_xpos),
    .dest_ypos              (dest_ypos),
    .dest_fbits             (dest_fbits),

    //axi lite signals
    //write address channel
    .m_axi_awaddr           (axi_awaddr),
    .m_axi_awvalid          (axi_awvalid),
    .m_axi_awready          (axi_awready),

    //write data channel
    .m_axi_wdata            (axi_wdata),
    .m_axi_wstrb            (),
    .m_axi_wvalid           (axi_wvalid),
    .m_axi_wready           (axi_wready),

    //read address channel
    .m_axi_araddr           (0),
    .m_axi_arvalid          (0),
    .m_axi_arready          (),

    //read data channel
    .m_axi_rdata            (),
    .m_axi_rresp            (),
    .m_axi_rvalid           (),
    .m_axi_rready           (0),

    //write response channel
    .m_axi_bresp            (),
    .m_axi_bvalid           (),
    .m_axi_bready           (0)
);

endmodule