# Scenario reference — Spectral Encoding

This document is a companion to `ICS-SpectralEncoding.pdf` (the normative form
of the ICS) and to the top-level `README.md`. It explains, for each worked
example, exactly which iccDEV tool runs, what the driver JSON expresses, and
what the expected output is.

All paths below are written relative to the package root.

---

## The spectralEncoding profile (profile R)

A **spectralEncoding** profile is an iccMAX (ISO 20677-1) profile of sub-class
`'sref'` whose transform connects device channels (the `Data colour space`,
`ncXXXX` / `NCLR`) to a **spectral reflectance Profile Connection Space**
(`rsXXXX`). It carries the PCC tags (`svcn`, and — when the observing
conditions are not D50 / 2° — `c2sp` and `s2cp`), so it can be used as a source
profile, a destination profile, or as a PCC override.

This ICS covers two flavours of the encoding, both exercised here:

| Flavour | Example profile | Device → spectral PCS | Notes |
|---------|-----------------|-----------------------|-------|
| **Full** spectral encoding | `ICC/R-Spec380_10_730-D50_2deg.icc` | `nc0024` (36) → `rs0024` (36) | one device channel per spectral band (identity); D50 2° observing conditions |
| **Abridged** multi-spectral encoding | `ICC/R-SixChanMsRef.icc` | `6CLR` (6) → `rs0024` (36) | six device channels reconstruct the 36-band reflectance via matrix `D2B3`; encodes via `B2D3`; D93 2° observing conditions |

The abridged profile is a compact ("multi-spectral") representation: only six
channels are stored, yet the full 36-band spectral reflectance can be
reconstructed and rendered under any illuminant/observer.

---

## Profiles and data that participate

| Symbolic name | Built / source file | Built from | Role |
|---------------|---------------------|------------|------|
| Full encoding (R) | `ICC/R-Spec380_10_730-D50_2deg.icc` | `Spec380_10_730-D50_2deg.xml` | full spectral encoding, 380–730 nm @ 10 nm, D50 |
| Abridged encoding (R) | `ICC/R-SixChanMsRef.icc` | `SixChanMsRef.xml` | abridged multi-spectral encoding, 6 → 36 bands, D93 |
| PCS @ D93 | `ICC/1-Lab_float-D93_2deg-MAT.icc` | `Data/Lab_float-D93_2deg-MAT.xml` | colorimetric PCC override (D93 2°, MAT) |
| PCS @ A | `ICC/2-Lab_float-IllumA_2deg-MAT.icc` | `Data/Lab_float-IllumA_2deg-MAT.xml` | colorimetric PCC override (Illuminant A 2°, MAT) |
| PCS @ D50 | `ICC/3-Lab_float-D50_2deg.icc` | `Data/Lab_float-D50_2deg.xml` | colorimetric PCS (D50 2°, ICC reference) |
| PCS @ F11 | `ICC/4-Lab_float-F11_2deg-MAT.icc` | `Data/Lab_float-F11_2deg-MAT.xml` | colorimetric PCC override (F11 2°, MAT) |
| PCS @ D65 | `ICC/5-Lab_int-D65_2deg-MAT.icc` | `Data/Lab_int-D65_2deg-MAT.xml` | colorimetric PCC override (D65 2°, MAT) |
| sRGB v4 | `Data/C-sRGB_v4_ICC_preference.icc` | (prebuilt) | ICC sRGB v4 preference profile, the display preview target |

The input imagery is `Data/smCows380_5_780.tif`, an **81-band spectral
reflectance image** (380…780 nm at 5 nm) with an embedded `sref` profile —
i.e. the image itself is an instance of a full spectralEncoding profile used as
a source.

`smCows380_5_780.tif` is a **"metacow" metamerism target**: the head and tail
halves of each cow have *different* spectral reflectances that nonetheless form
a **metameric pair under CIE Illuminant D65 with the 1931 standard 2° observer**
— under D65 the two halves produce the same colour, but under any other
illuminant the match breaks and they take on visibly different colours. This is
what makes the preview scenarios meaningful, and the reason a *spectral* (rather
than a single-illuminant colorimetric) encoding is needed.

`ICC/` and `Results/` are rebuilt every time `BuildAndTest.{bat,sh}` runs.

---

## Mapping of worked examples to ICS scenarios

The ICS document (clause 5.2.3) defines five abstract connection scenarios.
Each worked example below maps to one of them; full-encoding examples use the
suffix `a`, abridged examples use the suffix `b`.

