class coverage;

virtual LC3_io.TB top_io;
virtual fetchinterface Fetch_probe;
virtual decode_if Decode_probe;
virtual Probe_MA MemAccess_probe;
virtual probe_execute Execute_probe;
virtual Probe_WB Writeback_probe;
virtual probe_Controller Controller_Probe;

covergroup OPR_SEQ_cg;
Cov_opcode_order : coverpoint Decode_probe.instr_dout[15:12]
	{
		bins ALU_Memory = (4'b0101, 4'b0001, 4'b1001 => 4'b0010, 4'b0110, 4'b1010, 4'b1110, 4'b0011, 4'b0111, 4'b1011);
		bins Memory_Control = (4'b0010, 4'b0110, 4'b1010, 4'b1110, 4'b0011, 4'b0111, 4'b1011 => 4'b0101, 4'b0001, 4'b1001 );
		bins Memory_ALU = (4'b0010, 4'b0110, 4'b1010, 4'b1110, 4'b0011, 4'b0111, 4'b1011 => 4'b0101, 4'b0001, 4'b1001 );
	}
	Cov_mem_opcode : coverpoint Decode_probe.instr_dout[15:12]
	{
		bins LD_bin  = {4'b0010 };
		bins LDR_bin = {4'b0110};
		bins LDI_bin = {4'b1010};
		bins LEA_bin = {4'b1110};
		bins ST_bin  = {4'b0011 };
		bins STR_bin = {4'b0111};
		bins STI_bin = {4'b1011};
	}
	Cov_alu_opcode : coverpoint Decode_probe.instr_dout[15:12]
	{
		bins ADD_bin = {4'b0001};
		bins AND_bin = {4'b0101};
		bins NOT_bin = {4'b1001};
	}
	Cov_ctrl_opcode : coverpoint Decode_probe.instr_dout[15:12]
	{     
		bins BR_bin  = {4'b0000};
		bins JMP_bin = {4'b1100};
	}
endgroup

covergroup MEM_OPR_cg;
	Cov_mem_opcode : coverpoint Decode_probe.instr_dout[15:12]
	{
		bins LD_bin  = {4'b0010 };
		bins LDR_bin = {4'b0110};
		bins LDI_bin = {4'b1010};
		bins LEA_bin = {4'b1110};
		bins ST_bin  = {4'b0011 };
		bins STR_bin = {4'b0111};
		bins STI_bin = {4'b1011};
	}

		Cov_BaseR: coverpoint Decode_probe.instr_dout[8:6] iff ((Decode_probe.instr_dout[15:12] == 4'h6) || (Decode_probe.instr_dout[15:12] == 4'h7)); 
		Cov_SR: coverpoint Decode_probe.instr_dout[11:9] iff ((Decode_probe.instr_dout[15:12] == 4'h3) || (Decode_probe.instr_dout[15:12] == 4'h7) || (Decode_probe.instr_dout[15:12] == 4'hB)); 
		Cov_DR: coverpoint Decode_probe.instr_dout[11:9] iff ((Decode_probe.instr_dout[15:12] == 4'h2) || (Decode_probe.instr_dout[15:12] == 4'h6) || (Decode_probe.instr_dout[15:12] == 4'hA) || (Decode_probe.instr_dout[15:12] == 4'hE)); //LD, LDI, LDR, LEA
	Cov_PCoffset9 : coverpoint Decode_probe.instr_dout[8:0] iff(Decode_probe.instr_dout[15:12] == 4'b0010 || Decode_probe.instr_dout[15:12] == 4'b1010 || Decode_probe.instr_dout[15:12] == 4'b1110 || Decode_probe.instr_dout[15:12] == 4'b0011 || Decode_probe.instr_dout[15:12] == 4'b1011 || Decode_probe.instr_dout[15:12] == 4'b0000 )
	{
		option.auto_bin_max = 8 ;
	}
	Cov_PCoffset6 : coverpoint Decode_probe.instr_dout[5:0] iff(Decode_probe.instr_dout[15:12] == 4'b0110 || Decode_probe.instr_dout[15:12] == 4'b0111)
	{
		option.auto_bin_max = 8 ;
	}
	Cov_PCoffset9_c : coverpoint Decode_probe.instr_dout[8:0] iff(Decode_probe.instr_dout[15:12] == 4'b0010 || Decode_probe.instr_dout[15:12] == 4'b1010 || Decode_probe.instr_dout[15:12] == 4'b1110 || Decode_probe.instr_dout[15:12] == 4'b0011 || Decode_probe.instr_dout[15:12] == 4'b1011 || Decode_probe.instr_dout[15:12] == 4'b0000 )
	{
		bins PCoffset9_c_high= {9'b111111111};
		bins PCoffset9_c_low= {9'b000000000};
	}
	Cov_PCoffset6_c : coverpoint Decode_probe.instr_dout[5:0] iff(Decode_probe.instr_dout[15:12] == 4'b0110 || Decode_probe.instr_dout[15:12] == 4'b0111)
	{
		bins PCoffset6_c_high= {6'b111111};
		bins PCoffset6_c_low= {6'b000000};
	}

		
		Xc_BaseR_DR_offset6: cross Cov_BaseR, Cov_DR, Cov_PCoffset6 iff(Decode_probe.instr_dout[15:12] == 4'h6);				//LDR
		Xc_BaseR_DR_offset6_corner: cross Cov_BaseR, Cov_DR, Cov_PCoffset6_c iff(Decode_probe.instr_dout[15:12] == 4'h6);		//LDR
		
		Xc_BaseR_SR_offset6: cross Cov_BaseR, Cov_SR, Cov_PCoffset6 iff(Decode_probe.instr_dout[15:12] == 4'h7);				//STR
		Xc_BaseR_SR_offset6_corner: cross Cov_BaseR, Cov_SR, Cov_PCoffset6_c iff(Decode_probe.instr_dout[15:12] == 4'h7);		//STR
		
		Xc_DR_offset9: cross Cov_DR, Cov_PCoffset9 iff(Decode_probe.instr_dout[15:12] == 4'h2 || Decode_probe.instr_dout[15:12] == 4'hA || Decode_probe.instr_dout[15:12] == 4'hE);
		Xc_DR_offset9_corner: cross Cov_DR, Cov_PCoffset9_c iff(Decode_probe.instr_dout[15:12] == 4'h2 || Decode_probe.instr_dout[15:12] == 4'hA || Decode_probe.instr_dout[15:12] == 4'hE);
		
		Xc_SR_offset9: cross Cov_SR, Cov_PCoffset9 iff(Decode_probe.instr_dout[15:12] == 4'h3 || Decode_probe.instr_dout[15:12] == 4'hB);
		Xc_SR_offset9_corner: cross Cov_SR, Cov_PCoffset9_c iff(Decode_probe.instr_dout[15:12] == 4'h3 || Decode_probe.instr_dout[15:12] == 4'hB);


endgroup

covergroup CTRL_OPR_cg;

	Cov_ctrl_opcode : coverpoint Decode_probe.instr_dout[15:12]
	{
		bins BR_b  = {4'b0000};
		bins JMP_b = {4'b1100};
	}
	Cov_BaseR : coverpoint Decode_probe.instr_dout[8:6] iff(Decode_probe.instr_dout[15:12] == 4'b1100)
	{
		bins Base_JMP[] = {[0:7]};
	}
	Cov_NZP : coverpoint Decode_probe.instr_dout[11:9] iff(Decode_probe.instr_dout[15:12] == 4'b0000 || Decode_probe.instr_dout[15:12] == 4'b1100)
	{
			bins BRP = {1};
			bins BRZ = {2};
			bins BRZP = {3};
			bins BRN = {4};
			bins BRNP = {5};
			bins BRNZ = {6};
			bins BR = {7};
	}
	Cov_PSR : coverpoint Writeback_probe.wb_psr iff(Decode_probe.instr_dout[15:12] == 4'b0000 || Decode_probe.instr_dout[15:12] == 4'b1100)
	{
		bins psr_JMP_1 = {1};
		bins psr_JMP_2 = {2};
		bins psr_JMP_4 = {4};
	}
	Cov_PCoffset9 : coverpoint Decode_probe.instr_dout[8:0] iff(Decode_probe.instr_dout[15:12] == 4'b0000)
	{
		option.auto_bin_max = 8 ;
	}
	Cov_PCoffset9_c : coverpoint Decode_probe.instr_dout[8:0] iff(Decode_probe.instr_dout[15:12] == 4'b0000)
	{
		bins pcoffset9_corner_low   = {9'h000} ;
		bins pcoffset9_corner_high  = {9'h1FF} ;
	}
	Xc_NZP_PSR : cross Cov_NZP,Cov_PSR;
endgroup


covergroup ALU_OPR_cg;

	Cov_alu_opcode : coverpoint Decode_probe.instr_dout[15:12]
	{
		bins ADD_b = {4'b0001};
		bins AND_b = {4'b0101};
		bins NOT_b = {4'b1001};
	}
	Cov_alu_opcode_AND_ADD : coverpoint Decode_probe.instr_dout[15:12]
	{
		bins AND_p = {4'b0101};
		bins ADD_p = {4'b0001};
	}	
	Cov_alu_opcode_NOT : coverpoint Decode_probe.instr_dout[15:12]
	{
		bins NOT_p = {4'b1001};
	}
	Cov_DR: coverpoint Decode_probe.instr_dout[11:9] iff ((Decode_probe.instr_dout[15:12] == 4'h1) || (Decode_probe.instr_dout[15:12] == 4'h5) || (Decode_probe.instr_dout[15:12] == 4'h9));
        Cov_SR1: coverpoint Decode_probe.instr_dout[8:6] iff ((Decode_probe.instr_dout[15:12] == 4'h1) || (Decode_probe.instr_dout[15:12] == 4'h5) || (Decode_probe.instr_dout[15:12] == 4'h9));
        Cov_imm_en: coverpoint Decode_probe.instr_dout[5] iff ((Decode_probe.instr_dout[15:12] == 4'h1) || (Decode_probe.instr_dout[15:12] == 4'h5) || (Decode_probe.instr_dout[15:12] == 4'h9)); 
        Cov_SR2: coverpoint Decode_probe.instr_dout[2:0] iff ((Decode_probe.instr_dout[5] == 1'b0) && ((Decode_probe.instr_dout[15:12] == 4'h1) || (Decode_probe.instr_dout[15:12] == 4'h5)));
        Cov_imm5: coverpoint Decode_probe.instr_dout[4:0] iff ((Decode_probe.instr_dout[5] == 1'b1) && ((Decode_probe.instr_dout[15:12] == 4'h1) || (Decode_probe.instr_dout[15:12] == 4'h5)));

	Xc_opcode_imm_en : cross Cov_alu_opcode_AND_ADD,Cov_imm_en;
	Xc_opcode_dr_sr1_imm5 : cross Cov_alu_opcode_AND_ADD,Cov_SR1,Cov_DR,Cov_imm5 iff(Decode_probe.instr_dout[5] == 1'b1);			
	Xc_opcode_dr_sr1_sr2 : cross Cov_alu_opcode_AND_ADD,Cov_SR1,Cov_SR2,Cov_DR  iff(Decode_probe.instr_dout[5] == 1'b0);



      Cov_aluin1: coverpoint (Execute_probe.bypass_alu_1 ? Execute_probe.input_cbd.aluout : Execute_probe.bypass_mem_1 ? Execute_probe.Mem_Bypass_Val : Execute_probe.VSR1)
        {
           option.auto_bin_max = 8;
        }

        Cov_aluin1_corner: coverpoint (Execute_probe.bypass_alu_1 ? Execute_probe.input_cbd.aluout : Execute_probe.bypass_mem_1 ? Execute_probe.Mem_Bypass_Val : Execute_probe.VSR1)
        {
          bins zero = {0};
          bins one = {16'hffff};
          }
    Cov_opr_zero_zero_aluin1:coverpoint (Execute_probe.bypass_alu_1 ? Execute_probe.input_cbd.aluout : Execute_probe.bypass_mem_1 ? Execute_probe.Mem_Bypass_Val : Execute_probe.VSR1)
{
       bins zero_zero ={16'h0000};
}

Cov_opr_all1_zero_aluin1:coverpoint (Execute_probe.bypass_alu_1 ? Execute_probe.input_cbd.aluout : Execute_probe.bypass_mem_1 ? Execute_probe.Mem_Bypass_Val : Execute_probe.VSR1)
{
       bins all1_zero ={16'hfffe};
}
Cov_opr_all1_all1_aluin1:coverpoint (Execute_probe.bypass_alu_1 ? Execute_probe.input_cbd.aluout : Execute_probe.bypass_mem_1 ? Execute_probe.Mem_Bypass_Val : Execute_probe.VSR1)
{
       bins all1_all1 ={16'hffff};
}
Cov_opr_alt01_alt01_aluin1:coverpoint (Execute_probe.bypass_alu_1 ? Execute_probe.input_cbd.aluout : Execute_probe.bypass_mem_1 ? Execute_probe.Mem_Bypass_Val : Execute_probe.VSR1)
{
  bins alt01_alt01={16'h5555};
}

Cov_opr_alt10_alt10_aluin1:coverpoint (Execute_probe.bypass_alu_1 ? Execute_probe.input_cbd.aluout : Execute_probe.bypass_mem_1 ? Execute_probe.Mem_Bypass_Val : Execute_probe.VSR1)
{
  bins alt10_alt10={16'haaaa};
}
    
      Cov_aluin2_imm5: coverpoint { Execute_probe.IR[4:0]} iff (((Execute_probe.IR[15:12] == 4'h1) || (Execute_probe.IR[15:12] == 4'h5) || (Execute_probe.IR[15:12] == 4'h9)) && (Execute_probe.bypass_alu_2==0) && (Execute_probe.bypass_mem_2==0)&& (Execute_probe.IR[5]==1))
        {
           option.auto_bin_max = 8;
        }
       
      
      Cov_aluin2: coverpoint (Execute_probe.bypass_alu_2 ? Execute_probe.input_cbd.aluout : Execute_probe.bypass_mem_2 ? Execute_probe.Mem_Bypass_Val : Execute_probe.IR[5] ? {{11{Execute_probe.IR[4]}}, Execute_probe.IR[4:0]} : Execute_probe.VSR2)
        {
           option.auto_bin_max = 8;
        }

        Cov_aluin2_corner: coverpoint (Execute_probe.bypass_alu_2 ? Execute_probe.input_cbd.aluout : Execute_probe.bypass_mem_2 ? Execute_probe.Mem_Bypass_Val : Execute_probe.IR[5] ? {{11{Execute_probe.IR[4]}}, Execute_probe.IR[4:0]} : Execute_probe.VSR2)
        {
          bins zero = {0};
          bins one = {16'hffff};
          }

Cov_opr_zero_zero_aluin2:coverpoint (Execute_probe.bypass_alu_2 ? Execute_probe.input_cbd.aluout : Execute_probe.bypass_mem_2 ? Execute_probe.Mem_Bypass_Val : Execute_probe.IR[5] ? {{11{Execute_probe.IR[4]}}, Execute_probe.IR[4:0]} : Execute_probe.VSR2)
{
       bins zero_zero ={16'h0000};
}

Cov_opr_all1_zero_aluin2:coverpoint (Execute_probe.bypass_alu_2 ? Execute_probe.input_cbd.aluout : Execute_probe.bypass_mem_2 ? Execute_probe.Mem_Bypass_Val : Execute_probe.IR[5] ? {{11{Execute_probe.IR[4]}}, Execute_probe.IR[4:0]} : Execute_probe.VSR2)
{
       bins all1_zero ={16'hfffe};
}
Cov_opr_all1_all1_aluin2:coverpoint (Execute_probe.bypass_alu_2 ? Execute_probe.input_cbd.aluout : Execute_probe.bypass_mem_2 ? Execute_probe.Mem_Bypass_Val : Execute_probe.IR[5] ? {{11{Execute_probe.IR[4]}}, Execute_probe.IR[4:0]} : Execute_probe.VSR2)
{
       bins all1_all1 ={16'hffff};
}
Cov_opr_alt01_alt01_aluin2:coverpoint (Execute_probe.bypass_alu_2 ? Execute_probe.input_cbd.aluout : Execute_probe.bypass_mem_2 ? Execute_probe.Mem_Bypass_Val : Execute_probe.IR[5] ? {{11{Execute_probe.IR[4]}}, Execute_probe.IR[4:0]} : Execute_probe.VSR2)
{
  bins alt01_alt01={16'h5555};
}
Cov_opr_alt10_alt10_aluin2:coverpoint (Execute_probe.bypass_alu_2 ? Execute_probe.input_cbd.aluout : Execute_probe.bypass_mem_2 ? Execute_probe.Mem_Bypass_Val : Execute_probe.IR[5] ? {{11{Execute_probe.IR[4]}}, Execute_probe.IR[4:0]} : Execute_probe.VSR2)
{
  bins alt10_alt10={16'haaaa};
}
	Xc_opcode_aluin1 : cross Cov_alu_opcode,Cov_aluin1_corner;
	Xc_opcode_aluin2 : cross Cov_alu_opcode,Cov_aluin2_corner;
	Xc_Cov_opr_zero_ALL1 : cross Cov_alu_opcode_AND_ADD,Cov_aluin1_corner,Cov_aluin2_corner; 
		
	
	Cov_aluin1_pos_neg : coverpoint (Execute_probe.bypass_alu_1 ? Execute_probe.input_cbd.aluout[15] : Execute_probe.bypass_mem_1 ? Execute_probe.Mem_Bypass_Val[15] : Execute_probe.VSR1[15])
	{
		bins aluin1_pos = {1'b0} ;
		bins aluin1_neg = {1'b1} ;
	}
	Cov_aluin2_pos_neg : coverpoint (Execute_probe.bypass_alu_2 ? Execute_probe.input_cbd.aluout[15] : Execute_probe.bypass_mem_2 ? Execute_probe.Mem_Bypass_Val[15] : Execute_probe.IR[5] ? Execute_probe.IR[4] : Execute_probe.VSR2[15])
	{
		bins aluin2_pos = {1'b0} ;
		bins aluin2_neg = {1'b1} ;
	}
	Xc_Cov_opr_pos_neg : cross Cov_alu_opcode_AND_ADD,Cov_aluin1_pos_neg,Cov_aluin2_pos_neg;

Cov_aluin1_vsr1: coverpoint Execute_probe.VSR1 iff (((Execute_probe.IR[15:12] == 4'h1) || (Execute_probe.IR[15:12] == 4'h5) || (Execute_probe.IR[15:12] == 4'h9)) && (Execute_probe.bypass_alu_1==0) && (Execute_probe.bypass_mem_1==0))
        {
           option.auto_bin_max = 8;
        }

      Cov_aluin1_alu_bypass:coverpoint Execute_probe.input_cbd.aluout iff (((Execute_probe.IR[15:12] == 4'h1) || (Execute_probe.IR[15:12] == 4'h5) || (Execute_probe.IR[15:12] == 4'h9)) && (Execute_probe.bypass_alu_1==1) && (Execute_probe.bypass_mem_1==0))
        {
           option.auto_bin_max = 8;
        }

Cov_aluin2_vsr2: coverpoint Execute_probe.VSR2 iff (((Execute_probe.IR[15:12] == 4'h1) || (Execute_probe.IR[15:12] == 4'h5) || (Execute_probe.IR[15:12] == 4'h9)) && (Execute_probe.bypass_alu_2==0) && (Execute_probe.bypass_mem_2==0) && (Execute_probe.IR[5]==0))
        {
           option.auto_bin_max = 8;
        }

      Cov_aluin2_alu_bypass: coverpoint Execute_probe.input_cbd.aluout iff (((Execute_probe.IR[15:12] == 4'h1) || (Execute_probe.IR[15:12] == 4'h5) || (Execute_probe.IR[15:12] == 4'h9)) && (Execute_probe.bypass_alu_2==1) && (Execute_probe.bypass_mem_2==0)&& (Execute_probe.IR[5]==0))
        {
           option.auto_bin_max = 8;
        }
	cov_vsr1_vsr2 : cross Cov_aluin1_vsr1, Cov_aluin2_vsr2;
      	cov_vsr1_imm5 : cross Cov_aluin1_vsr1, Cov_aluin2_imm5;

endgroup

	function new(virtual LC3_io.TB top_io,virtual fetchinterface Fetch_probe,virtual decode_if Decode_probe,virtual Probe_MA MemAccess_probe,virtual probe_execute Execute_probe,virtual Probe_WB Writeback_probe,virtual probe_Controller Controller_Probe);

			this.top_io=top_io;
			this.Fetch_probe=Fetch_probe;
			this.Decode_probe=Decode_probe;
			this.MemAccess_probe=MemAccess_probe;
			this.Execute_probe=Execute_probe;
			this.Writeback_probe=Writeback_probe;
			this.Controller_Probe=Controller_Probe;
			
			   OPR_SEQ_cg=new();
			   MEM_OPR_cg=new();
			   CTRL_OPR_cg=new();
			   ALU_OPR_cg =new();
			
	endfunction

		task run;
			CTRL_OPR_cg.sample();
			OPR_SEQ_cg.sample();
			MEM_OPR_cg.sample();
			ALU_OPR_cg.sample();
			
		endtask
endclass
