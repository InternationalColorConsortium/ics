# ICS — Hybrid Multi-Spectral Encoding

This folder is an **Interoperability Conformance Specification (ICS)**
package that exercises the use of *hybrid multi-spectral encoding* ICC profiles
(iccMAX / ICC.2 v5 profiles that pair a colorimetric ICC base part with a
spectral-reflectance v5 sub-profile, exposing a multi-channel encoding whose
first channels map directly to colorimetry and whose remaining channels carry
the additional multi-spectral information).

> **Not to be confused with `SpectralEncoding`.** Both packages deal with
> multi-channel spectral data, but they specify fundamentally different profiles:
> * **`HybridMultiSpectralEncoding`** (this package) uses a **hybrid profile**: a
>   conventional colorimetric ICC base part (usable by legacy, non-iccMAX
>   systems) paired with an *embedded* iccMAX v5 spectral sub-profile (engaged
>   via `useV5SubProfile`). The same file therefore works in both legacy ICC
>   pipelines (base part) and spectral iccMAX pipelines (sub-profile).
> * **`SpectralEncoding`** uses a **pure iccMAX `'sref'` profile** whose primary
>   transform connects device channels directly to a spectral reflectance PCS,
>   with no colorimetric base part (iccMAX-only). It covers both *full* spectral
>   encoding and *abridged* (multi-spectral) encoding.
>
> In short: this hybrid package is backward-compatible with legacy ICC systems
> through its colorimetric base part; `SpectralEncoding` is iccMAX-only and
> spectral-first.

The package contains:

* **`ICS-HybridMultiSpectralEncoding.pdf`** — the ICS document. This is the
  normative reference for the package; everything else in the folder is example
  material that supports it.
* A worked example profile (`MultiSpectralRGB.xml`) and supporting PCS /
  observer / spectral profiles (in `Data/`).
* JSON configuration files (in `config/`) that drive each of the ICS
  scenarios (S1 … S6).
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
| `iccApplyProfiles` | Applying a profile sequence to a TIFF image |
| `iccTiffDump` | Dumping TIFF header / channel metadata |

On Windows the iccDEV binaries are typically installed to a location such as
`C:\Program Files\RefIccMAX\bin`; add that directory to your `PATH`.
On macOS / Linux either install the iccDEV tools to `/usr/local/bin` or prepend
the build output directory to `PATH` before invoking the script. Neither driver
modifies `PATH` itself.

A POSIX shell (`bash`) is required for `BuildAndTest.sh`. On Windows the script
can be run under Git Bash, WSL, or any other bash-compatible shell.

---

## 2. Running the package

Both scripts must be run from this folder. They create the `ICC/`, `Results/`
and `config/` directories on first run if they do not already exist (the
`config/` JSON files are part of the package — the script only ensures the
directory exists).

### Windows

```bat
BuildAndTest.bat
```

### macOS / Linux / Git Bash

```sh
./BuildAndTest.sh
```

Both scripts execute the same sequence of steps and should produce identical
content in `ICC/` and `Results/`.

---

## 3. Folder layout

