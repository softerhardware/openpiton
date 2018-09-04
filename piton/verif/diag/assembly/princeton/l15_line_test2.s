/*
* Copyright (c) 2016 Princeton University
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without
* modification, are permitted provided that the following conditions are met:
*     * Redistributions of source code must retain the above copyright
*       notice, this list of conditions and the following disclaimer.
*     * Redistributions in binary form must reproduce the above copyright
*       notice, this list of conditions and the following disclaimer in the
*       documentation and/or other materials provided with the distribution.
*     * Neither the name of Princeton University nor the
*       names of its contributors may be used to endorse or promote products
*       derived from this software without specific prior written permission.
* 
* THIS SOFTWARE IS PROVIDED BY PRINCETON UNIVERSITY "AS IS" AND
* ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
* DISCLAIMED. IN NO EVENT SHALL PRINCETON UNIVERSITY BE LIABLE FOR ANY
* DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
* (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
* LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
* ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
* (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
* SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
/****************************************************************
 * Name: princeton-test-test.s
 * Date: December 17, 2013
 *
 * Description: Test adding a test to the OpenSPARC T1 regressions
 *
 ****************************************************************/

! Number of loop iterations
#define LOOP_ITERATIONS 100

/*********************************************************/


#include "boot.s"


#define LOOP_COUNTER %o1
#define BASE_ADDRESS_REG %g1
#define ADDR_REG %o2
#define OFFSET_L2_REG %o3
#define TMP %o4
#define TMP2 %o7
#define SAVED_REG %o5

#define L1_OFFSET 2048
#define BASE_ADDRESS_P1 %g1
#define BASE_ADDRESS_P2 %g2
#define OFFSET_L1_REG %o6
#define ADDR1_REG %o2
#define ADDR2_REG %o4
#define ANSWER 0xc0c0c0c0c0c0c0c1
#define ANSWER2 0xc0c0c0c0c0c0c0c2

# buildmanycore -x_tiles=2 -y_tiles=1
# runmanycore test_l2_race_condition3.s -finish_mask=33  -midas_args=-DTHREAD_COUNT=4


.global main
main:
th_fork(th_main, %l0)       ! Start up to four threads.
                            ! All threads do the same thing.  No need to run
                            ! more than one core and no need to differentiate
                            ! the threads because nobody stores anything
th_main_0:
    setx array01, TMP, BASE_ADDRESS_REG
    setx 32768, TMP, OFFSET_L2_REG
    setx 2048, TMP, OFFSET_L1_REG
    add BASE_ADDRESS_REG, OFFSET_L1_REG, BASE_ADDRESS_REG
    add BASE_ADDRESS_REG, OFFSET_L1_REG, BASE_ADDRESS_REG
loop0:
    mov BASE_ADDRESS_REG, ADDR_REG
    ldx [ADDR_REG], %i1
    add %i1, 1, %i1
    stx %i1, [ADDR_REG]
    ldx [ADDR_REG], %i1
    add OFFSET_L1_REG, ADDR_REG, ADDR_REG
    ldx [ADDR_REG], %i1
    add %i1, 1, %i1
    stx %i1, [ADDR_REG]
    add OFFSET_L1_REG, ADDR_REG, ADDR_REG
    ldx [ADDR_REG], %i1
    add %i1, 1, %i1
    stx %i1, [ADDR_REG]
    add OFFSET_L1_REG, ADDR_REG, ADDR_REG
    ldx [ADDR_REG], %i1
    add %i1, 1, %i1
    stx %i1, [ADDR_REG]
    add OFFSET_L1_REG, ADDR_REG, ADDR_REG
    ldx [ADDR_REG], %i1
    add %i1, 2, %i1
    stx %i1, [ADDR_REG]
    add OFFSET_L1_REG, ADDR_REG, ADDR_REG
    ldx [ADDR_REG], %i1
    add %i1, 2, %i1
    stx %i1, [ADDR_REG]
    add OFFSET_L1_REG, ADDR_REG, ADDR_REG
    ldx [ADDR_REG], %i1
    add %i1, 2, %i1
    stx %i1, [ADDR_REG]
    add OFFSET_L1_REG, ADDR_REG, ADDR_REG
    ldx [ADDR_REG], %i1
    add %i1, 2, %i1
    stx %i1, [ADDR_REG]
    
   # mov ADDR_REG, SAVED_REG

    mov BASE_ADDRESS_REG, ADDR_REG

   # mov SAVED_REG, ADDR_REG
   # add 1024, ADDR_REG, ADDR_REG

    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

    setx 1601, TMP, TMP2
delay_loop:
    cmp %g0, TMP2
    bne delay_loop
    sub TMP2, 1, TMP2

    nop
    nop
    nop
    nop
    nop
    ldx [ADDR_REG], %i1
    setx ANSWER, TMP, %i2
    cmp %i1, %i2
    bne bad_end
    nop                             ! Delay slot

    add OFFSET_L1_REG, ADDR_REG, ADDR_REG
    ldx [ADDR_REG], %i1
    setx ANSWER, TMP, %i2
    cmp %i1, %i2
    bne bad_end
    nop                             ! Delay slot

    add OFFSET_L1_REG, ADDR_REG, ADDR_REG
    ldx [ADDR_REG], %i1
    setx ANSWER, TMP, %i2
    cmp %i1, %i2
    bne bad_end
    nop                             ! Delay slot

    add OFFSET_L1_REG, ADDR_REG, ADDR_REG
    ldx [ADDR_REG], %i1
    setx ANSWER, TMP, %i2
    cmp %i1, %i2
    bne bad_end
    nop                             ! Delay slot

    add OFFSET_L1_REG, ADDR_REG, ADDR_REG
    ldx [ADDR_REG], %i1
    setx ANSWER2, TMP, %i2
    cmp %i1, %i2
    bne bad_end
    nop                             ! Delay slot

    add OFFSET_L1_REG, ADDR_REG, ADDR_REG
    ldx [ADDR_REG], %i1
    setx ANSWER2, TMP, %i2
    cmp %i1, %i2
    bne bad_end
    nop                             ! Delay slot

    add OFFSET_L1_REG, ADDR_REG, ADDR_REG
    ldx [ADDR_REG], %i1
    setx ANSWER2, TMP, %i2
    cmp %i1, %i2
    bne bad_end
    nop                             ! Delay slot

    add OFFSET_L1_REG, ADDR_REG, ADDR_REG
    ldx [ADDR_REG], %i1
    setx ANSWER2, TMP, %i2
    cmp %i1, %i2
    be good_end
    nop                             ! Delay slot

bad_end:
    ta T_BAD_TRAP
    ba end
    nop                             ! Delay slot

th_main_1:
th_main_2:
th_main_3:
th_main_4:
th_main_5:
th_main_6:
th_main_7:

good_end:
    ta T_GOOD_TRAP
    nop
end:
    nop
    nop
    nop


!==========================
.data
.align 16384
array01:
.skip 262144,0xc0

.end
