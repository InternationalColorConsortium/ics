#!/usr/bin/env bash
#################################################################################
# ICS-HybridPrinterWithOverprintSimulation / BuildAndTest.sh
# Copyright (C) 2024-2026 The International Color Consortium.
#                                        All rights reserved.
#
# POSIX counterpart to BuildAndTest.bat.
#
# Builds the ICC profiles used by the ICS scenarios from their XML sources, then
# exercises each scenario (S1-S7) through iccApplyProfiles and iccApplyNamedCmm.
#
# Requires the iccDEV command line tools (iccFromXml, iccApplyProfiles,
# iccApplyNamedCmm, iccTiffDump) to be on PATH.
#################################################################################
set -eu

# Run from the directory that contains this script so relative paths resolve.
cd "$(dirname "$0")"

mkdir -p ICC Results config

echo "First lets build some useful ICC profiles"

echo "Build the hybrid overprint printer profiles"
iccFromXml CMYK-W_Overprint_Profile.xml      ICC/P-CMYK-W_Overprint_Profile.icc
iccFromXml CMYK-S_Overprint_Profile.xml      ICC/P-CMYK-S_Overprint_Profile.icc
iccFromXml CMYK-STop_Overprint_Profile.xml   ICC/P-CMYK-STop_Overprint_Profile.icc

echo "Build the overprint channel-selection (MID) profiles"
iccFromXml MW-Mid_Overprint.xml              ICC/M-MW-Mid_Overprint.icc
iccFromXml MS-Mid_Overprint.xml              ICC/M-MS-Mid_Overprint.icc
iccFromXml SC-Mid_Overprint.xml              ICC/M-SC-Mid_Overprint.icc

echo "Build the supporting PCS profiles"
iccFromXml Data/Lab_int-D50_2deg.xml         ICC/C-Lab_int-D50_2deg.icc
iccFromXml Data/Lab_int-D93_2deg-MAT.xml     ICC/1-Lab_int-D93_2deg-MAT.icc
iccFromXml Data/Spec380_10_730-D50_2deg.xml  ICC/S-Spec380_10_730-D50_2deg.icc

echo "****************************************************************************************"
echo "Demonstrate application of base part of hybrid printer profile with overprint simulation"
echo "****************************************************************************************"

iccApplyProfiles -cfg config/hpwos-S1-PrintOutput.json
iccTiffDump      Results/HappyBunniesCmyk.tif   || true   # inspection only: non-zero means profile warnings, not failure

iccApplyProfiles -cfg config/hpwos-S2-PrintProof.json

echo "********************************************************************"
echo "Apply Overprint simulation to CMYKS image to get background previews"
echo "********************************************************************"

iccApplyProfiles -cfg config/hpwos-S3-TShirtDesignPrevUW-W.json
iccApplyProfiles -cfg config/hpwos-S3-TShirtDesignPrevUW-R.json
iccApplyProfiles -cfg config/hpwos-S3-TShirtDesignPrevUW-G.json
iccApplyProfiles -cfg config/hpwos-S3-TShirtDesignPrevUW-B.json
iccApplyProfiles -cfg config/hpwos-S3-TShirtDesignPrevUW-K.json

iccApplyProfiles -cfg config/hpwos-S3-TShirtDesignPrevUS-W.json
iccApplyProfiles -cfg config/hpwos-S3-TShirtDesignPrevUS-R.json
iccApplyProfiles -cfg config/hpwos-S3-TShirtDesignPrevUS-G.json
iccApplyProfiles -cfg config/hpwos-S3-TShirtDesignPrevUS-B.json
iccApplyProfiles -cfg config/hpwos-S3-TShirtDesignPrevUS-K.json

iccApplyProfiles -cfg config/hpwos-S3-TShirtDesignPrevOS-W.json
iccApplyProfiles -cfg config/hpwos-S3-TShirtDesignPrevOS-R.json
iccApplyProfiles -cfg config/hpwos-S3-TShirtDesignPrevOS-G.json
iccApplyProfiles -cfg config/hpwos-S3-TShirtDesignPrevOS-B.json
iccApplyProfiles -cfg config/hpwos-S3-TShirtDesignPrevOS-K.json

iccApplyProfiles -cfg config/hpwos-S4-TShirtDesignPrevUW-G-M.json
iccApplyProfiles -cfg config/hpwos-S4-TShirtDesignPrevUS-G-M.json
iccApplyProfiles -cfg config/hpwos-S4-TShirtDesignPrevUS-W-CS.json

echo "*****************************************************************"
echo "Get information about spot colors in overprint simulation profile"
echo "*****************************************************************"

iccApplyNamedCmm -cfg config/hpwos-S5-SpotTintSampleLab.json         > Results/SpotTintSampleLab.txt
cat Results/SpotTintSampleLab.txt

iccApplyNamedCmm -cfg config/hpwos-S6-SpotTintSamplePccLab.json      > Results/SpotTintSamplePccLab.txt
cat Results/SpotTintSamplePccLab.txt

iccApplyNamedCmm -cfg config/hpwos-S7-SpotTintSampleRefOverWhite.json > Results/SpotTintSampleRefOverWhite.txt
cat Results/SpotTintSampleRefOverWhite.txt

iccApplyNamedCmm -cfg config/hpwos-S7-SpotTintSampleRefOverBlack.json > Results/SpotTintSampleRefOverBlack.txt
cat Results/SpotTintSampleRefOverBlack.txt
