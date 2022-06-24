all: compile run
compile: rtl_analyze frontend middlend backend

generate_machinelist:
	@echo "==== Generating machine list for parallel compilation"
	seq 10 | sed "s#.*#${HOST}#" > ./machine.list

rtl_analyze: generate_machinelist
	@echo "==== Run RTL analysis"
	redanalyze -mfcu -hdl verilog -f ./vps.fl

frontend: generate_machinelist
	@echo "==== Running frontend RTLC task"
	redcomp -task rtlc

middlend: generate_machinelist
	@echo "==== Running middlend VPS flow task"
	redcomp -start_task condition -end_task wrap

backend:
	@echo "==== Running backend Vivado task"
	redcomp -task spnr

run:
	@echo "==== Running runtime hardware test"
	redrun -do "redrun.tcl"

clean:
	\rm -rf redcomp.out redrt.out rtl_work machine.list velrunopts.ini veloce.map veloce.config veloce.log veloce.med _red_veloce.config _red_veloce.log _red_veloce.med

.PHONY: all compile rtl_analyze generate_machinelist frontend middlend backend run clean
