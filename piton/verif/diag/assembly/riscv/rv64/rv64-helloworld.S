    lui x1, 0xf0c2c
		lui x5, 0x00c2c

		addi  x3, x0, 0x48
		addi  x4, x0, 0x32
		addi  x3, x3, 0x01
		sb  x3, 0(x5)
		lb  x4, 0(x5)
		sb	x4, 0(x1)
    # Print Hello world
    li  x3, 0x48
    sb  x3, 0(x1)
    li  x3, 0x66
    sb  x3, 0(x1)
    li  x3, 0x6c
    sb  x3, 0(x1)
    li  x3, 0x6c
    sb  x3, 0(x1)
    li  x3, 0x6F
    sb  x3, 0(x1)
    li  x3, 0x20
    sb  x3, 0(x1)
    li  x3, 0x77
    sb  x3, 0(x1)
    li  x3, 0x6f
    sb  x3, 0(x1)
    li  x3, 0x72
    sb  x3, 0(x1)
    li  x3, 0x6c
    sb  x3, 0(x1)
    li  x3, 0x64
    sb  x3, 0(x1)
    #lb  x7, 0(x1)
		li x7, 0x48
		addi x7, x7, 0
		addi x7, x7, 0
    sb  x7, 0(x1)
		lb  x8, 0(x1)
		sb  x8, 0(x1)


# sit in loop and increment counter, because why not
    addi x2, x0, 0
loop:     
    //addi    x2,x2,1
    j       loop
