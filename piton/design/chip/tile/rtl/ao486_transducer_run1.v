/*
Copyright (c) 2018 Princeton University
All rights reserved.
Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Princeton University nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.
THIS SOFTWARE IS PROVIDED BY PRINCETON UNIVERSITY "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL PRINCETON UNIVERSITY BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

module ao486_transducer_run1(
    input clk,
    input rst_n,

    //Outputs dealing with L.15 and transducer (transducer -> L1.5)

    output [4:0]   transducer_l15_rqtype,
    output [39:0]  transducer_l15_address,
    output [63:0]  transducer_l15_data,
    output [63:0]  transducer_l15_data_next_entry,
    output         transducer_l15_req_ack,
    output         transducer_l15_val,
    output [2:0]   transducer_l15_size,
    output [3:0]   transducer_l15_amo_op,
    output         transducer_l15_nc,
    output [1:0]   transducer_l15_l1rplway,
        
    //Inputs dealing with L1.5 and transducer (L1.5 -> transducer)

    input          l15_transducer_ack,
    input          l15_transducer_noncacheable,
    input          l15_transducer_atomic,
    input [63:0]   l15_transducer_data_0,
    input [63:0]   l15_transducer_data_1,
    input [63:0]   l15_transducer_data_2,
    input [63:0]   l15_transducer_data_3,
    input          l15_transducer_header_ack,        
    input [3:0]    l15_transducer_returntype,
    input          l15_transducer_val,

    //Inputs dealing with transducer and core (core -> transducer)

    input          request_readcode_do,
    input [31:0]   request_readcode_address,
    input          request_readline_do,
    input [31:0]   request_readline_address,
    input          request_readburst_do,
    input [31:0]   request_readburst_address,

    //Outpts from transducer to core

    //output [31:0]  transducer_ao486_readcode_partial,
    output [127:0] transducer_ao486_readcode_line,
    output         transducer_ao486_request_readcode_done,
    output         ao486_int
);

//Tying off all outputs not being generated
    //assign transducer_l15_rqtype = 5'd0;
    //assign transducer_l15_address = 40'd0;
    assign transducer_l15_data = 64'd0;
    assign transducer_l15_data_next_entry = 64'd0;
    //assign transducer_l15_req_ack = 0;
    //assign transducer_l15_val = 0;
    assign transducer_l15_size = 3'd0;
    assign transducer_l15_amo_op = 4'd0;
    assign transducer_l15_nc = 0;
    assign transducer_l15_l1rplway = 2'd0;
//..........................................................................

//Parameters and reg variables
localparam IDLE  = 3'b000;
localparam NEW   = 3'b001;
localparam BUSY  = 3'b010;
localparam WRITE = 3'b100;
localparam READ  = 3'b011;
localparam IFILL = 3'b101;

reg [2:0] state;                            //Current state of processor <-> OP interface
reg [2:0] next_state;                       //Next state of processor <-> OP interface
reg [2:0] req_type;                         //Meant for READ/WRITE requests 
reg [31:0] addr_reg;                        //Reg to store address received from ao486 (request_readcode_address)
reg flop_bus;
reg int_recv;
reg ao486_int_reg;
reg [31:0] transducer_l15_address_reg_ifill;
reg [4:0] transducer_l15_rqtype_reg;
reg transducer_l15_val_reg;
reg transducer_l15_req_ack_reg;
reg [3:0] returntype_reg;
reg request_readcode_done_reg;
reg [31:0] ifill_return_partial_0;
reg [31:0] ifill_return_partial_1;
reg [31:0] ifill_return_partial_2;
reg [31:0] ifill_return_partial_3;
reg [31:0] readcode_partial_reg;
//..........................................................................

//Assign statements
assign ao486_int = ao486_int_reg;
assign transducer_l15_val = (int_recv) ? 1'b0 : transducer_l15_val_reg;
assign transducer_l15_address = (int_recv) ? 1'b0 : {{8{transducer_l15_address_reg_ifill[31]}}, transducer_l15_address_reg_ifill};
assign transducer_l15_rqtype = (int_recv) ? 1'b0 : transducer_l15_rqtype_reg;
assign transducer_l15_req_ack = transducer_l15_req_ack_reg;
assign transducer_a0486_request_readcode_done = request_readcode_done_reg;
//assign transducer_ao486_readcode_partial = readcode_partial_reg;
assign transducer_ao486_readcode_line = {ifill_return_partial_0, ifill_return_partial_1, ifill_return_partial_2, ifill_return_partial_3};
//..........................................................................

//Always block to obtain request type from core and set flop_bus
always @(posedge clk) begin
    if(request_readcode_do) begin
        flop_bus = 1'b1;
        req_type = IFILL;
    end
    else begin
        flop_bus = 1'b0;
        req_type = 1'b0;
    end
end
//..........................................................................

//Always block to convert big endian to little endian for ifill
always @(posedge clk) begin
    if(l15_transducer_returntype == `IFILL_RET & l15_transducer_val == 1'b1) begin
        returntype_reg <= `IFILL_RET;
        ifill_return_partial_0 <= {l15_transducer_data_2[39:32], l15_transducer_data_2[47:40], l15_transducer_data_2[55:48], l15_transducer_data_2[63:56]};
        ifill_return_partial_1 <= {l15_transducer_data_2[7:0], l15_transducer_data_2[15:8], l15_transducer_data_2[23:16], l15_transducer_data_2[31:24]};
        ifill_return_partial_2 <= {l15_transducer_data_3[39:32], l15_transducer_data_3[47:40], l15_transducer_data_3[55:48], l15_transducer_data_3[63:56]};
        ifill_return_partial_3 <= {l15_transducer_data_3[7:0], l15_transducer_data_3[15:8], l15_transducer_data_3[23:16], l15_transducer_data_3[31:24]};
        request_readcode_done_reg <= 1'b1;
    end
    else begin
        request_readcode_done_reg <= 1'b0;
        returntype_reg <= 1'b0;
    end
end
//..........................................................................

//Always block to set readcode_partial and readcode_line for ifill return to core
/*always @(posedge clk) begin
    if(returntype_reg == `IFILL_RET) begin
        
end*/
//..........................................................................

