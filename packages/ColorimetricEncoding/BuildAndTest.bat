@REM ###############################################################################
@REM ICS-ColorimetricEncoding / BuildAndTest.bat
@REM Copyright (C) 2024-2026 The International Color Consortium.
@REM                                          All rights reserved.
@REM
@REM Builds the colorimetricEncoding ICC profiles from their XML sources, then
@REM exercises every scenario (S1a..S7f) defined by the companion configuration
@REM files in .\config\ via iccApplyProfiles (image workflows S1..S5) and
@REM iccApplyNamedCmm (color-list workflows S6, S7).
@REM
@REM Requires the iccDEV command line tools (iccFromXml, iccApplyProfiles,
@REM iccApplyNamedCmm, iccTiffDump) to be on PATH.
@REM ###############################################################################

@REM Run from the directory that contains this script so relative paths resolve
@REM (matches cd "$(dirname "$0")" in BuildAndTest.sh).
@cd /d "%~dp0"

@if not exist ICC      mkdir ICC
@if not exist Results  mkdir Results
@if not exist config   mkdir config

@ECHO *******************************************************************************
@ECHO Build the colorimetricEncoding profiles (profile "E") and the PCC override
@ECHO profile (profile "P") from their XML sources in .\Illuminants
@ECHO *******************************************************************************

iccFromXml Illuminants\Lab_float-D50_2deg.xml         ICC\E-Lab_float-D50_2deg.icc
@if %errorlevel% neq 0 goto :failed
iccFromXml Illuminants\Lab_float-D93_2deg-MAT.xml     ICC\E-Lab_float-D93_2deg-MAT.icc
@if %errorlevel% neq 0 goto :failed
iccFromXml Illuminants\Lab_int-D50_2deg.xml           ICC\E-Lab_int-D50_2deg.icc
@if %errorlevel% neq 0 goto :failed
iccFromXml Illuminants\Lab_int-D65_2deg-MAT.xml       ICC\E-Lab_int-D65_2deg-MAT.icc
@if %errorlevel% neq 0 goto :failed
iccFromXml Illuminants\Lab_int-D93_2deg-MAT.xml       ICC\E-Lab_int-D93_2deg-MAT.icc
@if %errorlevel% neq 0 goto :failed
iccFromXml Illuminants\Lab_int-IllumA_2deg-MAT.xml    ICC\E-Lab_int-IllumA_2deg-MAT.icc
@if %errorlevel% neq 0 goto :failed
iccFromXml Illuminants\Lab_int-IllumA_2deg-Abs.xml    ICC\E-Lab_int-IllumA_2deg-Abs.icc
@if %errorlevel% neq 0 goto :failed
iccFromXml Illuminants\Lab_int-IllumA_2deg-Abs.xml    ICC\P-Lab_int-IllumA_2deg-Abs.icc
@if %errorlevel% neq 0 goto :failed
iccFromXml Illuminants\XYZ_float-D50_2deg.xml         ICC\E-XYZ_float-D50_2deg.icc
@if %errorlevel% neq 0 goto :failed
iccFromXml Illuminants\XYZ_float-D65_2deg-MAT.xml     ICC\E-XYZ_float-D65_2deg-MAT.icc
@if %errorlevel% neq 0 goto :failed
iccFromXml Illuminants\XYZ_int-D50_2deg.xml           ICC\E-XYZ_int-D50_2deg.icc
@if %errorlevel% neq 0 goto :failed
iccFromXml Illuminants\XYZ_int-D65_2deg-MAT.xml       ICC\E-XYZ_int-D65_2deg-MAT.icc
@if %errorlevel% neq 0 goto :failed
iccFromXml Illuminants\XYZ_int-D65_2deg-MAT-Lvl2.xml  ICC\E-XYZ_int-D65_2deg-MAT-Lvl2.icc
@if %errorlevel% neq 0 goto :failed
iccFromXml Illuminants\XYZ_int-D93_2deg-MAT.xml       ICC\E-XYZ_int-D93_2deg-MAT.icc
@if %errorlevel% neq 0 goto :failed
iccFromXml Illuminants\XYZ_int-IllumA_2deg-MAT.xml    ICC\E-XYZ_int-IllumA_2deg-MAT.icc
@if %errorlevel% neq 0 goto :failed

@ECHO *******************************************************************************
@ECHO Build additional colorimetricEncoding profiles (profile "E") for
@ECHO Asano's Categorical observers and the CIE 2015 observer
@ECHO (Not used by sceenarios but available for testing).
@ECHO *******************************************************************************

