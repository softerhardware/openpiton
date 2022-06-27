read_backend_ip -task pnr -file ./design/chipset/io_ctrl/xilinx/vps/ip_cores/uart_16550/uart_16550.dcp
read_backend_ip -task pnr -file ./design/chipset/io_ctrl/xilinx/vps/ip_cores/atg_uart_init/atg_uart_init.dcp

enable_memory_initialization -pattern 0
