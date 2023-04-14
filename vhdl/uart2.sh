ghdl -a -fsynopsys uart_rx_fsm.vhd uart_rx.vhd testbench.vhd && \
    ghdl -e -fsynopsys testbench && \
    ghdl -r -fsynopsys testbench --wave=wave.ghw --stop-time=1000ms
