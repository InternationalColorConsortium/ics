# ICS — Hybrid Printer With Reflectance

This folder is an **Interoperability Conformance Specification (ICS)**
package that exercises the use of *Hybrid Printer With Reflectance* ICC
profiles (iccMAX / ICC.2 v5 profiles that pair a colorimetric base part with
a spectral reflectance sub-profile).

The package contains:

* **`ICS-HybridPrinterWithReflectance.pdf`** — the ICS document. This is
  the normative reference for the package; everything else in the folder
  is example material that supports it.
* A worked example profile (`CMYK_Hybrid_Profile.xml`) and supporting PCS /
  observer / spectral profiles (in `Data/`).
* JSON configuration files (in `config/`) that drive each of the ICS
  scenarios (S1 … S6b).
* Build / test scripts (`BuildAndTest.bat`, `BuildAndTest.sh`) that assemble
  the profiles and execute every scenario end-to-end except S6b, plus
  `SpectralImageReproduction.{bat,sh}` for S6b, which runs an inverse search
  per pixel and so costs minutes rather than seconds.

It is intended to be run against the [iccDEV](https://github.com/InternationalColorConsortium/DemoIccMAX)
command line tool suite.

---

## 1. Prerequisites

The scripts assume the following iccDEV tools are installed and on `PATH`:

| Tool | Used for |
|------|----------|
| `iccFromXml` | Building `.icc` profiles from their XML definitions |
| `iccApplyProfiles` | Applying a profile sequence to a TIFF image |
| `iccApplyNamedCmm` | Applying a profile sequence to a colour list |
| `iccApplySearch` | Inverse search through a profile sequence |
| `iccTiffDump` | Dumping TIFF header / channel metadata |

On Windows the iccDEV binaries are typically installed to a location such as
`C:\Program Files\RefIccMAX\bin`; add that directory to your `PATH`.
On macOS / Linux either install the iccDEV tools to `/usr/local/bin` or
prepend the build output directory to `PATH` before invoking the script.

A POSIX shell (`bash`) is required for `BuildAndTest.sh`. On Windows the
script can be run under Git Bash, WSL, or any other bash-compatible shell.

---

## 2. Running the package

Both scripts must be run from this folder. They create the `ICC/`,
`Results/` and `config/` directories on first run if they do not already
exist (the `config/` JSON files are part of the package — the script only
ensures the directory exists).

### Windows

```bat
BuildAndTest.bat
```

### macOS / Linux / Git Bash

```sh
./BuildAndTest.sh
```

Both scripts execute the same sequence of steps and should produce
identical content in `ICC/` and `Results/`.

### Scenario S6b (optional, slow)

S6b reproduces a full multispectral image by inverse search — one search per
pixel — so it is driven by its own script rather than by `BuildAndTest`.
Run `BuildAndTest` first, then:

```bat
SpectralImageReproduction.bat
```

```sh
./SpectralImageReproduction.sh
```

Expect minutes rather than seconds; the config sets `connect.threads` to 0
(hardware concurrency), and the threaded result is identical to the
single-threaded one.

---

## 3. Folder layout

```
HybridPrinterWithReflectance/
├── BuildAndTest.bat                # Windows driver script
├── BuildAndTest.sh                 # POSIX driver script (same workflow)
├── SpectralImageReproduction.bat   # Windows driver for S6b (slow, run by hand)
├── SpectralImageReproduction.sh    # POSIX driver for S6b (same workflow)
├── CMYK_Hybrid_Profile.xml         # XML source of the hybrid printer profile
├── ICS-HybridPrinterWithReflectance.pdf  # ICS document (normative reference)
├── README.md                       # This file
├── docs/
│   └── Scenarios.md                # Per-scenario reference (S1 … S6b)
├── Data/                           # Inputs: imagery, observer XMLs, PCS XMLs
│   ├── C-sRGB_v4_ICC_preference.icc
│   ├── HappyBunniesRGB.tif         # Source RGB image for scenarios S1–S5a
│   ├── MS_smCows.tif               # 8-channel multispectral source for S6b
│   ├── Lab_float-D50_2deg.xml      # PCS @ D50, 2°
│   ├── Lab_float-D93_2deg-MAT.xml  # PCS @ D93, 2° (chromatic adaptation MAT)
│   ├── Lab_float-F11_2deg-MAT.xml  # PCS @ F11, 2°
│   ├── Lab_float-IllumA_2deg-MAT.xml # PCS @ Illuminant A, 2°
│   ├── MultiSpectralRGB.xml        # Multispectral RGB encoding profile
│   ├── Spec380_10_730-D50_2deg.xml # Spectral PCS (380…730 nm, 10 nm)
│   ├── cmykGrays.txt               # Two CMYK greys for the spectral round trip
│   └── cmykGreysPlot.png           # Reference plot of the round trip
├── config/                         # JSON drivers for each scenario
│   ├── hpwr-S1-PrintOutput.json
│   ├── hpwr-S2-PrintProof.json
│   ├── hpwr-S3-SpectralPcsAccess.json
│   ├── hpwr-S4a-SpectralPrintProof.json
│   ├── hpwr-S4b-SpectralPrintProof.json
│   ├── hpwr-S5a-SpectralExtraction.json
│   ├── hpwr-S5b-SpectralExtraction.json
│   ├── hpwr-S6a-SpectralReproduction.json
│   ├── hpwr-S6b-SpectralImageReproduction.json
│   └── hpwr-test_cmyk_to_ref.json   # ad-hoc extra (not part of the scenario set)
├── ICC/                            # Built profiles (created by script)
└── Results/                        # Generated images / colour lists (created by script)
```

`ICC/` and `Results/` are *populated* by the build script and are the
artifacts to inspect when verifying conformance. They are not source.

---

## 4. Scenarios

The ICS defines six scenarios that progressively exercise the hybrid
printer profile. Each scenario has a corresponding `hpwr-S*-*.json`
configuration file. A detailed description is in
[docs/Scenarios.md](docs/Scenarios.md); a one-line summary:

| ID | Driver / Config | What it demonstrates |
|----|-----------------|----------------------|
| S1 | `iccApplyProfiles` / `hpwr-S1-PrintOutput.json` | sRGB → hybrid-CMYK rendering |
| S2 | `iccApplyProfiles` / `hpwr-S2-PrintProof.json` | Colorimetric (D50) proof of the CMYK output back to sRGB |
| S3 | `iccApplyNamedCmm` / `hpwr-S3-SpectralPcsAccess.json` | Read spectral PCS values directly out of the v5 sub-profile (no PCS processing) |
| S4a | `iccApplyProfiles` / `hpwr-S4a-SpectralPrintProof.json` | Spectral proof under Illuminant A using the v5 sub-profile |
| S4b | `iccApplyProfiles` / `hpwr-S4b-SpectralPrintProof.json` | Spectral proof under D93 using the v5 sub-profile |
| S5a | `iccApplyProfiles` / `hpwr-S5a-SpectralExtraction.json` | Extract a multispectral RGB image from CMYK via reflectance |
| S5b | `iccApplyNamedCmm` / `hpwr-S5b-SpectralExtraction.json` | Extract the reflectance spectrum for two CMYK greys |
| S6a | `iccApplySearch` / `hpwr-S6a-SpectralReproduction.json` | Inverse spectral reproduction of a colour list (find CMYK matching a reflectance) under four illuminants |
| S6b | `iccApplyProfiles` / `hpwr-S6b-SpectralImageReproduction.json` | The same inverse search applied to a multispectral **image** (`connect.useSearch`). Not run by `BuildAndTest` — see `SpectralImageReproduction.{bat,sh}` |

S3 is the simplest of the v5 scenarios — it only uses the forward
transform of the sub-profile, so it needs no iccMAX PCS processing at all.

`config/hpwr-test_cmyk_to_ref.json` is an **ad-hoc extra**, not one of the ICS
scenarios and not run by `BuildAndTest.{bat,sh}`. It pushes the CMYK patches in
`Data/cmykTest.txt` through the hybrid profile's v5 sub-profile into the spectral
PCS — the same pipeline as S5b, but for paper white (`0 0 0 0`) and solid black
(`0 0 0 100`) instead of the two greys, so it brackets the printer's reflectance
range. Run it by hand:

```sh
iccApplyNamedCmm -cfg config/hpwr-test_cmyk_to_ref.json
```

The S5b / S6a pair forms a spectral round trip: S5b produces a reflectance
spectrum from CMYK, and S6a searches for a CMYK that reproduces it under
D93/A/D50/F11 with equal weight. The output `Results/cmykGraysEst.txt`
should be close to `Data/cmykGrays.txt`.

S6b scales that same search up from two patches to a 600×420 multispectral
image. `Data/MS_smCows.tif` is the RIT Munsell MetaCow target, built from
metameric pairs — precisely the content a colorimetric-only workflow cannot
reproduce, and the reason the search optimises across all four observing
conditions at once.

---

## 5. What the scripts produce

After a successful run, `ICC/` contains:

```
P-CMYK_Hybrid_Profile.icc          # The hybrid printer profile under test
1-Lab_float-D93_2deg-MAT.icc       # PCS profiles used for absolute colorimetric
2-Lab_float-IllumA_2deg-MAT.icc    # rendering under several illuminants and as
3-Lab_float-D50_2deg.icc           # PCC weights for the inverse search in Scenario 6
4-Lab_float-F11_2deg-MAT.icc
S-Spec380_10_730-D50_2deg.icc      # Spectral PCS (380–730 nm, 10 nm step)
S-MultiSpectralRGB.icc             # Multispectral RGB encoding profile
```

and `Results/` contains:

```
HappyBunniesCmyk.tif        # S1 — CMYK rendering of the source image
HappyBunniesProofD50.tif    # S2 — D50 colorimetric proof
cmykGraysRefPcs.txt         # S3  — Spectral PCS values of the two greys
HappyBunniesProofA.tif      # S4a — Illuminant A spectral proof
HappyBunniesProofD93.tif    # S4b — D93 spectral proof
HappyBunniesMSRGB.tif       # S5a — Multispectral RGB extraction
cmykGraysRef.txt            # S5b — Reflectance spectra of the two greys
cmykGraysEst.txt            # S6a — CMYK estimated from those spectra
```

`SpectralImageReproduction.{bat,sh}` adds one more:

```
MS_smCowsPrn.tif           # S6b — CMYK image reproduced by spectral search
```

The script also echoes the contents of `Data/cmykGrays.txt`,
`Results/cmykGraysRefPcs.txt`, `Results/cmykGraysRef.txt` and
`Results/cmykGraysEst.txt` so the spectral
round trip can be eyeballed directly.

---

## 6. Naming conventions

Built profile filenames use a single-character prefix to indicate role:

* `P-` — the **P**rofile under test (the hybrid printer profile).
* `1-`…`4-` — colorimetric PCS profiles used to evaluate under different
  illuminants. The number is also the PCC index used by the inverse
  search in S6a and S6b.
* `S-` — **S**pectral profiles (spectral PCS, or multispectral encoding).

Configuration filenames use the pattern `hpwr-S<n>-<purpose>.json`, where
`hpwr` denotes *Hybrid Printer With Reflectance* and `<n>` is the scenario
number from the ICS document. A letter suffix distinguishes drivers within
one numbered scenario — S4a/S4b differ by observing condition, S5a/S5b and
S6a/S6b by whether the workflow is a colour list or an image.

---

## 7. Path separators

All `config/*.json` driver files use POSIX-style forward slashes for paths
(e.g. `ICC/P-CMYK_Hybrid_Profile.icc`). Both Windows and POSIX builds of
the iccDEV tools accept forward slashes, so the same configs work under
either driver script. Do not introduce backslashes into the JSON if the
package is intended to remain cross-platform.

---

## 8. Maintainer

Max Derhak (ICC) — questions, errata and pull requests welcome.

---

## 9. License

Copyright © 2024–2026 The International Color Consortium. All rights reserved.

The package's **software and data** — build scripts, JSON scenario configurations,
profile XML sources and sample data — are distributed under the **BSD 3-Clause "New" or
"Revised" License**, the licence of the parent
[iccDEV](https://github.com/InternationalColorConsortium/iccDEV) project (see its
`LICENSE.md`).

The **`ICS-*.pdf` document is a specification, not software.** It was prepared under the
ICC Intellectual Property Policy stated in its own Foreword, and its distribution is
governed by ICC's policy for specification documents rather than by the BSD licence above.
