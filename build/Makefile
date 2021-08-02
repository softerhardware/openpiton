

compile_tile:
	make -j 2 -C metro_tile/rel-0.1/obj_dir -f Vmetro_tile.mk Vmetro_tile CXX=mpic++ LINK=mpic++

compile_chipset:
	make -j 2 -C metro_chipset/rel-0.1/obj_dir -f Vmetro_chipset.mk Vmetro_chipset CXX=mpic++ LINK=mpic++

run_both_old:
	mpirun -np 1 -output-filename logfile ./metro_chipset/rel-0.1/obj_dir/Vmetro_chipset \
	+wait_cycle_to_kill=10 +dowarningfinish +doerrorfinish +spc_pipe=0 +vcs+dumpvarsoff \
	+TIMEOUT=50000 +tg_seed=0 +good_trap0=0000000080000558  +bad_trap0=000000008000055a \
	+asm_diag_name=hello_world.c +dv_root=${DV_ROOT} : -np 1 -output-filename logfile \
	./metro_tile/rel-0.1/obj_dir/Vmetro_tile 

compile_both:
	sims -sys=metro_tile -ariane -vlt_build && sims -sys=metro_chipset -ariane -vlt_build

run_both:
	sims -sys=metro_chipset -ariane -vlt_run hello_world.c