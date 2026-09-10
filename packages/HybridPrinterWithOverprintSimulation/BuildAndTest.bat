@REM setup directory to the tools used in this script
@REM Run from the directory that contains this script so relative paths resolve
@REM (matches cd "$(dirname "$0")" in BuildAndTest.sh).
@cd /d "%~dp0"

@if not exist ICC mkdir ICC
@if not exist Results mkdir Results
@if not exist config mkdir config

@ECHO First lets build some useful ICC profiles 

iccFromXml CMYK-W_Overprint_Profile.xml ICC\P-CMYK-W_Overprint_Profile.icc
@if %errorlevel% neq 0 goto :failed
iccFromXml CMYK-S_Overprint_Profile.xml ICC\P-CMYK-S_Overprint_Profile.icc
@if %errorlevel% neq 0 goto :failed
iccFromXml CMYK-STop_Overprint_Profile.xml ICC\P-CMYK-STop_Overprint_Profile.icc
@if %errorlevel% neq 0 goto :failed

iccFromXml MW-Mid_Overprint.xml ICC\M-MW-Mid_Overprint.icc
@if %errorlevel% neq 0 goto :failed
iccFromXml MS-Mid_Overprint.xml ICC\M-MS-Mid_Overprint.icc
@if %errorlevel% neq 0 goto :failed
iccFromXml SC-Mid_Overprint.xml ICC\M-SC-Mid_Overprint.icc
@if %errorlevel% neq 0 goto :failed

iccFromXml Data\Lab_int-D50_2deg.xml ICC\C-Lab_int-D50_2deg.icc
@if %errorlevel% neq 0 goto :failed
iccFromXml Data\Lab_int-D93_2deg-MAT.xml ICC\1-Lab_int-D93_2deg-MAT.icc
@if %errorlevel% neq 0 goto :failed
iccFromXml Data\Spec380_10_730-D50_2deg.xml ICC\S-Spec380_10_730-D50_2deg.icc
@if %errorlevel% neq 0 goto :failed

@ECHO ****************************************************************************************
@ECHO Demonstrate application of base part of hybrid printer profile with overprint simulation
@ECHO ****************************************************************************************

iccApplyProfiles -cfg config\hpwos-S1-PrintOutput.json
@if %errorlevel% neq 0 goto :failed
iccTiffDump Results\HappyBunniesCmyk.tif

iccApplyProfiles -cfg config\hpwos-S2-PrintProof.json
@if %errorlevel% neq 0 goto :failed

@ECHO ********************************************************************
@ECHO Apply Overprint simulation to CMYKS image to get background previews
@ECHO ********************************************************************

iccApplyProfiles -cfg config\hpwos-S3-TShirtDesignPrevUW-W.json
@if %errorlevel% neq 0 goto :failed
iccApplyProfiles -cfg config\hpwos-S3-TShirtDesignPrevUW-R.json
@if %errorlevel% neq 0 goto :failed
iccApplyProfiles -cfg config\hpwos-S3-TShirtDesignPrevUW-G.json
@if %errorlevel% neq 0 goto :failed
iccApplyProfiles -cfg config\hpwos-S3-TShirtDesignPrevUW-B.json
@if %errorlevel% neq 0 goto :failed
iccApplyProfiles -cfg config\hpwos-S3-TShirtDesignPrevUW-K.json
@if %errorlevel% neq 0 goto :failed

iccApplyProfiles -cfg config\hpwos-S3-TShirtDesignPrevUS-W.json
@if %errorlevel% neq 0 goto :failed
iccApplyProfiles -cfg config\hpwos-S3-TShirtDesignPrevUS-R.json
@if %errorlevel% neq 0 goto :failed
iccApplyProfiles -cfg config\hpwos-S3-TShirtDesignPrevUS-G.json
@if %errorlevel% neq 0 goto :failed
iccApplyProfiles -cfg config\hpwos-S3-TShirtDesignPrevUS-B.json
@if %errorlevel% neq 0 goto :failed
iccApplyProfiles -cfg config\hpwos-S3-TShirtDesignPrevUS-K.json
@if %errorlevel% neq 0 goto :failed

iccApplyProfiles -cfg config\hpwos-S3-TShirtDesignPrevOS-W.json
@if %errorlevel% neq 0 goto :failed
iccApplyProfiles -cfg config\hpwos-S3-TShirtDesignPrevOS-R.json
@if %errorlevel% neq 0 goto :failed
iccApplyProfiles -cfg config\hpwos-S3-TShirtDesignPrevOS-G.json
@if %errorlevel% neq 0 goto :failed
iccApplyProfiles -cfg config\hpwos-S3-TShirtDesignPrevOS-B.json
@if %errorlevel% neq 0 goto :failed
iccApplyProfiles -cfg config\hpwos-S3-TShirtDesignPrevOS-K.json
@if %errorlevel% neq 0 goto :failed

iccApplyProfiles -cfg config\hpwos-S4-TShirtDesignPrevUW-G-M.json
@if %errorlevel% neq 0 goto :failed
iccApplyProfiles -cfg config\hpwos-S4-TShirtDesignPrevUS-G-M.json
@if %errorlevel% neq 0 goto :failed
iccApplyProfiles -cfg config\hpwos-S4-TShirtDesignPrevUS-W-CS.json
@if %errorlevel% neq 0 goto :failed

@ECHO *****************************************************************
@ECHO Get information about spot colors in overprint simulation profile
@ECHO *****************************************************************

iccApplyNamedCmm -cfg config\hpwos-S5-SpotTintSampleLab.json > Results\SpotTintSampleLab.txt
@if %errorlevel% neq 0 goto :failed
@type Results\SpotTintSampleLab.txt

iccApplyNamedCmm -cfg config\hpwos-S6-SpotTintSamplePccLab.json > Results\SpotTintSamplePccLab.txt
@if %errorlevel% neq 0 goto :failed
@type Results\SpotTintSamplePccLab.txt

iccApplyNamedCmm -cfg config\hpwos-S7-SpotTintSampleRefOverWhite.json > Results\SpotTintSampleRefOverWhite.txt
@if %errorlevel% neq 0 goto :failed
@type Results\SpotTintSampleRefOverWhite.txt

iccApplyNamedCmm -cfg config\hpwos-S7-SpotTintSampleRefOverBlack.json > Results\SpotTintSampleRefOverBlack.txt
@if %errorlevel% neq 0 goto :failed
@type Results\SpotTintSampleRefOverBlack.txt

@goto :done

:failed
@ECHO.
@ECHO *******************************************************************************
@ECHO ABORTING: the previous command failed with exit code %errorlevel%.
@ECHO Check that the iccDEV tools are on PATH and that earlier steps succeeded.
@ECHO *******************************************************************************
@exit /b %errorlevel%

:done
