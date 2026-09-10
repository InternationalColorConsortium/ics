#!/usr/bin/env bash
#################################################################################
# ICS-ColorimetricEncoding / BuildAndTest.sh
# Copyright (C) 2024-2026 The International Color Consortium.
#                                          All rights reserved.
#
# POSIX counterpart to BuildAndTest.bat.
#
# Builds the colorimetricEncoding ICC profiles from their XML sources, then
# exercises every scenario (S1a..S7f) defined by the companion configuration
# files in ./config/ via iccApplyProfiles (image workflows S1..S5) and
# iccApplyNamedCmm (color-list workflows S6, S7).
#
# Requires the iccDEV command line tools (iccFromXml, iccApplyProfiles,
# iccApplyNamedCmm, iccTiffDump) to be on PATH.
#################################################################################
set -eu

# Run from the directory that contains this script so relative paths resolve.
cd "$(dirname "$0")"

mkdir -p ICC Results config

echo "*******************************************************************************"
echo "Build the colorimetricEncoding profiles (profile \"E\") and the PCC override"
echo "profile (profile \"P\") from their XML sources in ./Illuminants"
echo "*******************************************************************************"

iccFromXml Illuminants/Lab_float-D50_2deg.xml         ICC/E-Lab_float-D50_2deg.icc
iccFromXml Illuminants/Lab_float-D93_2deg-MAT.xml     ICC/E-Lab_float-D93_2deg-MAT.icc
iccFromXml Illuminants/Lab_int-D50_2deg.xml           ICC/E-Lab_int-D50_2deg.icc
iccFromXml Illuminants/Lab_int-D65_2deg-MAT.xml       ICC/E-Lab_int-D65_2deg-MAT.icc
iccFromXml Illuminants/Lab_int-D93_2deg-MAT.xml       ICC/E-Lab_int-D93_2deg-MAT.icc
iccFromXml Illuminants/Lab_int-IllumA_2deg-MAT.xml    ICC/E-Lab_int-IllumA_2deg-MAT.icc
iccFromXml Illuminants/Lab_int-IllumA_2deg-Abs.xml    ICC/E-Lab_int-IllumA_2deg-Abs.icc
iccFromXml Illuminants/Lab_int-IllumA_2deg-Abs.xml    ICC/P-Lab_int-IllumA_2deg-Abs.icc
iccFromXml Illuminants/XYZ_float-D50_2deg.xml         ICC/E-XYZ_float-D50_2deg.icc
iccFromXml Illuminants/XYZ_float-D65_2deg-MAT.xml     ICC/E-XYZ_float-D65_2deg-MAT.icc
iccFromXml Illuminants/XYZ_int-D50_2deg.xml           ICC/E-XYZ_int-D50_2deg.icc
iccFromXml Illuminants/XYZ_int-D65_2deg-MAT.xml       ICC/E-XYZ_int-D65_2deg-MAT.icc
iccFromXml Illuminants/XYZ_int-D65_2deg-MAT-Lvl2.xml  ICC/E-XYZ_int-D65_2deg-MAT-Lvl2.icc
iccFromXml Illuminants/XYZ_int-D93_2deg-MAT.xml       ICC/E-XYZ_int-D93_2deg-MAT.icc
iccFromXml Illuminants/XYZ_int-IllumA_2deg-MAT.xml    ICC/E-XYZ_int-IllumA_2deg-MAT.icc

echo "*******************************************************************************"
echo "Build additional colorimetricEncoding profiles (profile \"E\") for"
echo "Asano's Categorical observers and the CIE 2015 observer"
echo "(Not used by sceenarios but available for testing)."
echo "*******************************************************************************"

iccFromXml CustomObservers/LabCat1-D50_2deg.xml  ICC/E-LabCat1-D50_2deg.icc
iccFromXml CustomObservers/LabCat1-D65_2deg.xml  ICC/E-LabCat1-D65_2deg.icc
iccFromXml CustomObservers/LabCat2-D50_2deg.xml  ICC/E-LabCat2-D50_2deg.icc
iccFromXml CustomObservers/LabCat2-D65_2deg.xml  ICC/E-LabCat2-D65_2deg.icc
iccFromXml CustomObservers/LabCat3-D50_2deg.xml  ICC/E-LabCat3-D50_2deg.icc
iccFromXml CustomObservers/LabCat3-D65_2deg.xml  ICC/E-LabCat3-D65_2deg.icc
iccFromXml CustomObservers/LabCat4-D50_2deg.xml  ICC/E-LabCat4-D50_2deg.icc
iccFromXml CustomObservers/LabCat4-D65_2deg.xml  ICC/E-LabCat4-D65_2deg.icc
iccFromXml CustomObservers/LabCat5-D50_2deg.xml  ICC/E-LabCat5-D50_2deg.icc
iccFromXml CustomObservers/LabCat5-D65_2deg.xml  ICC/E-LabCat5-D65_2deg.icc
iccFromXml CustomObservers/LabCat6-D50_2deg.xml  ICC/E-LabCat6-D50_2deg.icc
iccFromXml CustomObservers/LabCat6-D65_2deg.xml  ICC/E-LabCat6-D65_2deg.icc
iccFromXml CustomObservers/LabCat7-D50_2deg.xml  ICC/E-LabCat7-D50_2deg.icc
iccFromXml CustomObservers/LabCat7-D65_2deg.xml  ICC/E-LabCat7-D65_2deg.icc
iccFromXml CustomObservers/LabCat8-D50_2deg.xml  ICC/E-LabCat8-D50_2deg.icc
iccFromXml CustomObservers/LabCat8-D65_2deg.xml  ICC/E-LabCat8-D65_2deg.icc
iccFromXml CustomObservers/LabCat9-D50_2deg.xml  ICC/E-LabCat9-D50_2deg.icc
iccFromXml CustomObservers/LabCat9-D65_2deg.xml  ICC/E-LabCat9-D65_2deg.icc
iccFromXml CustomObservers/LabCat10-D50_2deg.xml ICC/E-LabCat10-D50_2deg.icc
iccFromXml CustomObservers/LabCat10-D65_2deg.xml ICC/E-LabCat10-D65_2deg.icc
iccFromXml CustomObservers/Lab2015-D50_2deg.xml  ICC/E-Lab2015-D50_2deg.icc
iccFromXml CustomObservers/Lab2015-D65_2deg.xml  ICC/E-Lab2015-D65_2deg.icc

