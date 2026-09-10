# ICS — Hybrid Printer With Overprint Simulation

This folder is an **Interoperability Conformance Specification (ICS)**
package that exercises the use of *Hybrid Printer With Overprint Simulation*
ICC profiles (iccMAX / ICC.2 v5 profiles that pair a colorimetric ICC printer
base part with an `osim` overprint-simulation sub-profile that adds spot/extra
ink channels and optional spectral reflectance).

The package contains:

* **`ICS-HybridPrinterWithOverprintSimulation.pdf`** — the ICS document. This is
  the normative reference for the package; everything else in the folder is
  example material that supports it.
* Eleven external data files in `Spot-Overprint/` that the three printer profile
  XMLs pull in by `Filename=` reference from inside their `calculatorElement`
  (shaper curves, CMYK scale/offset CLUTs and spot-ink tint arrays). They are
  source, not generated — `iccFromXml` reads them when building the profiles.
* Worked-example profiles — the hybrid printer profiles
  (`CMYK-W_Overprint_Profile.xml`, `CMYK-S_Overprint_Profile.xml`,
  `CMYK-STop_Overprint_Profile.xml`), the overprint channel-selection (MID)
  profiles (`MW-Mid_Overprint.xml`, `MS-Mid_Overprint.xml`,
  `SC-Mid_Overprint.xml`), and supporting PCS / spectral profiles (in `Data/`).
* JSON configuration files (in `config/`) that drive each of the ICS
  scenarios (S1 … S7).
* Build / test scripts (`BuildAndTest.bat`, `BuildAndTest.sh`) that assemble
  the profiles and execute every scenario end-to-end.

