#!/usr/bin/env bash
#################################################################################
# ICS packages / BuildAndTest.sh
# Copyright (C) 2024-2026 The International Color Consortium.
#                                          All rights reserved.
#
# POSIX counterpart to BuildAndTest.bat.
#
# Builds and tests every ICS package in this directory, in turn, and prints a
# pass/fail summary at the end.
#
# Checks first that the iccDEV command line tools are on PATH. Without them each
# package script creates empty ICC/ and Results/ directories and reports nothing
# useful, which is easily mistaken for success - so this stops before anything is
# built.
#
# Requires iccFromXml, iccApplyProfiles, iccApplyNamedCmm, iccApplySearch and
# iccTiffDump. See the iccDEV project for installation.
#################################################################################
# Deliberately not "set -e": a failing package should be recorded and reported in
# the summary, not abort the whole run.
set -u

# Run from the directory that contains this script so relative paths resolve.
cd "$(dirname "$0")"

RULE="==============================================================================="
STARS="*******************************************************************************"

# ---- preflight: are the tools reachable? ------------------------------------
TOOLS="iccFromXml iccApplyProfiles iccApplyNamedCmm iccApplySearch iccTiffDump"
MISSING=""
for tool in $TOOLS; do
    command -v "$tool" >/dev/null 2>&1 || MISSING="$MISSING $tool"
done

if [ -n "$MISSING" ]; then
    echo ""
    echo "$STARS"
    echo "WARNING: these iccDEV command line tools were not found on PATH:"
    echo ""
    for tool in $MISSING; do
        echo "       $tool"
    done
    echo ""
    echo "Nothing has been built. Without the tools each package would create empty"
    echo "ICC/ and Results/ directories and report no error, which looks like success."
    echo ""
    echo "Add the iccDEV tools to PATH and run this script again, for example:"
    echo ""
    echo "       export PATH=/path/to/iccdev/bin:\$PATH"
    echo ""
    echo "The expected output of every scenario is already committed under each"
    echo "package's Results/ directory, so the packages stay usable as a reference"
    echo "even without the tools."
    echo "$STARS"
    echo ""
    exit 1
fi

# ---- build and test each package --------------------------------------------
PASSED=""
FAILED=""
COUNT=0

for dir in */; do
    pkg="${dir%/}"
    [ -f "$pkg/BuildAndTest.sh" ] || continue
    COUNT=$((COUNT + 1))
    echo ""
    echo "$RULE"
    echo "  $pkg"
    echo "$RULE"
    # invoked through bash so a missing execute bit is not a failure mode;
    # the package script cd's to its own directory itself
    if bash "$pkg/BuildAndTest.sh"; then
        PASSED="$PASSED $pkg"
    else
        FAILED="$FAILED $pkg"
    fi
done

if [ "$COUNT" -eq 0 ]; then
    echo ""
    echo "WARNING: no package with a BuildAndTest.sh was found in $(pwd)."
    echo ""
    exit 1
fi

# ---- summary -----------------------------------------------------------------
echo ""
echo "$RULE"
echo "  Summary"
echo "$RULE"
for pkg in $PASSED; do echo "  PASS   $pkg"; done
for pkg in $FAILED; do echo "  FAIL   $pkg"; done
echo ""

if [ -n "$FAILED" ]; then
    echo "One or more packages failed. See the output above for the failing step."
    echo ""
    exit 1
fi

echo "All $COUNT packages built and tested."
echo "Inspect each package's ICC/ and Results/ directories for the artifacts."
echo ""
exit 0
