# Scenario reference — Hybrid Printer With Overprint Simulation

This document is a companion to `ICS-HybridPrinterWithOverprintSimulation.pdf`
(the normative form of the ICS — its **Annex A** lists these same worked
examples in summary form) and to the top-level `README.md`. It explains, for
each scenario S1 … S7, exactly which iccDEV tool runs, what the driver JSON
expresses, and what the expected output is.

All paths below are written relative to the package root.

---

## Profiles that participate

| Symbolic name | Built file | Built from | Role |
|---------------|------------|------------|------|
| Hybrid printer — white | `ICC/P-CMYK-W_Overprint_Profile.icc` | `CMYK-W_Overprint_Profile.xml` | Printer profile under test. ICC CMYK base part + `osim` v5 sub-profile adding a **white** spot channel. |
| Hybrid printer — silver (under) | `ICC/P-CMYK-S_Overprint_Profile.icc` | `CMYK-S_Overprint_Profile.xml` | As above, with a **silver** spot channel printed under the CMYK. |
| Hybrid printer — silver (on top) | `ICC/P-CMYK-STop_Overprint_Profile.icc` | `CMYK-STop_Overprint_Profile.xml` | As above, with the **silver** spot channel printed on top of the CMYK. |
| MID — white | `ICC/M-MW-Mid_Overprint.icc` | `MW-Mid_Overprint.xml` | `osel` multiplexIdentification profile selecting/ordering the white-spot channel set for an MCS connection. |
| MID — silver | `ICC/M-MS-Mid_Overprint.icc` | `MS-Mid_Overprint.xml` | `osel` profile for the silver-spot channel set. |
| MID — silver + CMYK | `ICC/M-SC-Mid_Overprint.icc` | `SC-Mid_Overprint.xml` | `osel` profile selecting silver together with CMYK channels. |
| PCS @ D50 | `ICC/C-Lab_int-D50_2deg.icc` | `Data/Lab_int-D50_2deg.xml` | Colorimetric PCS for D50 2° — the display proof target / interim PCS. |
| PCS @ D93 | `ICC/1-Lab_int-D93_2deg-MAT.icc` | `Data/Lab_int-D93_2deg-MAT.xml` | Colorimetric PCS for D93 2° (MAT) used as a **PCC override** in S6. |
| Spectral PCS | `ICC/S-Spec380_10_730-D50_2deg.icc` | `Data/Spec380_10_730-D50_2deg.xml` | Spectral PCS, 380…730 nm at 10 nm — the reflectance target in S7. |
| sRGB v4 | `Data/C-sRGB_v4_ICC_preference.icc` | (prebuilt) | The ICC sRGB v4 preference profile (display proof target for S2–S4). |

`ICC/` is rebuilt every time `BuildAndTest.{bat,sh}` runs.

The three printer profiles correspond to the way the silver/white spot ink
relates to the CMYK: `W` adds a white channel, `S` prints silver *under* the
CMYK, and `STop` prints silver *on top*. The driver filenames mirror this with
the prefixes **UW** (under white), **US** (under silver) and **OS** (over
silver / silver on top).

---

## S1 — Print output (sRGB → hybrid CMYK, base part)

**Driver:** `iccApplyProfiles -cfg config/hpwos-S1-PrintOutput.json`

The source image `Data/HappyBunniesRGB.tif` carries an embedded sRGB profile
(`iccFile: null` + `intent: perceptual` in the first stage tells
`iccApplyProfiles` to use the embedded profile). It is rendered through the
**base (ICC) part** of the hybrid printer profile, producing a 16-bit CMYK
TIFF. The `osim` sub-profile is *not* engaged — this is exactly the behaviour
of a system that does not support iccMAX.

```
src   : Data/HappyBunniesRGB.tif       (embedded sRGB)
stage1: <embedded>                     perceptual
stage2: P-CMYK-S_Overprint_Profile.icc perceptual   (base part — useV5SubProfile absent)
dst   : Results/HappyBunniesCmyk.tif   (16-bit, compressed, ICC embedded)
```

The script follows S1 with `iccTiffDump Results/HappyBunniesCmyk.tif` so the
output channels and embedded profile can be inspected.

---

## S2 — Print proof (CMYK → sRGB, base part)

**Driver:** `iccApplyProfiles -cfg config/hpwos-S2-PrintProof.json`