It is intended to be run against the [iccDEV](https://github.com/InternationalColorConsortium/DemoIccMAX)
command line tool suite.

---

## 1. Prerequisites

The scripts assume the following iccDEV tools are installed and on `PATH`:

| Tool | Used for |
|------|----------|
| `iccFromXml` | Building `.icc` profiles from their XML definitions |
| `iccApplyProfiles` | Applying a profile sequence to a TIFF image (S1–S4) |
| `iccApplyNamedCmm` | Looking up named-colour (spot) tints through a profile sequence (S5–S7) |
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

---

## 3. Folder layout

```
HybridPrinterWithOverprintSimulation/
├── BuildAndTest.bat                  # Windows driver script
├── BuildAndTest.sh                   # POSIX driver script (same workflow)
├── CMYK-W_Overprint_Profile.xml      # Hybrid printer profile — white spot ink
├── CMYK-S_Overprint_Profile.xml      # Hybrid printer profile — silver spot ink (under)
├── CMYK-STop_Overprint_Profile.xml   # Hybrid printer profile — silver spot ink (on top)
├── MW-Mid_Overprint.xml              # MID channel-selection profile (white)
├── MS-Mid_Overprint.xml              # MID channel-selection profile (silver)
├── SC-Mid_Overprint.xml              # MID channel-selection profile (silver + CMYK)
├── ICS-HybridPrinterWithOverprintSimulation.pdf  # ICS document (normative reference)
├── README.md                         # This file
├── docs/
│   └── Scenarios.md                  # Per-scenario reference (S1 … S7)
├── Data/                             # Inputs: imagery, PCS XMLs, display target
│   ├── C-sRGB_v4_ICC_preference.icc  # ICC sRGB v4 preference (display proof target)
│   ├── HappyBunniesRGB.tif           # Source RGB image for S1
│   ├── TShirtDesignCMYKW.tif         # CMYK + spot design for the S3 previews
│   ├── TShirtDesignKW.tif            # K + spot design for the S4 selective previews
│   ├── Lab_int-D50_2deg.xml          # Colorimetric PCS @ D50, 2°
│   ├── Lab_int-D93_2deg-MAT.xml      # Colorimetric PCS @ D93, 2° (PCC override)
│   └── Spec380_10_730-D50_2deg.xml   # Spectral PCS (380…730 nm, 10 nm)
├── Spot-Overprint/                   # External data loaded by the calculatorElement
│   ├── Shaper-{Cyan,Magenta,Yellow,Black}.txt   # per-ink shaper curves
│   ├── CLUT-CMYK-{scale,offset}XYZ.txt          # 17^4 CMYK -> XYZ scale / offset CLUTs
│   ├── CLUT-CMYK-XYZ.txt                        # reference CMYK -> XYZ CLUT
│   └── Under{Silver,White}-{scale,offset}XYZ.txt # spot-ink tint arrays
├── config/                           # JSON drivers for each scenario
│   ├── hpwos-S1-PrintOutput.json
│   ├── hpwos-S2-PrintProof.json
│   ├── hpwos-S3-TShirtDesignPrev{UW,US,OS}-{W,R,G,B,K}.json   # 15 files
│   ├── hpwos-S4-TShirtDesignPrev{UW-G-M,US-G-M,US-W-CS}.json  # 3 files
│   ├── hpwos-S5-SpotTintSampleLab.json
│   ├── hpwos-S6-SpotTintSamplePccLab.json
│   └── hpwos-S7-SpotTintSampleRefOver{White,Black}.json       # 2 files
├── ICC/                              # Built profiles (created by script)
└── Results/                          # Generated images / colour lists (created by script)
```

`ICC/` and `Results/` are *populated* by the build script and are the
artifacts to inspect when verifying conformance. They are not source.

---

## 4. Scenarios

The ICS defines seven scenarios that progressively exercise the hybrid
overprint printer profile; they are summarised in **Annex A** of the ICS
document. A detailed, package-specific description is in
[docs/Scenarios.md](docs/Scenarios.md); a one-line summary:

| ID | Driver / Config | What it demonstrates |
|----|-----------------|----------------------|
| S1 | `iccApplyProfiles` / `hpwos-S1-PrintOutput.json` | sRGB → hybrid-CMYK rendering using the **base** (ICC) part only — the "printing" workflow |
| S2 | `iccApplyProfiles` / `hpwos-S2-PrintProof.json` | Base colorimetric proof of the CMYK output back to sRGB — the "base proof" workflow |
| S3 | `iccApplyProfiles` / `hpwos-S3-TShirtDesignPrev*.json` (15) | Overprint **simulation** of an extended (CMYK + spot) design over various backgrounds, using the `osim` v5 sub-profile and `bkgX/Y/Z` background overrides |
| S4 | `iccApplyProfiles` / `hpwos-S4-TShirtDesignPrev*.json` (3) | **Selective** overprint simulation: a MID (`osel`) profile selects/orders extended ink channels via an MCS connection into the hybrid profile |
| S5 | `iccApplyNamedCmm` / `hpwos-S5-SpotTintSampleLab.json` | Overprint tint query — look up colorimetric (Lab) values for tints of a named spot channel |
| S6 | `iccApplyNamedCmm` / `hpwos-S6-SpotTintSamplePccLab.json` | Same tint query, but with a **PCC override** (D93) applied to the spot colorimetry |
| S7 | `iccApplyNamedCmm` / `hpwos-S7-SpotTintSampleRefOver{White,Black}.json` | Overprint tint query returning **spectral reflectance**, over white and over black backing |

S3 sweeps three overprint configurations against five background colours:

* **UW** — under **w**hite (`P-CMYK-W`)
* **US** — under **s**ilver (`P-CMYK-S`)
* **OS** — **o**ver **s**ilver, silver on top (`P-CMYK-STop`)
* background suffix `W`/`R`/`G`/`B`/`K` selects the substrate colour passed in
  through the `bkgX`, `bkgY`, `bkgZ` CMM environment variables.

---

## 5. What the scripts produce

After a successful run, `ICC/` contains:

```
P-CMYK-W_Overprint_Profile.icc      # Hybrid printer profile — white spot
P-CMYK-S_Overprint_Profile.icc      # Hybrid printer profile — silver (under)
P-CMYK-STop_Overprint_Profile.icc   # Hybrid printer profile — silver (on top)
M-MW-Mid_Overprint.icc              # MID channel-selection profile (white)
M-MS-Mid_Overprint.icc              # MID channel-selection profile (silver)
M-SC-Mid_Overprint.icc              # MID channel-selection profile (silver + CMYK)
C-Lab_int-D50_2deg.icc              # Colorimetric PCS @ D50 (display proof target)
1-Lab_int-D93_2deg-MAT.icc          # Colorimetric PCS @ D93 (PCC override, S6)
S-Spec380_10_730-D50_2deg.icc       # Spectral PCS (380–730 nm, 10 nm step)
```

and `Results/` contains:

```
HappyBunniesCmyk.tif                # S1 — base CMYK rendering of the source image
HappyBunniesProofD50.tif            # S2 — base D50 colorimetric proof
TShirtDesignPrevUW-{W,R,G,B,K}.tif  # S3 — under-white overprint previews
TShirtDesignPrevUS-{W,R,G,B,K}.tif  # S3 — under-silver overprint previews
TShirtDesignPrevOS-{W,R,G,B,K}.tif  # S3 — silver-on-top overprint previews
TShirtDesignPrevUW-G-M.tif          # S4 — selective preview, white, MID-driven
TShirtDesignPrevUS-G-M.tif          # S4 — selective preview, silver, MID-driven
TShirtDesignPrevUS-W-CS.tif         # S4 — selective preview, silver+CMYK, MID-driven
SpotTintSampleLab.txt               # S5 — spot tint colorimetry (Lab, D50)
SpotTintSamplePccLab.txt            # S6 — spot tint colorimetry (Lab, D93 PCC override)
SpotTintSampleRefOverWhite.txt      # S7 — spot tint reflectance over white
SpotTintSampleRefOverBlack.txt      # S7 — spot tint reflectance over black
```

The script echoes the S1 and S4 destination TIFF headers (`iccTiffDump`) and
the S5–S7 spot-tint result files so the named-colour queries can be eyeballed
directly.

---

## 6. Naming conventions

Built profile filenames use a single-character prefix to indicate role:

* `P-` — the **P**rinter profile under test (hybrid: ICC base part + `osim`
  overprint-simulation v5 sub-profile).
* `M-` — a **M**ultiplexIdentification (`osel`) overprint channel-selection
  profile, connected to the printer profile through an MCS connection.
* `C-` — the **C**olorimetric PCS / display proof target.
* `1-` — a colorimetric PCS used as a **P**CC override. The leading digit is
  the PCC index.
* `S-` — the **S**pectral PCS.

Configuration filenames use the pattern `hpwos-S<n>-<purpose>.json`, where
`hpwos` denotes *Hybrid Printer With Overprint Simulation* and `<n>` is the
scenario number from the ICS document.

---

## 7. CMM environment variables

Overprint-simulation profiles are implemented with a `calculatorElement` that
reads CMM environment variables, allowing runtime customisation of the
transform (see Table 6 of the ICS document):

| Signature | Meaning |
|-----------|---------|
| `0ni?` | Flag: if > 0.5, spot channels are **not** inverted (Photoshop inverts spot channels in CMYK images). Absent / 0 means invert. |
| `bkgX`, `bkgY`, `bkgZ` | CIE X/Y/Z of the substrate (background) colour seen when all device channels are 0. Used by the S3/S4 previews to place the design on a coloured background. |

The S3 background-colour variants (`-W/-R/-G/-B/-K`) differ only in their
`bkgX/Y/Z` values; the S4 selective previews additionally set `0ni?`.

---

## 8. Path separators

All `config/*.json` driver files use POSIX-style forward slashes for paths
(e.g. `ICC/P-CMYK-S_Overprint_Profile.icc`). Both Windows and POSIX builds of
the iccDEV tools accept forward slashes, so the same configs work under either
driver script. Do not introduce backslashes into the JSON if the package is
intended to remain cross-platform.

---

## 9. Maintainer

Max Derhak (ICC) — questions, errata and pull requests welcome.

---

## 10. License

Copyright © 2024–2026 The International Color Consortium. All rights reserved.

The package's **software and data** — build scripts, JSON scenario configurations,
profile XML sources and sample data — are distributed under the **BSD 3-Clause "New" or
"Revised" License**, the licence of the parent
[iccDEV](https://github.com/InternationalColorConsortium/iccDEV) project (see its
`LICENSE.md`).

The **`ICS-*.pdf` document is a specification, not software.** It was prepared under the
ICC Intellectual Property Policy stated in its own Foreword, and its distribution is
governed by ICC's policy for specification documents rather than by the BSD licence above.
