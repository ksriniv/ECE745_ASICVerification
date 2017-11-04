// Transaction class
class InstOp;
  // Loads use src1 for val and dest for address
  // Stores use src1 for val and src2 for address
  randc bit [2:0] src1, src2, dest;
  randc bit [5:0] PCoffset6;
  randc bit [8:0] PCoffset9;
  randc bit [4:0] imm5;
  rand bit alu_mode; // used for ADD and AND insts
  rand bit [2:0] nzp;

  // to be set by caller before randomizing
  bit alu_inst;

	// Instruction opcode type
	typedef enum {ADD, AND, NOT, LEA, LD, LDR, LDI, ST, STR, STI, BR, JMP} inst_opcodes_e;
	randc inst_opcodes_e INST_opcodes;

  constraint inst_opcodes{
    if(alu_inst) 
      INST_opcodes inside {[ADD:NOT]};
    else 
      INST_opcodes inside {[LEA:JMP]};
  }

  constraint source_regs{
    nzp != 3'b0;
  }

  function new(input int seed);
		$display("Seed is %d\n", seed);
    srandom(seed);
  endfunction

  function bit[3:0] get_opcode;
    case (INST_opcodes)
      ADD: get_opcode = 4'b1;
      AND: get_opcode = 4'b101;
      NOT: get_opcode = 4'b1001;
      LD:  get_opcode = 4'b10;
      LDR: get_opcode = 4'b110;
      LDI: get_opcode = 4'b1010;
      LEA: get_opcode = 4'b1110;
      ST:  get_opcode = 4'b11;
      STR: get_opcode = 4'b111;
      STI: get_opcode = 4'b1011;
      BR:  get_opcode = 4'b0;
      JMP: get_opcode = 4'b1100;
    endcase
  endfunction

  function bit[15:0] get_instruction;
    case (INST_opcodes)
      ADD: 
        if(!alu_mode)
        begin
          get_instruction = {4'b1, dest, src1, 3'b0, src2};
          $display($time, "Instruction is ADD with DR: %d, SR1: %d, SR2: %d", dest, src1, src2);
        end
        else
        begin
          get_instruction = {4'b1, dest, src1, 1'b1, imm5};
          $display($time, "Instruction is ADD with DR: %d, SR1: %d, imm: %d", dest, src1, imm5);
        end
      AND: 
        if(!alu_mode)
        begin
          get_instruction = {4'b101, dest, src1, 3'b0, src2};
          $display($time, "Instruction is AND with DR: %d, SR1: %d, SR2: %d", dest, src1, src2);
        end
        else
        begin
          get_instruction = {4'b101, dest, src1, 1'b1, imm5};
          $display($time, "Instruction is AND with DR: %d, SR1: %d, imm: %b", dest, src1, imm5);
        end
      NOT: 
      begin
        get_instruction = {4'b1001, dest, src1, 6'b1};
        $display($time, "Instruction is NOT with DR: %d, SR1: %d", dest, src1);
      end
      LD:
      begin
        get_instruction = {4'b10, dest, PCoffset9};
        $display($time, "Instruction is LD with DR: %d, offset: %h", dest, PCoffset9);
      end
      LDR:
      begin
        get_instruction = {4'b110, dest, src1, PCoffset6};
        $display($time, "Instruction is LDR with DR: %d, SR1: %d, offset: %h", dest, src1, PCoffset6);
      end
      LDI:
      begin
        get_instruction = {4'b1010, dest, PCoffset9};
        $display($time, "Instruction is LDI with DR: %d, offset: %h", dest, PCoffset9);
      end
      LEA:
      begin
        get_instruction = {4'b1110, dest, PCoffset9};
        $display($time, "Instruction is LEA with DR: %d, offset: %h", dest, PCoffset9);
      end
      ST:
      begin
        get_instruction = {4'b11, src1, PCoffset9};
        $display($time, "Instruction is ST with SR1: %d, imm: %h", src1, PCoffset9);
      end
      STR:
      begin
        get_instruction = {4'b111, src1, src2, PCoffset6};
        $display($time, "Instruction is STR with SR1: %d, BaseR: %d, offset: %h", src1, src2, PCoffset6);
      end
      STI:
      begin
        get_instruction = {4'b1011, src1, PCoffset9};
        $display($time, "Instruction is STI with SR1: %d, offset: %h", src1, PCoffset9);
      end
      BR:
      begin
        get_instruction = {4'b0, nzp, PCoffset9};
        $display($time, "Instruction is BR with NZP: %b, offset: %h", nzp, PCoffset9);
      end
      JMP:
      begin
        get_instruction = {4'b1100, 3'b0, src1, 6'b0};
        $display($time, "Instruction is JMP with BaseR: %d", src1);
      end
      default:
        get_instruction = 15'b0;
    endcase
    $display("\n");
  endfunction

endclass

//module test;
//  initial begin
//    int i;
//		InstOp opcode;
//		opcode = new();
//
//		repeat (30) begin
//      if(i > 5)begin
//        opcode.alu_inst = 0; 
//        i=0;
//      end
//      else
//        opcode.alu_inst = 1;
//			assert (opcode.randomize());
//      $display("Random inst: %b", opcode.get_opcode());
//      $display("Random opcode %s", opcode.INST_opcodes.name);
//      $display("SRC1: %b, SRC2: %b, DST: %b", opcode.src1, opcode.src2, opcode.dest);
//      $display("PC offset 6: %b", opcode.PCoffset6);
//      $display("PC offset 9: %b", opcode.PCoffset9);
//      $display("IMM5: %b", opcode.imm5);
//      $display("alu mode: %b", opcode.alu_mode);
//      $display("nzp: %b", opcode.nzp);
//      $display("Instruction: %b\n", opcode.get_instruction());
//      i++;
//    end
//  end
//endmodule
