@echo off
echo Program the PSoc3 via a MiniProg3 device
echo Unplug USB cable
echo Plug programming cable into LASOM2.C1 J25
echo with red stripe AWAY from power connector.
echo Attach USB cable to MiniProg3, then press a key.
pause
echo Press any key after viewing result
SWDApp GC1.hex
pause
echo Unplug USB cable first, then programming cable.
pause

