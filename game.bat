@echo off
title ���� ���߱� ����

set /a answer=%RANDOM% %% 100 + 1
set /a guess=0
set /a tries=0

echo 1���� 100 ������ ���ڸ� ���纸����.

:guessloop
set /p guess=������ ���ڸ� �Է��ϼ���: 

if %guess% lss %answer% (
    echo �� ���� ���ڸ� �����ϼ���.
    set /a tries+=1
    goto guessloop
) else if %guess% gtr %answer% (
    echo �� ���� ���ڸ� �����ϼ���.
    set /a tries+=1
    goto guessloop
) else (
    set /a tries+=1
    echo �����մϴ�! %answer% ���ڸ� %tries%�� ���� ���߼̽��ϴ�.
    pause
)
