# ICS — Colorimetric Encoding

This folder is a **Interoperability Conformance Specification (ICS)**
package that exercises the use of *colorimetricEncoding* ICC profiles
(profiles conforming to ISO 20677-1 whose transform encodes device values
directly into, or decodes them out of, a colorimetric Profile Connection
Space — optionally with a Profile Connection Condition (PCC) override).

The package contains:

* **`ICS-ColorimetricEncoding.pdf`** — the ICS document. This is the
  normative reference for the package; everything else in the folder is
  example material that supports it.
* A set of profile XML sources in `Illuminants/` covering several
  combinations of L\*a\*b\* / XYZ, integer / floating-point, and standard
  illuminants (D50, D65, D93, Illuminant A) at the 2° observer, plus
  variants for chromatic-adaptation (MAT), absolute (Abs) and Level 2.
* A library of custom-observer source XMLs in `CustomObservers/`
  (Asano's ten *Categorical* observers and the CIE 2015 2° observer)
  for experimentation beyond the strict ICS scenario set. The build
  scripts compile these into encoding profiles as well, but no scenario
  in this package consumes them.
* Input imagery and the reference sRGB profile in `Data/`.
* JSON configuration files in `config/` that drive each of the ICS
  scenarios (S1a … S5c).
* Build / test scripts (`BuildAndTest.bat`, `BuildAndTest.sh`) that
  assemble the profiles and execute every scenario end-to-end.

It is intended to be run against the [iccDEV](https://github.com/InternationalColorConsortium/DemoIccMAX)
command-line tool suite.

---

## 1. Prerequisites

The scripts assume the following iccDEV tools are installed and on `PATH`:

| Tool | Used for |
|------|----------|
| `iccFromXml` | Building `.icc` profiles from their XML definitions |
| `iccApplyProfiles` | Applying a profile sequence to a TIFF image (scenarios S1–S5) |
| `iccApplyNamedCmm` | Applying a profile sequence to a colour list (scenarios S6, S7) |
| `iccTiffDump` | Dumping TIFF header / channel metadata |

On Windows the iccDEV binaries are typically installed to a location such
as `C:\Program Files\RefIccMAX\bin`; add that directory to your `PATH`.
On macOS / Linux either install the iccDEV tools to `/usr/local/bin` or
prepend the build output directory to `PATH` before invoking the script.

A POSIX shell (`bash`) is required for `BuildAndTest.sh`. On Windows the
script can be run under Git Bash, WSL, or any other bash-compatible
shell.

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
ColorimetricEncoding/
├── BuildAndTest.bat                  # Windows driver script
├── BuildAndTest.sh                   # POSIX driver script (same workflow)
├── ICS-ColorimetricEncoding.pdf      # ICS document (normative reference)
├── README.md                         # This file
├── docs/
│   └── Scenarios.md                  # Per-scenario reference (S1a … S5c)
├── Illuminants/                      # XML sources for profile E (and profile P)
│   ├── Lab_float-D50_2deg.xml        #   floating-point Lab @ D50, 2°
│   ├── Lab_float-D93_2deg-MAT.xml    #   floating-point Lab @ D93, 2° (MAT)
│   ├── Lab_int-D50_2deg.xml          #   integer Lab @ D50, 2°
│   ├── Lab_int-D65_2deg-MAT.xml      #   integer Lab @ D65, 2° (MAT)
│   ├── Lab_int-D93_2deg-MAT.xml      #   integer Lab @ D93, 2° (MAT)
│   ├── Lab_int-IllumA_2deg-MAT.xml   #   integer Lab @ Illuminant A, 2° (MAT)
│   ├── Lab_int-IllumA_2deg-Abs.xml   #   integer Lab @ Illuminant A, 2° (Abs)
│   ├── XYZ_float-D50_2deg.xml        #   floating-point XYZ @ D50, 2°
│   ├── XYZ_float-D65_2deg-MAT.xml    #   floating-point XYZ @ D65, 2° (MAT)
│   ├── XYZ_int-D50_2deg.xml          #   integer XYZ @ D50, 2°
│   ├── XYZ_int-D65_2deg-MAT.xml      #   integer XYZ @ D65, 2° (MAT)
│   └── XYZ_int-D65_2deg-MAT-Lvl2.xml #   Level-2 integer XYZ @ D65, 2° (MAT)
├── CustomObservers/                  # Asano Categorical and CIE 2015 observer XMLs
│   ├── LabCat1-D50_2deg.xml  …  LabCat10-D65_2deg.xml
│   └── Lab2015-D50_2deg.xml  /  Lab2015-D65_2deg.xml
├── Data/                             # Inputs: imagery, reference sRGB, spectral data
│   ├── 1-HappyBunniesRGB.tif         #   Source RGB image used by S1, S2, S5a
│   ├── 1-sRGB_v4_ICC_preference.icc  #   sRGB v4 (used by S5b/S5c)
│   ├── 2-HappyBunniesMSRGB.tif       #   Multispectral-RGB image used by S5c
│   ├── C-sRGB_v4_ICC_preference.icc  #   sRGB v4 (used by S3a/S3b/S3c/S4)
│   ├── Spec380_10_730-D50_2deg.xml   #   Spectral PCS XML built into ICC/S-*.icc (used by S6)
│   └── chartRef.txt                  #   24-patch / 36-wavelength reflectance chart (S6 input)
├── config/                           # JSON drivers for each scenario
│   ├── ce-S1a-IccToColorEncodingD93.json
│   ├── ce-S1b-IccToColorEncodingA.json
│   ├── ce-S2-IccToColorEncodingAWithPcc.json
│   ├── ce-S3a-ColorEncodingD93ToIcc.json
│   ├── ce-S3b-ColorEncodingAToIcc.json
│   ├── ce-S3c-ColorEncodingAPccToIcc.json
│   ├── ce-S4-ColorEncodingAWithPccToIcc.json
│   ├── ce-S5a-IccToIccWithPcc.json
│   ├── ce-S5b-ColorIccWithPccToIcc.json
│   ├── ce-S5c-SpectralIccWithPccToIcc.json
│   ├── ce-S6a-RefToXYZA.json         #   Spectral chart → XYZ encoding (Illuminant A)
│   ├── ce-S6b-RefToXYZD50.json       #   Spectral chart → XYZ encoding (D50)
│   ├── ce-S6c-RefToXYZD93.json       #   Spectral chart → XYZ encoding (D93)
│   ├── ce-S6d-RefToLabD50.json       #   Spectral chart → Lab encoding (D50)
│   ├── ce-S6e-RefToLab2015.json      #   Spectral chart → Lab encoding (D50, CIE 2015 obs.)
│   ├── ce-S6f-RefToLabCat8.json      #   Spectral chart → Lab encoding (D50, Cat8 obs.)
│   ├── ce-S7a-XYZToLabA.json         #   E-XYZ (D93) → E-Lab (IllumA)
│   ├── ce-S7b-XYZToLabD93.json       #   E-XYZ (D93) → E-Lab (D93, float)
│   ├── ce-S7c-LabD50ToLabA.json      #   E-Lab (D50) → E-Lab (IllumA)
│   ├── ce-S7d-LabD50ToLabD93.json    #   E-Lab (D50) → E-Lab (D93, float)
│   ├── ce-S7e-LabD50ToLab2015.json   #   E-Lab (D50, std obs) → E-Lab (D50, CIE 2015)
│   └── ce-S7f-LabD50ToLabCat8.json   #   E-Lab (D50, std obs) → E-Lab (D50, Cat8)
├── ICC/                              # Built profiles (created by script)
└── Results/                          # Generated images (created by script)
```

`ICC/` and `Results/` are *populated* by the build script and are the
artifacts to inspect when verifying conformance. They are not source.

The `CustomObservers/` XML sources are compiled into `ICC/E-Cat*Lab-*.icc`
and `ICC/E-Lab2015-*.icc` profiles by the build scripts so they are
available for ad-hoc testing, but none of the S1a … S5c scenarios in
this package consume them. They are intended as additional source
material implementers can use to construct further `colorimetricEncoding`
profiles (typically as profile P, the PCC override) under
non-standard observers.

---

## 4. Scenarios

The ICS defines seven scenarios that progressively exercise the use of
a colorimetricEncoding profile (profile **E**) as a source, as a
destination, and as a PCC override, plus colour-list workflows that
convert reflectance spectra into the encoding and convert between
different encodings. The configuration files in `config/` follow a
data-flow naming pattern (`IccToColorEncoding`, `ColorEncodingToIcc`,
`RefTo*`, `XYZToLab*`, etc.) and group several variants per scenario.
A detailed description of each variant is in
[docs/Scenarios.md](docs/Scenarios.md); the one-line summary:

| Config ID | What it demonstrates | Profile E role | ICS doc |
|-----------|----------------------|----------------|---------|
| S1a | sRGB → Lab encoded under D93 (MAT) | destination | Scenario 1 |
| S1b | sRGB → Lab encoded under Illuminant A (MAT) | destination | Scenario 1 |
| S2  | sRGB → Lab encoded under Illuminant A, with absolute PCC override | destination + PCC | Scenario 2 |
| S3a | Lab(D93) encoded image → sRGB | source | Scenario 3 |
| S3b | Lab(A) encoded image → sRGB | source | Scenario 3 |
| S3c | Lab(A) encoded image with PCC override → sRGB | source | Scenario 3 |
| S4  | Lab(A) encoded image → sRGB, with PCC override on the source | source + PCC | Scenario 4 |
| S5a | sRGB → Lab encoded under A using profile E only as PCC override | PCC override | Scenario 5 |
| S5b | Round-trip of S5a back through sRGB, again with E as PCC override | PCC override | Scenario 5 |
| S5c | Multispectral-RGB image → sRGB with E supplying the PCC override | PCC override | Scenario 5 |
| S6a | `chartRef.txt` spectral reflectance → E-XYZ encoded under Illuminant A | destination | Scenario 6 |
| S6b | `chartRef.txt` → E-XYZ encoded under D50 | destination | Scenario 6 |
| S6c | `chartRef.txt` → E-XYZ encoded under D93 | destination | Scenario 6 |
| S6d | `chartRef.txt` → E-Lab encoded under D50 | destination | Scenario 6 |
| S6e | `chartRef.txt` → E-Lab encoded under D50 with the CIE 2015 2° observer | destination | Scenario 6 |
| S6f | `chartRef.txt` → E-Lab encoded under D50 with the Asano Cat8 observer | destination | Scenario 6 |
| S7a | E-XYZ(D93) (S6c output) → E-Lab encoded under Illuminant A | source + destination | Scenario 7 |
| S7b | E-XYZ(D93) → E-Lab encoded under D93 | source + destination | Scenario 7 |
| S7c | E-Lab(D50) (S6d output) → E-Lab encoded under Illuminant A | source + destination | Scenario 7 |
| S7d | E-Lab(D50) → E-Lab encoded under D93 | source + destination | Scenario 7 |
| S7e | E-Lab(D50, std obs) → E-Lab encoded under D50 with the CIE 2015 observer | source + destination | Scenario 7 |
| S7f | E-Lab(D50, std obs) → E-Lab encoded under D50 with the Asano Cat8 observer | source + destination | Scenario 7 |

S1/S2 form the *encoding* half of the round trip; S3/S4 form the
*decoding* half. S5 demonstrates the third use of a
colorimetricEncoding profile — supplying its `spectralViewingConditionsTag`
/ `customToStandardPccTag` / `standardToCustomPccTag` as a PCC override
for an unrelated profile. S6 and S7 are colour-list workflows
exercised by `iccApplyNamedCmm`: S6 converts a 36-wavelength reflectance
chart into a colorimetric encoding under various illuminants and
observers, and S7 chains S6 outputs through a second
colorimetricEncoding profile to demonstrate encoding-to-encoding
conversion (with observer / illuminant changes).

> **Note on scenario numbering.** The seven abstract scenarios in the
> ICS document (Scenario 1 … Scenario 7) are numbered in the same order
> as the configuration filenames: encode (S1, S2), then decode (S3, S4),
> then PCC-only use (S5), then spectral-to-encoding (S6), then
> encoding-to-encoding (S7). See [docs/Scenarios.md](docs/Scenarios.md)
> for the full cross-reference.

---

## 5. What the scripts produce

After a successful run, `ICC/` contains the built profiles. The
sixteen scenario profiles (consumed by S1a … S7f) are:

```
E-Lab_float-D50_2deg.icc            # floating-point Lab @ D50, 2°
E-Lab_float-D93_2deg-MAT.icc        # floating-point Lab @ D93, 2° (MAT)
E-Lab_int-D50_2deg.icc              # integer Lab @ D50, 2°
E-Lab_int-D65_2deg-MAT.icc          # integer Lab @ D65, 2° (MAT)
E-Lab_int-D93_2deg-MAT.icc          # integer Lab @ D93, 2° (MAT)
E-Lab_int-IllumA_2deg-MAT.icc       # integer Lab @ Illuminant A, 2° (MAT)
E-Lab_int-IllumA_2deg-Abs.icc       # integer Lab @ Illuminant A, 2° (Abs)
P-Lab_int-IllumA_2deg-Abs.icc       # same content, role = PCC override
E-XYZ_float-D50_2deg.icc            # floating-point XYZ @ D50, 2°
E-XYZ_float-D65_2deg-MAT.icc        # floating-point XYZ @ D65, 2° (MAT)
E-XYZ_int-D50_2deg.icc              # integer XYZ @ D50, 2°
E-XYZ_int-D65_2deg-MAT.icc          # integer XYZ @ D65, 2° (MAT)
E-XYZ_int-D65_2deg-MAT-Lvl2.icc     # Level-2 integer XYZ @ D65, 2° (MAT)
E-XYZ_int-D93_2deg-MAT.icc          # integer XYZ @ D93, 2° (MAT) — used by S6c, S7a, S7b
E-XYZ_int-IllumA_2deg-MAT.icc       # integer XYZ @ Illuminant A, 2° (MAT) — used by S6a
S-Spec380_10_730-D50_2deg.icc       # spectral PCS, 380–730 nm @ 10 nm (S6 source)
```

Followed by twenty-two additional encoding profiles built from
`CustomObservers/`:

```
E-LabCat1-D50_2deg.icc … E-LabCat10-D65_2deg.icc   # Asano Categorical (10 × D50/D65)
E-Lab2015-D50_2deg.icc, E-Lab2015-D65_2deg.icc     # CIE 2015 2° observer
```

Two of these custom-observer profiles are also used by the scenario
runs: `E-Lab2015-D50_2deg.icc` (S6e and S7e) and `E-LabCat8-D50_2deg.icc`
(S6f and S7f). The other twenty are built to verify that `iccFromXml`
accepts the sources and to give implementers a head start on testing
under non-standard observers.

and `Results/` contains the per-scenario output images and colour
lists:

```
E-HappyBunnies-S1a.tif         # S1a — Lab(D93) encoding of the source image
E-HappyBunnies-S1b.tif         # S1b — Lab(A)   encoding of the source image
E-HappyBunnies-S2.tif          # S2  — Lab(A)   encoding with PCC override
HappyBunnies-S3a.tif           # S3a — S1a decoded back to sRGB
HappyBunnies-S3b.tif           # S3b — S1b decoded back to sRGB
HappyBunnies-S3c.tif           # S3c — S2  decoded back to sRGB
HappyBunnies-S4.tif            # S4  — S2  decoded back to sRGB with PCC override
2-HappyBunniesS5a.tif          # S5a — sRGB rendered using E as PCC override only
1-HappyBunnies-S5b.tif         # S5b — S5a back through sRGB with E as PCC override
1-HappyBunnies-S5c.tif         # S5c — Multispectral-RGB → sRGB with E as PCC override
chartRef-S6a-XYZA.txt          # S6a — chart spectra encoded as XYZ under Illuminant A
chartRef-S6b-XYZD50.txt        # S6b — chart spectra encoded as XYZ under D50
chartRef-S6c-XYZD93.txt        # S6c — chart spectra encoded as XYZ under D93 (S7 input)
chartRef-S6d-LabD50.txt        # S6d — chart spectra encoded as Lab under D50 (S7 input)
chartRef-S6e-Lab2015.txt       # S6e — Lab under D50, CIE 2015 observer
chartRef-S6f-LabCat8.txt       # S6f — Lab under D50, Cat8 observer
S7a-XYZ-to-LabA.txt            # S7a — S6c XYZ(D93) re-encoded as Lab under IllumA
S7b-XYZ-to-LabD93.txt          # S7b — S6c XYZ(D93) re-encoded as Lab under D93
S7c-LabD50-to-LabA.txt         # S7c — S6d Lab(D50) re-encoded under IllumA
S7d-LabD50-to-LabD93.txt       # S7d — S6d Lab(D50) re-encoded under D93
S7e-LabD50-to-Lab2015.txt      # S7e — S6d Lab(D50) re-encoded under CIE 2015 observer
S7f-LabD50-to-LabCat8.txt      # S7f — S6d Lab(D50) re-encoded under Cat8 observer
```

The build scripts run `iccTiffDump` against the encoded outputs of S1a,
S1b, S2 and S5a so the channel layout and embedded profile of those
representative outputs can be inspected. The S6 and S7 outputs are
plain `iccDEV` legacy colour-list text files — open them directly to
inspect the per-patch values.

A few things to watch for in those outputs (see
[docs/Scenarios.md](docs/Scenarios.md) → *Notes on the S6 / S7 results*
for the longer version):

* Reflectance → XYZ produces a different value for the perfect
  reflecting diffuser under each illuminant (S6a / S6b / S6c).
* Reflectance → Lab gives `L\*=100, a\*=b\*=0` for the PRD under every
  observer / illuminant; the difference between observers shows up
  only on chromatic patches.
* Computing colorimetry directly from reflectance (S7a / S7b path,
  via the XYZ-encoding profile's chromatic adaptation) is not
  numerically identical to cross-converting one colorimetric encoding
  to another (S7c / S7d, via the destination profile's PCC tags).

---

## 6. Naming conventions

Built profile filenames use a single-character prefix to indicate role:

* `E-` — the colorimetric **E**ncoding profile (profile E in the ICS).
  Used as a source or destination profile in scenarios S1 … S4, S6, S7.
* `P-` — the same content, named to indicate that the profile is being
  used as the **P**CC override (the `pccFile` slot of an
  `iccApplyProfiles` driver). Used in scenarios S2, S4, S5.
* `S-` — a **S**pectral PCS profile, used as the source stage in
  scenario S6.

Encoded image filenames in `Results/` use a leading `E-` to indicate
that the embedded profile is a colorimetricEncoding profile rather than
a conventional display / capture / output profile.

Configuration filenames use the pattern `ce-S<n>{a..f}-<dataflow>.json`,
where `ce` denotes *colorimetricEncoding*, `<n>` is the scenario group,
and `<dataflow>` is a short hint at what the configuration converts.

---

## 7. Path separators

The `config/*.json` driver files use POSIX-style forward slashes for
paths (e.g. `ICC/E-Lab_int-IllumA_2deg-MAT.icc`). Both Windows and POSIX
builds of the iccDEV tools accept forward slashes, so the same configs
work under either driver script. Do not introduce backslashes into the
JSON if the package is intended to remain cross-platform.

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
