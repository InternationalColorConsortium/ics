# ICS — Spectral Encoding

This folder is an **Interoperability Conformance Specification (ICS)** package
that exercises the use of *spectralEncoding* ICC profiles — iccMAX
(ISO 20677-1) profiles of sub-class `'sref'` whose transform connects device
channels directly to, or decodes them out of, a **spectral reflectance Profile
Connection Space (PCS)**, optionally with a Profile Connection Condition (PCC)
override.

The ICS covers two flavours of the encoding:

* **Full** spectral encoding — one device channel per spectral band (the device
  colour space and the spectral PCS have the same number of channels).
* **Abridged** multi-spectral encoding — a small number of device channels (here
  six) from which the full spectral reflectance is reconstructed by the
  profile's transform. This is a compact, "multi-spectral" representation.

> **iccMAX only.** Unlike the hybrid packages in this repository, this ICS works
> *only* with iccMAX (ISO 20677-1) profiles. There is no ISO 15076-1 (v4) base
> part; images encoded with these profiles will not work with applications that
> do not support iccMAX-based colour management.

> **Not to be confused with `HybridMultiSpectralEncoding`.** Both packages deal
> with multi-channel spectral data, but they specify fundamentally different
> profiles:
> * **`spectralEncoding`** (this package) uses a **pure iccMAX `'sref'`
>   profile** whose *primary* transform connects the device channels directly to
>   a spectral reflectance PCS. There is no colorimetric base part, so the
>   profile is meaningful only to iccMAX-aware colour management.
> * **`HybridMultiSpectralEncoding`** uses a **hybrid profile**: a conventional
>   colorimetric ICC base part (usable by legacy, non-iccMAX systems) paired with
>   an *embedded* iccMAX v5 spectral sub-profile (engaged via
>   `useV5SubProfile`). Its first device channels are colorimetric and the
>   remainder carry the additional spectral information, so the same file works
>   both in legacy ICC pipelines (base part) and in spectral iccMAX pipelines
>   (sub-profile).
>
> In short: `spectralEncoding` is iccMAX-only and spectral-first; the hybrid
> package is backward-compatible with legacy ICC systems through its colorimetric
> base part.

The package contains:

* **`ICS-SpectralEncoding.pdf`** — the ICS document. This is the normative
  reference for the package; everything else in the folder is example material
  that supports it.
* The XML sources of the two example profiles under test, in the package main
  folder: a full spectral encoding (`Spec380_10_730-D50_2deg.xml`) and an
  abridged six-channel encoding (`SixChanMsRef.xml`). The supporting
  colorimetric PCC-override profile XMLs live in `Data/`.
* JSON configuration files in `config/` that drive each of the ICS scenarios
  (S1 … S5, in full and abridged variants).
* Build / test scripts (`BuildAndTest.bat`, `BuildAndTest.sh`) that assemble the
  profiles and execute every scenario end-to-end.

