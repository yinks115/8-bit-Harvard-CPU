`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: UMBC - CMPE316
// Engineer: Yinka Kolawole
// 
// Create Date: 10/04/2024 02:43:52 PM
// Design Name: 
// Module Name: alu_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Contains test bench for alu module
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments: IMPORTANT!!!! Inputs and outputs are registered. On the 1st posedge after input changed the change propagates, output is 
//caculated however this change in output doesn't propagate until the 2nd posedge. In summary when the inputs are changed it takes 2 posedge
//for the correct value to be on the output bus. In this test bench a 100Mhz clock is used, clock is high for 10ns and low for 10ns. The clock
//starts off at 0 at 0ns so a posedge occurs on every odd multiple of 10 (ie 10ns, 30ns, 50ns, 70ns,...). In this test bench the duration of
//an opcode instruction lasts 40ns. The first opcode instruction starts at 45ns. This input doesn't get registered until 50ns (which is a 
//posedge). The output propoagates on the 2nd posedge which occurs at 70ns. The next instruction occurs at 85ns. Then we just rinse and 
//repeat. The simulation time is 1845ns in which all 13 ALU operations are tested
// 
//////////////////////////////////////////////////////////////////////////////////


module alu_tb();

    logic clk = 0;
    logic rst = 0;
    logic ci;
    logic [7:0] opcode;
    logic [7:0] data_rd;
    logic [7:0] data_rr;
    logic [15:0] data_o;
    logic co;
    logic no;
    logic zo;
    
    alu t_alu(
        .clk(clk),
        .rst(rst),
        .ci(ci),
        .data_rd(data_rd),
        .data_rr(data_rr),
        .opcode(opcode),
        .data_o(data_o),
        .co(co),
        .no(no),
        .zo(zo)
    );
    
    initial begin
        //creates a 100Mhz clock so posedge is at 10ns, 30ns, 50ns, 70ns...
        forever #10ns clk = !clk;
    end
    
    
    initial begin
    data_rd = 8'b0;
    data_rr = 8'b0;
    opcode = 8'b0;
    ci = 8'b0;
    rst = 1;
    #40;
    rst = 0;
    #5;
    
    //************************TESTING AND OPERATION**********************
    $display("*****************************TESTING AND OPERATION******************************");
    $display("Starting at %0t ns", $time);
    //AND TEST 1 (inputs are asserted at 45ns, registered inputs change at 50ns, registered output chnages at 70ns)
    data_rd = 8'b1100_1011;
    data_rr = 8'b0000_0011;
    opcode = 8'b0000_1010;
    #30; //now at 75ns. output value should be valid
    //expected result is that data_o = 0000_0011 and that all flags are 0 (for AND we only care about no and zo)
//    @(posedge clk);
    if (data_o == 16'b0000_0000_0000_0011) begin
        $display("output of AND test 1 passed");
        if (zo == 1'b0)begin
            $display("Zero flag is valid for AND TEST 1");
        end else begin
            $display("Zero flag is invalid for AND TEST 1");
        end
        if (no == 1'b0) begin
            $display("Negative flag is valid for AND TEST 1");
        end else begin
            $display("Negative flag is invalid for AND TEST 1");
        end
    end else begin
        $display("INVALID OUTPUT FOR AND TEST 1");
    end
    #10; //now at 85ns
    //AND TEST 2 (input change occurs at 85ns. registered inputs change at 90ns. outputs should propogate at 110ns)
    data_rd = 8'b1111_1011;
    data_rr = 8'b1010_1110;
    opcode = 8'b0000_1010;
    #30; //now at 115ns. output bus should be valid
    //expected result is that data_o = 1010_1010, no = 1 and zo=0
//    @(posedge clk);
    if (data_o == 16'b0000_0000_1010_1010) begin
        $display("output of AND test 2 passed");
        if (zo == 1'b0)begin
            $display("Zero flag is valid for AND TEST 2");
        end else begin
            $display("Zero flag is invalid for AND TEST 2");
        end
        if (no == 1'b1) begin
            $display("Negative flag is valid for AND TEST 2");
        end else begin
            $display("Negative flag is invalid for AND TEST 2");
        end
    end else begin
        $display("INVALID OUTPUT FOR AND TEST 2");
    end
    #10; //now at 125ns
//    //AND TEST 3 (inputs change at 125ns, registered inputs change at 130ns, output should be at 150ns)
    data_rd = 8'b1111_1111;
    data_rr = 8'b0000_0000;
    opcode = 8'b0000_1010;
    #30; //now at 155ns
//    //expected result is that data_o = 0000_0000, zo = 1 and no=0
//    @(posedge clk);
    if (data_o == 16'b0000_0000_0000_0000) begin
        $display("output of AND test 3 passed");
        if (zo == 1'b1)begin
            $display("Zero flag is valid for AND TEST 3");
        end else begin
            $display("Zero flag is invalid for AND TEST 3");
        end
        if (no == 1'b0) begin
            $display("Negative flag is valid for AND TEST 3");
        end else begin
            $display("Negative flag is invalid for AND TEST 3");
        end
    end else begin
        $display("INVALID OUTPUT FOR AND TEST 3");
    end
    
    #10;//now at 165ns
    
    //************************TESTING OR OPERATION**********************
    $display("*****************************TESTING OR OPERATION******************************");
    $display("Starting at %0t ns", $time);
    //OR TEST 1 (inputs are asserted at 165ns, registered inputs change at 170ns, registered output chnages at 190ns)
    data_rd = 8'b1100_0011;
    data_rr = 8'b1110_0111;
    opcode = 8'b0001_1010;
    #30; //now at 195ns. output value should be 1110_0111
    //expected result is that data_o = 1110_0111, no =1, zo=0
//    @(posedge clk);
    if (data_o == 16'b0000_0000_1110_0111) begin
        $display("output of OR test 1 passed");
        if (zo == 1'b0)begin
            $display("Zero flag is valid for OR TEST 1");
        end else begin
            $display("Zero flag is invalid for OR TEST 1");
        end
        if (no == 1'b1) begin
            $display("Negative flag is valid for OR TEST 1");
        end else begin
            $display("Negative flag is invalid for OR TEST 1");
        end
    end else begin
        $display("INVALID OUTPUT FOR OR TEST 1");
    end
    #10; //now at 205ns
    //OR TEST 2 (inputs are asserted at 205ns, registered inputs change at 210ns, registered output chnages at 230ns)
    data_rd = 8'b1001_1011;
    data_rr = 8'b1110_0100;
    opcode = 8'b0001_1010;
    #30; //now at 235ns.
    //expected result is that data_o = 1111_1111, no =1, zo=0
    if (data_o == 16'b0000_0000_1111_1111) begin
        $display("output of OR test 2 passed");
        if (zo == 1'b0)begin
            $display("Zero flag is valid for OR TEST 2");
        end else begin
            $display("Zero flag is invalid for OR TEST 2");
        end
        if (no == 1'b1) begin
            $display("Negative flag is valid for OR TEST 2");
        end else begin
            $display("Negative flag is invalid for OR TEST 2");
        end
    end else begin
        $display("INVALID OUTPUT FOR OR TEST 2");
    end
    #10; //now at 245
    
    
    //************************TESTING ADD OPERATION**********************
    $display("*****************************TESTING ADD OPERATION******************************");
    $display("Starting at %0t ns", $time);
    //ADD TEST 1 (inputs are asserted at 245ns, registered inputs change at 250ns, registered output chnages at 270ns)
    data_rd = 8'b1101_1111;
    data_rr = 8'b0110_0110;
    opcode = 8'b0100_1111;
    #30; //now at 275ns.
    //expected result is that data_o = 0100_0101, co =1, zo=no=0
    $display("ADD TEST 1:");
    if (data_o == 16'b0000_0000_0100_0101) begin
        $display("    output of ADD test 1 passed");
        if (zo == 1'b0)begin
            $display("    Zero flag is valid for ADD TEST 1");
        end else begin
            $display("    Zero flag is invalid for ADD TEST 1");
        end
        if (co == 1'b1) begin
            $display("    Carry flag is valid for ADD TEST 1");
        end else begin
            $display("    Carry flag is invalid for ADD TEST 1");
        end
        if (no == 1'b0) begin
            $display("    Negative flag is valid for ADD test 1");
        end else begin
            $display("    Negative flag is invalid for ADD TEST 1");
        end
    end else begin
        $display("INVALID OUTPUT FOR ADD TEST 1");
    end
    #10; //285ns
    //ADD TEST 2 (inputs are asserted at 285ns, registered inputs change at 290ns, registered output chnages at 310ns)
    data_rd = 8'b0100_1001;
    data_rr = 8'b1110_1010;
    opcode = 8'b0100_1111;
    #30; //now at 315ns.
    //expected result is that data_o = 0011_0011, co =1, zo=no=0
    $display("ADD TEST 2:");
    if (data_o == 16'b0000_0000_0011_0011) begin
        $display("    output of ADD test 2 passed");
        if (zo == 1'b0)begin
            $display("    Zero flag is valid for ADD TEST 2");
        end else begin
            $display("    Zero flag is invalid for ADD TEST 2");
        end
        if (co == 1'b1) begin
            $display("    Carry flag is valid for ADD TEST 2");
        end else begin
            $display("    Carry flag is invalid for ADD TEST 2");
        end
        if (no == 1'b0) begin
            $display("    Negative flag is valid for ADD test 2");
        end else begin
            $display("    Negative flag is invalid for ADD TEST 2");
        end
    end else begin
        $display("    INVALID OUTPUT FOR ADD TEST 2");
    end
    #10; //325ns
    //ADD TEST 3 (inputs are asserted at 325ns, registered inputs change at 330ns, registered output chnages at 350ns)
    data_rd = 8'b1111_1111;
    data_rr = 8'b0000_0001;
    opcode = 8'b0100_1111;
    #30; //now at 355ns.
    //expected result is that data_o = 0000_0000, co =1, zo=1, no=0
    $display("ADD TEST 3:");
    if (data_o == 16'b0000_0000_0000_0000) begin
        $display("    output of ADD test 3 passed");
        if (zo == 1'b1)begin
            $display("    Zero flag is valid for ADD TEST 3");
        end else begin
            $display("    Zero flag is invalid for ADD TEST 3");
        end
        if (co == 1'b1) begin
            $display("    Carry flag is valid for ADD TEST 3");
        end else begin
            $display("    Carry flag is invalid for ADD TEST 3");
        end
        if (no == 1'b0) begin
            $display("    Negative flag is valid for ADD test 3");
        end else begin
            $display("    Negative flag is invalid for ADD TEST 3");
        end
    end else begin
        $display("    INVALID OUTPUT FOR ADD TEST 3");
    end
    #10; //365ns
    //ADD TEST 4 (inputs are asserted at 365ns, registered inputs change at 370ns, registered output chnages at 390ns)
    data_rd = 8'b1001_0000;
    data_rr = 8'b0110_1101;
    opcode = 8'b0100_1111;
    #30; //now at 395ns.
    //expected result is that data_o = 1111_1101, no =1, zo=co=0
    $display("ADD TEST 4:");
    if (data_o == 16'b0000_0000_1111_1101) begin
        $display("    output of ADD test 4 passed");
        if (zo == 1'b0)begin
            $display("    Zero flag is valid for ADD TEST 4");
        end else begin
            $display("    Zero flag is invalid for ADD TEST 4");
        end
        if (co == 1'b0) begin
            $display("    Carry flag is valid for ADD TEST 4");
        end else begin
            $display("    Carry flag is invalid for ADD TEST 4");
        end
        if (no == 1'b1) begin
            $display("    Negative flag is valid for ADD test 4");
        end else begin
            $display("    Negative flag is invalid for ADD TEST 4");
        end
    end else begin
        $display("    INVALID OUTPUT FOR ADD TEST 4");
    end
    #10; //405ns
    
    //************************TESTING ADDC OPERATION**********************
    $display("*****************************TESTING ADDC OPERATION******************************");
    $display("Starting at %0t ns", $time);
    //ADDC TEST 1 (inputs are asserted at 405ns, registered inputs change at 410ns, registered output chnages at 430ns)
    data_rd = 8'b1101_1111;
    data_rr = 8'b0110_0110;
    opcode = 8'b0101_1111;
    ci = 1'b1;
    #30; //now at 435ns.
    //expected result is that data_o = 0100_0110, co =1, zo=no=0
    
    $display("ADDC TEST 1 (ci = 1):");
    if (data_o == 16'b0000_0000_0100_0110) begin
        $display("    output of ADDC test 1 passed");
        if (zo == 1'b0)begin
            $display("    Zero flag is valid for ADDC TEST 1");
        end else begin
            $display("    Zero flag is invalid for ADDC TEST 1");
        end
        if (co == 1'b1) begin
            $display("    Carry flag is valid for ADDC TEST 1");
        end else begin
            $display("    Carry flag is invalid for ADDC TEST 1");
        end
        if (no == 1'b0) begin
            $display("    Negative flag is valid for ADDC test 1");
        end else begin
            $display("    Negative flag is invalid for ADDC TEST 1");
        end
    end else begin
        $display("INVALID OUTPUT FOR ADDC TEST 1");
    end
    #10; //445ns
    //ADDC TEST 2 (inputs are asserted at 445ns, registered inputs change at 450ns, registered output chnages at 470ns)
    data_rd = 8'b0100_1001;
    data_rr = 8'b1110_1010;
    opcode = 8'b0101_1111;
    #30; //now at 475ns.
    //expected result is that data_o = 0011_0100, co =1, zo=no=0
    $display("ADDC TEST 2 (ci = 1):");
    if (data_o == 16'b0000_0000_0011_0100) begin
        $display("    output of ADDC test 2 passed");
        if (zo == 1'b0)begin
            $display("    Zero flag is valid for ADDC TEST 2");
        end else begin
            $display("    Zero flag is invalid for ADDC TEST 2");
        end
        if (co == 1'b1) begin
            $display("    Carry flag is valid for ADDC TEST 2");
        end else begin
            $display("    Carry flag is invalid for ADDC TEST 2");
        end
        if (no == 1'b0) begin
            $display("    Negative flag is valid for ADDC test 2");
        end else begin
            $display("    Negative flag is invalid for ADDC TEST 2");
        end
    end else begin
        $display("    INVALID OUTPUT FOR ADDC TEST 2");
    end
    #10; //485ns
    //ADDC TEST 3 (inputs are asserted at 485ns, registered inputs change at 490ns, registered output chnages at 510ns)
    data_rd = 8'b1111_1111;
    data_rr = 8'b0000_0001;
    opcode = 8'b0101_1111;
    #30; //now at 515ns.
    //expected result is that data_o = 0000_0001, co =1, zo=0, no=0
    $display("ADDC TEST 3 (ci = 1):");
    if (data_o == 16'b0000_0000_0000_0001) begin
        $display("    output of ADDC test 3 passed");
        if (zo == 1'b0)begin
            $display("    Zero flag is valid for ADDC TEST 3");
        end else begin
            $display("    Zero flag is invalid for ADDC TEST 3");
        end
        if (co == 1'b1) begin
            $display("    Carry flag is valid for ADDC TEST 3");
        end else begin
            $display("    Carry flag is invalid for ADDC TEST 3");
        end
        if (no == 1'b0) begin
            $display("    Negative flag is valid for ADDC test 3");
        end else begin
            $display("    Negative flag is invalid for ADDC TEST 3");
        end
    end else begin
        $display("    INVALID OUTPUT FOR ADDC TEST 3");
    end
    #10; //525ns
    //ADDC TEST 4 (inputs are asserted at 525ns, registered inputs change at 530ns, registered output chnages at 550ns)
    data_rd = 8'b1001_0000;
    data_rr = 8'b0110_1101;
    opcode = 8'b0101_1111;
    #30; //now at 555ns.
    //expected result is that data_o = 1111_1110, no =1, zo=co=0
    $display("ADDC TEST 4 (ci = 1):");
    if (data_o == 16'b0000_0000_1111_1110) begin
        $display("    output of ADDC test 4 passed");
        if (zo == 1'b0)begin
            $display("    Zero flag is valid for ADDC TEST 4");
        end else begin
            $display("    Zero flag is invalid for ADDC TEST 4");
        end
        if (co == 1'b0) begin
            $display("    Carry flag is valid for ADDC TEST 4");
        end else begin
            $display("    Carry flag is invalid for ADDC TEST 4");
        end
        if (no == 1'b1) begin
            $display("    Negative flag is valid for ADDC test 4");
        end else begin
            $display("    Negative flag is invalid for ADDC TEST 4");
        end
    end else begin
        $display("    INVALID OUTPUT FOR ADDC TEST 4");
    end
    #10; //565ns
    ci = 1'b0;
    
    
    //************************TESTING SUB OPERATION**********************
    $display("*****************************TESTING SUB OPERATION******************************");
    $display("Starting at %0t ns", $time);
    //SUB TEST 1 (inputs are asserted at 565ns, registered inputs change at 570ns, registered output chnages at 590ns)
    data_rd = 8'b1100_1010;
    data_rr = 8'b1001_1011;
    opcode = 8'b0110_1111;
    #30; //now at 595ns.
    //expected result is that data_o = 0010_1111, co=zo=no=0
    $display("SUB TEST 1:");
    if (data_o == 16'b0000_0000_0010_1111) begin
        $display("    output of SUB test 1 passed");
        if (zo == 1'b0)begin
            $display("    Zero flag is valid for SUB TEST 1");
        end else begin
            $display("    Zero flag is invalid for SUB TEST 1");
        end
        if (co == 1'b0) begin
            $display("    Carry flag is valid for SUB TEST 1");
        end else begin
            $display("    Carry flag is invalid for SUB TEST 1");
        end
        if (no == 1'b0) begin
            $display("    Negative flag is valid for SUB test 1");
        end else begin
            $display("    Negative flag is invalid for SUB TEST 1");
        end
    end else begin
        $display("INVALID OUTPUT FOR SUB TEST 1");
    end
    #10; //605ns
    //SUB TEST 2 (inputs are asserted at 605ns, registered inputs change at 610ns, registered output chnages at 630ns)
    data_rd = 8'b1011_1101;
    data_rr = 8'b0111_1101;
    opcode = 8'b0110_1111;
    #30; //now at 635ns.
    //expected result is that data_o = 0100_0000, co=zo=no=0
    $display("SUB TEST 2:");
    if (data_o == 16'b0000_0000_0100_0000) begin
        $display("    output of SUB test 2 passed");
        if (zo == 1'b0)begin
            $display("    Zero flag is valid for SUB TEST 2");
        end else begin
            $display("    Zero flag is invalid for SUB TEST 2");
        end
        if (co == 1'b0) begin
            $display("    Carry flag is valid for SUB TEST 2");
        end else begin
            $display("    Carry flag is invalid for SUB TEST 2");
        end
        if (no == 1'b0) begin
            $display("    Negative flag is valid for SUB test 2");
        end else begin
            $display("    Negative flag is invalid for SUB TEST 2");
        end
    end else begin
        $display("INVALID OUTPUT FOR SUB TEST 2");
    end
    #10;//645ns
    //SUB TEST 3 (inputs are asserted at 645ns, registered inputs change at 650ns, registered output chnages at 670ns)
    data_rd = 8'b1111_1111;
    data_rr = 8'b1111_1111;
    opcode = 8'b0110_1111;
    #30; //now at 675ns.
    //expected result is that data_o = 0000_0000, zo= 1, co=no=0
    $display("SUB TEST 3:");
    if (data_o == 16'b0000_0000_0000_0000) begin
        $display("    output of SUB test 3 passed");
        if (zo == 1'b1)begin
            $display("    Zero flag is valid for SUB TEST 3");
        end else begin
            $display("    Zero flag is invalid for SUB TEST 3");
        end
        if (co == 1'b0) begin
            $display("    Carry flag is valid for SUB TEST 3");
        end else begin
            $display("    Carry flag is invalid for SUB TEST 3");
        end
        if (no == 1'b0) begin
            $display("    Negative flag is valid for SUB test 3");
        end else begin
            $display("    Negative flag is invalid for SUB TEST 3");
        end
    end else begin
        $display("INVALID OUTPUT FOR SUB TEST 3");
    end
    #10; //685ns
    //SUB TEST 4 (inputs are asserted at 685ns, registered inputs change at 690ns, registered output chnages at 710ns)
    data_rd = 8'b0011_1001;
    data_rr = 8'b1010_0011;
    opcode = 8'b0110_1111;
    #30; //now at 715ns.
    //expected result is that data_o = 1001_0110, co=1, zo=0, no=1
    $display("SUB TEST 4:");
    if (data_o == 16'b0000_0000_1001_0110) begin
        $display("    output of SUB test 4 passed");
        if (zo == 1'b0)begin
            $display("    Zero flag is valid for SUB TEST 4");
        end else begin
            $display("    Zero flag is invalid for SUB TEST 4");
        end
        if (co == 1'b1) begin
            $display("    Carry flag is valid for SUB TEST 4");
        end else begin
            $display("    Carry flag is invalid for SUB TEST 4");
        end
        if (no == 1'b1) begin
            $display("    Negative flag is valid for SUB test 4");
        end else begin
            $display("    Negative flag is invalid for SUB TEST 4");
        end
    end else begin
        $display("INVALID OUTPUT FOR SUB TEST 4");
    end
    #10; //now at 725ns
    
    
    //************************TESTING SUBC OPERATION**********************
    $display("*****************************TESTING SUBC OPERATION******************************");
    $display("Starting at %0t ns", $time);
    ci = 1'b1; //setting the carry to 1
    //SUBC TEST 1 (inputs are asserted at 725ns, registered inputs change at 730ns, registered output chnages at 750ns)
    data_rd = 8'b1100_1010;
    data_rr = 8'b1001_1011;
    opcode = 8'b0111_1111;
    #30; //now at 755ns.
    //expected result is that data_o = 0011_0000, co=zo=no=0
    $display("SUBC TEST 1:");
    if (data_o == 16'b0000_0000_0010_1110) begin
        $display("    output of SUBC test 1 passed");
        if (zo == 1'b0)begin
            $display("    Zero flag is valid for SUBC TEST 1");
        end else begin
            $display("    Zero flag is invalid for SUBC TEST 1");
        end
        if (co == 1'b0) begin
            $display("    Carry flag is valid for SUBC TEST 1");
        end else begin
            $display("    Carry flag is invalid for SUBC TEST 1");
        end
        if (no == 1'b0) begin
            $display("    Negative flag is valid for SUBC test 1");
        end else begin
            $display("    Negative flag is invalid for SUBC TEST 1");
        end
    end else begin
        $display("INVALID OUTPUT FOR SUBC TEST 1");
    end
    #10; //765ns
    //SUBC TEST 2 (inputs are asserted at 765ns, registered inputs change at 770ns, registered output chnages at 790ns)
    data_rd = 8'b1011_1101;
    data_rr = 8'b0111_1101;
    opcode = 8'b0111_1111;
    #30; //now at 795ns.
    //expected result is that data_o = 0011_1111, co=zo=no=0
    $display("SUBC TEST 2:");
    if (data_o == 16'b0000_0000_0011_1111) begin
        $display("    output of SUBC test 2 passed");
        if (zo == 1'b0)begin
            $display("    Zero flag is valid for SUBC TEST 2");
        end else begin
            $display("    Zero flag is invalid for SUBC TEST 2");
        end
        if (co == 1'b0) begin
            $display("    Carry flag is valid for SUBC TEST 2");
        end else begin
            $display("    Carry flag is invalid for SUBC TEST 2");
        end
        if (no == 1'b0) begin
            $display("    Negative flag is valid for SUBC test 2");
        end else begin
            $display("    Negative flag is invalid for SUBC TEST 2");
        end
    end else begin
        $display("INVALID OUTPUT FOR SUBC TEST 2");
    end
    #10;//805ns
    //SUBC TEST 3 (inputs are asserted at 805ns, registered inputs change at 810ns, registered output changes at 830ns)
    data_rd = 8'b1111_1111;
    data_rr = 8'b1111_1111;
    opcode = 8'b0111_1111;
    #30; //now at 835ns.
    //expected result is that data_o = 1111_1111, co= 1, zo=0, no=1
    $display("SUBC TEST 3:");
    if (data_o == 16'b0000_0000_1111_1111) begin
        $display("    output of SUBC test 3 passed");
        if (zo == 1'b0)begin
            $display("    Zero flag is valid for SUBC TEST 3");
        end else begin
            $display("    Zero flag is invalid for SUBC TEST 3");
        end
        if (co == 1'b1) begin
            $display("    Carry flag is valid for SUBC TEST 3");
        end else begin
            $display("    Carry flag is invalid for SUBC TEST 3");
        end
        if (no == 1'b1) begin
            $display("    Negative flag is valid for SUBC test 3");
        end else begin
            $display("    Negative flag is invalid for SUBC TEST 3");
        end
    end else begin
        $display("INVALID OUTPUT FOR SUBC TEST 3");
    end
    #10; //845ns
    //SUBC TEST 4 (inputs are asserted at 845ns, registered inputs change at 850ns, registered output chnages at 870ns)
    data_rd = 8'b1000_0011;
    data_rr = 8'b1100_0000;
    opcode = 8'b0111_1111;
    #30; //now at 875ns.
    //expected result is that data_o = 1100_0010, co=1, zo=0, no=1
    $display("SUBC TEST 4:");
    if (data_o == 16'b0000_0000_1100_0010) begin
        $display("    output of SUBC test 4 passed");
        if (zo == 1'b0)begin
            $display("    Zero flag is valid for SUBC TEST 4");
        end else begin
            $display("    Zero flag is invalid for SUBC TEST 4");
        end
        if (co == 1'b1) begin
            $display("    Carry flag is valid for SUBC TEST 4");
        end else begin
            $display("    Carry flag is invalid for SUBC TEST 4");
        end
        if (no == 1'b1) begin
            $display("    Negative flag is valid for SUBC test 4");
        end else begin
            $display("    Negative flag is invalid for SUBC TEST 4");
        end
    end else begin
        $display("INVALID OUTPUT FOR SUBC TEST 4");
    end
    #10; //now at 885ns
    ci = 1'b0;
    
    //******************************TESTING MULTIPLICATION OPERATION***************************
    opcode = 8'b0011_1111;
    $display("***********************TESTING MULT OPERATION (UNSIGNED)*****************");
    $display("Starting at %0t ns", $time);
    //MULT TEST 1
    //port inputs change at 885ns. internal (registered) input and internal output (not registered) changes at 890ns. port output (registered)
    //changes at 910ns
    data_rd = 8'b1011_1100;
    data_rr = 8'b1111_0101;
    //expected output is 1011_0011_1110_1100. co =1, zo = 0
    #30; //now at 915ns
    $display("MULT TEST 1:");
    if (data_o == 16'b1011_0011_1110_1100) begin
        $display("    output of MULT test 1 passed");
        if (zo == 1'b0)begin
            $display("    Zero flag is valid for MULT TEST 1");
        end else begin
            $display("    Zero flag is invalid for MULT TEST 1");
        end
        if (co == 1'b1) begin
            $display("    Carry flag is valid for MULT TEST 1");
        end else begin
            $display("    Carry flag is invalid for MULT TEST 1");
        end
    end else begin
        $display("INVALID OUTPUT FOR MULT TEST 1");
    end
    #10; //now at 925ns
    //MULT TEST 2
    //port inputs change at 925ns. internal (registered)input and internal output(not registered) changes at 930ns. port output(registered)
    //changes at 950ns
    data_rd = 8'b1011_0010;
    data_rr = 8'b0010_1110;
    //expected output is 0001_1111_1111_1100. co =0, zo = 0
    #30; //now at 955ns
    $display("MULT TEST 2:");
    if (data_o == 16'b0001_1111_1111_1100) begin
        $display("    output of MULT test 2 passed");
        if (zo == 1'b0)begin
            $display("    Zero flag is valid for MULT TEST 2");
        end else begin
            $display("    Zero flag is invalid for MULT TEST 2");
        end
        if (co == 1'b0) begin
            $display("    Carry flag is valid for MULT TEST 2");
        end else begin
            $display("    Carry flag is invalid for MULT TEST 2");
        end
    end else begin
        $display("INVALID OUTPUT FOR MULT TEST 2");
    end
    #10; //now at 965ns
    //MULT TEST 3
    //port inputs change at 965ns. internal (registered)input and internal output(not registered) changes at 970ns. port output(registered)
    //changes at 990ns
    data_rd = 8'b0000_1111;
    data_rr = 8'b1111_0000;
    //expected output is 0000_1110_0001_0000. co =0, zo = 0
    #30; //now at 995ns
    $display("MULT TEST 3:");
    if (data_o == 16'b0000_1110_0001_0000) begin
        $display("    output of MULT test 3 passed");
        if (zo == 1'b0)begin
            $display("    Zero flag is valid for MULT TEST 3");
        end else begin
            $display("    Zero flag is invalid for MULT TEST 3");
        end
        if (co == 1'b0) begin
            $display("    Carry flag is valid for MULT TEST 3");
        end else begin
            $display("    Carry flag is invalid for MULT TEST 3");
        end
    end else begin
        $display("INVALID OUTPUT FOR MULT TEST 3");
    end
    #10; //now at 1005ns
    //MULT TEST 4
    //port inputs change at 1005ns. internal (registered)input and internal output(not registered) changes at 1010ns. port output(registered)
    //changes at 1030ns
    data_rd = 8'b1111_1111;
    data_rr = 8'b1100_0000;
    //expected output is 1011_1111_0100_0000. co =1, zo = 0
    #30; //now at 1035ns
    $display("MULT TEST 4:");
    if (data_o == 16'b1011_1111_0100_0000) begin
        $display("    output of MULT test 4 passed");
        if (zo == 1'b0)begin
            $display("    Zero flag is valid for MULT TEST 4");
        end else begin
            $display("    Zero flag is invalid for MULT TEST 4");
        end
        if (co == 1'b1) begin
            $display("    Carry flag is valid for MULT TEST 4");
        end else begin
            $display("    Carry flag is invalid for MULT TEST 4");
        end
    end else begin
        $display("INVALID OUTPUT FOR MULT TEST 4");
    end
    #10; //now at 1045ns
    //MULT TEST 5
    //port inputs change at 1045ns. internal (registered)input and internal output(not registered) changes at 1050ns. port output(registered)
    //changes at 1070ns
    data_rd = 8'b1111_1111;
    data_rr = 8'b0000_0000;
    //expected output is 0000_0000_0000_0000. co =0, zo = 1
    #30; //now at 1075ns
    $display("MULT TEST 5:");
    if (data_o == 16'b0) begin
        $display("    output of MULT test 5 passed");
        if (zo == 1'b1)begin
            $display("    Zero flag is valid for MULT TEST 5");
        end else begin
            $display("    Zero flag is invalid for MULT TEST 5");
        end
        if (co == 1'b0) begin
            $display("    Carry flag is valid for MULT TEST 5");
        end else begin
            $display("    Carry flag is invalid for MULT TEST 5");
        end
    end else begin
        $display("INVALID OUTPUT FOR MULT TEST 5");
    end
    #10; //now at 1085ns
    
    
    //******************************TESTING LSL OPERATION***************************
    opcode = 8'b1000_1100;
    $display("***********************TESTING LSL OPERATION*****************");
    $display("Starting at %0t ns", $time);
    //LSL TEST 1
    //port inputs change at 1085ns. internal (registered) input and internal output (not registered) changes at 1090ns. port output (registered)
    //changes at 1110ns
    data_rd = 8'b1001_1110;
    //expected output is 0011_1100. co =1, zo=no= 0
    #30; //now at 1115ns
    $display("LSL TEST 1:");
    if (data_o == 16'b0000_0000_0011_1100) begin
        $display("    output of LSL test 1 passed");
        if (zo == 1'b0)begin
            $display("    Zero flag is valid for LSL TEST 1");
        end else begin
            $display("    Zero flag is invalid for LSL TEST 1");
        end
        if (co == 1'b1) begin
            $display("    Carry flag is valid for LSL TEST 1");
        end else begin
            $display("    Carry flag is invalid for LSL TEST 1");
        end
        if (no == 1'b0) begin
            $display("    Negative flag is valid for LSL TEST 1");
        end else begin
            $display("    Negative flag is invalid for LSL TEST 1");
        end
    end else begin
        $display("INVALID OUTPUT FOR LSL TEST 1");
    end
    #10; //now at 1125ns
    //LSL TEST 2
    //port inputs change at 1125ns. internal(registered) input and internal output(not registered) changes at 1130ns. port output(registered)
    //changes at 1150ns
    data_rd = 8'b0110_1010;
    //expected output is 1101_0100. no =1, co=Zo= 0
    #30; //now at 1155ns
    $display("LSL TEST 2:");
    if (data_o == 16'b0000_0000_1101_0100) begin
        $display("    output of LSL test 2 passed");
        if (zo == 1'b0)begin
            $display("    Zero flag is valid for LSL TEST 2");
        end else begin
            $display("    Zero flag is invalid for LSL TEST 2");
        end
        if (co == 1'b0) begin
            $display("    Carry flag is valid for LSL TEST 2");
        end else begin
            $display("    Carry flag is invalid for LSL TEST 2");
        end
        if (no == 1'b1) begin
            $display("    Negative flag is valid for LSL TEST 2");
        end else begin
            $display("    Negative flag is invalid for LSL TEST 2");
        end
    end else begin
        $display("INVALID OUTPUT FOR LSL TEST 2");
    end
    #10; //now at 1165ns
    //LSL TEST 3
    //port inputs change at 1165ns. internal(registered) input and internal output(not registered) changes at 1170ns. port output(registered)
    //changes at 1190ns
    data_rd = 8'b1000_0000;
    //expected output is 0000_0000. zo =1, co=1, no= 0
    #30; //now at 1195ns
    $display("LSL TEST 3:");
    if (data_o == 16'b0) begin
        $display("    output of LSL test 3 passed");
        if (zo == 1'b1)begin
            $display("    Zero flag is valid for LSL TEST 3");
        end else begin
            $display("    Zero flag is invalid for LSL TEST 3");
        end
        if (co == 1'b1) begin
            $display("    Carry flag is valid for LSL TEST 3");
        end else begin
            $display("    Carry flag is invalid for LSL TEST 3");
        end
        if (no == 1'b0) begin
            $display("    Negative flag is valid for LSL TEST 3");
        end else begin
            $display("    Negative flag is invalid for LSL TEST 3");
        end
    end else begin
        $display("INVALID OUTPUT FOR LSL TEST 3");
    end
    #10; //now at 1205ns
    //LSL TEST 4
    //port inputs change at 1205ns. internal(registered) input and internal output(not registered) changes at 1210ns. port output(registered)
    //changes at 1230ns
    data_rd = 8'b1101_0111;
    //expected output is 1010_1110. zo =0, co=1, no= 1
    #30; //now at 1235ns
    $display("LSL TEST 4:");
    if (data_o == 16'b0000_0000_1010_1110) begin
        $display("    output of LSL test 4 passed");
        if (zo == 1'b0)begin
            $display("    Zero flag is valid for LSL TEST 4");
        end else begin
            $display("    Zero flag is invalid for LSL TEST 4");
        end
        if (co == 1'b1) begin
            $display("    Carry flag is valid for LSL TEST 4");
        end else begin
            $display("    Carry flag is invalid for LSL TEST 4");
        end
        if (no == 1'b1) begin
            $display("    Negative flag is valid for LSL TEST 4");
        end else begin
            $display("    Negative flag is invalid for LSL TEST 4");
        end
    end else begin
        $display("INVALID OUTPUT FOR LSL TEST 4");
    end
    #10; //now at 1245ns
    
    
     //******************************TESTING ASR OPERATION***************************
    opcode = 8'b1000_1101;
    $display("***********************TESTING ASR OPERATION*****************");
    $display("Starting at %0t ns", $time);
    //ASR TEST 1
    //port inputs change at 1245ns. internal(registered) input and internal output(not registered) changes at 1250ns. port output(registered)
    //changes at 1270ns
    data_rd = 8'b1001_1110;
    //expected output is 1100_1111. no =1, zo=co= 0
    #30; //now at 1275ns
    $display("ASR TEST 1:");
    if (data_o == 16'b0000_0000_1100_1111) begin
        $display("    output of ASR test 1 passed");
        if (zo == 1'b0)begin
            $display("    Zero flag is valid for ASR TEST 1");
        end else begin
            $display("    Zero flag is invalid for ASR TEST 1");
        end
        if (co == 1'b0) begin
            $display("    Carry flag is valid for ASR TEST 1");
        end else begin
            $display("    Carry flag is invalid for ASR TEST 1");
        end
        if (no == 1'b1) begin
            $display("    Negative flag is valid for ASR TEST 1");
        end else begin
            $display("    Negative flag is invalid for ASR TEST 1");
        end
    end else begin
        $display("INVALID OUTPUT FOR ASR TEST 1");
    end
    #10; //now at 1285ns
    //ASR TEST 2
    //port inputs change at 1285ns. internal(registered) input and internal output(not registered) changes at 1290ns. port output(registered)
    //changes at 1310ns
    data_rd = 8'b0110_1010;
    //expected output is 0011_0101. no=co=Zo= 0
    #30; //now at 1315ns
    $display("ASR TEST 2:");
    if (data_o == 16'b0000_0000_0011_0101) begin
        $display("    output of ASR test 2 passed");
        if (zo == 1'b0)begin
            $display("    Zero flag is valid for ASR TEST 2");
        end else begin
            $display("    Zero flag is invalid for ASR TEST 2");
        end
        if (co == 1'b0) begin
            $display("    Carry flag is valid for ASR TEST 2");
        end else begin
            $display("    Carry flag is invalid for ASR TEST 2");
        end
        if (no == 1'b0) begin
            $display("    Negative flag is valid for ASR TEST 2");
        end else begin
            $display("    Negative flag is invalid for ASR TEST 2");
        end
    end else begin
        $display("INVALID OUTPUT FOR ASR TEST 2");
    end
    #10; //now at 1325ns
    //ASR TEST 3
    //port inputs change at 1325ns. internal(registered) input and internal output(not registered) changes at 1330ns. port output(registered)
    //changes at 1350ns
    data_rd = 8'b1000_0000;
    //expected output is 1100_0000. No =1, co=0, Zo= 0
    #30; //now at 1355ns
    $display("ASR TEST 3:");
    if (data_o == 16'b0000_0000_1100_0000) begin
        $display("    output of ASR test 3 passed");
        if (zo == 1'b0)begin
            $display("    Zero flag is valid for ASR TEST 3");
        end else begin
            $display("    Zero flag is invalid for ASR TEST 3");
        end
        if (co == 1'b0) begin
            $display("    Carry flag is valid for ASR TEST 3");
        end else begin
            $display("    Carry flag is invalid for ASR TEST 3");
        end
        if (no == 1'b1) begin
            $display("    Negative flag is valid for ASR TEST 3");
        end else begin
            $display("    Negative flag is invalid for ASR TEST 3");
        end
    end else begin
        $display("INVALID OUTPUT FOR ASR TEST 3");
    end
    #10; //now at 1365ns
    //ASR TEST 4
    //port inputs change at 1365ns. internal(registered) input and internal output(not registered) changes at 1370ns. port output(registered)
    //changes at 1390ns
    data_rd = 8'b1101_0111;
    //expected output is 1110_1011. zo =0, co=1, no= 1
    #30; //now at 1395ns
    $display("ASR TEST 4:");
    if (data_o == 16'b0000_0000_1110_1011) begin
        $display("    output of ASR test 4 passed");
        if (zo == 1'b0)begin
            $display("    Zero flag is valid for ASR TEST 4");
        end else begin
            $display("    Zero flag is invalid for ASR TEST 4");
        end
        if (co == 1'b1) begin
            $display("    Carry flag is valid for ASR TEST 4");
        end else begin
            $display("    Carry flag is invalid for ASR TEST 4");
        end
        if (no == 1'b1) begin
            $display("    Negative flag is valid for ASR TEST 4");
        end else begin
            $display("    Negative flag is invalid for ASR TEST 4");
        end
    end else begin
        $display("INVALID OUTPUT FOR ASR TEST 4");
    end
    #10; //now at 1405ns
    
    
    //******************************TESTING ROL OPERATION***************************
    opcode = 8'b1000_1110;
    ci = 1'b1; //can change this to see results for when ci equals one or zero
    $display("***********************TESTING ROL OPERATION*****************");
    $display("Starting at %0t ns", $time);
    //ROL TEST 1
    //port inputs change at 1405ns. internal(registered) input and internal output(not registered) changes at 1410ns. port output(registered)
    //changes at 1430ns
    data_rd = 8'b1011_1101;
    //expected output is 0111_101ci. co =1, zo=no= 0
    #30; //now at 1435ns
    $display("ROL TEST 1:");
    if (data_o == ((16'b0000_0000_0111_1010) + ci)) begin
        $display("    output of ROL test 1 passed");
        if (zo == 1'b0)begin
            $display("    Zero flag is valid for ROL TEST 1");
        end else begin
            $display("    Zero flag is invalid for ROL TEST 1");
        end
        if (co == 1'b1) begin
            $display("    Carry flag is valid for ROL TEST 1");
        end else begin
            $display("    Carry flag is invalid for ROL TEST 1");
        end
        if (no == 1'b0) begin
            $display("    Negative flag is valid for ROL TEST 1");
        end else begin
            $display("    Negative flag is invalid for ROL TEST 1");
        end
    end else begin
        $display("INVALID OUTPUT FOR ROL TEST 1");
    end
    #10; //now at 1445ns
    //ROL TEST 2
    //port inputs change at 1445ns. internal(registered) input and internal output(not registered) changes at 1450ns. port output(registered)
    //changes at 1470ns
    data_rd = 8'b1110_1000;
    //expected output is 1101_000ci. co =1, no= 1, zo= 0
    #30; //now at 1475ns
    $display("ROL TEST 2:");
    if (data_o == ((16'b0000_0000_1101_0000) + ci)) begin
        $display("    output of ROL test 2 passed");
        if (zo == 1'b0)begin
            $display("    Zero flag is valid for ROL TEST 2");
        end else begin
            $display("    Zero flag is invalid for ROL TEST 2");
        end
        if (co == 1'b1) begin
            $display("    Carry flag is valid for ROL TEST 2");
        end else begin
            $display("    Carry flag is invalid for ROL TEST 2");
        end
        if (no == 1'b1) begin
            $display("    Negative flag is valid for ROL TEST 2");
        end else begin
            $display("    Negative flag is invalid for ROL TEST 2");
        end
    end else begin
        $display("INVALID OUTPUT FOR ROL TEST 2");
    end
    #10; //now at 1485ns
    //ROL TEST 3
    //port inputs change at 1485ns. internal(registered) input and internal output(not registered) changes at 1490ns. port output(registered)
    //changes at 1510ns
    data_rd = 8'b0011_1110;
    //expected output is 0111_110ci. co =0, no= 0, zo= 0
    #30; //now at 1515ns
    $display("ROL TEST 3:");
    if (data_o == ((16'b0000_0000_0111_1100) + ci)) begin
        $display("    output of ROL test 2 passed");
        if (zo == 1'b0)begin
            $display("    Zero flag is valid for ROL TEST 3");
        end else begin
            $display("    Zero flag is invalid for ROL TEST 3");
        end
        if (co == 1'b0) begin
            $display("    Carry flag is valid for ROL TEST 3");
        end else begin
            $display("    Carry flag is invalid for ROL TEST 3");
        end
        if (no == 1'b0) begin
            $display("    Negative flag is valid for ROL TEST 3");
        end else begin
            $display("    Negative flag is invalid for ROL TEST 3");
        end
    end else begin
        $display("INVALID OUTPUT FOR ROL TEST 3");
    end
    #10; //now at 1525ns
    
    
    //******************************TESTING ROR OPERATION***************************
    opcode = 8'b1000_1111;
    ci = 1'b1; //can change this to see results for when ci equals one or zero
    $display("***********************TESTING ROR OPERATION*****************");
    $display("Starting at %0t ns", $time);
    //ROR TEST 1
    //port inputs change at 1525ns. internal(registered) input and internal output(not registered) changes at 1530ns. port output(registered)
    //changes at 1550ns
    data_rd = 8'b1011_1101;
    //expected output is ci101_1110. co =1, zo=0, no=ci
    #30; //now at 1555ns
    $display("ROR TEST 1:");
    if (data_o == {8'b0000_0000, ci, 7'b101_1110}) begin
        $display("    output of ROR test 1 passed");
        if (zo == 1'b0)begin
            $display("    Zero flag is valid for ROR TEST 1");
        end else begin
            $display("    Zero flag is invalid for ROR TEST 1");
        end
        if (co == 1'b1) begin
            $display("    Carry flag is valid for ROR TEST 1");
        end else begin
            $display("    Carry flag is invalid for ROR TEST 1");
        end
        if (no == ci) begin
            $display("    Negative flag is valid for ROR TEST 1");
        end else begin
            $display("    Negative flag is invalid for ROR TEST 1");
        end
    end else begin
        $display("INVALID OUTPUT FOR ROR TEST 1");
    end
    #10; //now at 1565ns
    //ROR TEST 2
    //port inputs change at 1565ns. internal(registered) input and internal output(not registered) changes at 1570ns. port output(registered)
    //changes at 1590ns
    data_rd = 8'b1110_1000;
    //expected output is ci111_0100 no = ci, zo=co=0
    #30; //now at 1595ns
    $display("ROR TEST 2:");
    if (data_o == {8'b0000_0000, ci, 7'b111_0100}) begin
        $display("    output of ROR test 2 passed");
        if (zo == 1'b0)begin
            $display("    Zero flag is valid for ROR TEST 2");
        end else begin
            $display("    Zero flag is invalid for ROR TEST 2");
        end
        if (co == 1'b0) begin
            $display("    Carry flag is valid for ROR TEST 2");
        end else begin
            $display("    Carry flag is invalid for ROR TEST 2");
        end
        if (no == ci) begin
            $display("    Negative flag is valid for ROR TEST 2");
        end else begin
            $display("    Negative flag is invalid for ROR TEST 2");
        end
    end else begin
        $display("INVALID OUTPUT FOR ROR TEST 2");
    end
    #10; //now at 1605ns
    //ROR TEST 3
    //port inputs change at 1605ns. internal(registered) input and internal output(not registered) changes at 1610ns. port output(registered)
    //changes at 1630ns
    data_rd = 8'b0011_1110;
    //expected output is ci001_1111. no=ci, zo=0, co=0
    #30; //now at 1635ns
    $display("ROR TEST 3:");
    if (data_o == {8'b0000_0000, ci, 7'b001_1111}) begin
        $display("    output of ROR test 3 passed");
        if (zo == 1'b0)begin
            $display("    Zero flag is valid for ROR TEST 3");
        end else begin
            $display("    Zero flag is invalid for ROR TEST 3");
        end
        if (co == 1'b0) begin
            $display("    Carry flag is valid for ROR TEST 3");
        end else begin
            $display("    Carry flag is invalid for ROR TEST 3");
        end
        if (no == ci) begin
            $display("    Negative flag is valid for ROR TEST 3");
        end else begin
            $display("    Negative flag is invalid for ROR TEST 3");
        end
    end else begin
        $display("INVALID OUTPUT FOR ROR TEST 3");
    end
    #10; //now at 1645ns
    
    
    //******************************TESTING XOR OPERATION***************************
    opcode = 8'b0010_1101;
    $display("***********************TESTING ASR OPERATION*****************");
    $display("Starting at %0t ns", $time);
    //XOR TEST 1
    //port inputs change at 1645ns. internal(registered) input and internal output(not registered) changes at 1650ns. port output(registered)
    //changes at 1670ns
    data_rd = 8'b1111_0011;
    data_rr = 8'b0110_1101;
    //expected output is 1001_1110. no =1, zo=0
    #30; //now at 1675ns
    $display("XOR TEST 1:");
    if (data_o == 16'b0000_0000_1001_1110) begin
        $display("    output of XOR test 1 passed");
        if (zo == 1'b0)begin
            $display("    Zero flag is valid for XOR TEST 1");
        end else begin
            $display("    Zero flag is invalid for XOR TEST 1");
        end
        if (no == 1'b1) begin
            $display("    Negative flag is valid for XOR TEST 1");
        end else begin
            $display("    Negative flag is invalid for XOR TEST 1");
        end
    end else begin
        $display("INVALID OUTPUT FOR XOR TEST 1");
    end
    #10; //now at 1685ns
    //XOR TEST 2
    //port inputs change at 1685ns. internal(registered) input and internal output(not registered) changes at 1690ns. port output(registered)
    //changes at 1710ns
    data_rd = 8'b1101_1001;
    data_rr = 8'b1111_1010;
    //expected output is 0010_0011. no =0, zo= 0
    #30; //now at 1715ns
    $display("XOR TEST 2:");
    if (data_o == 16'b0000_0000_1001_1110) begin
        $display("    output of XOR test 2 passed");
        if (zo == 1'b0)begin
            $display("    Zero flag is valid for XOR TEST 2");
        end else begin
            $display("    Zero flag is invalid for XOR TEST 2");
        end
        if (no == 1'b0) begin
            $display("    Negative flag is valid for XOR TEST 2");
        end else begin
            $display("    Negative flag is invalid for XOR TEST 2");
        end
    end else begin
        $display("INVALID OUTPUT FOR XOR TEST 2");
    end
    #10; //now at 1725ns
    
    
    //******************************TESTING NEG OPERATION(2's complement)***************************
    opcode = 8'b1001_1100;
    $display("***********************TESTING NEG OPERATION(2's complement)*****************");
    $display("Starting at %0t ns", $time);
    //NEG TEST 1
    //port inputs change at 1725ns. internal(registered) input and internal output(not registered) changes at 1730ns. port output(registered)
    //changes at 1750ns
    data_rd = 8'b1110_1101;
    //expected output is 0001_0011. no =0, zo=co= 0
    #30; //now at 1755ns
    $display("NEG TEST 1:");
    if (data_o == 16'b0000_0000_0001_0011) begin
        $display("    output of NEG test 1 passed");
        if (zo == 1'b0)begin
            $display("    Zero flag is valid for NEG TEST 1");
        end else begin
            $display("    Zero flag is invalid for NEG TEST 1");
        end
        if (co == 1'b0) begin
            $display("    Carry flag is valid for NEG TEST 1");
        end else begin
            $display("    Carry flag is invalid for NEG TEST 1");
        end
        if (no == 1'b0) begin
            $display("    Negative flag is valid for NEG TEST 1");
        end else begin
            $display("    Negative flag is invalid for NEG TEST 1");
        end
    end else begin
        $display("INVALID OUTPUT FOR NEG TEST 1");
    end
    #10; //now at 1765ns
    //NEG TEST 2
    //port inputs change at 1765ns. internal(registered) input and internal output(not registered) changes at 1770ns. port output(registered)
    //changes at 1790ns
    data_rd = 8'b0000_0001;
    //expected output is 1111_1111. no =1, zo=co= 0
    #30; //now at 1795ns
    $display("NEG TEST 2:");
    if (data_o == 16'b0000_0000_1111_1111) begin
        $display("    output of NEG test 2 passed");
        if (zo == 1'b0)begin
            $display("    Zero flag is valid for NEG TEST 2");
        end else begin
            $display("    Zero flag is invalid for NEG TEST 2");
        end
        if (co == 1'b0) begin
            $display("    Carry flag is valid for NEG TEST 2");
        end else begin
            $display("    Carry flag is invalid for NEG TEST 2");
        end
        if (no == 1'b1) begin
            $display("    Negative flag is valid for NEG TEST 2");
        end else begin
            $display("    Negative flag is invalid for NEG TEST 2");
        end
    end else begin
        $display("INVALID OUTPUT FOR NEG TEST 2");
    end
    #10; //now at 1805ns
    //NEG TEST 3
    //port inputs change at 1805ns. internal(registered) input and internal output(not registered) changes at 1810ns. port output(registered)
    //changes at 1830ns
    data_rd = 8'b0000_0000;
    //expected output is 0000_0000. no =0, zo=1, co= 1
    #30; //now at 1835ns
    $display("NEG TEST 3:");
    if (data_o == 16'b0000_0000_0000_0000) begin
        $display("    output of NEG test 3 passed");
        if (zo == 1'b1)begin
            $display("    Zero flag is valid for NEG TEST 3");
        end else begin
            $display("    Zero flag is invalid for NEG TEST 3");
        end
        if (co == 1'b1) begin
            $display("    Carry flag is valid for NEG TEST 3");
        end else begin
            $display("    Carry flag is invalid for NEG TEST 3");
        end
        if (no == 1'b0) begin
            $display("    Negative flag is valid for NEG TEST 3");
        end else begin
            $display("    Negative flag is invalid for NEG TEST 3");
        end
    end else begin
        $display("INVALID OUTPUT FOR NEG TEST 3");
    end
    #10; //now at 1845ns
    
    //***************END OF SIMULATION*******************
    $stop;
    end


endmodule
