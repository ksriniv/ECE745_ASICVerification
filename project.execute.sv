class execute;

   //outputs
   logic [15:0] aluout, pcout;
   logic [1:0]  W_Control_out;
   logic  Mem_Control_out;
   logic [2:0]  NZP;
   logic [15:0] IR_Exec;
   logic [2:0]  sr1, sr2;   //asynchronous
   logic [2:0]  dr;
   logic [15:0] M_Data;

   //Temporary Variables
   logic [15:0] aluin1_out, aluin2_out;


   virtual LC3_io.TB topio;
   virtual probe_execute prob_exec;

   extern function logic [15:0] aluin1(logic bypass_alu_1, bypass_mem_1, logic [15:0] VSR1, logic [15:0] Mem_Bypass_Val, logic [15:0] aluout);
   extern function logic [15:0] aluin2(logic bypass_alu_2, bypass_mem_2, logic mode, logic [4:0] imm5, logic [15:0] VSR2, logic [15:0] Mem_Bypass_Val, logic [15:0] aluout);

  function new(virtual LC3_io.TB topio,virtual probe_execute prob_exec);
    this.topio = topio;
    this.prob_exec = prob_exec;
  endfunction

  task run();
    forever
    begin
	fork
        goldenref_execute();
	async_nzp();
	check_execute();
 	check_async();
	join
    end
  endtask: run

  task goldenref_execute();
	@(prob_exec.input_cbd);
           //begin       
        if(prob_exec.input_cbd.reset)
         begin
          aluout = 16'b0;
          pcout = 16'b0;
          W_Control_out = 2'b0;
          Mem_Control_out = 0;
          IR_Exec = 16'b0;
         
          dr = 3'b0;
          M_Data = 16'b0;
            sr1 = 0;
            sr2 = 0;
          end

        else
        begin
	
        if(prob_exec.input_cbd.enable_execute == 1)
          begin
             W_Control_out = prob_exec.input_cbd.W_Control_in;
             Mem_Control_out = prob_exec.input_cbd.Mem_Control_in;
             IR_Exec = prob_exec.input_cbd.IR;