It is intended to be run against the
[iccDEV](https://github.com/InternationalColorConsortium/DemoIccMAX) command
line tool suite.

---

## 1. Prerequisites

The scripts assume the following iccDEV tools are installed and on `PATH`:

| Tool | Used for |
|------|----------|
| `iccFromXml` | Building `.icc` profiles from their XML definitions |
| `iccApplyProfiles` | Applying a profile sequence to a TIFF image |
| `iccTiffDump` | Dumping TIFF header / channel metadata |

Both scripts assume these tools are already on `PATH`; they do not modify
`PATH` themselves. On Windows the iccDEV binaries are typically installed to a
location such as `C:\Program Files\RefIccMAX\bin` (add that directory to your
`PATH`); on macOS / Linux install them to `/usr/local/bin` or prepend your
iccDEV build output directory to `PATH` before running the script.

A POSIX shell (`bash`) is required for `BuildAndTest.sh`. On Windows the script
can be run under Git Bash, WSL, or any other bash-compatible shell.

---

## 2. Running the package

Both scripts must be run from this folder. They create the `ICC/` and
`Results/` directories on first run if they do not already exist.

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
SpectralEncoding/
├── BuildAndTest.bat                  # Windows driver script
├── BuildAndTest.sh                   # POSIX driver script (same workflow)
├── Spec380_10_730-D50_2deg.xml       # FULL spectral encoding profile under test (36→36, D50)
├── SixChanMsRef.xml                  # ABRIDGED multi-spectral encoding profile under test (6→36, D93)
├── ICS-SpectralEncoding.pdf          # ICS document (normative reference)
├── README.md                         # This file
├── docs/
│   └── Scenarios.md                  # Per-scenario reference (S1 … S5)
├── Data/                             # Supporting inputs: imagery, PCC XMLs, reference sRGB
│   ├── smCows380_5_780.tif           # 81-band spectral image (380–780 nm, 5 nm); embedded sref profile
│   ├── Lab_float-D93_2deg-MAT.xml    # colorimetric PCC override (D93 2°, MAT)
│   ├── Lab_float-IllumA_2deg-MAT.xml # colorimetric PCC override (Illuminant A 2°, MAT)
│   ├── Lab_float-D50_2deg.xml        # colorimetric PCS (D50 2°)
│   ├── Lab_float-F11_2deg-MAT.xml    # colorimetric PCC override (F11 2°, MAT)
│   ├── Lab_int-D65_2deg-MAT.xml      # colorimetric PCC override (D65 2°, MAT)
│   └── C-sRGB_v4_ICC_preference.icc  # sRGB v4 display preview target
├── config/                           # JSON drivers for each scenario
│   ├── se-S1a-refCowsToSrgbD50.json
│   ├── se-S1b-ms6ToSrgb.json
│   ├── se-S2a-refCowsToSrgbA.json
│   ├── se-S2b-refCowsToSrgbD65.json
│   ├── se-S2c-refCowsToSrgbD93.json
│   ├── se-S2d-refCowsToSrgbF11.json
│   ├── se-S3a-refCowsToSpec.json
│   ├── se-S3b-ms6ToSpec.json
│   ├── se-S4a-specToRefCows.json
│   ├── se-S4b-specToMs6.json
│   └── se-S5-previewCowsMsPcc.json
├── ICC/                              # Built profiles (created by script)
└── Results/                          # Generated images (created by script)
```

`ICC/` and `Results/` are *populated* by the build script and are the artifacts
to inspect when verifying conformance. They are not source.

---

## 4. Scenarios

The ICS defines five connection scenarios that exercise a spectralEncoding
profile (profile **R**) as a source, as a destination, and as a PCC override.
Each worked example maps to one of them; full-encoding examples carry the suffix
`a`, abridged examples the suffix `b`. A detailed description is in
[docs/Scenarios.md](docs/Scenarios.md); a one-line summary:

| ID | ICS scenario | Flavour | What it demonstrates |
|----|--------------|---------|----------------------|
| S1a | 1 (R → C) | full | spectral image previewed to sRGB under its native D50 conditions |
| S1b | 1 (R → C) | abridged | the 6-channel image decoded to sRGB under its native D93 conditions |
| S2a–d | 2 (R + PCC → C) | full | preview under Illuminant A / D65 / D93 / F11 via a colorimetric PCC override |
| S3a | 3 (R → S) | full | 81-band spectral image resampled into the 36-band spectral encoding |
| S3b | 3 (R → S) | abridged | full 36-band reflectance reconstructed from the 6 channels |
| S4a | 4 (S → R) | full | spectral source re-encoded through the full profile (round trip) |
| S4b | 4 (S → R) | abridged | 36-band spectral image **encoded** into the 6-channel multi-spectral image |
| S5 | 5 (R as PCC override) | abridged | the abridged profile supplies the D93 observing conditions + PCC to an unrelated render |

S4b *builds* the 6-channel image that S1b and S3b consume, so the build scripts
run the steps in dependency order (S3a → S4a → S4b → S1b → S3b → S5).

### Why the "metacow" image?

`Data/smCows380_5_780.tif` is a *metameric* test target: the **head and tail
halves of each cow have different spectral reflectances but are a metameric pair**
— they produce **identical colour under CIE Illuminant D65 with the 1931
standard 2° observer**. Under any other illuminant the metameric match breaks
down and the two halves take on visibly different colours.

This is what makes the previews meaningful. In the **D65** preview
(`Preview-cowsD65_fromRef.tif`) the heads and tails match; in the **A, D93 and
F11** previews they diverge. Because the spectral encoding carries the full
spectral information, the previews reproduce this illuminant-dependent
metamerism correctly — something a colorimetric encoding fixed to a single
illuminant cannot do.

The abridged scenarios show that the six-channel multi-spectral encoding
preserves enough spectral information to reproduce the same behaviour: compare
the abridged D93 preview (`Preview-cowsMs6.tif`, S1b) and the abridged-PCC
render (`Preview-cowsMsPcc.tif`, S5) against the full D93 preview
(`Preview-cowsD93_fromRef.tif`, S2c), and the reconstructed spectral image
(`Spec_ms6Cows.tif`, S3b) against the original (`Spec_smCows.tif`, S3a).

---

## 5. What the scripts produce

After a successful run, `ICC/` contains:

```
R-Spec380_10_730-D50_2deg.icc   # FULL spectral encoding under test (36→36, D50)
R-SixChanMsRef.icc              # ABRIDGED multi-spectral encoding under test (6→36, D93)
1-Lab_float-D93_2deg-MAT.icc    # colorimetric PCC overrides used by the S2 previews.
2-Lab_float-IllumA_2deg-MAT.icc # The leading digit is the role index referenced
3-Lab_float-D50_2deg.icc        # from the config files.
4-Lab_float-F11_2deg-MAT.icc
5-Lab_int-D65_2deg-MAT.icc
```

and `Results/` contains:

```
Preview-cowsD50_fromRef.tif   # S1a — full encoding previewed at native D50
Preview-cowsA_fromRef.tif     # S2a — full encoding under Illuminant A (PCC override)
Preview-cowsD65_fromRef.tif   # S2b — under D65
Preview-cowsD93_fromRef.tif   # S2c — under D93
Preview-cowsF11_fromRef.tif   # S2d — under F11
Spec_smCows.tif               # S3a — 81-band image resampled to 36-band spectral encoding
Ref_smCows.tif                # S4a — full-encoding round trip (36 channels)
MS6_smCows.tif                # S4b — abridged 6-channel multi-spectral image
Preview-cowsMs6.tif           # S1b — abridged image decoded to sRGB at native D93
Spec_ms6Cows.tif              # S3b — 36-band reflectance reconstructed from the 6 channels
Preview-cowsMsPcc.tif         # S5  — abridged profile used as a D93 PCC override
```

`iccTiffDump` is run after S3a, S4a, S4b and S3b so the channel counts and
embedded profiles of the encoded images can be inspected (36 channels for the
full spectral images, 6 channels for the abridged image).

---

## 6. Naming conventions

Built profile filenames use a single-character / single-digit prefix to
indicate role:

* `R-` — a spectralEncoding profile under test (profile **R** in the ICS): the
  full `R-Spec380_10_730-D50_2deg.icc` and the abridged `R-SixChanMsRef.icc`.
* `1-`…`5-` — colorimetric PCS profiles used as PCC overrides to evaluate the
  encoding under different illuminants (1 = D93, 2 = Illuminant A, 3 = D50,
  4 = F11, 5 = D65).

Configuration filenames use the pattern `se-S<n><a|b>-<purpose>.json`, where
`se` denotes *spectralEncoding*, `<n>` is the clause-5 scenario number, and the
`a`/`b` suffix distinguishes the full (`a`) and abridged (`b`) flavours.

---

## 7. Path separators

All `config/*.json` driver files use POSIX-style forward slashes for paths
(e.g. `ICC/R-SixChanMsRef.icc`). Both Windows and POSIX builds of the iccDEV
tools accept forward slashes, so the same configs work under either driver
script. Do not introduce backslashes into the JSON if the package is intended to
remain cross-platform.

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
