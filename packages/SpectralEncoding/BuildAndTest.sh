#!/usr/bin/env bash
#################################################################################
# ICS-SpectralEncoding / BuildAndTest.sh
# Copyright (C) 2024-2026 The International Color Consortium.
#                                          All rights reserved.
#
# POSIX counterpart to BuildAndTest.bat.
#
# Builds the spectralEncoding profiles (a full-resolution spectral encoding and
# an abridged multi-spectral encoding) plus the supporting colorimetric PCC
# profiles from their XML sources, then exercises every scenario (S1..S5)
# defined by the companion configuration files in ./config/ via iccApplyProfiles.
#
# This ICS works only with iccMAX (ISO 20677-1) profiles.
#
# Requires the iccDEV command line tools (iccFromXml, iccApplyProfiles,
# iccTiffDump) to be installed and on PATH.
#################################################################################
set -eu

# Run from the directory that contains this script so relative paths resolve.
cd "$(dirname "$0")"

mkdir -p ICC Results config

echo "*******************************************************************************"
echo "Build the spectralEncoding profiles (profile \"R\"):"
echo "  R-Spec380_10_730-D50  - full spectral encoding  (36 device == 36 PCS bands)"
echo "  R-SixChanMsRef        - abridged multi-spectral encoding (6 device -> 36 PCS)"
echo "*******************************************************************************"
iccFromXml Spec380_10_730-D50_2deg.xml           ICC/R-Spec380_10_730-D50_2deg.icc
iccFromXml SixChanMsRef.xml                       ICC/R-SixChanMsRef.icc

echo "*******************************************************************************"
echo "Build the supporting colorimetric PCC override profiles (1..5)"
echo "*******************************************************************************"
iccFromXml Data/Lab_float-D93_2deg-MAT.xml       ICC/1-Lab_float-D93_2deg-MAT.icc
iccFromXml Data/Lab_float-IllumA_2deg-MAT.xml    ICC/2-Lab_float-IllumA_2deg-MAT.icc
iccFromXml Data/Lab_float-D50_2deg.xml           ICC/3-Lab_float-D50_2deg.icc
iccFromXml Data/Lab_float-F11_2deg-MAT.xml       ICC/4-Lab_float-F11_2deg-MAT.icc
iccFromXml Data/Lab_int-D65_2deg-MAT.xml         ICC/5-Lab_int-D65_2deg-MAT.icc

echo "*******************************************************************************"
echo "S1a - FULL encoding as source to a colorimetric destination (sRGB),"
echo "      previewed under its native D50 observing conditions   [Scenario 1: R->C]"
echo "*******************************************************************************"
iccApplyProfiles -cfg config/se-S1a-refCowsToSrgbD50.json

echo "*******************************************************************************"
echo "S2  - FULL encoding as source with a colorimetric PCC override, previewed to"
echo "      sRGB under alternate observing conditions             [Scenario 2: R+P->C]"
echo "*******************************************************************************"
iccApplyProfiles -cfg config/se-S2a-refCowsToSrgbA.json
iccApplyProfiles -cfg config/se-S2b-refCowsToSrgbD65.json
iccApplyProfiles -cfg config/se-S2c-refCowsToSrgbD93.json
iccApplyProfiles -cfg config/se-S2d-refCowsToSrgbF11.json

echo "*******************************************************************************"
echo "S3a - FULL encoding as source to a spectral-PCS destination (the 81-band"
echo "      380-780nm/5nm image resampled to 36-band 380-730nm/10nm)  [Scenario 3: R->S]"
echo "*******************************************************************************"
iccApplyProfiles -cfg config/se-S3a-refCowsToSpec.json
iccTiffDump      Results/Spec_smCows.tif   || true   # inspection only: non-zero means profile warnings, not failure

echo "*******************************************************************************"
echo "S4a - spectral-PCS source to the FULL encoding as destination (round trip,"
echo "      reconstructing the spectral device values)             [Scenario 4: S->R]"
echo "*******************************************************************************"
iccApplyProfiles -cfg config/se-S4a-specToRefCows.json
iccTiffDump      Results/Ref_smCows.tif   || true   # inspection only: non-zero means profile warnings, not failure

echo "*******************************************************************************"
echo "S4b - spectral-PCS source to the ABRIDGED encoding as destination: encode the"
echo "      36-band spectral cows into a 6-channel multi-spectral image [Scenario 4: S->R]"
echo "*******************************************************************************"
iccApplyProfiles -cfg config/se-S4b-specToMs6.json
iccTiffDump      Results/MS6_smCows.tif   || true   # inspection only: non-zero means profile warnings, not failure

echo "*******************************************************************************"
echo "S1b - ABRIDGED encoding as source to a colorimetric destination (sRGB): decode"
echo "      the 6-channel image to spectral, then to colorimetry under its native D93"
echo "      observing conditions                                   [Scenario 1: R->C]"
echo "*******************************************************************************"
iccApplyProfiles -cfg config/se-S1b-ms6ToSrgb.json

echo "*******************************************************************************"
echo "S3b - ABRIDGED encoding as source to a spectral-PCS destination: reconstruct the"
echo "      full 36-band spectral reflectance from the 6 channels   [Scenario 3: R->S]"
echo "*******************************************************************************"
iccApplyProfiles -cfg config/se-S3b-ms6ToSpec.json
iccTiffDump      Results/Spec_ms6Cows.tif   || true   # inspection only: non-zero means profile warnings, not failure

echo "*******************************************************************************"
echo "S5  - ABRIDGED encoding used purely as a PCC override: its D93 observing"
echo "      conditions and s2cp/c2sp transforms re-render the cows  [Scenario 5: R as PCC]"
echo "*******************************************************************************"
iccApplyProfiles -cfg config/se-S5-previewCowsMsPcc.json

echo ""
echo "Done. Inspect ICC/ and Results/ for the conformance artifacts."
echo ""
