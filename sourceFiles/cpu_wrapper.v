`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Yinka Kolawole
// 
// Create Date: 12/06/2024 08:04:26 PM
// Design Name: 
// Module Name: cpu_wrappeR
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module cpu_wrapper(
    clk, rst, led_driver_flag, rd_addr_flag, rd_addr, led_driver, carry_in
    );
    
    input clk; input rst;
    input rd_addr_flag; //needs to be set if we wan't to use fpga switches to rd dmem data
    input led_driver_flag; //will use switch 15 on fpga
    input carry_in; //used for ADDC and SUBC operations
    input wire [7:0] rd_addr;//connected to switches on the fpga
    
    output reg [7:0] led_driver;//signal that's fed into the 7_seg display
    
    
    //***************instantiations******************
    //program counter
    wire [7:0] opcode; //output of control logic. drives opcode port of alu and ld_count port of pc
    wire inc_en; wire jmp_en; wire call_en; wire ret_en;
    wire [7:0] count;
    program_counter inst_pc(
        .clk(clk), .rst(rst), .inc_en(inc_en), .jmp_en(jmp_en),
        .call_en(call_en), .ret_en(ret_en), .ld_count(opcode),
        
        .count(count)
    );
    
    //instruction memory
    wire [7:0] instruction;
    imem_2 inst_imem(
        .clka(clk), .addra(count),
        
        .douta(instruction)
    );
    
    //reg file
    wire wr_en_rf; reg [1:0] wr_addr_rf; //wire [1:0] rd_addr_rf; wire [1:0] rr_addr_rf;
    reg [7:0] wr_data; wire [7:0] rd_data; wire [7:0] rr_data; //rd_data is data of destination reg
    
    register_file inst_regFile(
        .clk(clk), .rst(rst), .wr_en(wr_en_rf), .wr_data(wr_data), 
        .rd_addr(opcode[3:2]), .rr_addr(opcode[1:0]), .wr_addr(wr_addr_rf), //rd_addr is address of destination reg
        
        .rd_data(rd_data), .rr_data(rr_data)
    );
    
    //alu
    /*data_rd and data_rr port of alu are connected to rd_data and rr_data wires*/
    wire [15:0] alu_result; //mult is not supported in this current implementation so we only need the lower 8 bits
    wire co; wire no; wire zo;
    
    alu inst_alu(
        .clk(clk), .rst(rst), .opcode(opcode),
        .data_rd(rd_data), .data_rr(rr_data), .ci(carry_in),
        
        .data_o(alu_result), .co(co), .no(no), .zo(zo)
    );
    
    //data mem
    /*input is wr_en_dmem (comes from control logic), rd_data,rr_data
    and rd_addr_dmem. rd_addr_dmem is the output of a mux whose inputs are rd_addr (input of cpu module) or rr_data
    */
    wire wr_en_dmem; wire [7:0] dmem_data; reg [7:0] rd_addr_dmem;
    
    data_mem inst_dmem(
        .clka(clk), .wea(wr_en_dmem), .dina(rd_data),
        .addra(rd_addr_dmem),
        
        .douta(dmem_data)
    );
    
    //io register
    wire wr_en_io; wire [7:0] io_data;
    io_reg inst_io_reg(
        .clk(clk), .rst(rst), .wr_en(wr_en_io), .data_in(dmem_data),
        
        .io_data(io_data)
    );
    
    //control logic
    wire [1:0] select; wire use_strd_addr; wire [1:0] wr_addr;
    control_logic inst_control(
        .clk(clk), .rst(rst), .zo_flag(zo), .no_flag(no),
        .co_flag(co), .instruction(instruction),
        
        .select(select), .wr_en_regFile(wr_en_rf), .wr_en_dmem(wr_en_dmem),
        .wr_en_io(wr_en_io), .jmp_en(jmp_en), .call_en(call_en), .inc_en(inc_en),
        .ret_en(ret_en), .use_strd_addr(use_strd_addr), .wr_addr(wr_addr),
        .opcode(opcode)
    );
    
    //********************LOGIC***************
    /*contains logic for what drives
    1. wr_data port of reg file
    2. addra port of data mem
    3. input for 7 seg disp
    4. wr_addr port of reg file
    */
    
    //procedural block for driving wr_data and wr_addr port of reg file and input for 7 seg disp
    always @(*) begin
        case (select)
            2'b00: begin //alu
                wr_data = alu_result[7:0];
            end
            
            2'b01: begin //data memory
                wr_data = dmem_data;
            end
            
            2'b10: begin //control logic
                wr_data = opcode;
            end
            
            default: begin //should never occur but i need to cover all cases
                wr_data = opcode;
            end
        endcase
        
        if (use_strd_addr) begin
            wr_addr_rf = wr_addr;
        end else begin
            wr_addr_rf = opcode[3:2];
        end
        
        if (led_driver_flag) begin //means we want to connect io_reg output to 7 seg disp
            led_driver = io_data;
        end else begin //connects dmem output to 7 seg disp
            led_driver = dmem_data;
        end 
    end
    
    //determines what drives read addr port of data mem
    always @(*) begin
        if (rd_addr_flag) begin
            rd_addr_dmem = rd_addr;
        end else begin
            rd_addr_dmem = rr_data;
        end
    end
   //******************************************************************************
   
    
   
endmodule
