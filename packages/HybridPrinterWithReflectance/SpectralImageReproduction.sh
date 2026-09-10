#!/usr/bin/env bash
#################################################################################
# ICS-HybridPrinterWithReflectance / SpectralImageReproduction.sh
# Copyright (C) 2024-2026 The International Color Consortium.
#                                        All rights reserved.
#
# Scenario S6b -- reproduce the 600x420 multispectral cows image into the hybrid
# CMYK printer profile by spectral inverse search, under the same four observing
# conditions (D93 / Illuminant A / D50 / F11) that the S6a cmykGrays search in
# BuildAndTest.sh uses.
#
# Deliberately NOT part of BuildAndTest.sh: every pixel runs a Nelder-Mead
# search across four weighted PCCs, so the full image costs minutes on modest
# hardware rather than the seconds every other scenario costs.
#
# Usage:  ./SpectralImageReproduction.sh        (from this folder)
#
#         Requires BuildAndTest.sh to have run first -- it builds the profiles
#         in ICC/ that the search chain and the PCC weights refer to.
#
# Requires the iccDEV command line tools (iccApplyProfiles, iccTiffDump) on PATH.
#################################################################################
set -eu

# Run from the directory that contains this script so relative paths resolve.
cd "$(dirname "$0")"

for required in Data/MS_smCows.tif \
                ICC/P-CMYK_Hybrid_Profile.icc \
                ICC/1-Lab_float-D93_2deg-MAT.icc \
                ICC/2-Lab_float-IllumA_2deg-MAT.icc \
                ICC/3-Lab_float-D50_2deg.icc \
                ICC/4-Lab_float-F11_2deg-MAT.icc; do
  if [ ! -f "$required" ]; then
    echo "missing $required -- run ./BuildAndTest.sh first" >&2
    exit 1
  fi
done

echo "*************************************************************************"
echo "S6b - Spectral image reproduction (full 600x420, inverse search per pixel)"
echo "This runs an inverse search per pixel; expect minutes, not seconds."
echo "*************************************************************************"

# connect.threads is 0 (hardware concurrency) in the config.  A search CMM gives
# every worker its own apply object with private sub-chain state, so the
# threaded result is identical to the single-threaded one -- only faster.
iccApplyProfiles -cfg config/hpwr-S6b-SpectralImageReproduction.json
iccTiffDump      Results/MS_smCowsPrn.tif   || true   # inspection only: non-zero means profile warnings, not failure

echo "Wrote Results/MS_smCowsPrn.tif"
