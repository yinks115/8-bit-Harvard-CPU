/*
Author: Yinka Kolawole
Module: ALU
Desc: 8 bit alu. Inputs are the data in 2 registers (register rd and register rr), 
the entire opcode, and a carry in bit. outputs the result of the operation (16 bits) and zero, negative,
 and carry flags. although the output is 16 bits we only use the lower 8 bits because our system
 is an 8 bit system. The entire 16 bit is only used for the mult instruction.

 The inputs and outputs are registered thus it takes 2 posedges for the correct output to be on the 
 data_o bus
*/

module alu(
    input clk,
    input rst,
    input ci,
    input logic [7:0] data_rd,
    input logic [7:0] data_rr,
    input logic [7:0] opcode,
    output logic [15:0] data_o,
    output logic co,
    output logic zo,
    output logic no 
 );
  
  //**************************REGISTERING INPUTS AND OUTPUTS*************************************
  //flip-flops 1: inputs to these 1st set of FFs are same as port(module) inputs, outputs are below
  logic [7:0] opcode_q; //output of opcode bus after it has been registered (ie output of a flip flop)
  logic [7:0] data_rd_q; //output of rd register after it has been registered
  logic [7:0] data_rr_q; //output of rr register after it has been registered
  logic ci_q; //output of carry in bit after it has been registered
  
  //flip-flops 2: input to these FFs are below. outputs are same as port(module) outputs
  logic [15:0] d_data_o;
  logic d_co;
  logic d_zo;
  logic d_no;
  
  //process that registers inputs and outputs of ALU
  always_ff @(posedge clk or posedge rst) begin
    if (rst) begin
        opcode_q <= 8'b0;
        data_rd_q <= 8'b0;
        data_rr_q <= 8'b0;
        ci_q <= 1'b0;
        
        data_o <= 16'b0;
        co <= 1'b0;
        zo <= 1'b0;
        no <= 1'b0;
    end else begin
        opcode_q <= opcode;
        data_rd_q <= data_rd;
        data_rr_q <= data_rr;
        ci_q <= ci;
        
        data_o <= d_data_o;
        co <= d_co;
        zo <= d_zo;
        no <= d_no;
    end
  end
  
  
//  //**************************REGISTERING OUTPUTS*******************************
//  //input to flip flops
//  logic [15:0] d_data_o;
//  logic d_co;
//  logic d_zo;
//  logic d_no;
  
