# Scenario reference — Hybrid Multi-Spectral Encoding

This document is a companion to `ICS-HybridMultiSpectralEncoding.pdf` (the
normative form of the ICS) and to the top-level `README.md`. It explains, for
each scenario S1 … S6, exactly which iccDEV tool runs, what the driver JSON
expresses, and what the expected output is.

All paths below are written relative to the package root.

---

## The hybrid multi-spectral encoding profile

`MultiSpectralRGB.xml` builds `ICC/P-MultiSpectralRGB.icc`, a hybrid profile
with two parts:

* a **base ICC colorspace part** — `RGB` device space → `XYZ` PCS. This is what
  systems that do not support iccMAX see and use. It encodes only the *first*
  (colorimetric) channels of the multi-spectral encoding.
* an embedded **iccMAX v5 sub-profile** (`'spac'` / `'mspc'`) whose device
  space is `8CLR` (the full eight-channel multi-spectral encoding) and whose
  Spectral PCS is `rs0024` — 36 spectral reflectance bands over 380…730 nm at
  10 nm. This is engaged with `"useV5SubProfile": true` and provides the
  conversion between the multi-spectral encoding and spectral reflectance.

  > **Sub-class signature.** Both the ICS document and this package use `'mspc'`
  > (*multiSpectralEncoding*). Earlier revisions of the PDF said `'spec'`
  > (*spectralReflectance*) in Table 1 and Table 3; that was corrected to match the
  > shipped profile, which has always declared `'mspc'`
  > (`MultiSpectralRGB.xml`, `<ProfileDeviceSubClass>`) — as does the upstream iccDEV
  > reference profile `iccDEV/Testing/hybrid/MultSpectralRGB.xml`. `iccTiffDump` reports
  > the embedded sub-profile as `SubClass: 'mspc' = 6D737063`.

The first channels of the encoding therefore have a direct colorimetric
interpretation; the remaining channels carry the extra information needed to
reconstruct spectral reflectance.

---

## Profiles that participate

| Symbolic name | Built file | Built from | Role |
|---------------|------------|------------|------|
| MS encoding (profile under test) | `ICC/P-MultiSpectralRGB.icc` | `MultiSpectralRGB.xml` | Hybrid = colorimetric RGB→XYZ base + 8CLR↔spectral v5 sub-profile. |
| PCS @ D93 | `ICC/1-Lab_float-D93_2deg-MAT.icc` | `Data/Lab_float-D93_2deg-MAT.xml` | Colorimetric PCC override for D93 2° (chromatic adaptation MAT). |
| PCS @ A | `ICC/2-Lab_float-IllumA_2deg-MAT.icc` | `Data/Lab_float-IllumA_2deg-MAT.xml` | Colorimetric PCC override for Illuminant A 2°. |
| PCS @ D50 | `ICC/3-Lab_float-D50_2deg.icc` | `Data/Lab_float-D50_2deg.xml` | Colorimetric PCS for D50 2° (the ICC reference). |
| PCS @ F11 | `ICC/4-Lab_float-F11_2deg-MAT.icc` | `Data/Lab_float-F11_2deg-MAT.xml` | Colorimetric PCC override for F11 2°. |
| PCS @ D65 | `ICC/5-Lab_int-D65_2deg-MAT.icc` | `Data/Lab_int-D65_2deg-MAT.xml` | Colorimetric PCC override for D65 2°. |
| Spectral PCS | `ICC/S-Spec380_10_730-D50_2deg.icc` | `Data/Spec380_10_730-D50_2deg.xml` | Spectral PCS, 380…730 nm at 10 nm (36 bands). |
| sRGB v4 | `Data/C-sRGB_v4_ICC_preference.icc` | (prebuilt) | The ICC sRGB v4 preference profile (used as the display preview target). |

`ICC/` is rebuilt every time `BuildAndTest.{bat,sh}` runs.

The input imagery is `Data/smCows380_5_780.tif` (an 81-band spectral
reflectance image, 380…780 nm at 5 nm, with an embedded spectral PCS profile)
and `Data/HappyBunniesRGB.tif` (an ordinary sRGB image used for the legacy
workflows).

