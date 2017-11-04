program automatic LC3_test(LC3_io.TB top_io, fetchinterface Fetch_probe, decode_if Decode_probe, Probe_MA MemAccess_probe, probe_execute Execute_probe, Probe_WB Writeback_probe, probe_Controller Controller_Probe);
  `include "project.generator.sv"
  `include "project.decode.sv"
  `include "project.fetch.sv"
  `include "project.writeback.sv"
  `include "project.memaccess.sv"
  `include "project.execute.sv"
  `include "project.controller.sv"
  Generator gen;
  
  // pipeline stages
  fetch fe;
  Decode dec;
  writeback wb;
  memaccess ma;
  execute ex;
  controller con;

  initial begin
    gen = new(top_io, Fetch_probe,Decode_probe,MemAccess_probe,Execute_probe,Writeback_probe,Controller_Probe, 2000);
    dec = new(top_io, Decode_probe);
    fe = new(top_io, Fetch_probe);
    wb = new(top_io, Writeback_probe);
    ma = new(top_io, MemAccess_probe);
    ex = new(top_io, Execute_probe);
    con = new(Controller_Probe);
    fork
      gen.run();
      fe.run();
      dec.run();
      wb.run();
      ex.run();
      ma.run();
      con.run();
    join_any
  end
endprogram