Takes the CMYK output of S1 and proofs it back to sRGB through the embedded
base profile (absolute) and perceptual rendering to sRGB. This is the *base*
colorimetric proof — it does not consult the `osim` sub-profile.

```
src   : Results/HappyBunniesCmyk.tif       (embedded P-CMYK-S base profile)
stage1: <embedded>                         absolute
stage2: Data/C-sRGB_v4_ICC_preference.icc  perceptual
dst   : Results/HappyBunniesProofD50.tif   (8-bit)
```

---

## S3 — Overprint simulation previews

**Driver:** `iccApplyProfiles -cfg config/hpwos-S3-TShirtDesignPrev<cfg>.json`
(15 configurations)

This is the core overprint-simulation workflow. The extended (CMYK + spot)
design `Data/TShirtDesignCMYKW.tif` is rendered through the **`osim` v5
sub-profile** of the hybrid printer profile (`useV5SubProfile: true`) and then
to sRGB for display, simulating how the print will look on a given substrate.

Two axes are swept:

* **Overprint configuration** (which printer profile / spot relationship):
  | Suffix | Stage-1 profile | Spot relationship |
  |--------|-----------------|-------------------|
  | `UW`   | `P-CMYK-W_Overprint_Profile.icc` | under white |
  | `US`   | `P-CMYK-S_Overprint_Profile.icc` | under silver |
  | `OS`   | `P-CMYK-STop_Overprint_Profile.icc` | silver on top |
* **Background colour**, set through the `bkgX`/`bkgY`/`bkgZ` CMM environment
  variables (CIE XYZ of the substrate when all channels are 0):
  | Suffix | Background |
  |--------|------------|
  | `W` | white (no `bkg*` override) |
  | `R` | red    (X 0.264, Y 0.168, Z 0.033) |
  | `G` | green  (X 0.098, Y 0.159, Z 0.122) |
  | `B` | blue   (X 0.210, Y 0.182, Z 0.498) |
  | `K` | black  (X 0, Y 0, Z 0) |

```
src   : Data/TShirtDesignCMYKW.tif         (extended CMYK + spot)
stage1: <UW|US|OS profile>     relative   useV5SubProfile=true   bkgX/Y/Z = substrate
stage2: Data/C-sRGB_v4_ICC_preference.icc  relative
dst   : Results/TShirtDesignPrev<cfg>.tif  (8-bit, no embedded ICC)
```

Together the 15 outputs show the same design under every combination of spot
configuration and substrate colour.

---

## S4 — Selective overprint simulation (MID / MCS)

**Driver:** `iccApplyProfiles -cfg config/hpwos-S4-TShirtDesignPrev<cfg>.json`
(3 configurations)

Adds a **multiplexIdentification (`osel`) profile** in front of the hybrid
profile. The MID profile selects and orders the extended ink channels and
passes them to the hybrid profile over an **MCS connection** (`transform:
MCS`). This allows print-ready data with a different channel ordering to be fed
into the overprint simulation. The `0ni?` environment variable (= 1.0) tells
the CMM not to invert the spot channels.

| Config | MID profile | Hybrid profile | Background |
|--------|-------------|----------------|------------|
| `UW-G-M`  | `M-MW-Mid_Overprint.icc` | `P-CMYK-W_Overprint_Profile.icc`    | green |
| `US-G-M`  | `M-MS-Mid_Overprint.icc` | `P-CMYK-S_Overprint_Profile.icc`    | green |
| `US-W-CS` | `M-SC-Mid_Overprint.icc` | `P-CMYK-STop_Overprint_Profile.icc` | white |

```
src   : Data/TShirtDesignKW.tif            (K + spot)
stage1: <MID profile>          perceptual  MCS          (channel selection)
stage2: <hybrid profile>       perceptual  MCS  useV5SubProfile=true  0ni?=1  [bkg*]
stage3: Data/C-sRGB_v4_ICC_preference.icc  relative
dst   : Results/TShirtDesignPrev<cfg>.tif  (8-bit)
```

---

## S5 — Spot tint colorimetry (Lab)

**Driver:** `iccApplyNamedCmm -cfg config/hpwos-S5-SpotTintSampleLab.json > Results/SpotTintSampleLab.txt`

