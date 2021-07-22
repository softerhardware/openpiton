

compile_tile:
	cp ${DV_ROOT}/tools/verilator/my_metro_tile.cpp metro_tile/rel-0.1/obj_dir
	cp ${DV_ROOT}/tools/verilator/metro_mpi.cpp metro_tile/rel-0.1/obj_dir
	make -j 2 -C metro_tile/rel-0.1/obj_dir -f Vmetro_tile.mk Vmetro_tile CXX=mpic++ LINK=mpic++

compile_chipset:
	cp ${DV_ROOT}/tools/verilator/my_metro_chipset.cpp metro_tile/rel-0.1/obj_dir
	cp ${DV_ROOT}/tools/verilator/metro_mpi.cpp metro_tile/rel-0.1/obj_dir
	make -j 2 -C metro_chipset/rel-0.1/obj_dir -f Vmetro_chipset.mk Vmetro_chipset CXX=mpic++ LINK=mpic++

run_both:
	mpirun -np 1 -output-filename logfile ./metro_chipset/rel-0.1/obj_dir/Vmetro_chipset \
	+wait_cycle_to_kill=10 +dowarningfinish +doerrorfinish +spc_pipe=0 +vcs+dumpvarsoff \
	+TIMEOUT=50000 +tg_seed=0 +good_trap0=000000008000054c  +bad_trap0=000000008000054e \
	+asm_diag_name=hello_world.c +dv_root=${DV_ROOT} : -np 1 -output-filename logfile \
	./metro_tile/rel-0.1/obj_dir/Vmetro_tile +wait_cycle_to_kill=10 \
	+dowarningfinish +doerrorfinish +spc_pipe=0 +vcs+dumpvarsoff +TIMEOUT=50000 +tg_seed=0 \
    +good_trap0=000000008000054c  +bad_trap0=000000008000054e +asm_diag_name=hello_world.c +dv_root=${DV_ROOT}
