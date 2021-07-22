/*
Copyright (c) 2019 Princeton University
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
#include "Vmetro_chipset.h"
#include "verilated.h"
#include <iostream>
#define VERILATOR_VCD 1
#ifdef VERILATOR_VCD
#include "verilated_vcd_c.h"
#endif
#include <iomanip>

const int YUMMY_NOC_1 = 0;
const int DATA_NOC_1  = 1;
const int YUMMY_NOC_2 = 2;
const int DATA_NOC_2  = 3;
const int YUMMY_NOC_3 = 4;
const int DATA_NOC_3  = 5;

uint64_t main_time = 0; // Current simulation time
uint64_t clk = 0;
Vmetro_chipset* top;
int rank, dest, size;

void initialize();

// MPI Yummy functions
unsigned short mpi_receive_yummy(int origin, int flag);

void mpi_send_yummy(unsigned short message, int dest, int rank, int flag);
// MPI data&Valid functions
void mpi_send_data(unsigned long long data, unsigned char valid, int dest, int rank, int flag);

unsigned long long mpi_receive_data(int origin, unsigned short* valid, int flag);
int getRank();

int getSize();

void finalize();

#ifdef VERILATOR_VCD
VerilatedVcdC* tfp;
#endif
// This is a 64-bit integer to reduce wrap over issues and
// // allow modulus. You can also use a double, if you wish.
double sc_time_stamp () { // Called by $time in Verilog
return main_time; // converts to double, to match
// what SystemC does
}

void tick() {
    top->core_ref_clk = !top->core_ref_clk;
    main_time += 250;
    top->eval();
#ifdef VERILATOR_VCD
    tfp->dump(main_time);
#endif
    top->core_ref_clk = !top->core_ref_clk;
    main_time += 250;
    top->eval();
#ifdef VERILATOR_VCD
    tfp->dump(main_time);
#endif
}

void mpi_work_chipset() {
    std::cout.precision(10); 
    if (top->offchip_processor_noc1_valid | top->offchip_processor_noc2_valid | top->offchip_processor_noc3_valid) {
        std::cout << "Cycle " << std::setw(10) <<  sc_time_stamp() << std::endl;
    }
    // send data
    mpi_send_data(top->offchip_processor_noc1_data, top->offchip_processor_noc1_valid, dest, rank, DATA_NOC_1);
    // send yummy
    mpi_send_yummy(top->processor_offchip_noc1_yummy, dest, rank, YUMMY_NOC_1);

    // send data
    mpi_send_data(top->offchip_processor_noc2_data, top->offchip_processor_noc2_valid, dest, rank, DATA_NOC_2);
    // send yummy
    mpi_send_yummy(top->processor_offchip_noc2_yummy, dest, rank, YUMMY_NOC_2);

    // send data
    mpi_send_data(top->offchip_processor_noc3_data, top->offchip_processor_noc3_valid, dest, rank, DATA_NOC_3);
    // send yummy
    mpi_send_yummy(top->processor_offchip_noc3_yummy, dest, rank, YUMMY_NOC_3);

    // receive data
    unsigned short valid_aux;
    top->processor_offchip_noc1_data = mpi_receive_data(dest, &valid_aux, DATA_NOC_1);
    top->processor_offchip_noc1_valid = valid_aux;
    // receive yummy
    top->offchip_processor_noc1_yummy = mpi_receive_yummy(dest, YUMMY_NOC_1);

    top->processor_offchip_noc2_data = mpi_receive_data(dest, &valid_aux, DATA_NOC_2);
    top->processor_offchip_noc2_valid = valid_aux;
    // receive yummy
    top->offchip_processor_noc2_yummy = mpi_receive_yummy(dest, YUMMY_NOC_2);

    top->processor_offchip_noc3_data = mpi_receive_data(dest, &valid_aux, DATA_NOC_3);
    top->processor_offchip_noc3_valid = valid_aux;
    // receive yummy
    top->offchip_processor_noc3_yummy = mpi_receive_yummy(dest, YUMMY_NOC_3);
}


void mpi_tick() {
    top->core_ref_clk = !top->core_ref_clk;
    main_time += 250;
    top->eval();
    mpi_work_chipset();
    // Do MPI
    top->eval();
#ifdef VERILATOR_VCD
    tfp->dump(main_time);
#endif
    top->core_ref_clk = !top->core_ref_clk;
    main_time += 250;
    top->eval();
#ifdef VERILATOR_VCD
    tfp->dump(main_time);
#endif
}



void reset_and_init() {
    
//    fail_flag = 1'b0;
//    stub_done = 4'b0;
//    stub_pass = 4'b0;

//    // Clocks initial value
    top->core_ref_clk = 0;

//    // Resets are held low at start of boot
    top->sys_rst_n = 0;
    top->pll_rst_n = 0;

    top->ok_iob = 0;

//    // Mostly DC signals set at start of boot
//    clk_en = 1'b0;
    top->pll_bypass = 1; // trin: pll_bypass is a switch in the pll; not reliable
    top->clk_mux_sel = 0; // selecting ref clock
//    // rangeA = x10 ? 5'b1 : x5 ? 5'b11110 : x2 ? 5'b10100 : x1 ? 5'b10010 : x20 ? 5'b0 : 5'b1;
    top->pll_rangea = 1; // 10x ref clock
//    // pll_rangea = 5'b11110; // 5x ref clock
//    // pll_rangea = 5'b00000; // 20x ref clock
    
//    // JTAG simulation currently not supported here
//    jtag_modesel = 1'b1;
//    jtag_datain = 1'b0;

    top->async_mux = 0;

    top->processor_offchip_noc1_valid = 0;
    top->processor_offchip_noc1_data  = 0;
    top->offchip_processor_noc1_yummy = 0;
    top->processor_offchip_noc2_valid = 0;
    top->processor_offchip_noc2_data  = 0;
    top->offchip_processor_noc2_yummy = 0;
    top->processor_offchip_noc3_valid = 0;
    top->processor_offchip_noc3_data  = 0;
    top->offchip_processor_noc3_yummy = 0;

    //init_jbus_model_call((char *) "mem.image", 0);

    std::cout << "Before first ticks" << std::endl << std::flush;
    tick();
    std::cout << "After very first tick" << std::endl << std::flush;
//    // Reset PLL for 100 cycles
//    repeat(100)@(posedge core_ref_clk);
//    pll_rst_n = 1'b1;
    for (int i = 0; i < 100; i++) {
        tick();
    }
    top->pll_rst_n = 1;

    std::cout << "Before second ticks" << std::endl << std::flush;
    std::cout << "Before third ticks" << std::endl << std::flush;
//    // After 10 cycles turn on chip-level clock enable
//    repeat(10)@(posedge `CHIP_INT_CLK);
//    clk_en = 1'b1;
    for (int i = 0; i < 10; i++) {
        tick();
    }
    top->clk_en = 1;

//    // After 100 cycles release reset
//    repeat(100)@(posedge `CHIP_INT_CLK);
//    sys_rst_n = 1'b1;
//    jtag_rst_l = 1'b1;
    for (int i = 0; i < 100; i++) {
        tick();
    }
    top->sys_rst_n = 1;

//    // Wait for SRAM init, trin: 5000 cycles is about the lowest
//    repeat(5000)@(posedge `CHIP_INT_CLK);
    for (int i = 0; i < 5000; i++) {
        tick();
    }

//    top->diag_done = 1;

    //top->ciop_fake_iob.ok_iob = 1;
    top->ok_iob = 1;
    std::cout << "Reset complete" << std::endl << std::flush;
}

int main(int argc, char **argv, char **env) {
    std::cout << "Started" << std::endl << std::flush;
    Verilated::commandArgs(argc, argv);
    top = new Vmetro_chipset;
    std::cout << "Vmetro_chipset created" << std::endl << std::flush;

#ifdef VERILATOR_VCD
    Verilated::traceEverOn(true);
    tfp = new VerilatedVcdC;
    top->trace (tfp, 99);
    tfp->open ("my_metro_chipset.vcd");

    Verilated::debug(1);
#endif

    // MPI work 
    initialize();
    rank = getRank();
    size = getSize();
    std::cout << "CHIPSET size: " << size << ", rank: " << rank <<  std::endl;
    if (rank==0) {
        dest = 1;
    } else {
        dest = 0;
    }

    reset_and_init();

    for (int i = 0; i < 100000; i++) {
        mpi_tick();
    }
    /*while (!Verilated::gotFinish()) { 
        mpi_tick();
    }*/

    #ifdef VERILATOR_VCD
    std::cout << "Trace done" << std::endl;
    tfp->close();
    #endif

    finalize();

    delete top;
    exit(0);
}
