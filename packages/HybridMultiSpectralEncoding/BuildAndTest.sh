#!/usr/bin/env bash
#################################################################################
# ICS-HybridMultiSpectralEncoding / BuildAndTest.sh
# Copyright (C) 2024-2026 The International Color Consortium.
#                                          All rights reserved.
#
# POSIX counterpart to BuildAndTest.bat.
#
# Builds the hybrid multi-spectral encoding profile and its supporting PCS / PCC
# profiles from their XML sources, then exercises every scenario (S1..S6) defined
# by the companion configuration files in ./config/ via iccApplyProfiles.
#
# Requires the iccDEV command line tools (iccFromXml, iccApplyProfiles,
# iccTiffDump) to be on PATH.
#################################################################################
set -eu

# Run from the directory that contains this script so relative paths resolve.
cd "$(dirname "$0")"

mkdir -p ICC Results config

echo "*******************************************************************************"
echo "First build the hybrid multi-spectral encoding profile (profile \"P\")"
echo "*******************************************************************************"
iccFromXml MultiSpectralRGB.xml                  ICC/P-MultiSpectralRGB.icc

echo "*******************************************************************************"
echo "Now build the supporting colorimetric PCC profiles (1..5) and spectral PCS (S)"
echo "*******************************************************************************"
iccFromXml Data/Lab_float-D93_2deg-MAT.xml       ICC/1-Lab_float-D93_2deg-MAT.icc
iccFromXml Data/Lab_float-IllumA_2deg-MAT.xml    ICC/2-Lab_float-IllumA_2deg-MAT.icc
iccFromXml Data/Lab_float-D50_2deg.xml           ICC/3-Lab_float-D50_2deg.icc
iccFromXml Data/Lab_float-F11_2deg-MAT.xml       ICC/4-Lab_float-F11_2deg-MAT.icc
iccFromXml Data/Lab_int-D65_2deg-MAT.xml         ICC/5-Lab_int-D65_2deg-MAT.icc
iccFromXml Data/Spec380_10_730-D50_2deg.xml      ICC/S-Spec380_10_730-D50_2deg.icc

echo "*******************************************************************************"
echo "S1/S2 - Demonstrate conversion to and from the multi-spectral encoding"
echo "*******************************************************************************"

echo "S1 - encode a spectral reflectance image into the multi-spectral encoding"
iccApplyProfiles -cfg config/hmse-S1-refCowsToMsCows.json
iccTiffDump      Results/MS_smCows.tif   || true   # inspection only: non-zero means profile warnings, not failure

echo "S2 - decode the multi-spectral encoding back to spectral reflectance"
iccApplyProfiles -cfg config/hmse-S2-msCowsToRefCows.json
iccTiffDump      Results/Ref_smCows.tif   || true   # inspection only: non-zero means profile warnings, not failure

echo "*******************************************************************************"
echo "S3/S4 - Preview the multi-spectral encoding as colorimetry (D50 and alternate"
echo "        observing conditions via a PCC override)"
echo "*******************************************************************************"

echo "S3 - colorimetric preview under the native D50 viewing conditions"
iccApplyProfiles -cfg config/hmse-S3-previewMSCowsD50.json

echo "S4 - colorimetric preview under alternate illuminants (PCC override)"
iccApplyProfiles -cfg config/hmse-S4-previewMSCowsA.json
iccApplyProfiles -cfg config/hmse-S4-previewMSCowsD65.json
iccApplyProfiles -cfg config/hmse-S4-previewMSCowsD93.json
iccApplyProfiles -cfg config/hmse-S4-previewMSCowsF11.json

echo "*******************************************************************************"
echo "For comparison, produce the same previews directly from the spectral image"
echo "*******************************************************************************"
iccApplyProfiles -cfg config/hmse-previewRefCowsD50.json
iccApplyProfiles -cfg config/hmse-previewRefCowsA.json
iccApplyProfiles -cfg config/hmse-previewRefCowsD65.json
iccApplyProfiles -cfg config/hmse-previewRefCowsD93.json
iccApplyProfiles -cfg config/hmse-previewRefCowsF11.json

echo "*******************************************************************************"
echo "S5 - legacy preview using only the base ICC profile (no iccMAX sub-profile)"
echo "*******************************************************************************"
iccApplyProfiles -cfg config/hmse-S5-previewRgbCowsD50.json

echo "*******************************************************************************"
echo "S6 - legacy to partial multi-spectral conversion (base ICC profile only)."
echo "     This creates a \"half\" multi-spectral image whose extra spectral channels"
echo "     were never populated - see the caution in the ICS document."
echo "*******************************************************************************"
iccApplyProfiles -cfg config/hmse-S6-rgbToHalfMS.json
iccTiffDump      Results/HappyBunniesHalfMS.tif   || true   # inspection only: non-zero means profile warnings, not failure

echo ""
echo "*******************************************************************************"
echo "The following application works - the base ICC profile can still preview the"
echo "half MS image (S5 style)"
echo "*******************************************************************************"
iccApplyProfiles -cfg config/hmse-S5-previewHalfMS.json

echo ""
echo "*******************************************************************************"
echo "The following application does NOT work - the spectral sub-profile needs multi-"
echo "spectral channels that the half MS image does not contain (S3 style)"
echo "*******************************************************************************"
iccApplyProfiles -cfg config/hmse-S3-previewHalfMS.json || \
  echo "(expected failure: the half MS image lacks the multi-spectral channels)"

echo ""
