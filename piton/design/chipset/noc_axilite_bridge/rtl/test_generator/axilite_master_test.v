/* This uses the Mealy State Machine. There is another implementation
for Moore State Machine as well. */

`include "define.tmp.h"

module axilite_master_test #(
    parameter AXILITE_ADDR_WIDTH = 64,
    parameter AXILITE_DATA_WIDTH = 64
) (
    input                                   clk,
    input                                   rst,

    output reg [AXILITE_ADDR_WIDTH-1:0]         m_axi_awaddr,
    output reg                                  m_axi_awvalid,
    input                                   m_axi_awready,
    output reg [AXILITE_DATA_WIDTH-1:0]         m_axi_wdata,
    output reg                                  m_axi_wvalid,
    input                                   m_axi_wready,

	/* verilator lint_off UNDRIVEN */
    output [AXILITE_ADDR_WIDTH-1:0]         m_axi_araddr,     
	/* verilator lint_off UNDRIVEN */
	output                                  m_axi_arvalid,
	/* verilator lint_off UNUSED */
    input                                   m_axi_arready 
);

localparam HOLD_WRITE = 1'b0;
localparam GEN_WRITE = 1'd1;
localparam WIDTH_CONSTANT = 48;

reg      	                                gen_write_f;
reg 	                                    gen_write_next;
reg											addr_valid;
reg											data_valid;
reg [AXILITE_ADDR_WIDTH-1:0]                addr_counter;
reg [AXILITE_DATA_WIDTH-1:0]                data_counter;
reg [3:0]									interval_counter;

wire										write_ready;

integer file;
initial begin
    file = $fopen("axilite_master_test.log", "w");
end

always @(posedge clk)
begin
    if (m_axi_awvalid)
    begin
        $fwrite(file, "awaddr-fifo %064x\n", m_axi_awaddr);
        $fflush(file);
    end 
    if (m_axi_wvalid)
    begin
        $fwrite(file, "wdata-fifo %064x\n", m_axi_wdata);
        $fflush(file);
    end
end

always @(posedge clk)
begin
    if (rst) begin
        gen_write_f <= HOLD_WRITE;
    end
    else begin
        gen_write_f <= gen_write_next;
    end
end

assign write_ready = m_axi_awready && m_axi_wready;

/* take two cases - backpressure and no backpressure*/
always @(*)
begin
	gen_write_next = gen_write_f;
	addr_valid = m_axi_awvalid;
	data_valid = m_axi_wvalid;
	addr_counter = m_axi_awaddr;
	data_counter = m_axi_wdata;

	case (gen_write_f)
		HOLD_WRITE: begin
			addr_valid = 1'b1;
			data_valid = 1'b1;
			if (write_ready) begin
				gen_write_next = GEN_WRITE;
				addr_counter = m_axi_awaddr + 1'b1;
				data_counter = m_axi_wdata + 1'b1;
			end
		end

		GEN_WRITE: begin
			if (!write_ready) begin
				gen_write_next = HOLD_WRITE;
			end
			else begin
				addr_counter = m_axi_awaddr + 1'b1;
				data_counter = m_axi_wdata + 1'b1;	
			end
		end
	endcase
end

always @(posedge clk)
begin
    if (rst) begin
        m_axi_awvalid <= 1'b0;
        m_axi_wvalid <= 1'b0;
        m_axi_awaddr <= 64'h40000000; // let it start with some random addr in mem-range {AXILITE_ADDR_WIDTH{1'b0}};
        m_axi_wdata <= {AXILITE_DATA_WIDTH{1'b0}};
    end
    else begin
        m_axi_awvalid <= addr_valid;
        m_axi_wvalid <= data_valid;
        m_axi_awaddr <= addr_counter;
        m_axi_wdata <= data_counter;
    end
end

endmodule

