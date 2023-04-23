// ECE:3350 SISC computer project
// finite state machine

`timescale 1ns/100ps


//TODO: Add the additional 6 internal signals to the parameter list
//added br_sel, pc_rst, pc_write, pc_sel, rb_sel, ir_load
module ctrl (clk, rst_f, opcode, mm, stat, rf_we, alu_op, wb_sel, br_sel, pc_rst, pc_write, pc_sel, rb_sel, ir_load);

  /* TODO: Declare the additional internal signals listed above as inputs or outputs */
  //It seems like all the new added signals are outputs, but a size isn't given
  //added br_sel, pc_rst, pc_write, pc_sel, rb_sel, ir_load all as outputs
  input clk, rst_f;
  input [3:0] opcode, mm, stat;
  output reg rf_we, wb_sel;
  output reg [1:0] alu_op;
  output reg br_sel, pc_rst, pc_write, pc_sel, rb_sel, ir_load;
  
  // state parameter declarations
  parameter start0 = 0, start1 = 1, fetch = 2, decode = 3, execute = 4, mem = 5, writeback = 6;
   
  // opcode paramenter declarations
  parameter NOOP = 0, LOD = 1, STR = 2, SWP = 3, BRA = 4, BRR = 5, BNE = 6, BNR = 7, ALU_OP = 8, HLT=15;

  // addressing modes
  parameter AM_IMM = 8;

  // state register and next state value
  reg [2:0]  present_state, next_state;

  // Initialize present state to 'start0'.
  initial
    present_state = start0;

  /* Clock procedure that progresses the fsm to the next state on the positive 
     edge of the clock, OR resets the state to 'start1' on the negative edge
     of rst_f. Notice that the computer is reset when rst_f is low, not high. */

  always @(posedge clk, negedge rst_f)
  begin
    if (rst_f == 1'b0)
      present_state <= start1;
    else
      present_state <= next_state;
  end
  
  /* Combinational procedure that determines the next state of the fsm. */

  always @(present_state, rst_f)
  begin
    case(present_state)
      start0:
        next_state = start1;
      start1:
	if (rst_f == 1'b0) 
          next_state = start1;
	else
          next_state = fetch;
      fetch:
        next_state = decode;
      decode:
        next_state = execute;
      execute:
        next_state = mem;
      mem:
        next_state = writeback;
      writeback:
        next_state = fetch;
      default:
        next_state = start1;
    endcase
  end
  



  always @(present_state, opcode, mm)
  begin

  /* TODO: Put your default assignments for the additional 6 internal signals here.  */
  //adding the 6, setting them all to 0 seems like the logical start, and work from there.
    rf_we  = 1'b0;
    wb_sel = 1'b0;
    alu_op = 2'b10;
	//the new ones start here
    br_sel = 1'b0;
    pc_rst = 1'b0;
    pc_write = 1'b0;
    pc_sel = 1'b0;
    rb_sel = 1'b0;
    ir_load = 1'b0;
  
    case(present_state)
     start1:
      begin
        /*TODO: Set PC_RST*/
	//try setting PC_RST to 1?
	pc_rst = 1'b1;
      end

      fetch:
      begin
        /*TODO: Set IR_LOAD and PC_WRITE*/
	pc_write <= 1'b1;
	ir_load <= 1'b1;
	
      end

      decode:
      begin
        /*TODO: Set PC_SEL and set BR_SEL and PC_WRITE based on different instructions*/
	//we need to check all of the opcodes against the branches, meaning we need an if for each opcode
	//do we need a second if statement seeing if the branch was taken at all?
	if (opcode == BRA) begin
		if ((mm & stat) != 0) begin
	  	pc_sel <= 1;
	  	pc_write <= 1;
	  	br_sel <= 1;
		end
	end
	if (opcode == BRR) begin
	  if ((mm & stat) != 0) begin
	  	pc_sel <= 1;
	  	pc_write <= 1;
	  	br_sel = 0; //changed due to be a relative branch
		end
	end
	if (opcode == BNE) begin
	  if ((mm & stat) == 0) begin
	  	pc_sel <= 1;
	  	pc_write <= 1;
	  	br_sel <= 1; 
		end
	end
	if (opcode == BNR) begin
	  if ((mm & stat) == 0) begin
	  	pc_sel <= 1;
	  	pc_write <= 1;
	  	br_sel = 0; //changed due to being a relative branch
		end
	end
	//removed end here
	else begin
	  br_sel <= 0;
	end
      end

      execute:
      begin
        if ((opcode == ALU_OP) && (mm == AM_IMM))
          alu_op = 2'b01;
        else
          alu_op = 2'b00;
      end

      mem:
      begin
        if ((opcode == ALU_OP) && (mm == AM_IMM))
          alu_op = 2'b11;
        else
          alu_op = 2'b10;
      end

      writeback:
      begin
        if (opcode == ALU_OP)
          rf_we = 1'b1;  
      end

      default:
      begin
      
      /* TODO: Put your default assignments for the additional 6 internal signals here.  */
        rf_we  = 1'b0;
        wb_sel = 1'b0;
        alu_op = 2'b10;
		//the new ones start here
    	br_sel = 1'b0;
    	pc_rst = 1'b0;
    	pc_write = 1'b0;
    	pc_sel = 1'b0;
    	rb_sel = 1'b0;
    	ir_load = 1'b0;
  
  
      end
    endcase
  end

// Halt on HLT instruction  
  always @(opcode)
  begin
    if (opcode == HLT)
    begin 
      #5 $display ("Halt."); //Delay 5 ns so $monitor will print the halt instruction
      $stop;
    end
  end
    
  
endmodule
