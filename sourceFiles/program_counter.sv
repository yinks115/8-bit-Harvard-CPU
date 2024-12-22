/*
Author: Yinka Kolawole
Module: Program Counter
Desc: Basically a customized 8 bit counter. The module has 3 enable signals. If the increment enable
is high the module functions just like a counter, the count increments by a value of 1. If the jump
enable signal is high it means we're going to jump to the count value indicated by the ld_count bus.
if the call enable signal is high we store (current count + 2) in a return register and jmp to the count
value indicated by ld_count. If the return enable is high our new count value will simply be the value we stored
in the return register after the last call command. If none of the enables are high the registers hold their 
values.

This module will be connected to control logic and instruction memory

takes 1 posedge to change the value of the count and return registers
*/

module program_counter (
    input clk, input rst,
    //enable signals are not registered
    input inc_en, input jmp_en, //jmp_en will be used for jmp and jmpc commands
    input call_en, input ret_en,
    input logic [7:0] ld_count, //new count/address

    output logic [7:0] count
);
    //signals for internal registers
    logic [7:0] count_q; logic [7:0] return_reg_q;
    logic [7:0] count_d; logic [7:0] return_reg_d;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            count_q <= 8'b0; return_reg_q <= 8'b0;
        end else begin
            count_q <= count_d;
            return_reg_q <= return_reg_d;
        end
    end

    always_comb begin
        
        //note: the syntax ...d = ...q is to prevent a latch. the input to our registers always need to be driven

        count = count_q;

        if (inc_en) begin
            count_d = count_q + 1;
            return_reg_d = return_reg_q;
        end else if (jmp_en) begin
            count_d = ld_count;
            return_reg_d = return_reg_q;
        end else if (call_en) begin
            //need to store return address which is the current count + 1 (address we're jumping to, k, is in count becuase 
            //call_en is high when we're loading k into the pc)
            return_reg_d = count_q + 1;
            count_d = ld_count;
        end else if (ret_en) begin
            count_d = return_reg_q;
            return_reg_d = return_reg_q; 
        end else begin
            count_d = count_q;
            return_reg_d = return_reg_q;
        end
    end
    
endmodule