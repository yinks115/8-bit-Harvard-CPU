/*
Author: Yinka Kolawole
Module: IO Register
Desc: Functions like a normal 8 bit register, ie it holds it value until written to. The write enable is registered
thus it takes 2 posedges to write to the register
*/


module io_reg (
    input clk, input rst,
    input wr_en, input logic [7:0] data_in,

    output logic [7:0] io_data
);

    //signal for registered write enable
    logic wr_en_q;

    //signal for internal register
    logic [7:0] io_data_d;
    logic [7:0] io_data_q;

    always_ff @(posedge clk or posedge rst) begin

        if (rst) begin
            io_data_q <= 8'b0;
            //io_data_d = 8'b0;
            wr_en_q <= 0;
        end else begin
            io_data_q <= io_data_d; //stores the data
            wr_en_q <= wr_en;
        end

    end

    always_comb begin

        io_data = io_data_q; //output is the value stored in the registers
        if (wr_en_q) begin
            io_data_d = data_in;
        end else begin
            io_data_d = io_data_q; //preventing a latch (io_data_d always needs to be driven)
        end

    end

endmodule