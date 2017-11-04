////////////////////////////////////////////////////////
//
//TO BE TESTED
//
//
////////////////////////////////////////////////////////


/*---------------- Fetch Stage Implementation ------------------ */



class fetch;
  logic chkval_instrmem_rd;	
	/*---------------- Virtualize interface from interface_all_stages.sv file ------------------ */
  virtual fetchinterface int_fetch ;
  virtual LC3_io top_IO;

	/*---------------- Invoke the new function ------------------ */
	function new (virtual LC3_io top_io, virtual fetchinterface fe);
		this.int_fetch =  fe;
    		this.top_IO = top_io;
	endfunction : new
	
	/*---------------- Golden Reference Model (GRM) for Fetch Stage ------------------ */
	task fetch_grm();
		
    		@(int_fetch.cb);
		if (int_fetch.reset)begin				
			int_fetch.chkval_pc = 16'h3000;
			int_fetch.chkval_npc = 16'h3001;
		end
		/*----- enable_updatePC signal -> if branch taken or not || pc updated if enable_updatePC == 1 ----- */
		if ((!int_fetch.reset) && (int_fetch.cb.enable_updatePC))	
		
			if ((int_fetch.cb.br_taken)) begin
				
				int_fetch.chkval_pc = int_fetch.taddr;
			end
			else begin
				int_fetch.chkval_pc = int_fetch.chkval_npc; 

			end
			
		

		else if ((!int_fetch.enable_updatePC))
			int_fetch.chkval_pc = int_fetch.chkval_pc; // forced update if not triggered, just redundant check!!

		
	endtask : fetch_grm

  task fetch_grm_async();
	

	if ((!int_fetch.reset) && (int_fetch.cb.enable_updatePC) )
			int_fetch.chkval_npc = int_fetch.chkval_pc + 16'h1;	
		
	int_fetch.chkval_instrmem_rd = int_fetch.cb.enable_fetch;
	
  endtask : fetch_grm_async

	/*----- checker function for functionality in sync mode ----- */
  task fetch_checker();

		if ( int_fetch.chkval_instrmem_rd != int_fetch.cb.instrmem_rd )
			$display ( $time, "\t: instrmem_rd mismatch in fetch stage ! GRM value = %h, DUT Value = %h, Enable_updatePC = %h",int_fetch.chkval_instrmem_rd, int_fetch.cb.instrmem_rd, int_fetch.enable_updatePC);	
		if ( int_fetch.chkval_pc != int_fetch.pc)
			$display ( $time, "\t:  pc mismatch in fetch stage ! GRM value = %h, DUT Value = %h,  Enable_updatePC = %h, is_br_taken = %h, taken_addr = %h",int_fetch.chkval_pc, int_fetch.pc, int_fetch.enable_updatePC, int_fetch.br_taken, int_fetch.taddr);	
		if ( int_fetch.chkval_npc != int_fetch.npc_out)
			$display ( $time, "\t: npc mismatch in fetch stage ! GRM value = %h, DUT Value = %h, DUT pc val = %h", int_fetch.chkval_npc, int_fetch.npc_out, int_fetch.pc);
  endtask : fetch_checker


task run();
  forever
  begin
    fork
      fetch_grm();
      fetch_grm_async();
      fetch_checker();
    join
  end
endtask : run

endclass
