######################################################################
#
# File name : Baudrate_Generator_simulate.do
# Created on: Tue Feb 12 02:18:46 +0200 2019
#
# Auto generated by Vivado for 'behavioral' simulation
#
######################################################################
vsim -voptargs="+acc" -t 1ps -L unisims_ver -L unimacro_ver -L secureip -L xil_defaultlib -lib xil_defaultlib xil_defaultlib.Baudrate_Generator xil_defaultlib.glbl

do {Baudrate_Generator_wave.do}

view wave
view structure
view signals

do {Baudrate_Generator.udo}

run 1000ns
