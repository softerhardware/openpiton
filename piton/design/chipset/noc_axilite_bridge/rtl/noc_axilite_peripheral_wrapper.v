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

assign reset = ~rst_n;

axilite_master_test axilite_master (
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

axilite_noc_bridge axilite_noc_bridge (
    .clk                    (clk),
    .rst                    (reset),

    /*.noc2_valid_in          (noc2_valid_in),
    .noc2_data_in           (noc2_data_in),
    .noc2_ready_out         (noc2_ready_out),*/

    .noc2_valid_out         (noc2_valid_out),
    .noc2_data_out          (noc2_data_out),
    .noc2_ready_in          (noc2_ready_in),

    .noc3_valid_in          (noc3_valid_in),
    .noc3_data_in           (noc3_data_in),
    .noc3_ready_out         (noc3_ready_out),

    /*.noc3_valid_out         (noc3_valid_out),
    .noc3_data_out          (noc3_data_out),
    .noc3_ready_in          (noc3_ready_in),*/

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