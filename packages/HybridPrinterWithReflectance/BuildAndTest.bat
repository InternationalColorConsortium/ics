@REM setup directory to the tools used in this script

@REM Run from the directory that contains this script so relative paths resolve
@REM (matches cd "$(dirname "$0")" in BuildAndTest.sh).
@cd /d "%~dp0"

@if not exist ICC mkdir ICC
@if not exist Results mkdir Results
@if not exist config mkdir config

@ECHO First lets build some useful ICC profiles 

@ECHO First lets create a hybrid spectral printer profile
iccFromXml CMYK_Hybrid_Profile.xml ICC\P-CMYK_Hybrid_Profile.icc
@if %errorlevel% neq 0 goto :failed

@ECHO Now we need some support profiles for working with spectral PCS
iccFromXml Data\Lab_float-D93_2deg-MAT.xml ICC\1-Lab_float-D93_2deg-MAT.icc
@if %errorlevel% neq 0 goto :failed
iccFromXml Data\Lab_float-IllumA_2deg-MAT.xml ICC\2-Lab_float-IllumA_2deg-MAT.icc
@if %errorlevel% neq 0 goto :failed
iccFromXml Data\Lab_float-D50_2deg.xml ICC\3-Lab_float-D50_2deg.icc
@if %errorlevel% neq 0 goto :failed
iccFromXml Data\Lab_float-F11_2deg-MAT.xml ICC\4-Lab_float-F11_2deg-MAT.icc
@if %errorlevel% neq 0 goto :failed
iccFromXml Data\Spec380_10_730-D50_2deg.xml ICC\S-Spec380_10_730-D50_2deg.icc
@if %errorlevel% neq 0 goto :failed
iccFromXml Data\MultiSpectralRGB.xml ICC\S-MultiSpectralRGB.icc
@if %errorlevel% neq 0 goto :failed

@ECHO *******************************************************************************
@ECHO Demonstrate application of base part of hybrid printer profile with reflectance
@ECHO *******************************************************************************

iccApplyProfiles -cfg config\hpwr-S1-PrintOutput.json
@if %errorlevel% neq 0 goto :failed
iccTiffDump Results\HappyBunniesCmyk.tif

iccApplyProfiles -cfg config\hpwr-S2-PrintProof.json
@if %errorlevel% neq 0 goto :failed

@ECHO ******************************************************************************
@ECHO Get spectral PCS data directly from a hybrid printer profile with reflectance
@ECHO ******************************************************************************

@type Data\cmykGrays.txt

iccApplyNamedCmm -cfg config\hpwr-S3-SpectralPcsAccess.json > Results\cmykGraysRefPcs.txt
@if %errorlevel% neq 0 goto :failed

@type Results\cmykGraysRefPcs.txt

@ECHO **********************************************************************************
@ECHO Do some spectral color management using an hybrid printer profile with reflectance
@ECHO **********************************************************************************

iccApplyProfiles -cfg config\hpwr-S4a-SpectralPrintProof.json
@if %errorlevel% neq 0 goto :failed

iccApplyProfiles -cfg config\hpwr-S4b-SpectralPrintProof.json
@if %errorlevel% neq 0 goto :failed

iccApplyProfiles -cfg config\hpwr-S5a-SpectralExtraction.json
@if %errorlevel% neq 0 goto :failed
iccTiffDump Results\HappyBunniesMSRGB.tif

@ECHO *************************************************************************
@ECHO Do a spectral round trip using an hybrid printer profile with reflectance
@ECHO *************************************************************************

@type Data\cmykGrays.txt

iccApplyNamedCmm -cfg config\hpwr-S5b-SpectralExtraction.json > Results\cmykGraysRef.txt
@if %errorlevel% neq 0 goto :failed

@type Results\cmykGraysRef.txt

iccApplySearch -cfg config\hpwr-S6-SpectralReproduction.json > Results\cmykGraysEst.txt
@if %errorlevel% neq 0 goto :failed

@type Results\cmykGraysEst.txt

@goto :done

:failed
@ECHO.
@ECHO *******************************************************************************
@ECHO ABORTING: the previous command failed with exit code %errorlevel%.
@ECHO Check that the iccDEV tools are on PATH and that earlier steps succeeded.
@ECHO *******************************************************************************
@exit /b %errorlevel%

:done
