.PHONY: all

TARGET=primitive
RTLLIST=${WORKSPACE}/design/primitive/* 
TBLIST=test_top.sv tb_top.sv dut_top.sv
IV_OPTIONS=-g2012 -o ${TARGET}


all:
	iverilog ${IV_OPTIONS} ${TBLIST} ${RTLLIST}

clean:
	-${RM} ${TARGET}