//Always block setting transducer_l15_req_ack high indicating response received
always @(posedge clk) begin
    if(l15_transducer_val) begin
        transducer_l15_req_ack_reg = 1'b1;
    end
    else begin
        transducer_l15_req_ack_reg = 1'b0;
    end
end
//..........................................................................

//Always block to set transducer_l15_val_reg to 0 based on l15_transducer_header_ack
/*always @(posedge clk) begin
    if(l15_transducer_header_ack == 1'b1) begin
        transducer_l15_val_reg <= 1'b0;
    end
    else begin
        transducer_l15_val_reg <= transducer_l15_val_reg;
    end
end*/
//..........................................................................

//Always block to send ifill request type to L1.5
always @(posedge clk) begin
    if(req_type == IFILL) begin
        transducer_l15_rqtype_reg <= `IMISS_RQ;
    end
    else begin
        transducer_l15_rqtype_reg <= 5'd0;
    end
end    
//..........................................................................

//Always block to set transducer_l15_val and address to be sent to L1.5 for instructions
always @(posedge clk) begin
    if(transducer_l15_rqtype_reg == `IMISS_RQ & ~l15_transducer_header_ack) begin
        transducer_l15_val_reg <= 1'b1;
        transducer_l15_address_reg_ifill <= addr_reg;
    end
    else if(l15_transducer_header_ack) begin
        transducer_l15_val_reg <= 1'b0;
    end
    else begin
        transducer_l15_val_reg <= 1'b0;
        transducer_l15_address_reg_ifill <= 1'b0;
    end
end
//..........................................................................

//Always block to flop address received from core 
always @(posedge clk) begin
  if (~rst_n) begin
    addr_reg <= 32'b0;
  end 
  else if (flop_bus) begin
    addr_reg <= request_readcode_address;
  end
end
//..........................................................................

//Always block to release reset into ao486 core
always @ (posedge clk) begin
    if (~rst_n) begin
        ao486_int_reg <= 1'b0;
    end
    else if (int_recv) begin
        ao486_int_reg <= 1'b1;
    end
    else if (ao486_int_reg) begin
        ao486_int_reg <= 1'b0;
    end
end
//..........................................................................

//Always block to obtain interrupt from interrupt controller
always @ * begin
   if (l15_transducer_val) begin
      case(l15_transducer_returntype)
        `LOAD_RET:                        //load response
          begin
             int_recv = 1'b0;
          end
        `ST_ACK:                          //store acknowledge
          begin
             int_recv = 1'b0;
          end
        `INT_RET:                         //interrupt return
          begin
             if (l15_transducer_data_0[17:16] == 2'b01) begin
                int_recv = 1'b1;
             end
             else begin
                int_recv = 1'b0;
             end
          end
        default: begin
           int_recv = 1'b0;
        end
      endcase 
   end
   else begin
       int_recv = 1'b0;
   end
end
//..........................................................................

//always block to initiate interface based on reset condition 
/*
always @ (rst_n) begin
    if(~rst_n)    begin
        state <= IDLE;
        req_type <= 3'b000;
    end
    else    begin
        state <= next_state;
        req_type <= next_req_type;
    end 
end
*/
//............................................................................

endmodule