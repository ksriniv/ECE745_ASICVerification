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


interface dut_Probe_if(	
                                        // fetch block interface signals
                                        input   logic                           fetch_enable_updatePC,
                                        input   logic                           fetch_enable_fetch,
                                        input   logic                           fetch_br_taken,
                                        input   logic           [15:0]          fetch_taddr,
                                        input   logic                           fetch_instrmem_rd,
                                        input   logic           [15:0]          fetch_pc,
                                        input   logic           [15:0]          fetch_npc_out
                                        );
endinterface
/*----------------------- Interfaces File------------------------ */

interface LC3_io(input bit clock);
  	
	logic reset, instrmem_rd, complete_instr, complete_data, Data_rd; 
	logic [15:0] pc, Instr_dout, Data_addr,  Data_dout, Data_din;
  	

  	clocking cb @(posedge clock);
   	  default input #1 output #0;

		  // instruction memory side
		  input	pc; 
     	input	instrmem_rd;  
     	output Instr_dout;

		  // data memory side
		  input Data_din;
		  input Data_rd;
		  input Data_addr;		
		  output Data_dout;
		
		  output reset;
		
  	endclocking
    
    clocking stage @(posedge clock);
       	  
          default input #1 output #10;
		      // instruction memory side
		      input	pc; 
          input	instrmem_rd;  
         	output Instr_dout;

		      // data memory side
		      input Data_din;
		      input Data_rd;
		      input Data_addr;		
		      output Data_dout;
		
		      output reset;
		
    endclocking

  	modport TB(clocking cb, output complete_data, output complete_instr);   //modify to include reset
endinterface


//////////////////////////////////
//
//TO BE TESTED
//- Vijay
//
//////////////////////////////////

/*----------------------- Interface for Fetch Stage------------------------ */
/* Everything is input here instead because the first few are coming from control and the last three from DUT 
 This means that fetch doesn't have any outputs to display, all the outputs will be from the interface of top module */

interface fetchinterface (  	input logic clock, input logic reset, input logic enable_updatePC, input logic enable_fetch, input logic [15:0] taddr, 
				input logic br_taken, input logic instrmem_rd, input logic [15:0] npc_out, input logic [15:0] pc);	 
	
	// These below values are the one that Golden reference model would change as its output
	logic chkval_instrmem_rd;
	logic [15:0] chkval_pc, chkval_npc;

clocking cb @(posedge clock);
  input #1 reset,enable_updatePC,enable_fetch,taddr, br_taken,instrmem_rd,npc_out,pc;
endclocking

endinterface : fetchinterface


/*----------------------- Interface for Decode Stage ------------------------ */
interface decode_if(
	
          // decode block interface signals
  input logic enable_decode,
	input logic [15:0] instr_dout,
	input logic [5:0] E_Control,
	input logic [15:0] npc_in,
	input logic Mem_Control, 
	input logic [1:0] W_Control, 
	input logic [15:0] IR, 
	input logic [15:0] npc_out,
  input logic reset,
  input logic clock
                                        );

  clocking input_cb @(posedge clock);
    default input #1;
    input enable_decode;
	  input instr_dout;
	  input E_Control;
	  input npc_in;
	  input Mem_Control; 
	  input W_Control; 
	  input IR; 
	  input npc_out;
    input reset;
  endclocking

property rst_de;
@(posedge clock)
reset|-> ##1(!(Mem_Control||W_Control||IR ||E_Control|| npc_out));
endproperty
assert property(rst_de);
cover property(rst_de);
endinterface

/*----------------------- Interface for Execute Stage ------------------------ */

interface probe_execute(
					input logic 				clock,
					input logic 				reset,
					input logic 				enable_execute,
					input logic		[5:0]		E_Control,
					input logic					bypass_alu_1,
					input logic					bypass_alu_2,
					input logic					bypass_mem_1,
					input logic					bypass_mem_2,
					input logic		[15:0]		IR,
					input logic		[15:0]		npc_in,
					input logic					Mem_Control_in,
					input logic		[1:0]		W_Control_in,
					input logic		[15:0]		Mem_Bypass_Val,    //doubtfil
					input logic		[2:0]		NZP,
					input logic		[15:0]		IR_Exec,
					input logic		[15:0]		aluout,
					input logic		[1:0]		W_Control_out,
					input logic					Mem_Control_out,
					input logic		[15:0]		M_Data,
					input logic		[15:0]		VSR1,
					input logic		[15:0]		VSR2,
					input logic		[2:0]		dr,
					input logic		[2:0]		sr1,
					input logic		[2:0]		sr2,
					input logic 	[15:0]		pcout
					);
					
