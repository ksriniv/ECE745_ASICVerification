class writeback;

virtual Probe_WB prob_wb;
virtual LC3_io top_io;
logic [2:0] psr;
logic [15:0] VSR1,VSR2;
logic [15:0] DR[7:0], DR_in;

function new (virtual LC3_io top_io, virtual Probe_WB prob_wb);
  this.prob_wb = prob_wb;
	this.top_io = top_io;
endfunction

task run();
  forever
  begin
    fork
      goldref_writeback();
      wb_checker_sync();
      wb_checker_Async();
    join
  end
endtask

task goldref_writeback();
	@(prob_wb.cb);
	if (prob_wb.cb.reset)
		begin 
			psr = 0;
		end
	else 
	begin
		if ( prob_wb.cb.wb_enable_writeback )
		begin
			if(prob_wb.cb.wb_W_control == 0)
			 	DR_in = prob_wb.cb.wb_aluout;
			else if(prob_wb.cb.wb_W_control== 1)
			  	DR_in = prob_wb.cb.wb_memout;
			else if(prob_wb.cb.wb_W_control== 2)
			  	DR_in = prob_wb.cb.wb_pcout;
		
			DR[prob_wb.cb.wb_dr] = DR_in;				  
      
			if (DR_in[15])			psr = 3'b100;
			else if ( DR_in > 0) 		psr = 3'b001;
			else if ( DR_in == 0) 		psr = 3'b010;
			else if (|DR_in == 1'b1) 	psr = 3'b001; 			// undefined cases
			else if (|DR_in === 1'bX) 	psr = 3'b010;			//if (^DR_in === 1'bX) psr = 3'b010;
			else $display(" WB PSR: This shouldn't happen");
		end
	      VSR1= DR[prob_wb.wb_sr1];
	      VSR2= DR[prob_wb.wb_sr2];
	end
endtask

task wb_checker_sync();
  if(prob_wb.wb_psr!=psr)
  begin
  $display( $time, "\t: psr mismatch in Writeback stage !!! dut=%h gref=%h", prob_wb.wb_psr, psr);	
  $display( $time, "\t: input is: %b", DR_in);	
  $display( $time, "\t: input pp: %b\n", |DR_in);	
  if(prob_wb.cb.wb_W_control==0)
    $display( $time, "\t: Input is : %h", prob_wb.cb.wb_aluout);
  else if(prob_wb.cb.wb_W_control==1)
    $display( $time, "\t: Input is : %h", prob_wb.cb.wb_memout);
  else if(prob_wb.cb.wb_W_control==2)
    $display( $time, "\t: Input is : %h", prob_wb.cb.wb_pcout);
  end
endtask : wb_checker_sync

task wb_checker_Async();
  if(prob_wb.wb_VSR1!=VSR1) $display( $time, "\t: VSR1 mismatch in Writeback stage !!! dut=%h gref=%h", prob_wb.wb_VSR1, VSR1);
  if(prob_wb.wb_VSR2!=VSR2) $display( $time, "\t: VSR2 mismatch in writeback stage !!! dut=%h gref=%h", prob_wb.wb_VSR2, VSR2);		
endtask : wb_checker_Async
endclass