| ID | ICS scenario | Flavour | Config |
|----|--------------|---------|--------|
| S1a | 1 — R → colorimetric (C) | full | `se-S1a-refCowsToSrgbD50.json` |
| S1b | 1 — R → colorimetric (C) | abridged | `se-S1b-ms6ToSrgb.json` |
| S2a–d | 2 — R + PCC override → C | full | `se-S2{a,b,c,d}-refCowsToSrgb{A,D65,D93,F11}.json` |
| S3a | 3 — R → spectral (S) | full | `se-S3a-refCowsToSpec.json` |
| S3b | 3 — R → spectral (S) | abridged | `se-S3b-ms6ToSpec.json` |
| S4a | 4 — spectral (S) → R | full | `se-S4a-specToRefCows.json` |
| S4b | 4 — spectral (S) → R | abridged | `se-S4b-specToMs6.json` |
| S5 | 5 — R as a PCC override | abridged | `se-S5-previewCowsMsPcc.json` |

Because S4b *builds* the abridged 6-channel image that S1b and S3b consume, the
build scripts run the steps in dependency order: S3a (make the 36-band spectral
image) → S4a → S4b (make the 6-channel image) → S1b → S3b → S5.

---

## S1a — Full encoding as source to a colorimetric destination

**Driver:** `iccApplyProfiles -cfg config/se-S1a-refCowsToSrgbD50.json`

The 81-band spectral image is connected through its embedded `sref` profile to
sRGB. The CMM converts spectral reflectance to colorimetry under the profile's
native **D50 2°** observing conditions, then to sRGB for display.

```
src   : Data/smCows380_5_780.tif         (embedded sref profile)
stage1: <embedded>           absolute     (no PCC override → native D50)
stage2: C-sRGB_v4_ICC_preference.icc  relative
dst   : Results/Preview-cowsD50_fromRef.tif  (8-bit)
```

This is clause-5 **Scenario 1** (R → C). Systems without iccMAX support cannot
perform it.

---

## S2 — Full encoding as source with a colorimetric PCC override

**Driver:** `iccApplyProfiles -cfg config/se-S2{a,b,c,d}-refCowsToSrgb*.json`

Identical to S1a except a **PCC override** (`pccFile`) re-evaluates the spectral
reflectance under a different illuminant/observer before conversion to sRGB:

| Config | `pccFile` | Output |
|--------|-----------|--------|
| `se-S2a-refCowsToSrgbA.json`   | `ICC/2-Lab_float-IllumA_2deg-MAT.icc` | `Results/Preview-cowsA_fromRef.tif` |
| `se-S2b-refCowsToSrgbD65.json` | `ICC/5-Lab_int-D65_2deg-MAT.icc`      | `Results/Preview-cowsD65_fromRef.tif` |
| `se-S2c-refCowsToSrgbD93.json` | `ICC/1-Lab_float-D93_2deg-MAT.icc`    | `Results/Preview-cowsD93_fromRef.tif` |
| `se-S2d-refCowsToSrgbF11.json` | `ICC/4-Lab_float-F11_2deg-MAT.icc`    | `Results/Preview-cowsF11_fromRef.tif` |

This is clause-5 **Scenario 2** (R + PCC → C). The override is possible only
because the encoding carries full spectral information.

**What to look for:** because the cows are metameric under D65, the **D65**
preview shows the head and tail halves matching, while the **A**, **D93** and
**F11** previews show them clearly differing. A single-illuminant colorimetric
encoding could not reproduce that divergence; a spectral encoding can.

---

## S3a — Full encoding as source to a spectral-PCS destination

**Driver:** `iccApplyProfiles -cfg config/se-S3a-refCowsToSpec.json`

The 81-band spectral image is connected to the 36-band full-encoding profile as
a spectral destination. The CMM resamples the source spectral data
(380…780 nm @ 5 nm) to the destination's spectral PCS (380…730 nm @ 10 nm) and
writes the 36-channel device encoding.

```
src   : Data/smCows380_5_780.tif         (embedded sref, 81 bands)
stage1: <embedded>           absolute
stage2: R-Spec380_10_730-D50_2deg.icc  absolute   (spectral destination)
dst   : Results/Spec_smCows.tif          (16-bit, 36 channels)
```

This is clause-5 **Scenario 3** (R → S). Spectral PCS sampling / range
adjustment is performed per Annex A of ISO 20677:2019.

---

## S4a — Spectral-PCS source to the full encoding as destination

**Driver:** `iccApplyProfiles -cfg config/se-S4a-specToRefCows.json`

The inverse of S3a: the S3a output (a spectral image carrying the embedded full
profile) is run back through the full-encoding profile as the destination,
reconstructing the spectral device values (a round trip).

```
src   : Results/Spec_smCows.tif          (embedded sref, 36 bands)
stage1: <embedded>           absolute
stage2: R-Spec380_10_730-D50_2deg.icc  absolute
dst   : Results/Ref_smCows.tif           (16-bit, 36 channels)
```