iccFromXml CustomObservers\LabCat1-D50_2deg.xml  ICC\E-LabCat1-D50_2deg.icc
@if %errorlevel% neq 0 goto :failed
iccFromXml CustomObservers\LabCat1-D65_2deg.xml  ICC\E-LabCat1-D65_2deg.icc
@if %errorlevel% neq 0 goto :failed
iccFromXml CustomObservers\LabCat2-D50_2deg.xml  ICC\E-LabCat2-D50_2deg.icc
@if %errorlevel% neq 0 goto :failed
iccFromXml CustomObservers\LabCat2-D65_2deg.xml  ICC\E-LabCat2-D65_2deg.icc
@if %errorlevel% neq 0 goto :failed
iccFromXml CustomObservers\LabCat3-D50_2deg.xml  ICC\E-LabCat3-D50_2deg.icc
@if %errorlevel% neq 0 goto :failed
iccFromXml CustomObservers\LabCat3-D65_2deg.xml  ICC\E-LabCat3-D65_2deg.icc
@if %errorlevel% neq 0 goto :failed
iccFromXml CustomObservers\LabCat4-D50_2deg.xml  ICC\E-LabCat4-D50_2deg.icc
@if %errorlevel% neq 0 goto :failed
iccFromXml CustomObservers\LabCat4-D65_2deg.xml  ICC\E-LabCat4-D65_2deg.icc
@if %errorlevel% neq 0 goto :failed
iccFromXml CustomObservers\LabCat5-D50_2deg.xml  ICC\E-LabCat5-D50_2deg.icc
@if %errorlevel% neq 0 goto :failed
iccFromXml CustomObservers\LabCat5-D65_2deg.xml  ICC\E-LabCat5-D65_2deg.icc
@if %errorlevel% neq 0 goto :failed
iccFromXml CustomObservers\LabCat6-D50_2deg.xml  ICC\E-LabCat6-D50_2deg.icc
@if %errorlevel% neq 0 goto :failed
iccFromXml CustomObservers\LabCat6-D65_2deg.xml  ICC\E-LabCat6-D65_2deg.icc
@if %errorlevel% neq 0 goto :failed
iccFromXml CustomObservers\LabCat7-D50_2deg.xml  ICC\E-LabCat7-D50_2deg.icc
@if %errorlevel% neq 0 goto :failed
iccFromXml CustomObservers\LabCat7-D65_2deg.xml  ICC\E-LabCat7-D65_2deg.icc
@if %errorlevel% neq 0 goto :failed
iccFromXml CustomObservers\LabCat8-D50_2deg.xml  ICC\E-LabCat8-D50_2deg.icc
@if %errorlevel% neq 0 goto :failed
iccFromXml CustomObservers\LabCat8-D65_2deg.xml  ICC\E-LabCat8-D65_2deg.icc
@if %errorlevel% neq 0 goto :failed
iccFromXml CustomObservers\LabCat9-D50_2deg.xml  ICC\E-LabCat9-D50_2deg.icc
@if %errorlevel% neq 0 goto :failed
iccFromXml CustomObservers\LabCat9-D65_2deg.xml  ICC\E-LabCat9-D65_2deg.icc
@if %errorlevel% neq 0 goto :failed
iccFromXml CustomObservers\LabCat10-D50_2deg.xml ICC\E-LabCat10-D50_2deg.icc
@if %errorlevel% neq 0 goto :failed
iccFromXml CustomObservers\LabCat10-D65_2deg.xml ICC\E-LabCat10-D65_2deg.icc
@if %errorlevel% neq 0 goto :failed
iccFromXml CustomObservers\Lab2015-D50_2deg.xml ICC\E-Lab2015-D50_2deg.icc
@if %errorlevel% neq 0 goto :failed
iccFromXml CustomObservers\Lab2015-D65_2deg.xml ICC\E-Lab2015-D65_2deg.icc
@if %errorlevel% neq 0 goto :failed

@ECHO *******************************************************************************
@ECHO Build the spectral PCS profile used as the source for the S6 scenarios.
@ECHO *******************************************************************************

iccFromXml Data\Spec380_10_730-D50_2deg.xml      ICC\S-Spec380_10_730-D50_2deg.icc
@if %errorlevel% neq 0 goto :failed

@ECHO *******************************************************************************
@ECHO Scenario S1 - encode an sRGB image into a colorimetric encoding ("E as dst")
@ECHO *******************************************************************************

iccApplyProfiles -cfg config\ce-S1a-IccToColorEncodingD93.json
@if %errorlevel% neq 0 goto :failed
iccTiffDump      Results\E-HappyBunnies-S1a.tif

iccApplyProfiles -cfg config\ce-S1b-IccToColorEncodingA.json
@if %errorlevel% neq 0 goto :failed
iccTiffDump      Results\E-HappyBunnies-S1b.tif

@ECHO *******************************************************************************
@ECHO Scenario S2 - same as S1 but with a PCC override on the encoding profile
@ECHO *******************************************************************************

iccApplyProfiles -cfg config\ce-S2-IccToColorEncodingAWithPcc.json
@if %errorlevel% neq 0 goto :failed
iccTiffDump      Results\E-HappyBunnies-S2.tif