```
HybridMultiSpectralEncoding/
├── BuildAndTest.bat                       # Windows driver script
├── BuildAndTest.sh                        # POSIX driver script (same workflow)
├── MultiSpectralRGB.xml                   # XML source of the hybrid MS encoding profile
├── ICS-HybridMultiSpectralEncoding.pdf    # ICS document (normative reference)
├── README.md                              # This file
├── docs/
│   └── Scenarios.md                       # Per-scenario reference (S1 … S6)
├── Data/                                  # Inputs: imagery, observer XMLs, PCS XMLs
│   ├── C-sRGB_v4_ICC_preference.icc       # sRGB v4 display proof target
│   ├── HappyBunniesRGB.tif                # Source RGB image (S5/S6 legacy workflows)
│   ├── smCows380_5_780.tif                # 81-band spectral reflectance image (380–780 nm, 5 nm)
│   ├── Lab_float-D50_2deg.xml             # PCS @ D50, 2° (the ICC reference)
│   ├── Lab_float-D93_2deg-MAT.xml         # PCS @ D93, 2° (chromatic adaptation MAT)
│   ├── Lab_float-F11_2deg-MAT.xml         # PCS @ F11, 2°
│   ├── Lab_float-IllumA_2deg-MAT.xml      # PCS @ Illuminant A, 2°
│   ├── Lab_int-D65_2deg-MAT.xml           # PCS @ D65, 2°
│   └── Spec380_10_730-D50_2deg.xml        # Spectral PCS (380…730 nm, 10 nm → 36 bands)
├── config/                                # JSON drivers for each scenario
│   ├── hmse-S1-refCowsToMsCows.json
│   ├── hmse-S2-msCowsToRefCows.json
│   ├── hmse-S3-previewMSCowsD50.json
│   ├── hmse-S3-previewHalfMS.json
│   ├── hmse-S4-previewMSCowsA.json
│   ├── hmse-S4-previewMSCowsD65.json
│   ├── hmse-S4-previewMSCowsD93.json
│   ├── hmse-S4-previewMSCowsF11.json
│   ├── hmse-S5-previewRgbCowsD50.json
│   ├── hmse-S5-previewHalfMS.json
│   ├── hmse-S6-rgbToHalfMS.json
│   └── hmse-previewRefCows{D50,A,D65,D93,F11}.json   # comparison previews from the spectral image
├── ICC/                                   # Built profiles (created by script)
└── Results/                               # Generated images (created by script)
```

`ICC/` and `Results/` are *populated* by the build script and are the artifacts
to inspect when verifying conformance. They are not source.

---

## 4. Scenarios

The ICS defines six scenarios that progressively exercise the hybrid
multi-spectral encoding profile. Each scenario has one or more
`hmse-S*-*.json` configuration files. A detailed description is in
[docs/Scenarios.md](docs/Scenarios.md); a one-line summary:

| ID | Driver / Config | What it demonstrates |
|----|-----------------|----------------------|
| S1 | `iccApplyProfiles` / `hmse-S1-refCowsToMsCows.json` | **Encode** a spectral reflectance image into the multi-spectral encoding (spectral source → hybrid MS destination) |
| S2 | `iccApplyProfiles` / `hmse-S2-msCowsToRefCows.json` | **Decode** the multi-spectral encoding back to spectral reflectance (hybrid MS source → spectral destination) |
| S3 | `iccApplyProfiles` / `hmse-S3-previewMSCowsD50.json` | **Preview** the MS encoding as colorimetry under its native D50 viewing conditions |
| S4 | `iccApplyProfiles` / `hmse-S4-previewMSCows{A,D65,D93,F11}.json` | **Preview** under alternate observing conditions via a PCC override |
| S5 | `iccApplyProfiles` / `hmse-S5-previewRgbCowsD50.json` | **Legacy preview** using only the base ICC profile (iccMAX sub-profile ignored) |
| S6 | `iccApplyProfiles` / `hmse-S6-rgbToHalfMS.json` | **Legacy → partial MS**: an RGB image rendered into the base channels only, producing a "half" MS image (see the caution in the ICS) |

For comparison, `hmse-previewRefCows{D50,A,D65,D93,F11}.json` produce the same
colorimetric previews **directly from the 81-band spectral image**, so the
multi-spectral-encoding previews (S3/S4) can be compared against a spectral
ground truth.

### Why the "metacow" image?

`Data/smCows380_5_780.tif` is a *metameric* test target: the **head and tail
halves of each cow have different spectral reflectances but are a metameric
pair** — they produce **identical colour under CIE Illuminant D65 with the 1931
standard 2° observer**. Under any other illuminant the metameric match breaks
down and the two halves take on visibly different colours.