echo "*******************************************************************************"
echo "Build the spectral PCS profile used as the source for the S6 scenarios."
echo "*******************************************************************************"

iccFromXml Data/Spec380_10_730-D50_2deg.xml      ICC/S-Spec380_10_730-D50_2deg.icc

echo "*******************************************************************************"
echo "Scenario S1 - encode an sRGB image into a colorimetric encoding (\"E as dst\")"
echo "*******************************************************************************"

iccApplyProfiles -cfg config/ce-S1a-IccToColorEncodingD93.json
iccTiffDump      Results/E-HappyBunnies-S1a.tif   || true   # inspection only: non-zero means profile warnings, not failure

iccApplyProfiles -cfg config/ce-S1b-IccToColorEncodingA.json
iccTiffDump      Results/E-HappyBunnies-S1b.tif   || true   # inspection only: non-zero means profile warnings, not failure

echo "*******************************************************************************"
echo "Scenario S2 - same as S1 but with a PCC override on the encoding profile"
echo "*******************************************************************************"

iccApplyProfiles -cfg config/ce-S2-IccToColorEncodingAWithPcc.json
iccTiffDump      Results/E-HappyBunnies-S2.tif   || true   # inspection only: non-zero means profile warnings, not failure

echo "*******************************************************************************"
echo "Scenario S3 - decode a colorimetrically-encoded image back to an ICC profile"
echo "*******************************************************************************"

iccApplyProfiles -cfg config/ce-S3a-ColorEncodingD93ToIcc.json
iccApplyProfiles -cfg config/ce-S3b-ColorEncodingAToIcc.json
iccApplyProfiles -cfg config/ce-S3c-ColorEncodingAPccToIcc.json

echo "*******************************************************************************"
echo "Scenario S4 - decode a colorimetrically-encoded image with a PCC override"
echo "*******************************************************************************"

iccApplyProfiles -cfg config/ce-S4-ColorEncodingAWithPccToIcc.json

echo "*******************************************************************************"
echo "Scenario S5 - use a colorimetricEncoding profile as a PCC override only"
echo "*******************************************************************************"

iccApplyProfiles -cfg config/ce-S5a-IccToIccWithPcc.json
iccTiffDump      Results/2-HappyBunniesS5a.tif   || true   # inspection only: non-zero means profile warnings, not failure

iccApplyProfiles -cfg config/ce-S5b-ColorIccWithPccToIcc.json
iccApplyProfiles -cfg config/ce-S5c-SpectralIccWithPccToIcc.json

echo "*******************************************************************************"
echo "Scenario S6 - convert spectral chart reference data to a colorimetric encoding"
echo "             (RefTo*: chartRef.txt -> S-Spec380 -> E-XYZ or E-Lab encoding)"
echo "*******************************************************************************"

iccApplyNamedCmm -cfg config/ce-S6a-RefToXYZA.json        > Results/chartRef-S6a-XYZA.txt
iccApplyNamedCmm -cfg config/ce-S6b-RefToXYZD50.json      > Results/chartRef-S6b-XYZD50.txt
iccApplyNamedCmm -cfg config/ce-S6c-RefToXYZD93.json      > Results/chartRef-S6c-XYZD93.txt
iccApplyNamedCmm -cfg config/ce-S6d-RefToLabD50.json      > Results/chartRef-S6d-LabD50.txt
iccApplyNamedCmm -cfg config/ce-S6e-RefToLab2015.json     > Results/chartRef-S6e-Lab2015.txt
iccApplyNamedCmm -cfg config/ce-S6f-RefToLabCat8.json     > Results/chartRef-S6f-LabCat8.txt

echo "*******************************************************************************"
echo "Scenario S7 - convert one colorimetric encoding to another (with possible"
echo "             change in observing conditions). Source values are inline in the"
echo "             config; both source and destination are colorimetricEncoding"
echo "             profiles (\"value\" encoded)."
echo "*******************************************************************************"

iccApplyNamedCmm -cfg config/ce-S7a-XYZToLabA.json        > Results/S7a-XYZ-to-LabA.txt
iccApplyNamedCmm -cfg config/ce-S7b-XYZToLabD93.json      > Results/S7b-XYZ-to-LabD93.txt
iccApplyNamedCmm -cfg config/ce-S7c-LabD50ToLabA.json     > Results/S7c-LabD50-to-LabA.txt
iccApplyNamedCmm -cfg config/ce-S7d-LabD50ToLabD93.json   > Results/S7d-LabD50-to-LabD93.txt
iccApplyNamedCmm -cfg config/ce-S7e-LabD50ToLab2015.json  > Results/S7e-LabD50-to-Lab2015.txt
iccApplyNamedCmm -cfg config/ce-S7f-LabD50ToLabCat8.json  > Results/S7f-LabD50-to-LabCat8.txt
