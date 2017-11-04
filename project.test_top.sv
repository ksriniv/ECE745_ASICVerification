
module LC3_test_top;
	parameter simulation_cycle = 20;

	reg  SysClock;
	LC3_io top_io(SysClock);  // Instantiate the top level interface of the testbench to be used for driving the LC3 and reading the LC3 outputs.
	
	// Instantiating and Connecting the probe signals for the Fetch block with the DUT fetch block signals using the "dut" instantation of LC3 below.
	fetchinterface Fetch_Probe(
          .clock(dut.Fetch.clock), 
          .reset(dut.Fetch.reset), 
					.enable_updatePC(dut.Fetch.enable_updatePC), 
					.enable_fetch(dut.Fetch.enable_fetch), 
					.pc(dut.Fetch.pc), 
					.npc_out(dut.Fetch.npc_out),
					.instrmem_rd(dut.Fetch.instrmem_rd),
					.taddr(dut.Fetch.taddr),
					.br_taken(dut.Fetch.br_taken)
				);

  decode_if Decode_Probe(
    .enable_decode(dut.Dec.enable_decode),
		.instr_dout(dut.Dec.dout),
		.E_Control(dut.Dec.E_Control),
		.npc_in(dut.Dec.npc_in),
		.Mem_Control(dut.Dec.Mem_Control), 
		.W_Control(dut.Dec.W_Control), 
		.IR(dut.Dec.IR), 
		.npc_out(dut.Dec.npc_out),
    .reset(dut.Dec.reset),
    .clock(dut.Dec.clock)
    
  );

  Probe_MA MemAccess_Probe(
    .memaccess_mem_state(dut.MemAccess.mem_state),
    .memaccess_M_Control(dut.MemAccess.M_Control),
    .memaccess_M_Data(dut.MemAccess.M_Data),
    .memaccess_M_addr(dut.MemAccess.M_Addr),
    .memaccess_Mem_out(dut.MemAccess.memout),
    .memaccess_DMem_addr(dut.MemAccess.Data_addr),
    .memaccess_DMem_din(dut.MemAccess.Data_din),
    .memaccess_DMem_dout(dut.MemAccess.Data_dout),
    .memaccess_DMem_rd(dut.MemAccess.Data_rd)
    );

  Probe_WB Writeback_Probe(
					.wb_aluout(dut.WB.aluout),
					.wb_W_control(dut.WB.W_Control),
					.wb_pcout(dut.WB.pcout),
					.wb_memout(dut.WB.memout),
					.wb_VSR1(dut.WB.d1),
					.wb_VSR2(dut.WB.d2),
					.wb_dr(dut.WB.dr),
					.wb_sr1(dut.WB.sr1),
					.wb_sr2(dut.WB.sr2),
					.wb_psr(dut.WB.psr),
					.wb_enable_writeback(dut.WB.enable_writeback),
          .reset(dut.WB.reset),
          .clock(dut.WB.clock)
					);

  probe_execute Execute_probe(
				  .clock(dut.Ex.clock),
				  .reset(dut.Ex.reset),
				  .enable_execute(dut.Ex.enable_execute),
				  .E_Control(dut.Ex.E_Control),
				  .bypass_alu_1(dut.Ex.bypass_alu_1),
				  .bypass_alu_2(dut.Ex.bypass_alu_2),
				  .bypass_mem_1(dut.Ex.bypass_mem_1),
				  .bypass_mem_2(dut.Ex.bypass_mem_2),
				  .IR(dut.Ex.IR),
				  .npc_in(dut.Ex.npc),
			    .Mem_Control_in(dut.Ex.Mem_Control_in),
				  .W_Control_in(dut.Ex.W_Control_in),
				  .Mem_Bypass_Val(dut.Ex.Mem_Bypass_Val),    //doubtfil
				  .NZP(dut.Ex.NZP),
				  .IR_Exec(dut.Ex.IR_Exec),
				  .aluout(dut.Ex.aluout),
				  .W_Control_out(dut.Ex.W_Control_out),
				  .Mem_Control_out(dut.Ex.Mem_Control_out),
				  .M_Data(dut.Ex.M_Data),
				  .VSR1(dut.Ex.VSR1),
				  .VSR2(dut.Ex.VSR2),
				  .dr(dut.Ex.dr),
				  .sr1(dut.Ex.sr1),
				  .sr2(dut.Ex.sr2),
				  .pcout(dut.Ex.pcout)
  );

  probe_Controller Controller_Probe(					.clock(dut.Ctrl.clock),
									.reset(dut.Ctrl.reset ),
									.completeData(dut.Ctrl.complete_data),
									.completeInst(dut.Ctrl.complete_instr),
									.IR(dut.Ctrl.IR),
									.NZP(dut.Ctrl.NZP),
									.psr(dut.Ctrl.psr),
									.IR_Exec(dut.Ctrl.IR_Exec),
									.IMem_Dout(dut.Ctrl.Instr_dout),
									.enableUpdatePC(dut.Ctrl.enable_updatePC),
									.enableFetch(dut.Ctrl.enable_fetch),
									.enableDecode(dut.Ctrl.enable_decode),
									.enableExecute(dut.Ctrl.enable_execute),
									.enableWriteback(dut.Ctrl.enable_writeback),
									.brTaken(dut.Ctrl.br_taken),
									.bypassAlu1(dut.Ctrl.bypass_alu_1),
									.bypassAlu2(dut.Ctrl.bypass_alu_2),
									.bypassMem1(dut.Ctrl.bypass_mem_1),
									.bypassMem2(dut.Ctrl.bypass_mem_2),
									.memState(dut.Ctrl.mem_state) 
				);

	// Passing the top level interface and probe interface to the testbench.
	LC3_test test(top_io, Fetch_Probe, Decode_Probe, MemAccess_Probe, Execute_probe, Writeback_Probe, Controller_Probe);
	 
	// Instatiating the top-level DUT.
	LC3 dut(
		.clock(top_io.clock), 
		.reset(top_io.reset), 
		.pc(top_io.pc), 
		.instrmem_rd(top_io.instrmem_rd), 
		.Instr_dout(top_io.Instr_dout), 
		.Data_addr(top_io.Data_addr), 
		.complete_instr(top_io.complete_instr), 
		.complete_data(top_io.complete_data),
		.Data_din(top_io.Data_din),
		.Data_dout(top_io.Data_dout),
		.Data_rd(top_io.Data_rd)

		);


	initial 
	begin
		SysClock = 0;
		forever 
		begin
			#(simulation_cycle/2)
			SysClock = ~SysClock;
		end
	end
endmodule

