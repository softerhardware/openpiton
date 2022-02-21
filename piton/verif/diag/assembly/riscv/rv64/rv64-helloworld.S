    lui x1, 0xf0c2c
    # Print Hello world
    li  x3, 0x48
    sb  x3, 0(x1)
    li  x3, 0x65
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
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop
    nop

# sit in loop and increment counter, because why not
pass:
    addi x2, x0, 0
loop:     
    addi    x2,x2,1
    j       loop
