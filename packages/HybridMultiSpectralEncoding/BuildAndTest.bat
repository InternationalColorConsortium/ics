@REM ###############################################################################
@REM ICS-HybridMultiSpectralEncoding / BuildAndTest.bat
@REM Copyright (C) 2024-2026 The International Color Consortium.
@REM                                          All rights reserved.
@REM
@REM Builds the hybrid multi-spectral encoding profile and its supporting PCS /
@REM PCC profiles from their XML sources, then exercises every scenario (S1..S6)
@REM defined by the companion configuration files in .\config\ via iccApplyProfiles.
@REM
@REM Requires the iccDEV command line tools (iccFromXml, iccApplyProfiles,
@REM iccTiffDump) to be on PATH.
@REM ###############################################################################

@REM Run from the directory that contains this script so relative paths resolve
@REM (matches cd "$(dirname "$0")" in BuildAndTest.sh).
@cd /d "%~dp0"

@if not exist ICC      mkdir ICC
@if not exist Results  mkdir Results
@if not exist config   mkdir config

@ECHO *******************************************************************************
@ECHO First build the hybrid multi-spectral encoding profile (profile "P")
@ECHO *******************************************************************************
iccFromXml MultiSpectralRGB.xml                  ICC\P-MultiSpectralRGB.icc
@if %errorlevel% neq 0 goto :failed

@ECHO *******************************************************************************
@ECHO Now build the supporting colorimetric PCC profiles (1..5) and spectral PCS (S)
@ECHO *******************************************************************************
iccFromXml Data\Lab_float-D93_2deg-MAT.xml       ICC\1-Lab_float-D93_2deg-MAT.icc
@if %errorlevel% neq 0 goto :failed
iccFromXml Data\Lab_float-IllumA_2deg-MAT.xml    ICC\2-Lab_float-IllumA_2deg-MAT.icc
@if %errorlevel% neq 0 goto :failed
iccFromXml Data\Lab_float-D50_2deg.xml           ICC\3-Lab_float-D50_2deg.icc
@if %errorlevel% neq 0 goto :failed
iccFromXml Data\Lab_float-F11_2deg-MAT.xml       ICC\4-Lab_float-F11_2deg-MAT.icc
@if %errorlevel% neq 0 goto :failed
iccFromXml Data\Lab_int-D65_2deg-MAT.xml         ICC\5-Lab_int-D65_2deg-MAT.icc
@if %errorlevel% neq 0 goto :failed
iccFromXml Data\Spec380_10_730-D50_2deg.xml      ICC\S-Spec380_10_730-D50_2deg.icc
@if %errorlevel% neq 0 goto :failed

@ECHO *******************************************************************************
@ECHO S1/S2 - Demonstrate conversion to and from the multi-spectral encoding
@ECHO *******************************************************************************

@ECHO S1 - encode a spectral reflectance image into the multi-spectral encoding
iccApplyProfiles -cfg config\hmse-S1-refCowsToMsCows.json
@if %errorlevel% neq 0 goto :failed
iccTiffDump      Results\MS_smCows.tif

@ECHO S2 - decode the multi-spectral encoding back to spectral reflectance
iccApplyProfiles -cfg config\hmse-S2-msCowsToRefCows.json
@if %errorlevel% neq 0 goto :failed
iccTiffDump      Results\Ref_smCows.tif

@ECHO *******************************************************************************
@ECHO S3/S4 - Preview the multi-spectral encoding as colorimetry (D50 and alternate
@ECHO         observing conditions via a PCC override)
@ECHO *******************************************************************************

@ECHO S3 - colorimetric preview under the native D50 viewing conditions
iccApplyProfiles -cfg config\hmse-S3-previewMSCowsD50.json
@if %errorlevel% neq 0 goto :failed

@ECHO S4 - colorimetric preview under alternate illuminants (PCC override)
iccApplyProfiles -cfg config\hmse-S4-previewMSCowsA.json
@if %errorlevel% neq 0 goto :failed
iccApplyProfiles -cfg config\hmse-S4-previewMSCowsD65.json
@if %errorlevel% neq 0 goto :failed
iccApplyProfiles -cfg config\hmse-S4-previewMSCowsD93.json
@if %errorlevel% neq 0 goto :failed
iccApplyProfiles -cfg config\hmse-S4-previewMSCowsF11.json
@if %errorlevel% neq 0 goto :failed

@ECHO *******************************************************************************
@ECHO For comparison, produce the same previews directly from the spectral image
@ECHO *******************************************************************************
iccApplyProfiles -cfg config\hmse-previewRefCowsD50.json
@if %errorlevel% neq 0 goto :failed
iccApplyProfiles -cfg config\hmse-previewRefCowsA.json
@if %errorlevel% neq 0 goto :failed
iccApplyProfiles -cfg config\hmse-previewRefCowsD65.json
@if %errorlevel% neq 0 goto :failed
iccApplyProfiles -cfg config\hmse-previewRefCowsD93.json
@if %errorlevel% neq 0 goto :failed
iccApplyProfiles -cfg config\hmse-previewRefCowsF11.json
@if %errorlevel% neq 0 goto :failed

@ECHO *******************************************************************************
@ECHO S5 - legacy preview using only the base ICC profile (no iccMAX sub-profile)
@ECHO *******************************************************************************
iccApplyProfiles -cfg config\hmse-S5-previewRgbCowsD50.json
@if %errorlevel% neq 0 goto :failed

@ECHO *******************************************************************************
@ECHO S6 - legacy to partial multi-spectral conversion (base ICC profile only).
@ECHO      This creates a "half" multi-spectral image whose extra spectral channels
@ECHO      were never populated - see the caution in the ICS document.
@ECHO *******************************************************************************
iccApplyProfiles -cfg config\hmse-S6-rgbToHalfMS.json
@if %errorlevel% neq 0 goto :failed
iccTiffDump      Results\HappyBunniesHalfMS.tif

@ECHO.
@ECHO *******************************************************************************
@ECHO The following application works - the base ICC profile can still preview the
@ECHO half MS image (S5 style)
@ECHO *******************************************************************************
iccApplyProfiles -cfg config\hmse-S5-previewHalfMS.json
@if %errorlevel% neq 0 goto :failed

@ECHO.
@ECHO *******************************************************************************
@ECHO The following application does NOT work - the spectral sub-profile needs multi-
@ECHO spectral channels that the half MS image does not contain (S3 style)
@ECHO *******************************************************************************
iccApplyProfiles -cfg config\hmse-S3-previewHalfMS.json
@REM NOTE: iccApplyProfiles exits -1 on this error. cmd's "if errorlevel N" is a
@REM signed >= test, so "if errorlevel 1" does NOT catch a negative code; use neq.
@if %errorlevel% neq 0 @ECHO (expected failure: the half MS image lacks the multi-spectral channels)

@ECHO.

@goto :done

:failed
@ECHO.
@ECHO *******************************************************************************
@ECHO ABORTING: the previous command failed with exit code %errorlevel%.
@ECHO Check that the iccDEV tools are on PATH and that earlier steps succeeded.
@ECHO *******************************************************************************
@exit /b %errorlevel%

:done
