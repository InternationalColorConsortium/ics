@ECHO OFF
REM ###############################################################################
REM ICS packages / BuildAndTest.bat
REM Copyright (C) 2024-2026 The International Color Consortium.
REM                                          All rights reserved.
REM
REM Builds and tests every ICS package in this directory, in turn, and prints a
REM pass/fail summary at the end.
REM
REM Checks first that the iccDEV command line tools are on PATH. Without them
REM each package script creates empty ICC\ and Results\ directories and reports
REM nothing useful, which is easily mistaken for success - so this stops before
REM anything is built.
REM
REM Requires iccFromXml, iccApplyProfiles, iccApplyNamedCmm, iccApplySearch and
REM iccTiffDump. See the iccDEV project for installation.
REM ###############################################################################
SETLOCAL ENABLEDELAYEDEXPANSION

REM Run from the directory that contains this script so relative paths resolve
REM (matches cd "$(dirname "$0")" in BuildAndTest.sh).
CD /D "%~dp0"

REM ---- preflight: are the tools reachable? ------------------------------------
SET "TOOLS=iccFromXml iccApplyProfiles iccApplyNamedCmm iccApplySearch iccTiffDump"
SET "MISSING="
FOR %%T IN (%TOOLS%) DO (
    WHERE /Q %%T 2>NUL
    IF ERRORLEVEL 1 SET "MISSING=!MISSING! %%T"
)

IF DEFINED MISSING (
    ECHO.
    ECHO *******************************************************************************
    ECHO WARNING: these iccDEV command line tools were not found on PATH:
    ECHO.
    FOR %%M IN (!MISSING!) DO ECHO        %%M
    ECHO.
    ECHO Nothing has been built. Without the tools each package would create empty
    ECHO ICC\ and Results\ directories and report no error, which looks like success.
    ECHO.
    ECHO Add the iccDEV tools to PATH and run this script again, for example:
    ECHO.
    ECHO        set PATH=C:\path\to\iccdev\bin;%%PATH%%
    ECHO.
    ECHO Note that double-clicking this file does not pick up a PATH set in another
    ECHO window - open a command prompt, set PATH there, and run it from that prompt.
    ECHO.
    ECHO The expected output of every scenario is already committed under each
    ECHO package's Results\ directory, so the packages stay usable as a reference
    ECHO even without the tools.
    ECHO *******************************************************************************
    ECHO.
    EXIT /B 1
)

REM ---- build and test each package --------------------------------------------
SET "PASSED="
SET "FAILED="
SET "COUNT=0"

FOR /D %%P IN (*) DO (
    IF EXIST "%%P\BuildAndTest.bat" (
        SET /A COUNT+=1
        ECHO.
        ECHO ===============================================================================
        ECHO   %%P
        ECHO ===============================================================================
        CALL "%%P\BuildAndTest.bat"
        IF ERRORLEVEL 1 (
            SET "FAILED=!FAILED! %%P"
        ) ELSE (
            SET "PASSED=!PASSED! %%P"
        )
        REM each package script cd's to its own directory - come back
        CD /D "%~dp0"
    )
)

IF "%COUNT%"=="0" (
    ECHO.
    ECHO WARNING: no package with a BuildAndTest.bat was found in "%~dp0".
    ECHO.
    EXIT /B 1
)

REM ---- summary -----------------------------------------------------------------
ECHO.
ECHO ===============================================================================
ECHO   Summary
ECHO ===============================================================================
FOR %%P IN (!PASSED!) DO ECHO   PASS   %%P
FOR %%P IN (!FAILED!) DO ECHO   FAIL   %%P
ECHO.

IF DEFINED FAILED (
    ECHO One or more packages failed. See the output above for the failing step.
    ECHO.
    EXIT /B 1
)

ECHO All %COUNT% packages built and tested.
ECHO Inspect each package's ICC\ and Results\ directories for the artifacts.
ECHO.
EXIT /B 0