//calculation of DR
             if((prob_exec.input_cbd.IR[15:12]==4'd1)||(prob_exec.input_cbd.IR[15:12]==4'd5)||(prob_exec.input_cbd.IR[15:12]==4'd9)||(prob_exec.input_cbd.IR[15:12]==4'd2)||(prob_exec.input_cbd.IR[15:12]==4'd6)||(prob_exec.input_cbd.IR[15:12]==4'd10)||(prob_exec.input_cbd.IR[15:12]==4'd14))
                dr  = prob_exec.input_cbd.IR[11:9];
             else 
                dr = 3'b0;
            
        aluin1_out = aluin1(prob_exec.input_cbd.bypass_alu_1, prob_exec.input_cbd.bypass_mem_1, prob_exec.input_cbd.VSR1, prob_exec.input_cbd.Mem_Bypass_Val, aluout);
        aluin2_out = aluin2(prob_exec.input_cbd.bypass_alu_2,prob_exec.input_cbd.bypass_mem_2, prob_exec.input_cbd.IR[5], prob_exec.input_cbd.IR[4:0], prob_exec.input_cbd.VSR2, prob_exec.input_cbd.Mem_Bypass_Val, aluout);
//calculation of M_Data
        M_Data = prob_exec.input_cbd.VSR2;
        if(prob_exec.input_cbd.bypass_alu_2) 
            M_Data = aluin2_out;
//calculation of aluout          
        if(prob_exec.input_cbd.IR[15:12] == 4'd1 || prob_exec.input_cbd.IR[15:12] == 4'd5 || prob_exec.input_cbd.IR[15:12] == 4'd9)
        begin
                if(prob_exec.input_cbd.E_Control[5:4] == 2'b00)
                  aluout = aluin1_out + aluin2_out;
                else if(prob_exec.input_cbd.E_Control[5:4] == 2'b01)
                  aluout = aluin1_out & aluin2_out;
                else if(prob_exec.input_cbd.E_Control[5:4] == 2'b10)
                  aluout = ~(aluin1_out);
                else
                  aluout = 16'b0;

                pcout = aluout;
        end //aluout end
        else //calculation of pcout
        begin
                  if(prob_exec.input_cbd.E_Control[3:2]==2'b00)
                      begin
                           if(prob_exec.input_cbd.E_Control[1])
                           pcout = prob_exec.input_cbd.npc_in - 16'b1 + {{5{prob_exec.input_cbd.IR[10]}},prob_exec.input_cbd.IR[10:0]};
                           else
                           pcout = aluin1(prob_exec.input_cbd.bypass_alu_1, prob_exec.input_cbd.bypass_mem_1, prob_exec.input_cbd.VSR1, prob_exec.input_cbd.Mem_Bypass_Val, aluout) + {{5{prob_exec.input_cbd.IR[10]}},prob_exec.input_cbd.IR[10:0]};
                        end
                  else if(prob_exec.input_cbd.E_Control[3:2]==2'b01)
                      begin
                           if(prob_exec.input_cbd.E_Control[1])
                           pcout = prob_exec.input_cbd.npc_in - 16'b1 + {{7{prob_exec.input_cbd.IR[8]}},prob_exec.input_cbd.IR[8:0]};
                           else
                           pcout = aluin1(prob_exec.input_cbd.bypass_alu_1, prob_exec.input_cbd.bypass_mem_1, prob_exec.input_cbd.VSR1, prob_exec.input_cbd.Mem_Bypass_Val, aluout) + {{7{prob_exec.input_cbd.IR[8]}},prob_exec.input_cbd.IR[8:0]};
                        end
                  else if(prob_exec.input_cbd.E_Control[3:2]==2'b10)
                      begin
                           if(prob_exec.input_cbd.E_Control[1])
                           pcout =  prob_exec.input_cbd.npc_in  - 16'b1 + {{10{prob_exec.input_cbd.IR[5]}},prob_exec.input_cbd.IR[5:0]};
                           else
                           pcout = aluin1(prob_exec.input_cbd.bypass_alu_1, prob_exec.input_cbd.bypass_mem_1, prob_exec.input_cbd.VSR1, prob_exec.input_cbd.Mem_Bypass_Val, aluout) + {{10{prob_exec.input_cbd.IR[5]}},prob_exec.input_cbd.IR[5:0]};
                        end
                  else if(prob_exec.input_cbd.E_Control[3:2]==2'b11)
                      begin
                           if(prob_exec.input_cbd.E_Control[1])
                           pcout =  prob_exec.input_cbd.npc_in  - 16'b1;
                           else
                           pcout = aluin1(prob_exec.input_cbd.bypass_alu_1, prob_exec.input_cbd.bypass_mem_1, prob_exec.input_cbd.VSR1, prob_exec.input_cbd.Mem_Bypass_Val, aluout);
                        end
                  else 
                      pcout = 16'b0;
          aluout = pcout;
        end //pcoutend

          end
        end
           //end
sr1 = prob_exec.IR[8:6];
              if(prob_exec.IR[15:12]==4'd1 || prob_exec.IR[15:12]==4'd5 || prob_exec.IR[15:12]==4'd9) sr2 = prob_exec.IR[2:0];
              else if(prob_exec.IR[15:12]==4'd3 || prob_exec.IR[15:12]==4'd7 || prob_exec.IR[15:12]==4'd11) sr2 = prob_exec.IR[11:9];
              else if(prob_exec.IR[15:12]==4'd0 || prob_exec.IR[15:12]==4'd12 || prob_exec.IR[15:12]==4'd2 || prob_exec.IR[15:12]==4'd6 || prob_exec.IR[15:12]==4'd10 || prob_exec.IR[15:12]==4'd14)sr2 = 3'b0;
           
       
  endtask

  task async_nzp();

	if(prob_exec.reset)
	 NZP=3'b0;
	@(prob_exec.input_cbd);
	if(prob_exec.input_cbd.enable_execute == 0)
	    NZP = 3'b0;
	else
	begin
		//calculation of NZP
             if(prob_exec.input_cbd.IR[15:12] == 4'b0000)
                NZP = prob_exec.input_cbd.IR[11:9];
             else if(prob_exec.input_cbd.IR[15:12] == 4'b1100)
                NZP = 3'b111;
             else
                NZP = 3'b0;
	end
  endtask

  task check_execute();
          if(aluout !== prob_exec.aluout)
              $display($time,"BUG IN EXECUTE DUT aluout_DUT = %h | aluout = %h\n",prob_exec.aluout,aluout);

          if(pcout !== prob_exec.pcout)
              $display($time,"BUG IN EXECUTE DUT pcout_DUT = %h | pcout = %h\n",prob_exec.pcout,pcout);

          if(NZP !== prob_exec.NZP)
              $display($time,"BUG IN EXECUTE DUT NZP_DUT = %b | NZP = %b\n",prob_exec.NZP,NZP);

if(dr !== prob_exec.dr) 
              $display($time,"BUG IN EXECUTE DUT dr_DUT = %b | dr = %b\n",prob_exec.dr,dr);


          if(M_Data !== prob_exec.M_Data)
              $display($time,"BUG IN EXECUTE DUT M_Data_DUT = %h | M_Data = %h \n",prob_exec.M_Data,M_Data);
          
          if(W_Control_out !== prob_exec.W_Control_out)
              $display($time,"BUG IN EXECUTE DUT W_Control_out_DUT = %h | W_Control_out = %h\n",prob_exec.W_Control_out,W_Control_out);
          
          if(Mem_Control_out !== prob_exec.Mem_Control_out)
              $display($time,"BUG IN EXECUTE DUT Mem_Control_out_DUT = %h | Mem_Control_out = %h\n",prob_exec.Mem_Control_out,Mem_Control_out);
          
          if(IR_Exec !== prob_exec.IR_Exec)
              $display($time,"BUG IN EXECUTE DUT IR_Exec_DUT = %h | IR_Exec = %h\n",prob_exec.IR_Exec,IR_Exec);
  endtask


  task check_async();
          if(sr1 !== prob_exec.sr1) 
              $display($time,"BUG IN EXECUTE DUT sr1_DUT = %b | sr1 = %b\n",prob_exec.sr1,sr1);

          if(sr2 !== prob_exec.sr2)
              $display($time,"BUG IN EXECUTE DUT sr2_DUT = %b | sr2 = %b\n",prob_exec.sr2,sr2);
  endtask
endclass


function logic [15:0] execute :: aluin1(logic bypass_alu_1, logic bypass_mem_1, logic [15:0] VSR1, logic [15:0] Mem_Bypass_Val, logic [15:0] aluout);
   case({bypass_mem_1,bypass_alu_1})
      2'b01: aluin1 = aluout;
      2'b10: aluin1 = Mem_Bypass_Val;
      default: aluin1 = VSR1;
   endcase
endfunction


function logic [15:0] execute :: aluin2(logic bypass_alu_2, logic bypass_mem_2, logic mode, logic [4:0] imm5, logic [15:0] VSR2, logic [15:0] Mem_Bypass_Val, logic [15:0] aluout);
   case({bypass_mem_2,bypass_alu_2})
      2'b01: aluin2 = aluout;
      2'b10: aluin2 = Mem_Bypass_Val;
      default: begin
                  if(mode == 0)
                     aluin2 = VSR2;
                  else
                     aluin2 = {{11{imm5[4]}},imm5[4:0]};
               end
   endcase
endfunction



