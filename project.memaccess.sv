class memaccess;

virtual Probe_MA prob_mem;
virtual LC3_io top_io;
logic DMem_rd;
logic [15:0] DMem_din, DMem_addr,Mem_out;

function new (virtual LC3_io top_io, virtual Probe_MA prob_mem);
  this.prob_mem = prob_mem;
	this.top_io = top_io;
endfunction

task run();
  forever
  begin
    fork
      goldref_memaccess();
      mem_checker_Async();
    join
  end
endtask

task goldref_memaccess();
begin
@(prob_mem.memaccess_mem_state,prob_mem.memaccess_M_Control,prob_mem.memaccess_DMem_dout,prob_mem.memaccess_M_addr,prob_mem.memaccess_M_Data);
Mem_out = prob_mem.memaccess_DMem_dout;
case (prob_mem.memaccess_mem_state)
0:	
begin
	DMem_rd=1;
	DMem_din=0;
	if(prob_mem.memaccess_M_Control==1)
    DMem_addr=prob_mem.memaccess_DMem_dout;
  else
    DMem_addr=prob_mem.memaccess_M_addr;
end

1:
begin
	DMem_rd=1;
	DMem_din=0;
	DMem_addr=prob_mem.memaccess_M_addr;
end

2:
begin
	DMem_rd=0;
	DMem_din=prob_mem.memaccess_M_Data;
	if(prob_mem.memaccess_M_Control==1)
    DMem_addr=prob_mem.memaccess_DMem_dout;
  else
    DMem_addr=prob_mem.memaccess_M_addr;
end

3:
begin
	DMem_rd=1'bz;
	DMem_din=16'bz;
	DMem_addr=16'bz;
end
default:
begin
	DMem_rd=1'bz;
	DMem_din=16'bz;
	DMem_addr=16'bz;
end
endcase
end
endtask

task mem_checker_Async();
  if(prob_mem.memaccess_DMem_rd!==DMem_rd)
    $display ( $time, "\t: DMem_rd mismatch in memaccess stage !!!dut=%h,gref=%h",prob_mem.memaccess_DMem_rd,DMem_rd);
  if(prob_mem.memaccess_DMem_din!==DMem_din)
    $display ( $time, "\t: DMem_din mismatch in memaccess stage !!!dut=%h,gref=%h",prob_mem.memaccess_DMem_din,DMem_din );
  if(prob_mem.memaccess_DMem_addr!==DMem_addr)
    $display ( $time, "\t: DMem_addr mismatch in memaccess stage !!!dut=%h,gref=%h",prob_mem.memaccess_DMem_addr,DMem_addr);	
  if(prob_mem.memaccess_Mem_out !== Mem_out)
    $display ( $time, "\t: Mem_out mismatch in memaccess stage !!!dut=%h,gref=%h",prob_mem.memaccess_Mem_out,Mem_out);	
endtask : mem_checker_Async
endclass
