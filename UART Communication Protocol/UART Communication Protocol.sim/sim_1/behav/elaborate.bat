@echo off
set bin_path=E:\modelsim_ase\win32aloem
call %bin_path%/vsim  -c -do "do {Baudrate_Generator_elaborate.do}" -l elaborate.log
if "%errorlevel%"=="1" goto END
if "%errorlevel%"=="0" goto SUCCESS
:END
exit 1
:SUCCESS
exit 0
