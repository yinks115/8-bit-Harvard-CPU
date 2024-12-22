`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/07/2024 04:27:56 PM
// Design Name: 
// Module Name: cpu_tb
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


module cpu_tb();
    //signals for testing
    logic t1=0; logic t2=0; logic t3=1; logic results=0;
    /*
    t1, t2, and t3 correspond to the different coe files we put inside our instruction memory
    NOTE: if t1 is enabled the .coe file in the instruction memory should be test 1
          if t2 is enabled the .coe file in the instruction memory should be test 2
          if t3 is enabled the .coe file in the instruction memory should be test 3
    ************T1 Assembly code equivalent************
    ld R0, x34;
    ld R1, x48;
    ld R3, x01;
    Add R0, R1;
    WR R0, R3;
    WRIO R3;
    At the end of the sequence the value inside the R0 register should be x7C
    a ld command should take a total of 11 posedges, Add takes 6 posedges, WR takes 5 and wrio takes 6 posedge
    in total it should take 50 posedges for io reg to have correct value.
    
    **************T2 Assembly Code***************
    ld R0, x64;
    ld R1, x25;
    ld R2, x2D;
    ld R3, x00;
    Add R1, R2;
    WR R1, R3;
    Sub R0, R1;
    ld R3, x01;
    Wr R0, R3;
    OR R2, R1;
    ld R3, x02;
    Wr R2, R3;
    Neg R0;
    ld R3, x03;
    Wr R0, R3
    JMPN CONT;
    Brk;
    
    CONT:
        Wrio R3;
        NOOP
        
     At the end of this code the IO register will store the value xEE, R0 = xEE, R1 = x52, R2 = x7F, and R3 = x03
     The values x52, x12, x7F, and xEE are in address 0, 1, 2, and 3 of the data memory
    */
    
    
    //signals for instantiation
    logic clk = 0; logic rst = 0;
    logic led_driver_flag; logic rd_addr_flag;
    logic carry_in; logic [7:0] rd_addr;
    logic [7:0] led_driver;
    
    //module to be tested
    cpu_wrapper dut(
        .clk(clk), .rst(rst), .carry_in(carry_in),
        .led_driver_flag(led_driver_flag), .rd_addr_flag(rd_addr_flag),
        .rd_addr(rd_addr),
        
        .led_driver(led_driver)
    );
    
    //task for checking address of data memory
    task check_addr(
        input [7:0] addr, input [7:0] expected_val, output result
    );
        //this task should be called once the cpu has executed all instructions
        
        //enables the flag to give reading access to the rd_addr port
        //and flag to connect dmem output to led_driver bus
        rd_addr_flag = 1'b1;
        led_driver_flag = 1'b0;
        rd_addr = addr;
        
        //waits 2 posedge for dmem to output correct value
        repeat (2) @(posedge clk); #5
        
        if (led_driver == expected_val) begin
//            $display("Time=%t: Correct value of %h in address %h", $time, expected_val, addr);
            result = 1'b1; //true
        end else begin
//            $display("Time=%t: Inorrect value in address %h", $time, addr);       
            result = 1'b0; //false
        end
        
        #2;
        rd_addr_flag = 1'b0;
        
    endtask
    
    //clock generation
    initial begin
        forever #10ns clk = !clk;
    end
    
    //initializing input ports
    initial begin
        led_driver_flag = 0; rd_addr_flag = 0; carry_in =0;
        rd_addr = 8'b0;
        
        //asserting reset signal
        rst = 1;
        #15
        rst = 0;   
    end
    
    initial begin
        if (t1)begin
            $display("**********************************************TEST 3***********************************************");        
            repeat (70) @(posedge clk);
            led_driver_flag = 1'b1; //connects io reg output to led_driver signal
            #5;//not neccessary to be honest
            if (led_driver == 8'h7C) begin
                $display("Time=%t: Correct Value in IO Register!!!", $time);
            end else begin 
                $display("Time=%t: TEST FAILED. Value in IO Register is %h", $time, led_driver);
            end
            
            //in test1 we only write to address 1 of the data memory. The expected value is x7C
            check_addr(.addr(8'h01), .expected_val(8'h7C), .result(results));
            if (results) begin
                $display("Time=%t: Correct value of %h in address %h", $time, 8'h7C, rd_addr);
            end else begin
                $display("Time=%t: Inorrect value in address %h", $time, rd_addr);       
            end
        end else if (t2) begin
            $display("**********************************************TEST 2***********************************************");        
            repeat (200) @(posedge clk);
            led_driver_flag = 1'b1; //connects io reg output to led_driver signal
            #5;//not neccessary to be honest
            if (led_driver == 8'hEE) begin
                $display("Time=%t: Correct Value in IO Register!!!", $time);
            end else begin 
                $display("Time=%t: TEST FAILED. Value in IO Register is %h", $time, led_driver);
            end
            
            //After test2 executes The values x52, x12, x7F, and xEE are in address 0, 1, 2, and 3 of the data memory
            check_addr(.addr(8'h00), .expected_val(8'h52), .result(results));
            if (results) begin
                $display("Time=%t: Correct value of %h in address %h", $time, 8'h52, rd_addr);
            end else begin
                $display("Time=%t: Inorrect value in address %h", $time, rd_addr);       
            end
            #5;
            
            check_addr(.addr(8'h01), .expected_val(8'h12), .result(results));
            if (results) begin
                $display("Time=%t: Correct value of %h in address %h", $time, 8'h12, rd_addr);
            end else begin
                $display("Time=%t: Inorrect value in address %h", $time, rd_addr);       
            end
            #5;
            
            check_addr(.addr(8'h02), .expected_val(8'h7F), .result(results));
            if (results) begin
                $display("Time=%t: Correct value of %h in address %h", $time, 8'h7F, rd_addr);
            end else begin
                $display("Time=%t: Inorrect value in address %h", $time, rd_addr);       
            end
            #5;
            
            check_addr(.addr(8'h03), .expected_val(8'hEE), .result(results));
            if (results) begin
                $display("Time=%t: Correct value of %h in address %h", $time, 8'hEE, rd_addr);
            end else begin
                $display("Time=%t: Inorrect value in address %h", $time, rd_addr);       
            end
            #5;
        end else if (t3) begin
            $display("**********************************************TEST 3***********************************************");
            repeat (230) @(posedge clk);
            led_driver_flag = 1'b1; //connects io reg output to led_driver signal
            #5;//not neccessary to be honest
            if (led_driver == 8'hA5) begin
                $display("Time=%t: Correct Value in IO Register!!!", $time);
            end else begin 
                $display("Time=%t: TEST FAILED. Value in IO Register is %h", $time, led_driver);
            end
            
            //After test3 executes The values xFF, x0E, x02, and xFF are in registers 0, 1, 2, and 3 of the register file
            //The values xA5, xFF, x0E, and xFF are in address 1, 2, FF, and 0E of the data memory
            check_addr(.addr(8'h01), .expected_val(8'hA5), .result(results));
            if (results) begin
                $display("Time=%t: Correct value of %h in address %h", $time, 8'hA5, rd_addr);
            end else begin
                $display("Time=%t: Inorrect value in address %h", $time, rd_addr);       
            end
            #5;
            
            check_addr(.addr(8'h02), .expected_val(8'hFF), .result(results));
            if (results) begin
                $display("Time=%t: Correct value of %h in address %h", $time, 8'hFF, rd_addr);
            end else begin
                $display("Time=%t: Inorrect value in address %h", $time, rd_addr);       
            end
            #5;
            
            check_addr(.addr(8'h0E), .expected_val(8'hFF), .result(results));
            if (results) begin
                $display("Time=%t: Correct value of %h in address %h", $time, 8'hFF, rd_addr);
            end else begin
                $display("Time=%t: Inorrect value in address %h", $time, rd_addr);       
            end
            #5;
            
            check_addr(.addr(8'hFF), .expected_val(8'h0E), .result(results));
            if (results) begin
                $display("Time=%t: Correct value of %h in address %h", $time, 8'h0E, rd_addr);
            end else begin
                $display("Time=%t: Inorrect value in address %h", $time, rd_addr);       
            end
            #5;
        
        
        end
    end

endmodule
