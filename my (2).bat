@echo off
SETLOCAL ENABLEDELAYEDEXPANSION
:loop
set /a "a=a+1"
echo %a%
goto loop
