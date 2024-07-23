@echo off
mode con cols=200 lines=70


color 1f
echo.
echo ======================================
echo YOUR PC RAN INTO A PROBLEM AND NEEDS TO RESTART
echo ======================================
echo.
echo Technical information:
echo.
echo *** STOP: 0x00000050 (0xFFFFF6FB40000000,0x0000000000000001,0xFFFFF80144E8D2B2,0x0000000000000002)
echo.
echo *** NTFS.sys - Address FFFFF80144E8D2B2 base at FFFFF80144E72000, DateStamp 606a5699
echo.
echo.
echo Restarting in 10 seconds...
ping -n 11 127.0.0.1 > nul