`smCows380_5_780.tif` is a **"metacow" metamerism target**: the head and tail
halves of each cow have *different* spectral reflectances that nonetheless form
a **metameric pair under CIE Illuminant D65 with the 1931 standard 2° observer**
— under D65 the two halves produce the same colour, but under any other
illuminant the match breaks and they take on visibly different colours. This
property is what the preview scenarios (S3, S4 and the `_fromRef` comparisons)
are designed to expose, and it is the reason a *spectral* (rather than a
single-illuminant colorimetric) encoding is needed.

---

## S1 — Encode a spectral image into the multi-spectral encoding

**Driver:** `iccApplyProfiles -cfg config/hmse-S1-refCowsToMsCows.json`

The 81-band spectral image is connected, through its embedded spectral PCS, to
the destination MS encoding profile with the v5 sub-profile engaged. The CMM
resamples the source spectral data to the sub-profile's 36-band PCS and writes
the eight-channel multi-spectral encoding.

```
src   : Data/smCows380_5_780.tif         (embedded spectral PCS)
stage1: <embedded>           absolute
stage2: P-MultiSpectralRGB.icc absolute  (v5 sub-profile)
dst   : Results/MS_smCows.tif            (16-bit, 8 channels, P embedded)
```

The script follows S1 with `iccTiffDump Results/MS_smCows.tif` so the encoded
channel count and embedded profile can be inspected. This is ISO 20677-1
Scenario 1 (spectral "encoding").

---

## S2 — Decode the multi-spectral encoding back to spectral reflectance

**Driver:** `iccApplyProfiles -cfg config/hmse-S2-msCowsToRefCows.json`

The inverse of S1: the encoded image from S1 is run through the v5 sub-profile
back into the spectral PCS, producing a 36-band spectral reflectance image.

```
src   : Results/MS_smCows.tif            (embedded P-MultiSpectralRGB.icc)
stage1: <embedded v5 sub>    absolute
stage2: S-Spec380_10_730-D50_2deg.icc  absolute
dst   : Results/Ref_smCows.tif           (16-bit, 36 channels)
```

S1 + S2 together form the multi-spectral round trip. This is ISO 20677-1
Scenario 2 (spectral "decoding" / "sampling").

---

## S3 — Colorimetric preview (native D50)

**Driver:** `iccApplyProfiles -cfg config/hmse-S3-previewMSCowsD50.json`

The encoded image is converted to colorimetry through the v5 sub-profile (which
yields spectral reflectance, then colorimetry under the profile's native D50
2° viewing conditions) and rendered to sRGB for display.

```
src   : Results/MS_smCows.tif            (embedded P, v5 sub-profile)
stage1: <embedded v5 sub>    absolute    (no PCC override → native D50)
stage2: C-sRGB_v4_ICC_preference.icc  relative
dst   : Results/Preview-cowsD50_fromMS.tif  (8-bit)
```

This is ISO 20677-1 Scenario 3 (multi-spectral preview). Systems without iccMAX
support cannot perform it.

---

## S4 — Colorimetric preview under alternate observing conditions

**Driver:** `iccApplyProfiles -cfg config/hmse-S4-previewMSCows{A,D65,D93,F11}.json`

Identical to S3 except a **PCC override** (`pccFile`) re-evaluates the spectral
reflectance under a different illuminant/observer before conversion to sRGB:

| Config | `pccFile` | Output |
|--------|-----------|--------|
| `hmse-S4-previewMSCowsA.json`   | `ICC/2-Lab_float-IllumA_2deg-MAT.icc` | `Results/Preview-cowsA_fromMS.tif` |
| `hmse-S4-previewMSCowsD65.json` | `ICC/5-Lab_int-D65_2deg-MAT.icc`      | `Results/Preview-cowsD65_fromMS.tif` |
| `hmse-S4-previewMSCowsD93.json` | `ICC/1-Lab_float-D93_2deg-MAT.icc`    | `Results/Preview-cowsD93_fromMS.tif` |
| `hmse-S4-previewMSCowsF11.json` | `ICC/4-Lab_float-F11_2deg-MAT.icc`    | `Results/Preview-cowsF11_fromMS.tif` |