//check about asynchronous signals
clocking input_cbd @(posedge clock);
    default input #1;
					input  				reset;
					input  				enable_execute;
					input 				E_Control;
					input 				bypass_alu_1;
					input 				bypass_alu_2;
					input 				bypass_mem_1;
					input 				bypass_mem_2;
					input 				IR;
					input 				npc_in;
					input 				Mem_Control_in;
					input 				W_Control_in;
					input 				Mem_Bypass_Val;    //doubtfil
					input 				NZP;
					input 				IR_Exec;
					input 				aluout;
					input 				W_Control_out;
					input 				Mem_Control_out;
					input 				M_Data;
					input 				VSR1;
					input 				VSR2;
					input 				dr;
					input 				sr1;
					input 				sr2;
					input  				pcout;
  endclocking
property rst_ex;
@(posedge clock)
reset|-> ##1(!(Mem_Control_out||W_Control_out||dr||NZP||IR_Exec||aluout||pcout||M_Data));
endproperty
assert property(rst_ex);
cover property(rst_ex);
endinterface

/*----------------------- Interface for Writeback Stage ------------------------ */
interface Probe_WB(
					input logic		[15:0]		wb_aluout,
					input logic		[1:0]		wb_W_control,
					input logic		[15:0]		wb_pcout,
					input logic		[15:0]		wb_memout,
					input logic		[15:0]		wb_VSR1,
					input logic		[15:0]		wb_VSR2,
					input logic		[2:0]		wb_dr,
					input logic		[2:0]		wb_sr1,
					input logic		[2:0]		wb_sr2,
					input logic		[2:0]		wb_psr,
					input logic		wb_enable_writeback,
          input logic   reset,
          input logic   clock
					);

  clocking cb@(posedge clock);
    default input #1;
    input wb_aluout;
    input wb_W_control;
    input wb_pcout;
    input wb_memout;
    input wb_VSR1;
    input wb_VSR2;
    input wb_dr;
    input wb_sr1;
    input wb_sr2;
    input wb_psr;
    input wb_enable_writeback;
    input reset;
  endclocking
property rst_wb;
@(posedge clock)
reset|->##1(!wb_psr);
endproperty 
assert property(rst_wb);
cover property(rst_wb);
endinterface

/*----------------------- Interface for Memory Stage ------------------------ */

interface Probe_MA(
    input logic [1:0] memaccess_mem_state,
    input logic memaccess_M_Control,
    input logic [15:0] memaccess_M_Data,
    input logic [15:0] memaccess_M_addr,
    input logic [15:0] memaccess_Mem_out,
    input logic [15:0] memaccess_DMem_addr,
    input logic [15:0] memaccess_DMem_din,
    input logic [15:0] memaccess_DMem_dout,
    input logic memaccess_DMem_rd
    );
clocking cb@( memaccess_mem_state);
    default input #1;
    input  memaccess_Mem_out;
    input  memaccess_DMem_addr;
    input  memaccess_DMem_din;
    input  memaccess_DMem_rd;
  endclocking
endinterface

