`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Yinka Kolawole
// 
// Create Date: 12/05/2024 03:14:05 PM
// Design Name: 
// Module Name: control_logic
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
///////////////////////////////////////////////////////////////////////////////////


module control_logic(
    input clk, input rst,
    input zo_flag, input co_flag,
    input no_flag, input logic [7:0] instruction,

    output logic [1:0] select, //will be our select signal to determine what's driving wr_data port of reg file
    
    output logic wr_en_regFile, output logic wr_en_dmem, output logic wr_en_io,
    output logic inc_en, output logic jmp_en, output logic call_en, output logic ret_en, //signals for program counter
    output logic use_strd_addr, //flag that determines if we're going to select reg file addr based on opcode[3:2] or wr_addr
    
    output logic [1:0] wr_addr, //need to store what address we're writing to in reg file during a ld command
    output logic [7:0] opcode //just a registered version of instruction signal
);
    
    //****************creating signals for internal registers/signals**********************
    
    //registers to hold the value of the flags. We only want them to change when we're doing an alu operation but the alu is
    //always working so the flags may be overwritten even if we were performing another instruction like load for example. By
    //registering them we can use one of our states in the alu command sequence as an enable. thus the flags can only change when we're
    //performing an alu operation
    logic no_q; logic no_d;
    logic co_q; logic co_d;
    logic zo_q; logic zo_d;
    logic alu_op_q; logic alu_op_d; //flag that lets us know that we're doing an alu operation
    
    logic [1:0] c_flow_reg_q; logic [1:0] c_flow_reg_d; //11 for jmp/jmpc, 01 for call, and 10 for ret
    logic wr_en_rf_q; logic wr_en_rf_d; 
    logic wr_en_dmem_q; logic wr_en_dmem_d;
    logic wr_en_io_q; logic wr_en_io_d;
    //since inc, jmp, call, and ret are registered we need to wait an additional posedge for the pc to increment
    //2 posedges in total. This also means that reading a new instruction takes 5 posedge in total
    //(2 posedge for pc, 2 for reading from instruction mem, and 1 for instruction to be stored in opcode_reg)
    logic inc_en_q; logic inc_en_d;
    logic jmp_en_q; logic jmp_en_d;
    logic call_en_q; logic call_en_d;
    logic ret_en_q; logic ret_en_d;
    
    logic [1:0] wr_addr_d; logic [1:0] wr_addr_q;
    logic use_strd_addr_d; logic use_strd_addr_q;
    logic [7:0] opcode_reg_q; logic [7:0] opcode_reg_d;
    
    //decode(000), wait(001), set_up_regFile_alu(010), set_up_regFile(011), write_back(100)
    //write(101), writeIO(110), control_flow(111)
    logic [2:0] state_reg_q; logic [2:0] state_reg_d;
    
    //syntax is driver(select_val) -> alu(00), data_mem(01), control_logic(10)
    logic [1:0] select_q; logic [1:0] select_d;
    
    //signal for the down counter used by the wait state
    logic [1:0] down_count_q; logic [1:0] down_count_d;
    //logic down_count_en;
    //*******************************************************************************
    
    //creating our state signals. setup1 is set_up_regFile_alu and setup2 is set_up_regFile
    enum {clear, reset, decode, wait_state, setup1, setup2, write_back, write, writeIO, control_flow}curr_state, next_state;
    
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            no_q <= 0; zo_q <= 0; co_q <= 0; alu_op_q <=0;
            select_q <= 2'b0;
            c_flow_reg_q <= 0;
            state_reg_q <= 3'b0; down_count_q <=2'b0;
            opcode_reg_q <= 8'b0; wr_addr_q <= 0;
            use_strd_addr_q <= 0;
            wr_en_rf_q <= 0; wr_en_io_q <= 0;
            wr_en_dmem_q <= 0;
            inc_en_q <= 0; jmp_en_q <= 0;
            call_en_q <= 0; ret_en_q <= 0;
            curr_state <= reset; //this state will set some flags to 0 then go to dcode state
        end else begin
            no_q <= no_d; zo_q <= zo_d; co_q <= co_d; alu_op_q <= alu_op_d;
            select_q <= select_d;
            c_flow_reg_q <= c_flow_reg_d;
            state_reg_q <= state_reg_d; down_count_q <= down_count_d;
            opcode_reg_q <= opcode_reg_d; wr_addr_q <= wr_addr_d;
            use_strd_addr_q <= use_strd_addr_d;
            curr_state <= next_state; 
            wr_en_rf_q <= wr_en_rf_d; wr_en_io_q <= wr_en_io_d;
            wr_en_dmem_q <= wr_en_dmem_d;
            inc_en_q <= inc_en_d; jmp_en_q <= jmp_en_d;
            call_en_q <= call_en_d; ret_en_q <= ret_en_d;
        end
    end
    
    //procedural block for signals that the state machine doesn't alter
    always_comb begin
        opcode = opcode_reg_q;
        wr_addr = wr_addr_q;
        use_strd_addr = use_strd_addr_q;
        //select_disp = select_disp_q;
        select = select_q;
        opcode_reg_d = instruction;
        wr_en_regFile = wr_en_rf_q;
        wr_en_io = wr_en_io_q; wr_en_dmem = wr_en_dmem_q;
        inc_en = inc_en_q; jmp_en = jmp_en_q;
        call_en = call_en_q; ret_en = ret_en_q;
    end
    
    //***********State Machine*******
    always_comb begin
        //preventing latches (hopefully)
        alu_op_d = alu_op_q;
        if (alu_op_q) begin
            no_d = no_flag; co_d = co_flag; zo_d = zo_flag;
        end else begin
            no_d = no_q; co_d = co_q; zo_d = zo_q; 
        end
        use_strd_addr_d = use_strd_addr_q;//this signal is meant to be used by ld command
        wr_addr_d = wr_addr_q;
        down_count_d = down_count_q;
        state_reg_d = state_reg_q;
        c_flow_reg_d = c_flow_reg_q;
        //select_disp_d = select_disp_q;
        select_d = select_q;
        wr_en_rf_d = wr_en_rf_q;
        wr_en_dmem_d = wr_en_dmem_q; wr_en_io_d = wr_en_io_q;
        inc_en_d = inc_en_q; jmp_en_d = jmp_en_q; call_en_d = call_en_q;
        ret_en_d = ret_en_q;
    
        case (curr_state)
    
            reset: 
                begin
                    //down_count_en = 0;
                    
                    //the posedge after rst goes low opcode_reg_q still holds a value of x00 so we need to wait until the next posedge
                    //before going to our decode state
                    next_state = wait_state;
                    state_reg_d = 3'b000;
                end
                
            clear:
                begin
                //turning off enable signals that may have been set by the other states
                    wr_en_rf_d = 0; wr_en_dmem_d = 0;
                    wr_en_io_d = 0; //down_count_en = 0;
                    c_flow_reg_d = 2'b0; alu_op_d = 0;
                    
                    next_state = decode;
                end
                
            decode: 
                begin
                    //need to check if we're performing a write, writeIO, Load, Read, jmp/jmpc, call,
                    //return, or alu operation
                    casez (opcode_reg_q)
                    
                        8'b1001??11: begin //LD command
                            inc_en_d = 1; //increments the pc
//                            down_count_en = 0; //this signal isn't registered so it always needs to be driven in all scenarios
                            
                            //we need to set up the reg file so that the wr_data port is driven by opcode_reg_q
                            //the core states we need to go to are the setup_regFile (setup2) and write_back state
                            //we need to wait 5 posedge to read the next instruction which contains our load value, k.
                            //2 posedge for correct pc output, 2 posedge for correct instruction mem output, and 1 posedge
                            //for instruction to be stored in opcode_reg_q
                            
                            //by the time we reach the write back state k should already be in the opcode_reg_q
                            
                            //LD command sequence
                            //we go from here to setup2, then to the wait state, we stay at the wait state for 2 posedges,
                            //then go to write_back. we reach write_back on the 5th edge (might want to stay at wait state for 3
                            //posedge incase there are timing issues)
                            next_state = setup2;
                            select_d = 2'b10; //connects opcode_q to wr_data port of reg file. need to set this for setup2 state
                            
                            //this needs to be here because when k is placed into opcode_reg_q we no longer know what reg
                            //in the reg file should hold k
                            wr_addr_d = opcode_reg_q[3:2];
                        end
                        
                        8'b1010????: begin //write command
                            inc_en_d = 1;
//                            down_count_en = 0;
                            
                            //it takes 1 posedge for reg file output, 2 posedge to write to the dmem
                            /*Write command sequence
                            1. go from here to write state (1 posedge)
                            2. from write go to wait, then clear, then decode (4 posedge)
                            NOTE: we stay at wait for 1 posedge because we want the total instruction to take 5 posedge
                            or more. because it takes 5 posedge to read the next instruction
                            */
                            wr_en_dmem_d = 1; //dmem enable will be high when we get to write state
                            next_state = write;
                        end
                        
                        8'b1011????: begin //RD command
                            inc_en_d = 1; //increments the pc
//                            down_count_en = 0;
                            
                            //it takes 1 posedge for reg file to output correct value. 2 posedge to read from data mem
                            // and 2 posedge to write to reg file
                            /*Read command sequence
                            1. go to setup2 from here (1 posedge)
                            2. from set up go to wait (1 posedge)
                            3. from wait go to write back (1 posedge). dmem should have correct output when we get to write back
                            4. from write back go to wait then clear then decode (3 posedge)
                            */
                            
                            next_state = setup2;
                            select_d = 2'b01; //connects output of data memory to wr_data port of reg file
                        end
                        
                        8'b11000000: begin //jmp command
                            //need to wait 5 posedges to get k
                            
                            /*Sequence
                             1. from here go to wait (1 posedge)
                             2. stay at wait for (3 posedge)
                             3. from wait go to c_flow (1 posedge). k should be in op_reg by now
                             4. from c_flow go to wait (1 posedge)
                             5. stay at wait for 2 posedge
                             6. from wait go to clear then decode (2 posedge)
                             */
                             
                             //before leaving the wait state i need to set the jmp enable
                             inc_en_d = 1;
                             c_flow_reg_d = 2'b11;//signal for jump. used by c_flow_state
//                             down_count_en = 1;
                             down_count_d = 2'b11;
                             state_reg_d = 3'b111;//signal for c flow state
                             next_state = wait_state;
                        end
                        
                        8'b11001???: begin //jmpc command
                            
                                //it takes 5 posedge for k to get into the opcode_reg. after loading the pc to the new count
                                //we need to wait another 5 posedge for the new instruction to be inside of opcode_reg
                                
                                /*Sequence
                                1. from here go to wait (1 posedge)
                                2. stay at wait for (3 posedge)
                                3. from wait go to c_flow (1 posedge). k should be in op_reg by now
                                4. from c_flow go to wait (1 posedge)
                                5. stay at wait for 2 posedge
                                6. from wait go to clear then decode (2 posedge)
                                */
                                
                            //need to check the alu flags and if we're doing a JMPC, JMPZ, or JMPN
                            //else we just increase the program counter and wait 5 posedges for next instruction
                            if (zo_q & opcode_reg_q[1]) begin //jmpz
                                inc_en_d = 1;
                                c_flow_reg_d = 2'b11;//signal for jump. used by c_flow_state
//                                down_count_en = 1;
                                down_count_d = 2'b11;
                                state_reg_d = 3'b111;//signal for c flow state
                                next_state = wait_state;
                            end else if (co_q & opcode_reg_q[2]) begin //jmpc
                                inc_en_d = 1;
                                c_flow_reg_d = 2'b11;//signal for jump. used by c_flow_state
//                                down_count_en = 1;
                                down_count_d = 2'b11;
                                state_reg_d = 3'b111;//signal for c flow state
                                next_state = wait_state;
                            end else if (no_q & opcode_reg_q[0]) begin //jmpn
                                inc_en_d = 1;
                                c_flow_reg_d = 2'b11;//signal for jump. used by c_flow_state
//                                down_count_en = 1;
                                down_count_d = 2'b11;
                                state_reg_d = 3'b111;//signal for c flow state
                                next_state = wait_state;
                            end else begin
                                //goes to the next instruction
                                inc_en_d = 1; //wait state will be responsible for turning this off
                                down_count_d = 2'b11; //need to stay in wait state for 3 posedges
//                                down_count_en = 1; //wait state is responsible for turning this off
                                state_reg_d = 3'b000; //value for decode state
                                next_state = wait_state;
                            end
                            
                        end
                        
                        8'b11010000: begin //call command
                            //need to wait 5 posedges to get k
                            
                            /*Sequence
                             1. from here go to wait (1 posedge)
                             2. stay at wait for (3 posedge)
                             3. from wait go to c_flow (1 posedge). k should be in op_reg by now
                             4. from c_flow go to wait (1 posedge)
                             5. stay at wait for 2 posedge
                             6. from wait go to clear then decode (2 posedge)
                             */
                             
                             //before leaving the wait state i need to set the call enable
                             inc_en_d = 1;
                             c_flow_reg_d = 2'b01;//signal for call. used by c_flow_state
//                             down_count_en = 1;
                             down_count_d = 2'b11;
                             state_reg_d = 3'b111;//signal for c flow state
                             next_state = wait_state;
                            
                        end
                        
                        8'b11011000: begin //ret command
                        
                            //we don't need to wait 5 posedges here. we go straight to the c flow state
                            c_flow_reg_d = 2'b10; //signal for return
                            ret_en_d = 1; //
                            next_state = control_flow;
                        
                        end
                        
                        8'b111000??: begin //wrIO command
                            inc_en_d = 1;
//                            down_count_en = 0;
                            
                            //need to wait 1 posedge for reg file. 2 posedge to read from dmem. and 2 posedge
                            //to write to io register
                            
                            /*WriteIO command sequence
                            1. from here go to setup2 (1 posedge)
                            2. from setup2 go to wait state (1 posedge)
                            3. from wait state go to wrio state (1 posedge). dmem will have correct output when we arrive
                            4. from wrio go to wait, then clear, then decode
                            */
                            
                            next_state = setup2;
                        end
                        
                        8'b11110000: begin //NOOP command
                            /*we're going to increment the program count.
                            after getting the next instruction we go back to the decode state.
                            reading the next instruction takes 5 posedges (1 posedge to enable increment flag
                            , 1 posedge for program counter to increment its count, 2 posedge for instruction
                            memory to output new instruction, 1 posedge for new instruction to be in the opcode_reg_q
                            register.
                            Note that going from one state to the other takes a posedge
                            */
                            inc_en_d = 1; //wait state will be responsible for turning this off
                            down_count_d = 2'b11; //need to stay in wait state for 3 posedges
//                            down_count_en = 1; //wait state is responsible for turning this off
                            state_reg_d = 3'b000; //value for decode state
                            next_state = wait_state;
                        end
                        
                        8'b11111111: begin //BRK command
                            //for this command we simply stay in place (ie we don't increase the PC)
                            inc_en_d = 0;
//                            down_count_en = 0;
                            next_state = curr_state; //stays at decode
                        end
                        
                        //any other opcode value is assumed to be an alu instruction
                        default: begin
                            //mult operation is not supported in this current implementation. The remaining 12 alu operations are
                            inc_en_d = 1; //increments the pc
                            next_state = setup1; //sets up the reg file for the alu
                            //bits [3:2] and bits [1:0] of opcode are always driving the wr_addr, rd_addr and rr_addr ports of the 
                            //reg file (takes 1 posedge for reg file to output correct values) so we can assume that the correct
                            //values are fed into the reg fle
                            
                             
                            //down_count_en = 0;//this signal needs to be driven by a value in all possible scenarios since it isn't registered
                        end
                    
                    endcase
                end
                
            wait_state: 
                begin
                    //if we're coming to this state after the decode state we need to turn off the increment enable
                    inc_en_d = 0;
                    //checks if we're using the count down timer
                    if (down_count_q != 2'b0) begin
                        down_count_d = down_count_q - 1;
                        next_state = wait_state;
//                        down_count_en = 1;
                    end else begin
//                        down_count_en = 0; //this is for when our count ends
//                        down_count_d = 2'b0;//safety precaution incase we're in a situation where enable is low but count has a value
                        
                        //figuring out the next state
                        case (state_reg_q)
                            3'b000: begin //decode state
                                next_state = clear; //we clear all our external enable signals before going back to decode
                            end
                            
                            3'b001: begin //should never occur base on my implementation but not taking chances
                                next_state = wait_state;
                            end
                            
                            3'b010: begin
                                next_state = setup1; //not used
                            end
                            
                            3'b011: begin //not used
                                next_state = setup2;
                            end
                            
                            3'b100: begin
                                next_state = write_back;
                                wr_en_rf_d = 1; //when we enter the wr_back state wr_en_rf_q will be 1
                            end
                            
                            3'b101: begin
                                next_state = write;
                            end
                            
                            3'b110: begin
                                wr_en_io_d = 1; //signal will be high on the next posedge which is when we arrive at wrio state
                                next_state = writeIO;
                            end
                            
                            3'b111: begin
                                case (c_flow_reg_q)
                                    2'b11: begin
                                        //means we're performing a jmp/jmpc
                                        jmp_en_d = 1;
                                    end
                                    
                                    2'b01: begin
                                        //call
                                        call_en_d = 1;
                                    end
                                    
//                                    2'b10: begin
//                                        //return
//                                        ret_en_d = 1;
//                                    end
                                    
                                endcase
                                next_state = control_flow;
                            end
                            
                            default: begin
                                //should never be here
                                //might put an error flag if i need to debug
                                next_state = clear;
                            end
                        endcase
                    end
                    
                end
                
            setup1: 
                begin
                    //need to turn off pc increment enable
                    inc_en_d = 0;
                    select_d = 2'b00; //connecting alu output bus to wr_data port of reg file 

                    /*The entire alu instruction will take 5 posedge to complete
                     1 posedge for reg file to output correct rd and rr values (this should already be done since
                     it takes 1 posedge to go from alu state to the setup1 state)
                     2 posedge for alu to output correct result
                     2 posedge to write results to reg file        
                    */
                    
                    //we go to the wait state then from wait state we go to write back state.
                    //by the time we reach write back state alu should have correct output (and flags).
                    //when we're going to the write back state we want to enable our co, no, and zo registers
                    alu_op_d = 1'b1;
                    state_reg_d = 3'b100; //value for write_back state
                    next_state = wait_state;
//                    down_count_en = 0;
                    
                end
            
            setup2: 
                begin
                    inc_en_d = 0;
                    if (opcode_reg_q[7:2] == 6'b111000) begin //this is for when we're performing a wrio command
                        //when we get here reg file should have correct output value
                        //we need to wait 2 posedge to read correct value from dmem
                        
                        next_state = wait_state;
                        state_reg_d = 3'b110; //wrio state
//                        down_count_en = 0;
                    end else begin
                        //we need to check what's driving the wr_data port of the reg file
                        case (select_q)
                            2'b01: begin //driver is data memory. we're performing a read command
                                //when we're here the reg file has the correct output so we just need to wait 2 posedge
                                //for dmem to output correct value
                                
                                next_state = wait_state;
                                state_reg_d = 3'b100; //write back
//                                down_count_en = 0;
                            end
                            
                            2'b10: begin //driver is control logic. we're performing a load command
                                //we're going to go to the wait state and stay there for 2 posedge, then from there we go the write_back state
                                state_reg_d = 3'b100; //write_back
                                next_state = wait_state;
//                                down_count_en = 1;
                                down_count_d = 2'b10;
                                use_strd_addr_d = 1;//top module will use this flag to connect stored address to wr_addr port of reg file
                                
                                //we also need to set the write enable for the reg file just before we leave the wait state so that when we
                                //get to write_back state the enable is high
                            end
                            
                            default: begin
                                //we'll only be here if driver is alu(which should never happen cuz of setup1) or if select is 11(should never happen)
                                //might add an error flag output here if I need to debug
                                
                                //we still need to wait 4 posedges to read next instruction
//                                down_count_en = 1;
                                down_count_d = 2'b11;
                                state_reg_d = 3'b000; //decode state
                                next_state = wait_state;
                            end
                        endcase
                    end
                    
                end
                
            write_back: 
                begin
                    //by the time we get to this state it is assumed that there is a valid value on the wr_data port of the reg file
                    //and that it's being driven by the correct signal
                    //it is also assumed that wr_en_rf_q goes high by the time we get to this state
                    
                    wr_en_rf_d = 0; //enable will turn off in the next posedge
                    use_strd_addr_d = 0;//if we came to this state in the ld command sequence.
                    
                    //next state is decode state for next instruction but we need to wait 2 posedge for a succesfull write to the reg 
                    //file and we need to set our enable signals to low
                    state_reg_d = 3'b000; //value for decode state
                    next_state = wait_state;
                    
                    
                    //if we're here during a ld command sequence then in the next 2 posedge we would have succesfully wrote k into
                    //our reg file, however the next instruction (instruction after k) wouldn't be in the opcode reg. 
                    //so we need to increment the pc and wait another 5 posedges
                    if (select_q == 2'b10) begin
                        inc_en_d = 1;
//                        down_count_en = 1;
                        down_count_d = 2'b11;
                    end else begin
//                        down_count_en = 0;
                    end
                end
                
            write: 
                begin
                    inc_en_d = 0;
                    //when we get here inputs to dmem should be correct and enable should also be high
                    //we wait at the wait state for 1 posedge
                    
                    wr_en_dmem_d = 0;
                    next_state = wait_state;
                    state_reg_d = 3'b000;// decode
                    down_count_d = 2'b01;
//                    down_count_en = 1;
            
                end
                
            writeIO: 
                begin
                    //when we get here the output of dmem is correct and the wrio enable signal should be high
                    //we need to wait 2 posedges for a succesful write
                    wr_en_io_d = 0;
                    next_state = wait_state;
                    state_reg_d = 3'b000;
//                    down_count_en = 0;
                end
                
            control_flow: 
                begin
                    //when we arrive at this state the proper enable is high and k has arrived at the opcode_reg
                    //we just need to wait 5 posedge for the new instruction to be in opcode_reg
                    //we go to wait, stay there for 2 posedge, then go to clear, then decode
                    next_state = wait_state;
//                    down_count_en = 1;
                    down_count_d = 2'b10; //count of 2
                    state_reg_d = 3'b000; //decode state
                    
                    //turning off enable signals and flags
                    jmp_en_d = 0; call_en_d = 0; ret_en_d = 0;
                end
    
        endcase
    end
    
endmodule