This is clause-5 **Scenario 4** (S → R).

---

## S4b — Spectral-PCS source to the abridged encoding as destination

**Driver:** `iccApplyProfiles -cfg config/se-S4b-specToMs6.json`

The 36-band spectral image is **encoded into the abridged six-channel
multi-spectral representation** via the abridged profile's `B2D3` (36 → 6)
transform.

```
src   : Results/Spec_smCows.tif          (embedded sref, 36 bands)
stage1: <embedded>           absolute
stage2: R-SixChanMsRef.icc   absolute     (abridged destination, B2D3 36→6)
dst   : Results/MS6_smCows.tif            (16-bit, 6 channels, abridged profile embedded)
```

This is also clause-5 **Scenario 4** (S → R), with the abridged encoding as the
destination. The resulting `MS6_smCows.tif` is the input for S1b and S3b.
`iccTiffDump` confirms it carries **6 channels** (`MCH6Data`) and the embedded
abridged profile.

---

## S1b — Abridged encoding as source to a colorimetric destination

**Driver:** `iccApplyProfiles -cfg config/se-S1b-ms6ToSrgb.json`

The six-channel image is decoded back to 36-band spectral reflectance (via the
abridged profile's `D2B3`), converted to colorimetry under its native **D93 2°**
observing conditions, and rendered to sRGB.

```
src   : Results/MS6_smCows.tif            (embedded abridged profile, 6 channels)
stage1: <embedded>           absolute     (no PCC override → native D93)
stage2: C-sRGB_v4_ICC_preference.icc  relative
dst   : Results/Preview-cowsMs6.tif       (8-bit)
```

This is clause-5 **Scenario 1** (R → C) for the abridged encoding. Because the
abridged profile's native observing conditions are D93, this preview should
resemble the full-encoding **D93** preview (`Preview-cowsD93_fromRef.tif`) —
demonstrating that the six-channel representation preserves the spectral content
well enough to reproduce the colorimetry.

---

## S3b — Abridged encoding as source to a spectral-PCS destination

**Driver:** `iccApplyProfiles -cfg config/se-S3b-ms6ToSpec.json`

The six-channel image is reconstructed to the full 36-band spectral reflectance
and written through the full-encoding profile as a spectral destination.

```
src   : Results/MS6_smCows.tif            (embedded abridged profile, 6 channels)
stage1: <embedded>           absolute     (D2B3 6→36)
stage2: R-Spec380_10_730-D50_2deg.icc  absolute
dst   : Results/Spec_ms6Cows.tif          (16-bit, 36 channels)
```

This is clause-5 **Scenario 3** (R → S) for the abridged encoding. Compare
`Spec_ms6Cows.tif` against `Spec_smCows.tif` (the original 36-band spectral
image from S3a) to see how faithfully the six-channel abridged encoding
reconstructs the full spectral reflectance.

---

## S5 — Abridged encoding used as a PCC override

**Driver:** `iccApplyProfiles -cfg config/se-S5-previewCowsMsPcc.json`

The abridged profile is used **only as a PCC override** of the spectral image:
all of its device transforms are ignored, and only its `svcn` (D93 observing
conditions) plus `c2sp` / `s2cp` transforms participate, re-rendering the cows
under D93.

```
src   : Data/smCows380_5_780.tif         (embedded sref, 81 bands)
stage1: <embedded>           absolute, pccFile = R-SixChanMsRef.icc  (D93 PCC)
stage2: C-sRGB_v4_ICC_preference.icc  relative
dst   : Results/Preview-cowsMsPcc.tif     (8-bit)
```

This is clause-5 **Scenario 5** (R as a PCC override). The result should match
the colorimetric **D93** preview (`Preview-cowsD93_fromRef.tif` from S2c),
because both re-render the same spectral image under D93 — one via a colorimetric
PCC override, the other via the spectralEncoding profile's PCC tags.

---

## Sanity check after a run

```sh
ls ICC/       # 7 .icc files: R-Spec380…, R-SixChanMsRef, 1-…5-
ls Results/   # Preview-* (S1a/S2/S1b/S5), Spec_smCows / Ref_smCows / MS6_smCows / Spec_ms6Cows
iccTiffDump Results/Spec_smCows.tif   # 36 spectral channels (full encoding)
iccTiffDump Results/MS6_smCows.tif    # 6 channels (abridged encoding), abridged profile embedded
iccTiffDump Results/Spec_ms6Cows.tif  # 36 channels reconstructed from the 6
```

Every scenario is expected to complete successfully (the POSIX script runs with
`set -eu` and exits 0).