@ECHO *******************************************************************************
@ECHO Scenario S3 - decode a colorimetrically-encoded image back to an ICC profile
@ECHO *******************************************************************************

iccApplyProfiles -cfg config\ce-S3a-ColorEncodingD93ToIcc.json
@if %errorlevel% neq 0 goto :failed
iccApplyProfiles -cfg config\ce-S3b-ColorEncodingAToIcc.json
@if %errorlevel% neq 0 goto :failed
iccApplyProfiles -cfg config\ce-S3c-ColorEncodingAPccToIcc.json
@if %errorlevel% neq 0 goto :failed

@ECHO *******************************************************************************
@ECHO Scenario S4 - decode a colorimetrically-encoded image with a PCC override
@ECHO *******************************************************************************

iccApplyProfiles -cfg config\ce-S4-ColorEncodingAWithPccToIcc.json
@if %errorlevel% neq 0 goto :failed

@ECHO *******************************************************************************
@ECHO Scenario S5 - use a colorimetricEncoding profile as a PCC override only
@ECHO *******************************************************************************

iccApplyProfiles -cfg config\ce-S5a-IccToIccWithPcc.json
@if %errorlevel% neq 0 goto :failed
iccTiffDump      Results\2-HappyBunniesS5a.tif

iccApplyProfiles -cfg config\ce-S5b-ColorIccWithPccToIcc.json
@if %errorlevel% neq 0 goto :failed
iccApplyProfiles -cfg config\ce-S5c-SpectralIccWithPccToIcc.json
@if %errorlevel% neq 0 goto :failed

@ECHO *******************************************************************************
@ECHO Scenario S6 - convert spectral chart reference data to a colorimetric encoding
@ECHO              (RefTo*: chartRef.txt -^> S-Spec380 -^> E-XYZ or E-Lab encoding)
@ECHO *******************************************************************************

iccApplyNamedCmm -cfg config\ce-S6a-RefToXYZA.json        > Results\chartRef-S6a-XYZA.txt
@if %errorlevel% neq 0 goto :failed
iccApplyNamedCmm -cfg config\ce-S6b-RefToXYZD50.json      > Results\chartRef-S6b-XYZD50.txt
@if %errorlevel% neq 0 goto :failed
iccApplyNamedCmm -cfg config\ce-S6c-RefToXYZD93.json      > Results\chartRef-S6c-XYZD93.txt
@if %errorlevel% neq 0 goto :failed
iccApplyNamedCmm -cfg config\ce-S6d-RefToLabD50.json      > Results\chartRef-S6d-LabD50.txt
@if %errorlevel% neq 0 goto :failed
iccApplyNamedCmm -cfg config\ce-S6e-RefToLab2015.json     > Results\chartRef-S6e-Lab2015.txt
@if %errorlevel% neq 0 goto :failed
iccApplyNamedCmm -cfg config\ce-S6f-RefToLabCat8.json     > Results\chartRef-S6f-LabCat8.txt
@if %errorlevel% neq 0 goto :failed

@ECHO *******************************************************************************
@ECHO Scenario S7 - convert one colorimetric encoding to another (with possible
@ECHO              change in observing conditions). Source values are inline in the
@ECHO              config; both source and destination are colorimetricEncoding
@ECHO              profiles ("value" encoded).
@ECHO *******************************************************************************

iccApplyNamedCmm -cfg config\ce-S7a-XYZToLabA.json        > Results\S7a-XYZ-to-LabA.txt
@if %errorlevel% neq 0 goto :failed
iccApplyNamedCmm -cfg config\ce-S7b-XYZToLabD93.json      > Results\S7b-XYZ-to-LabD93.txt
@if %errorlevel% neq 0 goto :failed
iccApplyNamedCmm -cfg config\ce-S7c-LabD50ToLabA.json     > Results\S7c-LabD50-to-LabA.txt
@if %errorlevel% neq 0 goto :failed
iccApplyNamedCmm -cfg config\ce-S7d-LabD50ToLabD93.json   > Results\S7d-LabD50-to-LabD93.txt
@if %errorlevel% neq 0 goto :failed
iccApplyNamedCmm -cfg config\ce-S7e-LabD50ToLab2015.json  > Results\S7e-LabD50-to-Lab2015.txt
@if %errorlevel% neq 0 goto :failed
iccApplyNamedCmm -cfg config\ce-S7f-LabD50ToLabCat8.json  > Results\S7f-LabD50-to-LabCat8.txt
@if %errorlevel% neq 0 goto :failed

@goto :done

:failed
@ECHO.
@ECHO *******************************************************************************
@ECHO ABORTING: the previous command failed with exit code %errorlevel%.
@ECHO Check that the iccDEV tools are on PATH and that earlier steps succeeded.
@ECHO *******************************************************************************
@exit /b %errorlevel%

:done
