`define ADD	4'b0001
`define AND	4'b0101
`define NOT	4'b1001

`define BR	4'b0000
`define JMP	4'b1100

`define LD	4'b0010
`define LDR	4'b0110
`define LDI	4'b1010
`define LEA	4'b1110

`define ST	4'b0011
`define STR	4'b0111
`define STI	4'b1011

class controller;


	typedef virtual probe_Controller vController;
		// Member Elements
	vController pController;




	// To Check Elements
	logic enable_updatePC;
	logic enable_fetch;
	logic enable_decode;
	logic enable_exec;
	logic enable_writeback;
	logic br_taken;
	logic bypassAlu1;
	logic bypassAlu2;
	logic bypassMem1;
	logic bypassMem2;
	logic [1:0] memState;
	reg [3:0] next_state ;
	reg [3:0] current_state ;
	reg [3:0] current_enable_state;
	reg [3:0] next_enable_state;
	reg [3:0] old_value = 4'b0;
	logic from_c_state = 1'b0;
	bit flag;

	/* Function  NEW ()*/
	function new(vController pController); // We can add elements here if we have to
		
		this.pController = pController;
		
	endfunction




/* Task RUN()*/


	task run();

	fork
	  con_grm();// controller Golden Reference Model
    con_grm_async();
	  con_enable_update();
	  con_chk();// controller checker
	  con_chk_enable();//Checker Enabe UpdatePC and update Fetch;
	join
	endtask


	task con_grm_async();
	forever begin
	   @(pController.IR_Exec or pController.IMem_Dout or pController.brTaken or pController.IR or  pController.NZP  );
	   current_enable_state = next_enable_state;
	   

	   if (current_enable_state == 4'h3) begin
        next_enable_state = 4'h2;
	   end		
	   
		
	   if (current_enable_state == 4'h2) begin
		  //enable_updatePC = 1 ;
		  next_enable_state = 4'h1;
	   end	
    
     if (current_enable_state == 4'h1) begin
		  enable_fetch = 1 ;
      enable_updatePC = 1 ;
		  next_enable_state = 4'h0;
	   end		
	   
      if (current_enable_state == 4'h0) begin


	   	 if (pController.IMem_Dout[15:12] == `JMP || pController.IMem_Dout[15:12] == `BR ) 
				begin
				enable_updatePC = 0 ;
				enable_fetch = 0;
				next_enable_state = 4'h3;
				end	
		end

	end //forever	
	endtask
	
	task con_enable_update();

		forever begin

		/*----- Enable Signals - Decode, Exec and Writeback ----- */
		@(posedge pController.cb);
		current_state = next_state;
		/********Enable Logic*************/

		case (current_state) 
		4'h0:	begin 
				next_state =  4'h1;	 
			end
		4'h1:	begin
				if(pController.reset)
					enable_decode = 0;
				else
					enable_decode = 1;
				if(from_c_state) begin			
					enable_writeback = 1;
					from_c_state = 0;
				end
				
				next_state  = 4'h2;

			end
		4'h2:	begin 
				enable_exec = 1;
				next_state =  4'h3;
				
				
			end
		4'h3:	begin 
				enable_writeback  = 1;
				next_state = 3;
				if (pController.IR[15:12] == `LD || pController.IR[15:12] == `LDR || pController.IR[15:12] == `LDI || pController.IR[15:12] == `ST || pController.IR[15:12] == `STR 
						|| pController.IR[15:12] == `STI) begin
          					
          old_value = pController.IR[15:12];
					next_state = 4'hd;	
					
				end
			
				// Code for JMP with and without Branch flag
				else if ((pController.IMem_Dout[15:12] == `JMP || pController.IMem_Dout[15:12] == `BR) && (!flag)) begin
					flag = 1;
					enable_decode = 0;
					from_c_state = 1'b1;
					next_state = 4'hc;
				end
			
				else if ((pController.IMem_Dout[15:12] == `JMP || pController.IMem_Dout[15:12] == `BR) && (flag)) begin
					flag = 1;
					enable_decode = 0;
					from_c_state = 1'b1;	
					next_state = 4'hc;
				end
			
				
			end
		4'h4: 	begin											// From State 3 Stage for Instr = LD/LDR
            enable_fetch = 1;
            enable_updatePC = 1;		    		
            enable_decode = 1;
		    		enable_exec = 1;
		    		enable_writeback = 1;
				    next_state = 4'h3;	
			end				
		4'h5: 	begin											// From State 3 Stage for Instr = ST/STR
            enable_fetch = 1;
            enable_updatePC = 1;	
		    		enable_decode = 1;
		    		enable_exec = 1;
		    		enable_writeback = 0;
				next_state  = 4'h6;	
			end
		4'h6:  begin											// From State 5 Stage for Instr = ST/STR
            enable_fetch = 1;
            enable_updatePC = 1;					
            enable_writeback = 1;
				    next_state = 4'h3;	
			    end
		4'h7:	begin											// From State 3 Stage for Instr = LDI
				next_state =  4'h4;
			end
		4'h8:  	begin											// From State 3 Stage for Instr = STI
				next_state =  4'h5;
			end															
		4'h9: 	begin											// From Decode Stage for Instr = JMP/BR	

				enable_decode = 0;
				if(from_c_state)			
					enable_exec = 0;
				else	
					enable_exec = 1;
								
				next_state = 4'ha;	
			end									
		4'ha: 	begin														
				if(!from_c_state)			
					enable_decode = 0;
				else	begin
					enable_decode = 1;
				end
				enable_exec = 0;
				enable_writeback = 0;
				next_state = 4'hb;
			end
		4'hb:	begin														

				if(from_c_state) 			
					enable_exec= 1;
				
				else 	
					enable_exec = 0;
					
				
				next_state =  4'h1;	
		
			end

		4'hc:	begin										// Jump from Execute if branch flag is done
				enable_writeback = 0;
				enable_exec = 0;
				enable_decode = 0;
				next_state = 4'h9;
			end
		4'hd: begin
      enable_fetch = 0;
      enable_updatePC = 0;
			enable_decode = 0;
			enable_exec = 0;
			enable_writeback = 0;
			if ( old_value == `LDI)
				next_state = 4'h7;
			else if (old_value == `LD || old_value == `LDR)
				next_state = 4'h4;
			else if ( old_value == `STI)
				next_state = 4'h8;
			else if (old_value == `ST || old_value == `STR)
				next_state = 4'h5;
			
		      	end

		endcase
    		/********* Branch Logic*************/
		
	if (pController.enableUpdatePC)
		br_taken  = |(pController.NZP & pController.psr);
		
	if ( pController.brTaken &&  pController.IMem_Dout[15:12] == `BR )begin	
		enable_updatePC = 1'b1;	
		current_enable_state = 4'h2;	
		end

	if ( pController.brTaken &&  pController.IMem_Dout[15:12] == `JMP )begin	
		enable_updatePC = 1'b1;	
		current_enable_state = 4'h2;	
		end

		end //forever

	endtask

	task con_grm();
	forever
	   begin
		//$display("1. Old value of memstate is %h @ %t",pController.cb.memState, $time);
		/*-------Reset Logic ----------- */
		if (pController.reset) begin
			$display ("This is the Reset for Controller " );
			enable_updatePC = 1'b1;
			enable_fetch = 1'b1;
			enable_decode = 1'b0;
			enable_exec = 1'b0;
			enable_writeback = 1'b0;
			br_taken  = 4'b0;
			flag = 0;
			bypassAlu1 <=0;
			bypassAlu2 <=0;
			bypassMem1 <= 0;
			bypassMem2 <= 0;
			memState = 2'd3;
			next_state = 4'h0;
			next_enable_state = 4'h0;
			from_c_state = 1'b0;	
			end
		
		@(posedge pController.cb);	
		//$display("2. Old value of memstate is %h @ %t",pController.cb.memState, $time);
		/*****MemState Logic ************/
		casex( pController.cb.memState)
		
		0:      begin
				if (pController.completeData)
					memState = 3;
			end
		
		2:      begin
				if (pController.completeData)
					memState = 3;
			end
		
		1: begin
				if (pController.completeData)
				begin
					if (pController.cb.IR_Exec[15:12] == `LDI)
						memState = 0;
					else if (pController.cb.IR_Exec[15:12] == `STI)
						memState = 2;
					else
					begin	
						memState = 3; // This condition Should never come
						$display("ERROR Ilegal state");
					end 
				end
		
			end
		
		
		default: begin	
				if (pController.cb.enableExecute) // If the Execute stage is enable then only we should edit anything else not
				begin
					if ((pController.cb.IR[15:12] == `LD) || ((pController.cb.IR[15:12] == `LDR)))
						memState = 0;
					else if ((pController.cb.IR[15:12] == `ST) || ((pController.cb.IR[15:12] == `STR)))
						memState = 2;
					else if ((pController.cb.IR[15:12] == `LDI) || ((pController.cb.IR[15:12] == `STI)))
						memState = 1;
					else
						memState =3; 
				end		
			end
		
		endcase
	
		



		/******************** Bypass Logics ***********************/
		/* Instruction Register Info
		 * SRC 1 :  8:6
		 * SRC 2 :  2:0
		 * opcode:  15:12
		 * DEST	 :	11:9 // But this is source for Store
		 * if immediate is used for src 2 then bit [5] = 1
		 *
		 * IMem_Dout = instruction in fetch stage
		 * IR = Instruction in Decode Stage
		 * IR_Exec = instruction in Execute Stage
		 */
		bypassAlu1 = 0;
		bypassAlu2 = 0;
		bypassMem1 = 0;
		bypassMem2 = 0;
		 
	 
	 
		 if (pController.IR[13:12] != 2'b00) // Not a control Instruction
		begin
		
		// ALU Bypass	
			if ((pController.IR_Exec[15:12] == `ADD) ||
				(pController.IR_Exec[15:12] == `AND) ||
				(pController.IR_Exec[15:12] == `LEA)  ||
				(pController.IR_Exec[15:12] == `NOT) )
			
				begin
				
					casex(pController.IR[15:12])
				
					4'bxx01:	// ALU Operations
					begin
						if (pController.IR_Exec[11:9] == pController.IR[8:6])
							bypassAlu1 = 1;

						if (!(pController.IR[5]))
							begin
								if 	(pController.IR_Exec[11:9] == pController.IR[2:0])
									bypassAlu2 = 1;

							end
						
					end	
				
					`LDR:
					begin
						if (pController.IR_Exec[11:9] == pController.IR[8:6])
							bypassAlu1 = 1;
					end

					`STR:
					begin
						if (pController.IR_Exec[11:9] == pController.IR[8:6])
						bypassAlu1 = 1;
						
						if (pController.IR_Exec[11:9] == pController.IR[11:9])
							bypassAlu2 = 1;
					end
				

					`ST , `STI:
					begin
						if (pController.IR_Exec[11:9] == pController.IR[11:9])
							bypassAlu2 = 1;
					end
					
					
					endcase
				
				end
		
		
		// Memory Bypass	
			if ((pController.IR_Exec[15:12] == `LD) ||  (pController.IR_Exec[15:12] == `LDI) || (pController.IR_Exec[15:12] == `LDR))// Load Operation
				begin
				
					casex(pController.IR[15:12])
				
					4'bxx01:	// ALU Operations
						begin
						if (pController.IR_Exec[11:9] == pController.IR[8:6])
							bypassMem1 = 1;

						if (!(pController.IR[5]))
							begin
								if 	(pController.IR_Exec[11:9] == pController.IR[2:0])
									bypassMem2 = 1;

							end
						
						end	

					`LDR:
					begin
						if (pController.IR_Exec[11:9] == pController.IR[8:6])
							bypassMem1 = 1;
					end

					`STR:
					begin
						if (pController.IR_Exec[11:9] == pController.IR[8:6])
							bypassMem1 = 1;
						
						if (pController.IR_Exec[11:9] == pController.IR[11:9])
							bypassMem2 = 1;
					end
				

					`ST: 
					begin
						if (pController.IR_Exec[11:9] == pController.IR[11:9])
							bypassMem2 = 1;
					end
											
				endcase		
			end
			

		end

		
	/**************** If JMP Instruction****************/
		if (pController.IR[15:12] == `JMP) // Not a control Instruction
		begin
			
			casex(pController.IR_Exec[15:12])
			
				4'bxx01:
				begin
					if (pController.IR_Exec[11:9] == pController.IR[8:6])
						bypassAlu1 = 1;
				end
			endcase
		end
		//**********************Bypass Logic Done********************************
		
		
	



		
	end//forever
endtask






/****************************Checker Task ************************/


	task con_chk();
	forever
	   begin

	@(posedge pController.cb);	
	/******************** MemState Checker*******************/
	if (pController.memState !=  memState)
	begin
		$display("ERROR in MemState"); 
		$display("Expected cb %b  Expected %b   and Local Value %b, Time: %t",pController.cb.memState, pController.memState,memState, $time);
	end

	/******************** Bypass Logic Checker*******************/

	if (pController.bypassAlu1 !=  bypassAlu1)
	begin
		$display("ERROR in bypassAlu1");
		$display("Expected %b    and Local Value %b, Time: %t", bypassAlu1, pController.bypassAlu1, $time);
	end

	if (pController.bypassAlu2 !=  bypassAlu2)
		begin
		$display("ERROR in bypassAlu2");
		$display("Expected %b    and Local Value %b, Time: %t", bypassAlu2, pController.bypassAlu2, $time);
		end

	if (pController.bypassMem1 !=  bypassMem1)
		$display("ERROR in bypassMem1 Exp: %b   Act:%b  Time: %t",bypassMem1, pController.bypassMem1,$time);

	if (pController.bypassMem2 !=  bypassMem2)
		$display("ERROR in bypassMem2 Exp: %b   Act:%b  Time: %t",bypassMem2, pController.bypassMem2,$time);




	/******************** Enable Checker*******************/

	if (pController.enableDecode !=  enable_decode)
		$display("ERROR in enable_decode!! Exp: %b and Act %b Time %t",enable_decode, pController.enableDecode ,$time);

	if (pController.enableExecute !=  enable_exec)
		$display("ERROR in enable_exec!! Exp: %b and Act %b Time %t",enable_exec, pController.enableExecute ,$time);

	if (pController.enableWriteback !=  enable_writeback)
		$display("ERROR in enable_writeback!! Exp: %b and Act %b Time %t",enable_writeback, pController.enableWriteback ,$time);



	end
	endtask




	task con_chk_enable();
	forever
	   begin
		@(pController.IR_Exec or pController.IMem_Dout or pController.brTaken or pController.IR or  pController.NZP  );

		/******************** Branch Checker*******************/

		if (pController.brTaken !=  br_taken)
			$display("ERROR in br_taken!!!  Exp: %b and Act %b Time %t",br_taken, pController.brTaken ,$time);

		if (pController.enableUpdatePC !=  enable_updatePC)
			$display("ERROR in enable_updatePC!! Exp: %b and Act %b Time %t ",enable_updatePC, pController.enableUpdatePC, $time);

		if (pController.enableFetch !=  enable_fetch)
			$display("ERROR in enable_fetch!!  Exp: %b and Act %b Time %t",  enable_fetch, pController.enableFetch, $time);
 

	   end
	endtask




endclass


	
