# ECE745_Project
# LC3 microcontroller verification project

Directions for running project:

1) git clone the directory onto the Linux AFS system
2) Use the "add modelsim10.3b" command to add the waveform viewer.
3) Export the .ini file with "export MODELSIM=modelsim.ini" command.
4) Enter "vlib mti_lib". This will setup the directories for verilog binaries.
5) Run the following commands to compile the DUT and TB:
  - "vlog *.vp" to compile the DUT's pipeline stages
  - "vlog *.v" to compile the top level DUT module.
  - "vlog *.sv" to compile the TB modules.
6) Now the modules can be loaded into ModelSim and run.
