@echo off
title 숫자 맞추기 게임

set /a answer=%RANDOM% %% 100 + 1
set /a guess=0
set /a tries=0

echo 1부터 100 사이의 숫자를 맞춰보세요.

:guessloop
set /p guess=추측한 숫자를 입력하세요: 

if %guess% lss %answer% (
    echo 더 높은 숫자를 추측하세요.
    set /a tries+=1
    goto guessloop
) else if %guess% gtr %answer% (
    echo 더 낮은 숫자를 추측하세요.
    set /a tries+=1
    goto guessloop
) else (
    set /a tries+=1
    echo 축하합니다! %answer% 숫자를 %tries%번 만에 맞추셨습니다.
    pause
)
