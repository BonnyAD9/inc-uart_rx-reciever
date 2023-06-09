#!/usr/bin/bash
SUBNAME:=xstigl00

.PHONY: submit uart_rx clean sim

uart_rx: vhdl/wave.ghw

sim: vhdl/wave.ghw
	gtkwave vhdl/wave.ghw --script=vhdl/wave.tcl

vhdl/wave.ghw: vhdl/uart_rx.vhd vhdl/uart_rx_fsm.vhd vhdl/testbench.vhd
	cd vhdl && \
		ghdl -a -fsynopsys uart_rx_fsm.vhd uart_rx.vhd testbench.vhd && \
		ghdl -e -fsynopsys testbench && \
		ghdl -r -fsynopsys testbench --wave=wave.ghw --stop-time=1000ms

submit: LaTeX/zprava.pdf
	zip -j xstigl00.zip LaTeX/zprava.pdf vhdl/uart_rx_fsm.vhd vhdl/uart_rx.vhd

LaTeX/zprava.pdf: LaTeX/zprava.tex LaTeX/assets/simulation.png \
		LaTeX/assets/RTL.png LaTeX/assets/FSM.pdf
	(cd LaTeX && pdflatex zprava.tex)

clean:
	-rm vhdl/*.o vhdl/testbench vhdl/*.ghw vhdl/*.cf \
		LaTeX/*.aux LaTeX/*.log LaTeX/*.out LaTeX/zprava.pdf \
		$(SUBNAME).zip
