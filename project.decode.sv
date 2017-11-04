//////////////////////////////////////////////////////////////////
//
//      TO BE TESTED
//
//
//////////////////////////////////////////////////////////////////
class Decode;
  typedef virtual decode_if vDecodeIF;
  typedef virtual LC3_io.TB vLC3_io;


  // Member variables
  vLC3_io dut_io;
  vDecodeIF DecodeIO;

    // Golden ref
  logic [15:0] IR, npc_out;
  logic [5:0] E_control;
  logic [1:0] W_control;
  logic Mem_control;

  function new(input vLC3_io ports, input vDecodeIF DecodeIO);
    this.dut_io = ports;
    this.DecodeIO = DecodeIO;
  endfunction

  task run();
    forever
    begin
      fork
        Decode_GoldenRef();
        Decode_checker();
      join
    end
  endtask;

  task Decode_GoldenRef();
    @(DecodeIO.input_cb);
    if(DecodeIO.input_cb.reset) begin
      npc_out = 16'b0;
      IR = 16'b0;
      E_control = 6'b0;
      W_control = 2'b0;
      Mem_control = 1'b0;
    end
    else begin
      if(DecodeIO.input_cb.enable_decode)
      begin
        npc_out = DecodeIO.input_cb.npc_in;
        IR = DecodeIO.input_cb.instr_dout;
        case(DecodeIO.input_cb.instr_dout[15:12])
          4'b0001://ADD
            begin
              if(DecodeIO.input_cb.instr_dout[5])
                E_control = {2'b0, 2'b0, 1'b0, 1'b0};
              else
                E_control = {2'b0, 2'b0, 1'b0, 1'b1};
              W_control = 2'b0;
            end
          4'b0101://AND
            begin
              if(DecodeIO.input_cb.instr_dout[5])
                E_control = {2'b1, 2'b0, 1'b0, 1'b0};
              else
                E_control = {2'b1, 2'b0, 1'b0, 1'b1};
              W_control = 2'b0;
            end
          4'b1001://NOT
            begin
              E_control = {2'b10, 2'b0, 1'b0, 1'b0};
              W_control = 2'b0;
            end
          4'b0010://LD
            begin
            E_control = {2'b0, 2'b1, 1'b1, 1'b0};
            W_control = 2'b1;
            Mem_control = 1'b0;
            end
          4'b0110://LDR
            begin
            E_control = {2'b0, 2'b10, 1'b0, 1'b0};
            W_control = 2'b1;
            Mem_control = 1'b0;
            end
          4'b1010://LDI
            begin
            E_control = {2'b0, 2'b1, 1'b1, 1'b0};
            W_control = 2'b1;
            Mem_control = 1'b1;
            end
          4'b1110://LEA
            begin
            E_control = {2'b0, 2'b1, 1'b1, 1'b0};
            W_control = 2'b10;
            end
          4'b0011://ST
            begin
            E_control = {2'b0, 2'b1, 1'b1, 1'b0};
            W_control = 2'b0;
            Mem_control = 1'b0;
            end
          4'b0111://STR
            begin
            E_control = {2'b0, 2'b10, 1'b0, 1'b0};
            W_control = 2'b0;
            Mem_control = 1'b0;
            end
          4'b1011://STI
            begin
            E_control = {2'b0, 2'b1, 1'b1, 1'b0};
            W_control = 2'b0;
            Mem_control = 1'b1;
            end
          4'b0000://BR
            begin
            E_control = {2'b0, 2'b1, 1'b1, 1'b0};
            W_control = 2'b0;
            end
          4'b1100://JMP
            begin
            E_control = {2'b0, 2'b11, 1'b0, 1'b0};
            W_control = 2'b0;
            end
        endcase
      end
    end
  endtask

  task Decode_checker();
    if(DecodeIO.input_cb.enable_decode)
      begin
      if(DecodeIO.npc_out != npc_out) $display($time, "Error in DECODE: npc_out, dut=%h,gref=%h", DecodeIO.npc_out, npc_out);
      if(DecodeIO.IR != IR) $display($time, "Error in DECODE: IR, dut=%h, gref=%h", DecodeIO.IR, IR);
      if(DecodeIO.W_Control != W_control) $display($time, "Error in DECODE: W_control, dut=%h, gref=%h", DecodeIO.W_Control, W_control);

      case(DecodeIO.instr_dout[15:12])
          4'b0001, 4'b0101://AND and ADD
            begin
              if(DecodeIO.E_Control[5:4] !== E_control[5:4] || DecodeIO.E_Control[0] !== E_control[0])
              begin
                $display($time, "Error in DECODE: E_control, dut[5:4]=%b gref[5:4]=%b, dut[0]=%b gref[0]=%b", DecodeIO.E_Control[5:4], E_control[5:4],DecodeIO.E_Control[0], E_control[0]);
                print_instr();
              end
            end      
          4'b1001://NOT
            begin
              if(DecodeIO.E_Control[5:4] !== E_control[5:4])
              begin
                $display($time, "Error in DECODE: E_control, dut[5:4]=%b gref[5:4]=%b", DecodeIO.E_Control[5:4], E_control[5:4]);
                print_instr();
              end
            end
          default:// Every other type of instruction
            begin
              if(DecodeIO.E_Control[3:1] !== E_control[3:1])
              begin
                $display($time, "Error in DECODE: E_control, dut[3:1]=%b gref[3:1]=%b", DecodeIO.E_Control[3:1], E_control[3:1]);
                print_instr();
              end
            end
      endcase

      case(DecodeIO.input_cb.instr_dout[15:12])
          4'b0010, 4'b0110, 4'b1010,4'b0011, 4'b0111, 4'b1011://STI://STR://ST://LDI://LDR://LD
            begin
              if(DecodeIO.Mem_Control != Mem_control)
              begin
                $display($time, "Error in DECODE: Mem_control, dut[15:12]: %h gref[15:12]: %h", DecodeIO.Mem_Control, Mem_control);
                print_instr();
              end
            end
      endcase
    end
  endtask

  task print_instr();
    case(DecodeIO.instr_dout[15:12])
      4'b0001://ADD
        if(DecodeIO.instr_dout[5] === 1'b1)
        begin
          $display($time, "Instruction is ADD with DR: %d, SR1: %d, imm: %d", DecodeIO.instr_dout[11:9], DecodeIO.instr_dout[8:6], DecodeIO.instr_dout[4:0]);
        end
        else
        begin
          $display($time, "Instruction is ADD with DR: %d, SR1: %d, SR2: %d", DecodeIO.instr_dout[11:9], DecodeIO.instr_dout[8:6], DecodeIO.instr_dout[2:0]);
        end
      4'b0101://AND
        if(DecodeIO.instr_dout[5] === 1'b1)
        begin
          $display($time, "Instruction is AND with DR: %d, SR1: %d, imm: %d", DecodeIO.instr_dout[11:9], DecodeIO.instr_dout[8:6], DecodeIO.instr_dout[4:0]);
        end
        else
        begin
          $display($time, "Instruction is AND with DR: %d, SR1: %d, SR2: %d", DecodeIO.instr_dout[11:9], DecodeIO.instr_dout[8:6], DecodeIO.instr_dout[2:0]);
        end
      4'b1001://NOT
        begin
          $display($time, "Instruction is NOT with DR: %d, SR1: %d", DecodeIO.instr_dout[11:9], DecodeIO.instr_dout[8:6]);
        end
      4'b0010://LD
        begin
          $display($time, "Instruction is LD with DR: %d, Mem_offset: %d", DecodeIO.instr_dout[11:9], DecodeIO.instr_dout[8:0]);
        end
      4'b0110://LDR
        begin
          $display($time, "Instruction is LDR with DR: %d, Base R: %d, Mem_offset: %d", DecodeIO.instr_dout[11:9], DecodeIO.instr_dout[8:6], DecodeIO.instr_dout[5:0]);
        end
      4'b1010://LDI
        begin
          $display($time, "Instruction is LDI with DR: %d, Mem_offset: %d", DecodeIO.instr_dout[11:9], DecodeIO.instr_dout[8:0]);
        end
      4'b1110://LEA
        begin
          $display($time, "Instruction is LEA with DR: %d, Mem_offset: %d", DecodeIO.instr_dout[11:9], DecodeIO.instr_dout[8:0]);
        end
      4'b0011://ST
        begin
          $display($time, "Instruction is ST with SR: %d, Mem_offset: %d", DecodeIO.instr_dout[11:9], DecodeIO.instr_dout[8:0]);
        end
      4'b0111://STR
        begin
          $display($time, "Instruction is STR with SR: %d, Base R: %d, Mem_offset: %d", DecodeIO.instr_dout[11:9], DecodeIO.instr_dout[8:6], DecodeIO.instr_dout[5:0]);
        end
      4'b1011://STI
        begin
          $display($time, "Instruction is STI with SR: %d, Mem_offset: %d", DecodeIO.instr_dout[11:9], DecodeIO.instr_dout[8:0]);
        end
      4'b0000://BR
        begin
          $display($time, "Instruction is BR with NZP: %b, Mem_offset: %d", DecodeIO.instr_dout[11:9], DecodeIO.instr_dout[8:0]);
        end
      4'b1100://JMP
        begin
          $display($time, "Instruction is JMP with Base R: %d", DecodeIO.instr_dout[8:6]);
        end
    endcase
  endtask
endclass