//  //process that registers the outputs of ALU
//  always_ff @(posedge clk or posedge rst) begin
//    if (rst) begin
//        data_o <= 16'b0;
//        co <= 1'b0;
//        zo <= 1'b0;
//        no <= 1'b0;
//    end else begin
//        data_o <= d_data_o;
//        co <= d_co;
//        zo <= d_zo;
//        no <= d_no;
//    end
//  end

  
  //****************************ALU OPERATIONS**********************************
  
  always_comb begin
  
    //d_zo, d_no, and d_co are combinatorial and need to be driven by some other signal to avoid an inferred latch since
    // they need to hold their values for alu instructions that don't change certain flags
    d_zo = zo;
    d_no = no;
    d_co = co;
    casez (opcode_q)
        //AND instruction
        8'b0000????: 
            begin
                d_data_o[7:0] = data_rd_q & data_rr_q; 
                d_no = d_data_o[7];
                d_zo = ~(d_data_o[7] | d_data_o[6] | d_data_o[5]| d_data_o[4]| d_data_o[3]| d_data_o[2]| d_data_o[1] | d_data_o[0]); //if d_data_o is all zeroes then zero flag is set
    
                d_co = d_co + 0;
                d_data_o[15:8] = 8'b0; //sets the 8 MSB to 0's
            end
            
        //OR instruction
        8'b0001????: 
            begin
                d_data_o[7:0] = data_rd_q | data_rr_q;
                d_no = d_data_o[7];
                d_zo = ~(d_data_o[7] | d_data_o[6] | d_data_o[5]| d_data_o[4]| d_data_o[3]| d_data_o[2]| d_data_o[1] | d_data_o[0]); //if d_data_o is all zeroes then zero flag is set
               
                d_co = d_co;
                d_data_o[15:8] = 8'b0; //sets the 8 MSB to 0's

            end
        
        //XOR instruction
        8'b0010????:
            begin
                d_data_o[7:0] = data_rd_q ^ data_rr_q;
                d_no = d_data_o[7];
                d_zo = ~(d_data_o[7] | d_data_o[6] | d_data_o[5]| d_data_o[4]| d_data_o[3]| d_data_o[2]| d_data_o[1] | d_data_o[0]); //if d_data_o is all zeroes then zero flag is set
                
                d_co = d_co;
                
                d_data_o[15:8] = 8'b0; //sets the 8 MSB to 0's

            end
        
        //MULT instruction (unisgned, so we don't need to check the negative flag)
        8'b0011????:
            begin
                d_data_o = data_rd_q * data_rr_q;
                d_zo = ~(d_data_o[15] | d_data_o[14] | d_data_o[13]| d_data_o[12]| d_data_o[11]| d_data_o[10]| d_data_o[9] | d_data_o[8] |
                d_data_o[7] | d_data_o[6] | d_data_o[5] | d_data_o[4] | d_data_o[3] | d_data_o[2] | d_data_o[1] | d_data_o[0]); //if d_data_o is all zeroes then zero flag is set
                d_co = d_data_o[15];
                

            end
        
        //ADD instruction (no carry in)
        8'b0100????:
            begin
                d_data_o[7:0] = data_rd_q + data_rr_q;
                d_no = d_data_o[7];
                d_zo = ~(d_data_o[7] | d_data_o[6] | d_data_o[5]| d_data_o[4]| d_data_o[3]| d_data_o[2]| d_data_o[1] | d_data_o[0]);
                d_co = (data_rd_q[7] & ~d_data_o[7]) | (data_rr_q[7] & ~d_data_o[7]) | (data_rr_q[7] & data_rd_q[7]);
                d_data_o[15:8] = 8'b0; //sets the 8 MSB to 0's
            end
        
        //ADDC instruction (uses carry in)
        8'b0101????:
            begin
                d_data_o[7:0] = data_rd_q + data_rr_q + ci_q;
                d_no = d_data_o[7];
                d_zo = ~(d_data_o[7] | d_data_o[6] | d_data_o[5]| d_data_o[4]| d_data_o[3]| d_data_o[2]| d_data_o[1] | d_data_o[0]);
                d_co = (data_rd_q[7] & ~d_data_o[7]) | (data_rr_q[7] & ~d_data_o[7]) | (data_rr_q[7] & data_rd_q[7]);
                d_data_o[15:8] = 8'b0; //sets the 8 MSB to 0's
            end
        
        //SUB instruction (no carry in)
        8'b0110????:
            begin
                d_data_o[7:0] = data_rd_q - data_rr_q;
                d_no = d_data_o[7];
                d_zo = ~(d_data_o[7] | d_data_o[6] | d_data_o[5]| d_data_o[4]| d_data_o[3]| d_data_o[2]| d_data_o[1] | d_data_o[0]);
                if (data_rr_q > data_rd_q) begin
                    d_co = 1'b1; //if absolute value of data_rr is greater than data_rd then carry out will be set
                end else begin
                    d_co = (~data_rd_q[7] & data_rr_q[7]) | (~data_rd_q[7] & d_data_o[7]) | (data_rr_q[7] & d_data_o[7]); //this is kind of redundant because if !rd[7] & rr[7]
                //is true then !rd & R[7] and rr[7] & R[7] would also have to be true
                end
                 d_data_o[15:8] = 8'b0; //sets the 8 MSB to 0's                               
            end
        
        //SUBC instruction (uses carry in)
        8'b0111????:
            begin
                d_data_o[7:0] = data_rd_q - data_rr_q - ci_q;
                d_no = d_data_o[7];
                d_zo = ~(d_data_o[7] | d_data_o[6] | d_data_o[5]| d_data_o[4]| d_data_o[3]| d_data_o[2]| d_data_o[1] | d_data_o[0]);
                //if rd and rr are equal but ci=1 then negative flag will be set. if absolute value of rr > rd then negative flag
                //will be set
                if ((data_rr_q == data_rd_q) & (ci_q == 1'b1)) begin
                    d_co = 1'b1;
                end else if (data_rr_q > data_rd_q) begin
                    d_co = 1'b1;
                end else begin
                    d_co = (~data_rd_q[7] & data_rr_q[7]) | (~data_rd_q[7] & d_data_o[7]) | (data_rr_q[7] & d_data_o[7]);
                end
                d_data_o[15:8] = 8'b0; //sets the 8 MSB to 0's                
            end
        
        //LSL instruction (logical left shift, fills in with 0)
        8'b1000??00:
            begin
                d_co = data_rd_q[7];
                d_data_o[7:0] = data_rd_q << 1;
                d_zo = ~(d_data_o[7] | d_data_o[6] | d_data_o[5]| d_data_o[4]| d_data_o[3]| d_data_o[2]| d_data_o[1] | d_data_o[0]);
                d_no = d_data_o[7];
                d_data_o[15:8] = 8'b0;            
            end
        
        //ASR instruction (arithmetic right shift, fill in is whatever rd[7] is)
        8'b1000??01:
            begin
                d_co = data_rd_q[0];
                d_data_o[7:0] = {data_rd_q[7], data_rd_q[7:1]};
                d_zo = ~(d_data_o[7] | d_data_o[6] | d_data_o[5]| d_data_o[4]| d_data_o[3]| d_data_o[2]| d_data_o[1] | d_data_o[0]);
                d_no = d_data_o[7];
                d_data_o[15:8] = 8'b0;
            end
        
        //ROL instruction (rotate left through carry)
        8'b1000??10:
            begin
                d_data_o[7:0] = {data_rd_q[6:0], ci_q};
                d_zo = ~(d_data_o[7] | d_data_o[6] | d_data_o[5]| d_data_o[4]| d_data_o[3]| d_data_o[2]| d_data_o[1] | d_data_o[0]);
                d_no = d_data_o[7];
                d_co = data_rd_q[7];
                d_data_o[15:8] = 8'b0;
            end
        
        //ROR instruction (rotate right through carry)
        8'b1000??11:
            begin
                d_data_o[7:0] = {ci_q, data_rd_q[7:1]};
                d_zo = ~(d_data_o[7] | d_data_o[6] | d_data_o[5]| d_data_o[4]| d_data_o[3]| d_data_o[2]| d_data_o[1] | d_data_o[0]);
                d_no = d_data_o[7];
                d_co = data_rd_q[0];
                d_data_o[15:8] = 8'b0;
            end
        
        //NEG instruction (replaces content of Rd with its 2's complement)
        8'b1001??00:
            begin
                d_data_o[7:0] = ~data_rd_q + 1;
                d_zo = ~(d_data_o[7] | d_data_o[6] | d_data_o[5]| d_data_o[4]| d_data_o[3]| d_data_o[2]| d_data_o[1] | d_data_o[0]);
                d_no = d_data_o[7];
                d_data_o[15:8] = 8'b0;
                d_co = ~d_data_o[7] & ~data_rd_q[7];
            end
            
        default: 
            begin 
                d_data_o = data_o;
                d_zo = zo;
                d_no = no;
                d_co = co;
            end
    
    endcase
  
  end
  
    
endmodule
