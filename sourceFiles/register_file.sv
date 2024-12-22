/*
Author: Yinka Kolawole
Module: Register file
Desc:

All inputs are registered
This module will be connected to the control logic, alu, and data memory

*/

module register_file (
    input clk, input rst,
    input wr_en, input logic [1:0] wr_addr,
    input logic [1:0] rd_addr, input logic [1:0] rr_addr,
    input logic [7:0] wr_data,

    output logic [7:0] rd_data,
    output logic [7:0] rr_data
);

    //creating signal for internal registers. we have 4 registers with a width of 8 bits
    logic [7:0] reg_data_q [0:3];
    logic [7:0] reg_data_d [0:3];

    //creating registered input signals
    logic wr_en_q; logic [1:0] wr_addr_q;
    logic [1:0] rd_addr_q; logic [1:0] rr_addr_q;
    logic [7:0] wr_data_q;

    logic [1:0] rd_addr_d; logic [1:0] rr_addr_d;
    logic [7:0] wr_data_d; logic [1:0] wr_addr_d;

    //always blocks
    always_ff @(posedge clk or posedge rst) begin

        if (rst) begin
            reg_data_q[0] <= 8'b0;
            reg_data_q[1] <= 8'b0;
            reg_data_q[2] <= 8'b0;
            reg_data_q[3] <= 8'b0;
            wr_en_q <= 0;
            wr_addr_q <= 2'b0; wr_data_q <= 8'b0;
            rd_addr_q <= 2'b0; rr_addr_q <= 2'b0;
        end else begin
            wr_en_q <= wr_en;
            reg_data_q <= reg_data_d;
            wr_data_q <= wr_data_d; wr_addr_q <= wr_addr_d;
            rd_addr_q <= rd_addr_d; rr_addr_q <= rr_addr_d;
        end

    end

    //putting the combinational logic into separate always block to increase readability
    always_comb begin
        rd_addr_d = rd_addr; rr_addr_d = rr_addr;
        wr_data_d = wr_data; wr_addr_d = wr_addr;
    end

    //determines what register to write to
    always_comb begin
        if (wr_en_q) begin
            reg_data_d[wr_addr_q] = wr_data_q;
            
            case (wr_addr_q)//really scared of latches
                2'b00: begin
                    reg_data_d[1] = reg_data_q[1];
                    reg_data_d[2] = reg_data_q[2];
                    reg_data_d[3] = reg_data_q[3];
                end
                2'b01: begin
                    reg_data_d[0] = reg_data_q[0];
                    reg_data_d[2] = reg_data_q[2];
                    reg_data_d[3] = reg_data_q[3];                
                end
                2'b10: begin
                    reg_data_d[0] = reg_data_q[0];
                    reg_data_d[1] = reg_data_q[1];
                    reg_data_d[3] = reg_data_q[3];                
                end
                2'b11: begin
                    reg_data_d[0] = reg_data_q[0];
                    reg_data_d[1] = reg_data_q[1];
                    reg_data_d[2] = reg_data_q[2];                
                end
            endcase
        end else begin
            reg_data_d = reg_data_q; //preventing a latch
        end
    end

    //determines which registers we're reading from (outputs are not registered)
    always_comb begin
        rd_data = reg_data_q[rd_addr_q];
        rr_data = reg_data_q[rr_addr_q];
    end

    
endmodule