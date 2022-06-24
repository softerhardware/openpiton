read_ip -task pnr -file ./design/chipset/io_ctrl/xilinx/vcu440/ip_cores/uart_16550/uart_16550.xci
read_ip -task pnr -file ./design/chipset/io_ctrl/xilinx/vcu440/ip_cores/atg_uart_init/atg_uart_init.xci

enable_memory_initialization -pattern 0