This is ISO 20677-1 Scenario 4 (multi-spectral preview with alternate observing
conditions). The override is possible only because the encoding carries full
spectral information.

**What to look for:** because the cows are metameric under D65 (see the metacow
note above), `Preview-cowsD65_fromMS.tif` should show the head and tail halves
matching, while `Preview-cowsA_fromMS.tif`, `Preview-cowsD93_fromMS.tif` and
`Preview-cowsF11_fromMS.tif` should show them clearly differing. A single-
illuminant colorimetric encoding could not reproduce that divergence; the
multi-spectral encoding can.

### Comparison: previews straight from the spectral image

`hmse-previewRefCows{D50,A,D65,D93,F11}.json` perform the *same* colorimetric
previews directly from `Data/smCows380_5_780.tif` (its embedded spectral PCS,
with the same PCC overrides), writing `Results/Preview-cows*_fromRef.tif`.
Comparing `*_fromMS` against `*_fromRef` shows how faithfully the multi-spectral
encoding preserves the spectral content.

---

## S5 — Legacy preview (base ICC profile only)

**Driver:** `iccApplyProfiles -cfg config/hmse-S5-previewRgbCowsD50.json`

The encoded image is previewed using **only the base ICC part** of the profile
(`useV5SubProfile` is absent), exactly as a system with no iccMAX support would
do. The base part reads the first (colorimetric) channels and ignores the
extra multi-spectral channels.

```
src   : Results/MS_smCows.tif            (embedded P — base part only)
stage1: <embedded base>      relative
stage2: C-sRGB_v4_ICC_preference.icc  relative
dst   : Results/Preview-RgbCows_fromMS.tif  (8-bit)
```

This is ISO 20677-1 Scenario 5 (legacy multi-spectral preview).

---

## S6 — Legacy → partial multi-spectral conversion

**Driver:** `iccApplyProfiles -cfg config/hmse-S6-rgbToHalfMS.json`

An ordinary sRGB image is rendered *into* the MS encoding profile using the
base part only. Because the base part encodes just the colorimetric subset of
channels, the result is a **"half" multi-spectral image** — the extra spectral
channels are never populated.

```
src   : Data/HappyBunniesRGB.tif         (embedded sRGB)
stage1: <embedded>           perceptual
stage2: P-MultiSpectralRGB.icc perceptual (base part only)
dst   : Results/HappyBunniesHalfMS.tif   (16-bit, base channels only, P embedded)
```

This is ISO 20677-1 Scenario 6 (legacy to partial multi-spectral conversion).
The ICS flags it with a **caution**: an image produced this way carries an
embedded hybrid profile but lacks the multi-spectral channels the sub-profile
needs, so it should generally be avoided. The two follow-up runs make the point
concrete:

* `hmse-S5-previewHalfMS.json` previews the half MS image through the **base**
  profile → **works** (`Results/Preview-HappyBunniesRgb.tif`), because only the
  colorimetric channels are needed.
* `hmse-S3-previewHalfMS.json` tries to preview it through the **v5
  sub-profile** → **fails by design**, because the multi-spectral channels
  required by the spectral transform were never written. The tool aborts with:

  ```
  Number of samples 3 in image[Results/HappyBunniesHalfMS.tif] doesn't match device samples 8 in first profile
  ```

  The build scripts label this step as an expected failure (and
  `BuildAndTest.sh` guards it so the script still exits 0). This case is also
  recorded as the final row of Table A.1 in the ICS document's Annex A.

---

## Sanity check after a run

```sh
ls ICC/       # 7 .icc files: P-, 1-…5-, one S-
ls Results/   # MS_smCows.tif, Ref_smCows.tif, the Preview-*_fromMS / _fromRef
              # previews, HappyBunniesHalfMS.tif and Preview-HappyBunniesRgb.tif
iccTiffDump Results/MS_smCows.tif   # 8 channels, embedded P-MultiSpectralRGB.icc
iccTiffDump Results/Ref_smCows.tif  # 36 spectral channels
```

The expected end state is that every scenario completes **except** the final
`hmse-S3-previewHalfMS.json` step, which fails by design with the device-channel
mismatch shown above (the scripts label it accordingly and still exit 0).
