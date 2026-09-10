@REM ###############################################################################
@REM ICS-HybridPrinterWithReflectance / SpectralImageReproduction.bat
@REM Copyright (C) 2024-2026 The International Color Consortium.
@REM                                        All rights reserved.
@REM
@REM Scenario S6b -- reproduce the 600x420 multispectral cows image into the
@REM hybrid CMYK printer profile by spectral inverse search, under the same four
@REM observing conditions (D93 / Illuminant A / D50 / F11) that the S6a
@REM cmykGrays search in BuildAndTest.bat uses.
@REM
@REM Deliberately NOT part of BuildAndTest.bat: every pixel runs a Nelder-Mead
@REM search across four weighted PCCs, so the full image costs minutes on modest
@REM hardware rather than the seconds every other scenario costs.
@REM
@REM Run BuildAndTest.bat first -- it builds the profiles in ICC\ that the
@REM search chain and the PCC weights refer to.
@REM ###############################################################################

@REM Run from the directory that contains this script so relative paths resolve.
@cd /d "%~dp0"

@if not exist Data\MS_smCows.tif                 goto :missing
@if not exist ICC\P-CMYK_Hybrid_Profile.icc      goto :missing
@if not exist ICC\1-Lab_float-D93_2deg-MAT.icc   goto :missing
@if not exist ICC\2-Lab_float-IllumA_2deg-MAT.icc goto :missing
@if not exist ICC\3-Lab_float-D50_2deg.icc       goto :missing
@if not exist ICC\4-Lab_float-F11_2deg-MAT.icc   goto :missing

@ECHO *************************************************************************
@ECHO S6b - Spectral image reproduction (full 600x420, inverse search per pixel)
@ECHO This runs an inverse search per pixel; expect minutes, not seconds.
@ECHO *************************************************************************

@REM connect.threads is 0 (hardware concurrency) in the config.  A search CMM
@REM gives every worker its own apply object with private sub-chain state, so
@REM the threaded result is identical to the single-threaded one -- only faster.
iccApplyProfiles -cfg config\hpwr-S6b-SpectralImageReproduction.json
@if %errorlevel% neq 0 goto :failed
iccTiffDump Results\MS_smCowsPrn.tif

@ECHO Wrote Results\MS_smCowsPrn.tif
@goto :done

:missing
@ECHO.
@ECHO *******************************************************************************
@ECHO ABORTING: a required input is missing -- run BuildAndTest.bat first.
@ECHO It builds ICC\ and needs Data\MS_smCows.tif to be present.
@ECHO *******************************************************************************
@exit /b 1

:failed
@ECHO.
@ECHO *******************************************************************************
@ECHO ABORTING: the previous command failed with exit code %errorlevel%.
@ECHO Check that the iccDEV tools are on PATH and that BuildAndTest.bat succeeded.
@ECHO *******************************************************************************
@exit /b %errorlevel%

:done
