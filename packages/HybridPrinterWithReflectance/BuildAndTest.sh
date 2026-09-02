#!/usr/bin/env bash
#################################################################################
# ICS-HybridPrinterWithReflectance / BuildAndTest.sh
# Copyright (C) 2024-2026 The International Color Consortium.
#                                        All rights reserved.
#
# POSIX counterpart to BuildAndTest.bat.
#
# Builds the ICC profiles used by the ICS scenarios from their XML sources, then
# exercises each scenario through iccApplyProfiles, iccApplyNamedCmm and
# iccApplySearch.
#
# Requires the iccDEV command line tools (iccFromXml, iccApplyProfiles,
# iccApplyNamedCmm, iccApplySearch, iccTiffDump) to be on PATH.
#################################################################################
set -eu

# Run from the directory that contains this script so relative paths resolve.
cd "$(dirname "$0")"

mkdir -p ICC Results config

echo "First lets build some useful ICC profiles"

echo "First lets create a hybrid spectral printer profile"
iccFromXml CMYK_Hybrid_Profile.xml             ICC/P-CMYK_Hybrid_Profile.icc

echo "Now we need some support profiles for working with spectral PCS"
iccFromXml Data/Lab_float-D93_2deg-MAT.xml     ICC/1-Lab_float-D93_2deg-MAT.icc
iccFromXml Data/Lab_float-IllumA_2deg-MAT.xml  ICC/2-Lab_float-IllumA_2deg-MAT.icc
iccFromXml Data/Lab_float-D50_2deg.xml         ICC/3-Lab_float-D50_2deg.icc
iccFromXml Data/Lab_float-F11_2deg-MAT.xml     ICC/4-Lab_float-F11_2deg-MAT.icc
iccFromXml Data/Spec380_10_730-D50_2deg.xml    ICC/S-Spec380_10_730-D50_2deg.icc
iccFromXml Data/MultiSpectralRGB.xml           ICC/S-MultiSpectralRGB.icc

echo "*******************************************************************************"
echo "Demonstrate application of base part of hybrid printer profile with reflectance"
echo "*******************************************************************************"

iccApplyProfiles -cfg config/hpwr-S1-PrintOutput.json
iccTiffDump      Results/HappyBunniesCmyk.tif   || true   # inspection only: non-zero means profile warnings, not failure

iccApplyProfiles -cfg config/hpwr-S2-PrintProof.json

echo "******************************************************************************"
echo "Get spectral PCS data directly from a hybrid printer profile with reflectance"
echo "******************************************************************************"

cat Data/cmykGrays.txt

iccApplyNamedCmm -cfg config/hpwr-S3-SpectralPcsAccess.json      > Results/cmykGraysRefPcs.txt

cat Results/cmykGraysRefPcs.txt

echo "**********************************************************************************"
echo "Do some spectral color management using an hybrid printer profile with reflectance"
echo "**********************************************************************************"

iccApplyProfiles -cfg config/hpwr-S4a-SpectralPrintProof.json

iccApplyProfiles -cfg config/hpwr-S4b-SpectralPrintProof.json

iccApplyProfiles -cfg config/hpwr-S5a-SpectralExtraction.json
iccTiffDump      Results/HappyBunniesMSRGB.tif   || true   # inspection only: non-zero means profile warnings, not failure

echo "*************************************************************************"
echo "Do a spectral round trip using an hybrid printer profile with reflectance"
echo "*************************************************************************"

cat Data/cmykGrays.txt

iccApplyNamedCmm -cfg config/hpwr-S5b-SpectralExtraction.json > Results/cmykGraysRef.txt

cat Results/cmykGraysRef.txt

iccApplySearch   -cfg config/hpwr-S6-SpectralReproduction.json > Results/cmykGraysEst.txt

cat Results/cmykGraysEst.txt
