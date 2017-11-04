`include "project.instruction.sv"
`include "coverage.sv"
class Generator;
  typedef virtual LC3_io.TB vLC3_io;
  
  // probe interfaces for various stages
typedef virtual fetchinterface vProbe;
typedef virtual decode_if Decode_probe;
typedef virtual Probe_MA MemAccess_probe;
typedef virtual probe_execute Execute_probe;
typedef virtual Probe_WB Writeback_probe;
typedef virtual probe_Controller Controller_Probe;

  vLC3_io ports;
  vProbe FetchIO;
  Decode_probe decodeIO;
  MemAccess_probe memIO;
  Execute_probe executeIO;
  Writeback_probe writebackIO;
  Controller_Probe controlIO;
  int n_insts;
  coverage cov;

  function new(input vLC3_io ports , input vProbe Fetch,input Decode_probe decodeIO,input MemAccess_probe memIO,input Execute_probe executeIO,input Writeback_probe writebackIO,input Controller_Probe controlIO,input int n_insts);
    this.ports = ports;
    this.FetchIO = Fetch;
    this.n_insts = n_insts;
    cov=new(ports,Fetch,decodeIO,memIO,executeIO,writebackIO,controlIO);
  endfunction 

  task run();
    InstOp tr;
    bit [2:0] reg_n = 3'b0;
    int i;

    repeat(5) begin
	    tr = new($urandom());

	    $display("Resetting DUT");
	    @(ports.cb);
	    ports.cb.reset <= 1'b1;
	    // asynchronous signals
	    ports.complete_data <= 1'b1;
	    ports.complete_instr <= 1'b1;
	    ports.cb.Instr_dout <= {4'b101, reg_n, reg_n, 1'b1, 5'b0};

	    $display("Clearing registers");
	    repeat(8) begin
	      @(posedge ports.cb);
	      ports.cb.reset <= 1'b0;
	      ports.cb.Instr_dout <= {4'b101, reg_n, reg_n, 1'b1, 5'b0};
	      reg_n++;
	    end
	    $display("Generating...");

	    repeat(n_insts) begin
	      @(posedge ports.cb);
	      if(FetchIO.cb.instrmem_rd) begin
          // Request ALU inst or MEM/CTRL inst
          if(i > 7)begin
            tr.alu_inst = 0; 
            i=0;
          end
          else
            tr.alu_inst = 1;
          i++;

          assert(tr.randomize());
          $display($time," Random inst: %b", tr.get_opcode());
          $display($time," Random opcode %s\n", tr.INST_opcodes.name);

          ports.cb.Instr_dout <= tr.get_instruction;
          // Change the data out later if needed
          ports.cb.Data_dout <= 16'b0;
          cov.run();
	      end
	    end
	    $display("Generator done!");
    end
  endtask
endclass