A named-colour (spot) tint query. The `osim` sub-profile's `namedColorTag`
holds spectral reflectance for tints of the `Silver` channel; `transform:
namedSpectral` looks that reflectance up (at 100 % and 0 %) and the D50 PCS
profile integrates it to Lab under its viewing conditions.

```
colorData : Silver @ 1.0, Silver @ 0.0           (srcSpace nmcl, percent)
stage1    : P-CMYK-S_Overprint_Profile.icc  absolute  namedSpectral  useV5SubProfile=true
stage2    : C-Lab_int-D50_2deg.icc          absolute
output    : Lab values → Results/SpotTintSampleLab.txt
```

---

## S6 — Spot tint colorimetry with PCC override (D93)

**Driver:** `iccApplyNamedCmm -cfg config/hpwos-S6-SpotTintSamplePccLab.json > Results/SpotTintSamplePccLab.txt`

Identical to S5 except the spot colorimetry is evaluated under a **PCC
override**: `pccFile: ICC/1-Lab_int-D93_2deg-MAT.icc` re-evaluates the named
colour under D93 (2°, MAT), and the same D93 profile is used as the destination
PCS. This demonstrates that the spot colorimetry tracks the connection
condition.

```
colorData : Silver @ 1.0, Silver @ 0.0           (srcSpace nmcl, percent)
stage1    : P-CMYK-S_Overprint_Profile.icc  absolute  namedSpectral  useV5SubProfile=true
            pccFile = 1-Lab_int-D93_2deg-MAT.icc
stage2    : 1-Lab_int-D93_2deg-MAT.icc      absolute
output    : Lab values → Results/SpotTintSamplePccLab.txt
```

---

## S7 — Spot tint reflectance (over white / over black)

**Driver:**
`iccApplyNamedCmm -cfg config/hpwos-S7-SpotTintSampleRefOverWhite.json > Results/SpotTintSampleRefOverWhite.txt`
and
`iccApplyNamedCmm -cfg config/hpwos-S7-SpotTintSampleRefOverBlack.json > Results/SpotTintSampleRefOverBlack.txt`

The same named-colour query, but returning **spectral reflectance** from the
`osim` sub-profile into the spectral PCS. The main purpose of this scenario is
**spot ink formulation**: the measured spectral reflectance of each spot tint
lets an ink be formulated so a press can reproduce the spot colour *spectrally*
correctly — not merely colorimetrically under a single illuminant. The two
configs differ only in the backing:

* `…OverWhite` uses `transform: namedSpectral` — reflectance measured over a white
  backing.
* `…OverBlack` uses `transform: namedSpectralOnBlack` — reflectance measured over a
  black backing.

```
colorData : Silver @ 1.0, Silver @ 0.0           (srcSpace nmcl, percent)
stage1    : P-CMYK-S_Overprint_Profile.icc  absolute  namedSpectral | namedSpectralOnBlack  useV5SubProfile=true
stage2    : S-Spec380_10_730-D50_2deg.icc   absolute
output    : 36-band reflectance (380–730 nm) → Results/SpotTintSampleRefOver{White,Black}.txt
```

---

## Mapping to the ICS document

The seven scenarios here correspond directly to the connection scenarios in
Section 5 (and the worked-example summary in Annex A) of
`ICS-HybridPrinterWithOverprintSimulation.pdf`:

| Here | ICS scenario | Use of `osim` sub-profile |
|------|--------------|---------------------------|
| S1 | Scenario 1 — source → hybrid as destination, colorimetric | No (base part) |
| S2 | Scenario 2 — hybrid as source → colorimetric destination | No (base part) |
| S3 | Scenario 3 — extended colour space, hybrid as source | Yes |
| S4 | Scenario 4 — selective (MCS / MID) overprint | Yes (MCS connection) |
| S5 | Scenario 5 — named-colour tint query, colorimetric | Yes |
| S6 | Scenario 6 — named-colour tint query, PCC override | Yes |
| S7 | Scenario 7 — named-colour tint query, spectral output (spot ink formulation) | Yes |

---

## Sanity check after a run

A quick way to confirm the package ran end-to-end:

```sh
ls ICC/        # 9 .icc files: 3 P-, 3 M-, C-, 1-, S-
ls Results/    # 20 .tif files (S1, S2, 15× S3, 3× S4) + 4 .txt spot-tint files
```

The S1/S4 `iccTiffDump` output and the four `Results/SpotTintSample*.txt`
files are echoed by the build script for direct inspection.
