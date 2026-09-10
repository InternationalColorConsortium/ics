@REM ###############################################################################
@REM ICS-SpectralEncoding / BuildAndTest.bat
@REM Copyright (C) 2024-2026 The International Color Consortium.
@REM                                          All rights reserved.
@REM
@REM Builds the spectralEncoding profiles (a full-resolution spectral encoding and
@REM an abridged multi-spectral encoding) plus the supporting colorimetric PCC
@REM profiles from their XML sources, then exercises every scenario (S1..S5)
@REM defined by the companion configuration files in .\config\ via iccApplyProfiles.
@REM
@REM This ICS works only with iccMAX (ISO 20677-1) profiles.
@REM
@REM Requires the iccDEV command line tools (iccFromXml, iccApplyProfiles,
@REM iccTiffDump) to be installed and on PATH.
@REM ###############################################################################

@REM Run from the directory that contains this script so relative paths resolve
@REM (matches cd "$(dirname "$0")" in BuildAndTest.sh).
@cd /d "%~dp0"

@if not exist ICC      mkdir ICC
@if not exist Results  mkdir Results
@if not exist config   mkdir config

@ECHO *******************************************************************************
@ECHO Build the spectralEncoding profiles (profile "R"):
@ECHO   R-Spec380_10_730-D50  - full spectral encoding  (36 device == 36 PCS bands)
@ECHO   R-SixChanMsRef        - abridged multi-spectral encoding (6 device -^> 36 PCS)
@ECHO *******************************************************************************
iccFromXml Spec380_10_730-D50_2deg.xml           ICC\R-Spec380_10_730-D50_2deg.icc
@if %errorlevel% neq 0 goto :failed
iccFromXml SixChanMsRef.xml                       ICC\R-SixChanMsRef.icc
@if %errorlevel% neq 0 goto :failed

@ECHO *******************************************************************************
@ECHO Build the supporting colorimetric PCC override profiles (1..5)
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

@ECHO *******************************************************************************
@ECHO S1a - FULL encoding as source to a colorimetric destination (sRGB),
@ECHO       previewed under its native D50 observing conditions   [Scenario 1: R-^>C]
@ECHO *******************************************************************************
iccApplyProfiles -cfg config\se-S1a-refCowsToSrgbD50.json
@if %errorlevel% neq 0 goto :failed

@ECHO *******************************************************************************
@ECHO S2  - FULL encoding as source with a colorimetric PCC override, previewed to
@ECHO       sRGB under alternate observing conditions             [Scenario 2: R+P-^>C]
@ECHO *******************************************************************************
iccApplyProfiles -cfg config\se-S2a-refCowsToSrgbA.json
@if %errorlevel% neq 0 goto :failed
iccApplyProfiles -cfg config\se-S2b-refCowsToSrgbD65.json
@if %errorlevel% neq 0 goto :failed
iccApplyProfiles -cfg config\se-S2c-refCowsToSrgbD93.json
@if %errorlevel% neq 0 goto :failed
iccApplyProfiles -cfg config\se-S2d-refCowsToSrgbF11.json
@if %errorlevel% neq 0 goto :failed

@ECHO *******************************************************************************
@ECHO S3a - FULL encoding as source to a spectral-PCS destination (the 81-band
@ECHO       380-780nm/5nm image resampled to 36-band 380-730nm/10nm)  [Scenario 3: R-^>S]
@ECHO *******************************************************************************
iccApplyProfiles -cfg config\se-S3a-refCowsToSpec.json
@if %errorlevel% neq 0 goto :failed
iccTiffDump      Results\Spec_smCows.tif

@ECHO *******************************************************************************
@ECHO S4a - spectral-PCS source to the FULL encoding as destination (round trip,
@ECHO       reconstructing the spectral device values)             [Scenario 4: S-^>R]
@ECHO *******************************************************************************
iccApplyProfiles -cfg config\se-S4a-specToRefCows.json
@if %errorlevel% neq 0 goto :failed
iccTiffDump      Results\Ref_smCows.tif

@ECHO *******************************************************************************
@ECHO S4b - spectral-PCS source to the ABRIDGED encoding as destination: encode the
@ECHO       36-band spectral cows into a 6-channel multi-spectral image [Scenario 4: S-^>R]
@ECHO *******************************************************************************
iccApplyProfiles -cfg config\se-S4b-specToMs6.json
@if %errorlevel% neq 0 goto :failed
iccTiffDump      Results\MS6_smCows.tif

@ECHO *******************************************************************************
@ECHO S1b - ABRIDGED encoding as source to a colorimetric destination (sRGB): decode
@ECHO       the 6-channel image to spectral, then to colorimetry under its native D93
@ECHO       observing conditions                                   [Scenario 1: R-^>C]
@ECHO *******************************************************************************
iccApplyProfiles -cfg config\se-S1b-ms6ToSrgb.json
@if %errorlevel% neq 0 goto :failed

@ECHO *******************************************************************************
@ECHO S3b - ABRIDGED encoding as source to a spectral-PCS destination: reconstruct the
@ECHO       full 36-band spectral reflectance from the 6 channels   [Scenario 3: R-^>S]
@ECHO *******************************************************************************
iccApplyProfiles -cfg config\se-S3b-ms6ToSpec.json
@if %errorlevel% neq 0 goto :failed
iccTiffDump      Results\Spec_ms6Cows.tif

@ECHO *******************************************************************************
@ECHO S5  - ABRIDGED encoding used purely as a PCC override: its D93 observing
@ECHO       conditions and s2cp/c2sp transforms re-render the cows  [Scenario 5: R as PCC]
@ECHO *******************************************************************************
iccApplyProfiles -cfg config\se-S5-previewCowsMsPcc.json
@if %errorlevel% neq 0 goto :failed

@ECHO.
@ECHO Done. Inspect ICC\ and Results\ for the conformance artifacts.
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
