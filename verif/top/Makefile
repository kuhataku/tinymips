.PHONY: all

TARGET=top
RTLLIST= ${WORKSPACE}/design/top/mult_top.sv ${WORKSPACE}/design/top/top.sv ${WORKSPACE}/design/alu/alu.sv ${WORKSPACE}/design/primitive/*  ${WORKSPACE}/design/controller/controller.sv ${WORKSPACE}/design/controller/mult_controller.sv
TBLIST=test_top.sv tb_top.sv dut_top.sv tb_ctrl.sv
IV_OPTIONS=-g2012 -o ${TARGET}
VCDNAME=${TARGET}.vcd


all: comp run

comp:
	iverilog ${IV_OPTIONS} ${TBLIST} ${RTLLIST}

run:
	mkdir -p logs
	./${TARGET}  +VCDNAME=${VCDNAME} | tee logs/${TARGET}.log
	mv *.vcd logs

clean:
	-${RM} ${TARGET}
	-${RM} -r logs