/*----------------------- Interface for Control------------------------ */
interface probe_Controller(						input clock,
									input reset,
									input completeData,
									input completeInst,
									input [15:0] IR,
									input [2:0] NZP,
									input [2:0] psr,
									input [15:0] IR_Exec,
									input [15:0] IMem_Dout,
									input enableUpdatePC,
									input enableFetch,
									input enableDecode,
									input enableExecute,
									input enableWriteback,
									input brTaken,
									input bypassAlu1,
									input bypassAlu2,
									input bypassMem1,
									input bypassMem2,
									input [1:0] memState);
	clocking cb @(posedge clock);
		input #1 clock, reset, completeData, completeInst, IR, NZP, psr, IR_Exec, IMem_Dout, enableUpdatePC, enableFetch, enableDecode, enableExecute, enableWriteback, brTaken, bypassAlu1, bypassAlu2, bypassMem1, bypassMem2, memState;
	endclocking
	
	/*##############################################################################################################################*/
	/*------------------- Control Stage Enable Properties, Writeback for Loads and Stores ----------------- */
	property rst_ctrl;
		@(posedge clock)
		reset |-> ( enableFetch == 0 && enableUpdatePC == 0 && enableDecode == 0 && enableWriteback == 0 && enableExecute == 0 && memState == 2'h3);
	endproperty 

		//------------branch taken----------------------//
	property ctrl_br_taken_jmp;
		@(posedge clock)
		|(NZP & psr)|-> brTaken==1;
	endproperty
	

	property ctrl_enableFetch_init;
		@(posedge clock)
		( (!reset) &&  (IR_Exec[15:12] == `LD || IR_Exec[15:12] == `LDR || IR_Exec[15:12]== `ST || IR_Exec[15:12] == `STR || IR_Exec[15:12] == `LDI || IR_Exec[15:12] == `STI)) |-> enableFetch == 1'h0;  
	endproperty


	property ctrl_enableFetch_A;
		@(posedge clock)
		 ((!reset) &&  (IR_Exec[15:12]== `LD || IR_Exec[15:12] == `LDR || IR_Exec[15:12] == `ST || IR_Exec[15:12] == `STR)) |=> enableFetch == 1'h1;
	endproperty

	property ctrl_enableFetch_B;
		@(posedge clock)
		((!reset) && (IR_Exec[15:12] == `LDI || IR_Exec[15:12] == `STI))|-> ##2 enableFetch == 1'h1;
	endproperty

property ctrl_enableFetch_c;
		@(posedge clock)
		((IR_Exec[15:12] == `BR || IR_Exec[15:12] == `JMP))|-> ##3 enableFetch;
	endproperty
assert property (ctrl_enableFetch_c);
cover property (ctrl_enableFetch_c);


	property ctrl_enableDecode_init;
		@(posedge clock)
		( (!reset) && (IR_Exec[15:12] == `LD || IR_Exec[15:12] == `LDR || IR_Exec[15:12]== `ST || IR_Exec[15:12] == `STR || IR_Exec[15:12] == `LDI || IR_Exec[15:12] == `STI))|-> enableDecode == 1'h0; 
	endproperty


	property ctrl_enableDecode_A;
		@(posedge clock)
		 ((!reset) && (IR_Exec[15:12] == `LD || IR_Exec[15:12] == `LDR || IR_Exec[15:12] == `ST || IR_Exec[15:12] == `STR)) |=> ##1 enableDecode == 1'h1;      
	endproperty

	property ctrl_enableDecode_B;
		@(posedge clock)
		((!reset) &&  (IR_Exec[15:12]==`LDI || IR_Exec[15:12]==`STI)) |-> ##2 enableDecode == 1'h1; 
	endproperty

property ctrl_enableDecode_C;
		@(posedge clock)
		((IR_Exec[15:12]==`BR || IR_Exec[15:12]==`JMP)) |-> ##4 enableDecode; 
	endproperty


cover property (ctrl_enableDecode_C);

	property ctrl_enableExecute_init;
		@(posedge clock)
		((!reset) && (IR_Exec[15:12] == `LD || IR_Exec[15:12]== `LDR || IR_Exec[15:12]== `ST || IR_Exec[15:12]== `STR || IR_Exec[15:12]==`LDI || IR_Exec[15:12]==`STI)) |-> enableExecute == 1'h0; 
	endproperty


	property ctrl_enableExecute_A;
		@(posedge clock)
		((!reset) && (IR_Exec[15:12] == `LD || IR_Exec[15:12] == `LDR || IR_Exec[15:12] == `ST || IR_Exec[15:12] == `STR)) |=> enableExecute == 1'h1;      
	endproperty


	property ctrl_enableExecute_B;
		@(posedge clock)
		((!reset) && (IR_Exec[15:12]==`LDI || IR_Exec[15:12]==`STI)) |-> ##2 enableExecute == 1'h1; 
	endproperty

property ctrl_enableExecute_C;
		@(posedge clock)
		((IR_Exec[15:12]==`BR || IR_Exec[15:12]==`JMP)) |-> ##5 enableExecute; 
	endproperty


cover property (ctrl_enableExecute_C);


	property ctrl_enableWriteback_init;
		@(posedge clock)
		((!reset) && (IR_Exec[15:12] == `LD || IR_Exec[15:12]== `LDR || IR_Exec[15:12]== `ST || IR_Exec[15:12]== `STR || 	IR_Exec[15:12]==`LDI || IR_Exec[15:12]==`STI)) |-> enableWriteback == 1'h0; 
	endproperty


	property ctrl_enableWriteback_A;
		@(posedge clock)
		((!reset) && (IR_Exec[15:12] == `LD || IR_Exec[15:12] == `LDR)) |=> enableWriteback == 1'h1;      
	endproperty

	property ctrl_enableWriteback_B;
		@(posedge clock)
		((!reset) && (IR_Exec[15:12]==`LDI || IR_Exec[15:12] == `ST || IR_Exec[15:12] == `STR)) |-> ##2 enableWriteback == 1'h1;      
	endproperty

	property ctrl_enableWriteback_C;
		@(posedge clock)
		((!reset) && ( IR_Exec[15:12]==`STI)) |-> ##3 enableWriteback == 1'h1; 
	endproperty

property ctrl_enableWriteback_D;
		@(posedge clock)
		((!reset) && ( IR_Exec[15:12]==`BR ||IR_Exec[15:12]==`JMP )) |-> ##6 enableWriteback == 1'h1; 
	endproperty

cover property (ctrl_enableWriteback_D);
	
	property ctrl_enable_memState_3;
		@(posedge clock)
		(!reset && (IR_Exec[15:12]== `LD || IR_Exec[15:12]== `LDR || IR_Exec[15:12] == `ST || IR_Exec[15:12]== `STR))|=> memState == 2'h3;
	endproperty
	
/*############################################################################################################################# */
	/*------------------- Control Stage Bypass ALU Properties ----------------- */

property CTRL_bypass_alu_1_AA;
			@(posedge clock)
		((IR[15:12] == `ADD) || (IR[15:12] == `AND) || (IR[15:12] == `NOT)) && ((IR_Exec[15:12] == `ADD) || (IR_Exec[15:12] == `AND) || (IR_Exec[15:12] == `NOT) || (IR_Exec[15:12] == `LEA)) && (IR_Exec[11:9] == IR[8:6]) |-> bypassAlu1 == 1'b1;
		endproperty



		property CTRL_bypass_alu_2_AA;
			@(posedge clock)
		((IR[15:12] == `ADD) || (IR[15:12] == `AND) || (IR[15:12] == `NOT)) && ((IR_Exec[15:12] == `ADD) || (IR_Exec[15:12] == `AND) || (IR_Exec[15:12] == `NOT) || (IR_Exec[15:12] == `LEA)) && ((IR_Exec[11:9] == IR[2:0]) && (IR[5] == 1'b0)) |->bypassAlu2 == 1'b1;
		endproperty

		property CTRL_bypass_alu_1_AL;
			@(posedge clock)
		((IR_Exec[15:12] == `ADD) || (IR_Exec[15:12] == `AND) || (IR_Exec[15:12] == `NOT)) && (IR[15:12] == `LDR) && (IR_Exec[11:9] == IR[8:6]) |-> bypassAlu1 == 1'b1;
		endproperty

	property ctrl_bypassAlu1_AS;
		@(posedge clock)
			((IR_Exec[15:12]  ==  `ADD || IR_Exec[15:12]  ==  `AND || IR_Exec[15:12]  ==  `NOT )&&( IR[15:12]  ==  `STR) && (IR_Exec[11:9]  ==  IR[8:6])) |-> bypassAlu1 == 1'h1;
	endproperty
	
assert property (CTRL_bypass_alu_1_AA);
	cover property (CTRL_bypass_alu_1_AA);

assert property (CTRL_bypass_alu_2_AA);
	cover property (CTRL_bypass_alu_2_AA);

assert property (CTRL_bypass_alu_1_AL);
	cover property (CTRL_bypass_alu_1_AL);
assert property (ctrl_bypassAlu1_AS);
	cover property (ctrl_bypassAlu1_AS);
	
	
/*############################################################################################################################# */
		/*------------------- Control Stage Bypass MEM Properties ----------------- */

	property ctrl_bypassMem1_LA;
		@(posedge clock)
		((IR_Exec[15:12] == `LD || IR_Exec[15:12] == `LDR || IR_Exec[15:12] == `LDI) && (IR[15:12] == `ADD || IR[15:12] == `AND || IR[15:12] == `NOT) && (IR_Exec[11:9] == IR[8:6])) |-> bypassMem1 == 1'h1;
	endproperty
	

	property ctrl_bypassMem2_LA;
		@(posedge clock)
		((IR_Exec[15:12] == `LD || IR_Exec[15:12] == `LDR || IR_Exec[15:12] == `LDI) && (IR[15:12] == `ADD || IR[15:12] == `AND || IR[15:12] == `NOT) && ((IR_Exec[11:9] == IR[2:0]) && (IR[5]!=1'h1))) |-> bypassMem2 == 1'h1;
	endproperty
	
	
/*############################################################################################################################# */
	/*------------------- Control Stage memState Properties ----------------- */
	
	property ctrl_memstate_3_2;
		@(posedge clock)
		(!reset) && (memState==2'b11)&&(IR[15:12]==`STI)|=>  memState == 2'h1 ##1 memState == 2'h2;
	endproperty
	
	property ctrl_memstate_3_1;
		@(posedge clock)
		(!reset) && (memState==2'b11)&&(IR[15:12]==`LDI)|=> memState == 2'h1;
	endproperty
	
	property ctrl_memstate_3_0;
		@(posedge clock)
		(!reset) && (memState==2'b11)&&(IR[15:12]==`LDI) |=> memState == 2'h1 ##1 memState == 2'h0;  
	endproperty

	property ctrl_memstate_2_3;
		@(posedge clock)
		(!reset) &&(memState == 2'b10)&&(completeData==1) |=> memState == 2'h3; 
	endproperty

	property ctrl_memstate_1_2;
		@(posedge clock)
		memState == 2'h1 |=> memState == 2'h2; 
	endproperty	

	property ctrl_memstate_1_0;
		@(posedge clock)
		memState == 2'h1 |=> memState == 2'h0; 
	endproperty
	
	property ctrl_memstate_0_3;
		@(posedge clock)
		(!reset) &&(memState == 2'b00)&&(completeData==1) |=> memState == 2'h3;  
	endproperty

	property ctrl_memstate_sti;
		@(posedge clock)
		(IR_Exec[15:12] == `STI) |-> memState == 2'h1 ##1 memState == 2'h2 ##1 memState == 2'h3;
	endproperty

	property ctrl_memstate_ldi;
		@(posedge clock)
		(IR_Exec[15:12] == `LDI) |-> memState == 2'h1 ##1 memState == 2'h0 ##1 memState == 2'h3;
	endproperty

/*############################################################################################################################# */	
	/*------------------- Control Stage FSM Stall Property ----------------- */

	property ctrl_fsm_stall;
		@(posedge clock)
		(IR_Exec[15:12] == `LD || IR_Exec[15:12]== `LDR || IR_Exec[15:12]== `ST || IR_Exec[15:12]== `STR || IR_Exec[15:12]==`LDI || IR_Exec[15:12]==`STI)|-> (enableFetch == 0 && enableDecode == 1'h0 && enableExecute == 1'h0 && enableWriteback == 1'h0); 
	endproperty
	/*--------------------- Cover Properties ------------------- */	
	
assert property(rst_ctrl);
	cover property(rst_ctrl);

	assert property(ctrl_br_taken_jmp);
	cover property(ctrl_br_taken_jmp);	
	

	cover property (ctrl_enableFetch_init);

assert property (ctrl_enableFetch_A);
	cover property (ctrl_enableFetch_A);

assert property (ctrl_enableFetch_B);
	cover property (ctrl_enableFetch_B);


	cover property (ctrl_enableDecode_init);

assert property (ctrl_enableDecode_A);
	cover property (ctrl_enableDecode_A);

assert property (ctrl_enableDecode_B);
	cover property (ctrl_enableDecode_B);


	cover property (ctrl_enableExecute_init);

assert property (ctrl_enableExecute_A);
	cover property (ctrl_enableExecute_A);

assert property (ctrl_enableExecute_B);
	cover property (ctrl_enableExecute_B);

assert property (ctrl_enable_memState_3);
	cover property (ctrl_enable_memState_3);


	cover property (ctrl_enableWriteback_init);

assert property (ctrl_enableWriteback_A);
	cover property (ctrl_enableWriteback_A);
	
assert property (ctrl_enableWriteback_B);
	cover property (ctrl_enableWriteback_B);

assert property (ctrl_enableWriteback_C);
	cover property (ctrl_enableWriteback_C);


	
assert property (ctrl_bypassMem1_LA);
	cover property (ctrl_bypassMem1_LA);

assert property (ctrl_bypassMem2_LA);
	cover property (ctrl_bypassMem2_LA);
	
        
	cover property (ctrl_memstate_3_2);

assert property (ctrl_memstate_3_1);
	cover property (ctrl_memstate_3_1);

assert property (ctrl_memstate_3_0);
	cover property (ctrl_memstate_3_0);

assert property (ctrl_memstate_2_3);
	cover property (ctrl_memstate_2_3);


	cover property (ctrl_memstate_1_2);


	cover property (ctrl_memstate_1_0);

assert property (ctrl_memstate_0_3);
	cover property (ctrl_memstate_0_3);

cover property (ctrl_memstate_sti);
	cover property (ctrl_memstate_sti);

cover property (ctrl_memstate_ldi);
	cover property (ctrl_memstate_ldi);
	

	cover property (ctrl_fsm_stall);
	
	
endinterface
