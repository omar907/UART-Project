@echo off
set bin_path=E:\modelsim_ase\win32aloem
call %bin_path%/vsim   -do "do {Baudrate_Generator_simulate.do}" -l simulate.log
if "%errorlevel%"=="1" goto END
if "%errorlevel%"=="0" goto SUCCESS
:END
exit 1
:SUCCESS
exit 0