This is what makes the previews meaningful. In the **D65** previews
(`Preview-cowsD65_fromMS.tif`) the heads and tails match; in the **D50, A, D93
and F11** previews they diverge. Because the multi-spectral encoding carries the
full spectral information, S3/S4 reproduce this illuminant-dependent metamerism
correctly — something a colorimetric encoding fixed to a single illuminant
cannot do. The `_fromMS` previews should track their `_fromRef` counterparts
illuminant for illuminant.

The S5/S6 pair also illustrates the limitation called out in the ICS (and in
Annex A of the document): the `hmse-S5-previewHalfMS.json` preview of the half
MS image **works** (it only needs the base channels), whereas
`hmse-S3-previewHalfMS.json` is **expected to fail** — it aborts with

```
Number of samples 3 in image[Results/HappyBunniesHalfMS.tif] doesn't match device samples 8 in first profile
```

because the spectral sub-profile requires the eight multi-spectral channels
that the half MS image never received. This is the last step in both build
scripts; they label it as an expected failure and continue (and the POSIX
`BuildAndTest.sh` guards it so the script still exits 0).

---

## 5. What the scripts produce

After a successful run, `ICC/` contains:

```
P-MultiSpectralRGB.icc             # The hybrid MS encoding profile under test
1-Lab_float-D93_2deg-MAT.icc       # Colorimetric PCS / PCC overrides used by the
2-Lab_float-IllumA_2deg-MAT.icc    # S4 alternate-illuminant previews. The number is
3-Lab_float-D50_2deg.icc           # the role index referenced from the config files.
4-Lab_float-F11_2deg-MAT.icc
5-Lab_int-D65_2deg-MAT.icc
S-Spec380_10_730-D50_2deg.icc      # Spectral PCS (380–730 nm, 10 nm step → 36 bands)
```

and `Results/` contains (among the comparison previews):

```
MS_smCows.tif               # S1 — spectral image encoded into the MS encoding
Ref_smCows.tif              # S2 — MS encoding decoded back to spectral reflectance
Preview-cowsD50_fromMS.tif  # S3 — colorimetric preview (native D50)
Preview-cowsA_fromMS.tif    # S4 — preview under Illuminant A
Preview-cowsD65_fromMS.tif  # S4 — preview under D65
Preview-cowsD93_fromMS.tif  # S4 — preview under D93
Preview-cowsF11_fromMS.tif  # S4 — preview under F11
Preview-cows*_fromRef.tif   # comparison previews straight from the spectral image
Preview-RgbCows_fromMS.tif  # S5 — legacy base-only preview
HappyBunniesHalfMS.tif      # S6 — half MS image (base channels only)
Preview-HappyBunniesRgb.tif # half MS previewed via the base profile (works)
```

`iccTiffDump` is run after S1, S2 and S6 so the channel counts and embedded
profiles of the encoded images can be inspected.

---

## 6. Naming conventions

Built profile filenames use a single-character / single-digit prefix to
indicate role:

* `P-` — the **P**rofile under test (the hybrid multi-spectral encoding profile).
* `1-`…`5-` — colorimetric PCS profiles used as PCC overrides to evaluate the
  encoding under different illuminants (1 = D93, 2 = Illuminant A, 3 = D50,
  4 = F11, 5 = D65). The number is the PCC role index referenced from the
  config files.
* `S-` — the **S**pectral PCS profile.

Configuration filenames use the pattern `hmse-S<n>-<purpose>.json`, where
`hmse` denotes *Hybrid Multi-Spectral Encoding* and `<n>` is the scenario
number from the ICS document. The auxiliary comparison previews use
`hmse-previewRefCows<condition>.json` (no scenario number).

---

## 7. Path separators

All `config/*.json` driver files use POSIX-style forward slashes for paths
(e.g. `ICC/P-MultiSpectralRGB.icc`). Both Windows and POSIX builds of the
iccDEV tools accept forward slashes, so the same configs work under either
driver script. Do not introduce backslashes into the JSON if the package is
intended to remain cross-platform.

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
