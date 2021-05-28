@ECHO OFF
@REM BUILD SCRIPT

@REM CHECK VLANG COMPILER
WHERE v
IF %ERRORLEVEL% NEQ 0 (
    echo VLang compiler doesn't available, please install it or add to the PATH variable
    echo For more details please visit to github page: https://github.com/vlang/v
    exit /B 1
) ELSE (
    echo VLang compiler available:
    v version
)
set V=
FOR /F "delims=" %%i IN ('"where v"') DO set V=%%i

set COMMAND=%1
set ARG1=%2
set ARG2=%3
set ARG3=%4
set ARG4=%5
set ARG5=%6
set ARG6=%7
set ARG7=%8

IF "x%COMMAND%" == "xbuild" (
    call :build
)

IF "x%COMMAND%" == "xtests" (
    call :build
    Setlocal EnableDelayedExpansion
    call :tests RESULT_CODE
    echo RESULT_CODE is !RESULT_CODE!
    IF "x!RESULT_CODE!"=="x0" (
        echo The tests were success!
    ) ELSE (
        echo One or more tests were failing!
        exit /B 1
    )
)

IF "x%COMMAND%"=="xclear" (
    call :clear
)

IF "x%COMMAND%"=="xrelease-notes" (
    call :release_logs %ARG1%
)

IF "x%COMMAND%"=="x" (
    echo *
    echo No command
    echo *
    echo Available commands are: build tests clear release-notes
)

EXIT /B 0
REM ===========================================================================================
REM Functions

:clear
    echo *
    echo Clear folders
    echo *

    if exist dist\ (
 	    rmdir /Q /S dist
    )
    if exist build\ (
 	    rmdir /Q /S build
    )
EXIT /B 0

:build
    echo *
    echo Build cpf
    echo *

    if exist build\ (
 	    rmdir /Q /S build
    )
    mkdir build
    %V% cpf.v -o build\cpf.exe
EXIT /B 0

:tests
    echo *
    echo Tests
    echo *
    setlocal EnableExtensions
    :mktemp_loop
    set "TMP_FOLDER=%tmp%\tmp.%RANDOM%"
    if exist "%TMP_FOLDER%" goto :mktemp_loop
    @REM COPY TEST STUFF
    mkdir %TMP_FOLDER%\data
    copy tests\data\*.* %TMP_FOLDER%\data
    copy build\*.* %TMP_FOLDER%
    copy tests\*_test.v %TMP_FOLDER%
    %V% tests\tests.v -o %TMP_FOLDER%\tests.exe

    set CURRENT_FOLDER=%CD%
    chdir %TMP_FOLDER%
    %TMP_FOLDER%\tests "%V%"
    set "RETURN_CODE=%ERRORLEVEL%"
    chdir %CURRENT_FOLDER%

    echo %TMP_FOLDER%

    del /S /Q %TMP_FOLDER%
    rmdir /S /Q %TMP_FOLDER%

    if NOT "%RETURN_CODE%"=="0" (
        endlocal
        set "%1=1"
    ) ELSE (
        endlocal
        set "%1=0"
    )
EXIT /B 0

:release_logs
    set CMD1='git rev-list -n 1 %1'
    echo %CMD1%
    for /f %%i in (%CMD1%) do set HASH1=%%i
    for /f %%i in ('git rev-list -n 1 master') do set HASH2=%%i
    echo HASH1 is %HASH1%
    echo HASH2 is %HASH2%
    set HASH1=%HASH1: =%
    set HASH2=%HASH2: =%

    git log %HASH1%..%HASH2% --pretty=format:"%%h %%s %%b"
EXIT /B 0

