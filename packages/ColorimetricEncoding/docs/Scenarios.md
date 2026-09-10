# Scenario reference — Colorimetric Encoding

This document is a companion to `ICS-ColorimetricEncoding.pdf`
(the normative form of the ICS) and to the top-level `README.md`. It
explains, for each `ce-S*-*.json` configuration file in `config/`,
which iccDEV tool runs, what the driver JSON expresses, and what the
expected output is.

All paths below are written relative to the package root.

---

## Profile roles in this ICS

| Symbol | Description | Where it lives in this package |
|--------|-------------|--------------------------------|
| **E**  | The *colorimetricEncoding* profile under test (ISO 20677-1). Transform type is `colorimetric`; the AToBxTag encodes device values to a colorimetric PCS and the BToAxTag decodes it back. | `ICC/E-*.icc`, built from `Illuminants/*.xml` and `CustomObservers/*.xml` |
| **P**  | A profile that supplies a PCC override via its `spectralViewingConditionsTag`, `customToStandardPccTag`, `standardToCustomPccTag`. Functionally a profile-E with the role-of-PCC-override. | `ICC/P-*.icc`, built from the same XML as the matching E- |
| **C**  | An arbitrary profile with a colorimetric PCS — here, the ICC sRGB v4 preference profile. | `Data/C-sRGB_v4_ICC_preference.icc` / `Data/1-sRGB_v4_ICC_preference.icc` |
| **1**  | A profile (ISO 20677-1 or ISO 15076-1) used as the connecting source profile in S3/S4. In this package an embedded sRGB profile in the source TIFF plays this role. | embedded in `Data/1-HappyBunniesRGB.tif` |
| **2**  | A profile (ISO 20677-1) used in S5 as the profile whose PCS evaluation is overridden by profile E. In this package an embedded profile in the S5 source TIFFs plays this role. | embedded in `Data/2-HappyBunniesMSRGB.tif` and in `Results/2-HappyBunniesS5a.tif` |
| **S**  | A spectral PCS profile (ISO 20677-1, `'spac'`/`'sref'` sub-class) used in S6 to convert reflectance spectra to a colorimetric PCS. | `ICC/S-Spec380_10_730-D50_2deg.icc`, built from `Data/Spec380_10_730-D50_2deg.xml` |

`ICC/` is rebuilt every time `BuildAndTest.{bat,sh}` runs.

---

## ICS document → config-file cross reference

The seven abstract scenarios in `ICS-ColorimetricEncoding.pdf` are
numbered in the same order as the configuration filenames in `config/`
(encode first, then decode, then PCC-only use, then spectral and
encoding-to-encoding conversions). The cross-reference is:

| ICS doc scenario | Role of profile E | Maps to config IDs |
|------------------|-------------------|--------------------|
| Scenario 1 | 1 source → E destination | S1a, S1b |
| Scenario 2 | 1 source + PCC override → E destination | S2 |
| Scenario 3 | E source → C destination | S3a, S3b, S3c |
| Scenario 4 | E source + PCC override → C destination | S4 |
| Scenario 5 | E as PCC override only | S5a, S5b, S5c |
| Scenario 6 | Spectral PCS → E destination (color-list workflow) | S6a, S6b, S6c, S6d, S6e, S6f |
| Scenario 7 | E source → E destination (color-list workflow, observer/illuminant change) | S7a, S7b, S7c, S7d, S7e, S7f |

In the per-scenario sections below the ICS doc scenario is identified
where it applies. Scenarios S1 … S5 use `iccApplyProfiles` against TIFF
imagery; scenarios S6 and S7 use `iccApplyNamedCmm` against text
color-list data. All scenarios use the relative-colorimetric intent
in every stage of their profile sequence; differences across scenarios
are driven by which profiles are connected and by the presence or
absence of a `pccFile` slot.

---

## S1a — sRGB → Lab encoded under D93 (MAT)

**ICS doc:** Scenario 1 — 1 → E destination
**Driver:** `iccApplyProfiles -cfg config/ce-S1a-IccToColorEncodingD93.json`

The source image carries an embedded sRGB profile (`iccFile: null` in
the first stage tells `iccApplyProfiles` to use the embedded profile).
It is rendered through `E-Lab_float-D93_2deg-MAT` with the
relative-colorimetric intent, producing a 32-bit-float Lab TIFF under
D93.

```
src   : Data/1-HappyBunniesRGB.tif        (embedded sRGB)
stage1: <embedded>                       relative
stage2: E-Lab_float-D93_2deg-MAT.icc     relative
dst   : Results/E-HappyBunnies-S1a.tif   (float, compressed, ICC embedded)
```

---

## S1b — sRGB → Lab encoded under Illuminant A (MAT)

**ICS doc:** Scenario 1 — 1 → E destination
**Driver:** `iccApplyProfiles -cfg config/ce-S1b-IccToColorEncodingA.json`

Same as S1a but the destination encoding is L\*a\*b\* under Illuminant A
with a MAT chromatic adaptation, and the output is 16-bit integer:

```
src   : Data/1-HappyBunniesRGB.tif        (embedded sRGB)
stage1: <embedded>                       relative
stage2: E-Lab_int-IllumA_2deg-MAT.icc    relative
dst   : Results/E-HappyBunnies-S1b.tif   (16-bit, compressed, ICC embedded)
```

---

## S2 — sRGB → Lab encoded under Illuminant A, with a PCC override

**ICS doc:** Scenario 2 — 1 + PCC → E destination
**Driver:** `iccApplyProfiles -cfg config/ce-S2-IccToColorEncodingAWithPcc.json`

Identical to S1b except a `pccFile` is supplied on the destination
stage. That tells the CMM to evaluate the encoding's
`standardToCustomPccTag` against the PCC override (here profile P, also
under Illuminant A but using the absolute mapping):

```
src   : Data/1-HappyBunniesRGB.tif        (embedded sRGB)
stage1: <embedded>                       relative
stage2: E-Lab_int-IllumA_2deg-MAT.icc    relative
        pcc = P-Lab_int-IllumA_2deg-Abs.icc
dst   : Results/E-HappyBunnies-S2.tif    (16-bit)
```

---

## S3a — Lab encoded under D93 → sRGB

**ICS doc:** Scenario 3 — E → C destination
**Driver:** `iccApplyProfiles -cfg config/ce-S3a-ColorEncodingD93ToIcc.json`

Takes the encoded TIFF produced by S1a (`E-HappyBunnies-S1a.tif`, whose
embedded profile is `E-Lab_float-D93_2deg-MAT`) and decodes it back
through sRGB. The first stage uses the embedded profile (`iccFile:
null`) — this exercises the BToAxTag of the encoding profile:

```
src   : Results/E-HappyBunnies-S1a.tif    (embedded E-Lab_float-D93_2deg-MAT)
stage1: <embedded>                       relative
stage2: C-sRGB_v4_ICC_preference.icc     relative
dst   : Results/HappyBunnies-S3a.tif     (8-bit)
```

---

## S3b — Lab encoded under Illuminant A → sRGB

**ICS doc:** Scenario 3 — E → C destination
**Driver:** `iccApplyProfiles -cfg config/ce-S3b-ColorEncodingAToIcc.json`

Same pattern as S3a but starting from the S1b output (Illuminant A
encoding). Output goes to `Results/HappyBunnies-S3b.tif`.

S3a / S3b together demonstrate that the same colorimetricEncoding
profile machinery decodes correctly under different illuminants when the
encoded data carries the matching profile.

---

## S3c — Lab encoded under Illuminant A (PCC) → sRGB

**ICS doc:** Scenario 3 — E → C destination (using S2's output)
**Driver:** `iccApplyProfiles -cfg config/ce-S3c-ColorEncodingAPccToIcc.json`

Starts from the S2 output (whose embedded encoding profile carries the
results of the PCC override applied during encoding) and decodes it to
sRGB:

```
src   : Results/E-HappyBunnies-S2.tif     (embedded E-Lab_int-IllumA_2deg-MAT)
stage1: <embedded>                       relative
stage2: C-sRGB_v4_ICC_preference.icc     relative
dst   : Results/HappyBunnies-S3c.tif     (8-bit)
```

---

## S4 — Lab encoded under Illuminant A → sRGB, with a PCC override on the source

**ICS doc:** Scenario 4 — E + PCC → C destination
**Driver:** `iccApplyProfiles -cfg config/ce-S4-ColorEncodingAWithPccToIcc.json`

Same input as S3c but the source stage carries its own `pccFile`. This
exercises the `customToStandardPccTag` of profile P on the way out of
the encoding profile:

```
src   : Results/E-HappyBunnies-S2.tif     (embedded E-Lab_int-IllumA_2deg-MAT)
stage1: <embedded>                       relative
        pcc = P-Lab_int-IllumA_2deg-Abs.icc
stage2: C-sRGB_v4_ICC_preference.icc     relative
dst   : Results/HappyBunnies-S4.tif      (8-bit)
```

---

## S5a — sRGB → Lab encoded under A, with profile E supplying the PCC override

**ICS doc:** Scenario 5 — E as PCC override
**Driver:** `iccApplyProfiles -cfg config/ce-S5a-IccToIccWithPcc.json`

In S5, profile E is no longer used in its colorimetric-transform role.
Instead it supplies the PCC tags (`spectralViewingConditionsTag`,
`customToStandardPccTag`, `standardToCustomPccTag`) used to evaluate the
PCS of the destination profile. S5a feeds the sRGB image through an
Illuminant A encoding profile *as the destination* but with profile P
(equivalently profile E in its PCC role) overriding the PCC:

```
src   : Data/1-HappyBunniesRGB.tif        (embedded sRGB)
stage1: <embedded>                       relative
stage2: E-Lab_int-IllumA_2deg-MAT.icc    relative
        pcc = P-Lab_int-IllumA_2deg-Abs.icc
dst   : Results/2-HappyBunniesS5a.tif    (8-bit)
```

---

## S5b — round-trip back through sRGB with a PCC override

**ICS doc:** Scenario 5 — E as PCC override
**Driver:** `iccApplyProfiles -cfg config/ce-S5b-ColorIccWithPccToIcc.json`

Closes the S5a round trip. The S5a output is decoded back to sRGB; the
source stage carries the same PCC override:

```
src   : Results/2-HappyBunniesS5a.tif     (embedded encoding profile)
stage1: <embedded>                       relative
        pcc = P-Lab_int-IllumA_2deg-Abs.icc
stage2: Data/1-sRGB_v4_ICC_preference.icc relative
dst   : Results/1-HappyBunnies-S5b.tif   (8-bit)
```

---

## S5c — multispectral-RGB → sRGB with a PCC override

**ICS doc:** Scenario 5 — E as PCC override
**Driver:** `iccApplyProfiles -cfg config/ce-S5c-SpectralIccWithPccToIcc.json`

The input is a multispectral-RGB image (`Data/2-HappyBunniesMSRGB.tif`)
whose embedded profile is a multispectral encoding. Its PCS evaluation
is overridden by profile P before the result is rendered back through
sRGB:

```
src   : Data/2-HappyBunniesMSRGB.tif      (embedded multispectral encoding)
stage1: <embedded>                       relative
        pcc = P-Lab_int-IllumA_2deg-Abs.icc
stage2: Data/1-sRGB_v4_ICC_preference.icc relative
dst   : Results/1-HappyBunnies-S5c.tif   (8-bit)
```

---

## S6a — chartRef.txt → E-XYZ encoded under Illuminant A

**ICS doc:** Scenario 6 — Spectral → E destination
**Driver:** `iccApplyNamedCmm -cfg config/ce-S6a-RefToXYZA.json > Results/chartRef-S6a-XYZA.txt`

S6 is a colour-list workflow: the 24-patch spectral reflectance table
`Data/chartRef.txt` (36 wavelengths per patch, 380–730 nm @ 10 nm,
`icEncodeFloat`) is passed through the spectral PCS profile and into
the destination colorimetricEncoding profile, producing one
encoded-XYZ value per patch. `dstEncoding: "float"` is used so the
output is in PCS-normalized form (X, Y, Z each in 0 … ~1.1) — which is
also what makes the file consumable by the S7 chain.

```
src   : Data/chartRef.txt                  (36-channel spectral reflectance)
stage1: S-Spec380_10_730-D50_2deg.icc      relative
stage2: E-XYZ_int-IllumA_2deg-MAT.icc      relative
dst   : Results/chartRef-S6a-XYZA.txt      ('XYZ ', icEncodeFloat)
```

The output's first patch (white reflectance) is approximately
`X=1.0984 Y=1.0000 Z=0.3559` — the standard Illuminant A white point.

---

## S6b — chartRef.txt → E-XYZ encoded under D50

**ICS doc:** Scenario 6 — Spectral → E destination
**Driver:** `iccApplyNamedCmm -cfg config/ce-S6b-RefToXYZD50.json > Results/chartRef-S6b-XYZD50.txt`

Identical to S6a but the destination encoding is the standard ICC
D50 / 2°. The white-patch output is `0.9642 / 1.0000 / 0.8249` — the
D50 reference white.

---

## S6c — chartRef.txt → E-XYZ encoded under D93

**ICS doc:** Scenario 6 — Spectral → E destination
**Driver:** `iccApplyNamedCmm -cfg config/ce-S6c-RefToXYZD93.json > Results/chartRef-S6c-XYZD93.txt`

Same pattern, D93 destination. White patch: `0.9532 / 1.0000 / 1.4140`
(D93 chromaticity). S7a and S7b consume this file.

---

## S6d — chartRef.txt → E-Lab encoded under D50

**ICS doc:** Scenario 6 — Spectral → E destination
**Driver:** `iccApplyNamedCmm -cfg config/ce-S6d-RefToLabD50.json > Results/chartRef-S6d-LabD50.txt`

Same chain, but the destination is `E-Lab_int-D50_2deg.icc`. The white
patch comes out as `1.0000 / 0.5000 / 0.5000` (PCS-normalized Lab —
equivalent to standard L\*=100, a\*=b\*=0). S7c, S7d, S7e and S7f
consume this file.

---

## S6e — chartRef.txt → E-Lab encoded under D50 with the CIE 2015 2° observer

**ICS doc:** Scenario 6 — Spectral → E destination
**Driver:** `iccApplyNamedCmm -cfg config/ce-S6e-RefToLab2015.json > Results/chartRef-S6e-Lab2015.txt`

Demonstrates encoding under a custom observer (CIE 2015 2° cone
fundamentals, from `CustomObservers/Lab2015-D50_2deg.xml`). Slight
differences from S6d on coloured patches show the observer's effect on
the colorimetric encoding.

---

## S6f — chartRef.txt → E-Lab encoded under D50 with Asano's Categorical observer #8

**ICS doc:** Scenario 6 — Spectral → E destination
**Driver:** `iccApplyNamedCmm -cfg config/ce-S6f-RefToLabCat8.json > Results/chartRef-S6f-LabCat8.txt`

Same as S6e but uses Asano's *Cat8* categorical observer
(`CustomObservers/LabCat8-D50_2deg.xml`) as the destination. Pairs
with S7f.

---

## S7a — E-XYZ(D93) → E-Lab encoded under Illuminant A

**ICS doc:** Scenario 7 — E source → E destination
**Driver:** `iccApplyNamedCmm -cfg config/ce-S7a-XYZToLabA.json > Results/S7a-XYZ-to-LabA.txt`

S7 is the second color-list workflow: an already-encoded colorimetric
file is converted to another colorimetric encoding, possibly under a
different observer/illuminant. Both stages are colorimetricEncoding
profiles.

```
src   : Results/chartRef-S6c-XYZD93.txt    (E-XYZ encoded under D93, float)
stage1: E-XYZ_int-D93_2deg-MAT.icc         relative
stage2: E-Lab_int-IllumA_2deg-MAT.icc      relative
dst   : Results/S7a-XYZ-to-LabA.txt        ('Lab ', icEncodeValue)
```

White-patch output: `L=130.15 a=27.36 b=60.83` — Lab under Illuminant A
for what the S6c file says is "D93 white reflectance"; the high L\*
and warm shift are the expected effect of evaluating a cool-white
patch through the Illuminant-A observer.

---

## S7b — E-XYZ(D93) → E-Lab encoded under D93

**ICS doc:** Scenario 7 — E source → E destination
**Driver:** `iccApplyNamedCmm -cfg config/ce-S7b-XYZToLabD93.json > Results/S7b-XYZ-to-LabD93.txt`

Same source as S7a; destination is `E-Lab_float-D93_2deg-MAT.icc`.
White-patch output: `L=130.1501 a=-2.4047 b=-49.5864` — the same L\* as
S7a, as expected (both start from the same S6c XYZ values under D93 and
differ only in the destination illuminant).

> **Why this config uses `"dstEncoding": "float"`.** The `Lab_int-*` and
> `Lab_float-*` profile families in `Illuminants/` are two different device
> encodings, not two precisions. The `int` profiles carry an `AToB1Tag` matrix
> (×100, ×256−128) that converts PCS-normalized Lab into familiar Lab units, so
> their device space *is* L\*a\*b\*. The `float` profiles have an **empty**
> `AToB1Tag` (identity), so their device space is PCS-normalized Lab.
> `icEncodeValue` applies the legacy Lab value conversion on top of the device
> values, which is right for an `int` destination and wrong for a `float` one —
> it previously produced `L=13015 a=-741 b=-12772`, exactly 100× too large.
> The rule: **`int` Lab destination → `"value"`; `float` Lab destination →
> `"float"`.** (`"percent"` is refused outright by a `Lab ` destination.)
> No extra profile is required.

---

## S7c — E-Lab(D50) → E-Lab encoded under Illuminant A

**ICS doc:** Scenario 7 — E source → E destination
**Driver:** `iccApplyNamedCmm -cfg config/ce-S7c-LabD50ToLabA.json > Results/S7c-LabD50-to-LabA.txt`

Demonstrates a pure colorimetric-encoding to colorimetric-encoding
conversion: input is the Lab values produced by S6d (under D50,
standard observer), output is Lab under Illuminant A:

```
src   : Results/chartRef-S6d-LabD50.txt    (E-Lab encoded under D50, float)
stage1: E-Lab_int-D50_2deg.icc             relative
stage2: E-Lab_int-IllumA_2deg-MAT.icc      relative
dst   : Results/S7c-LabD50-to-LabA.txt     ('Lab ', icEncodeValue)
```

White-patch output: `L≈99.999 a≈21.6 b≈48.2` (Lab under IllumA for the
patch that was Lab=100,0,0 under D50).

---

## S7d — E-Lab(D50) → E-Lab encoded under D93

**ICS doc:** Scenario 7 — E source → E destination
**Driver:** `iccApplyNamedCmm -cfg config/ce-S7d-LabD50ToLabD93.json > Results/S7d-LabD50-to-LabD93.txt`

Same input as S7c but the destination encoding is D93. Like S7b it uses
`"dstEncoding": "float"` because the destination is a `float` Lab profile
(see the note under S7b). White-patch output:
`L=100.0008 a=-1.9107 b=-39.3529` — L\*≈100 for the patch that was
Lab=100,0,0 under D50, with the a/b shift produced by the D50→D93 change.

---

## S7e — E-Lab(D50, standard observer) → E-Lab encoded under D50 with CIE 2015 observer

**ICS doc:** Scenario 7 — E source → E destination
**Driver:** `iccApplyNamedCmm -cfg config/ce-S7e-LabD50ToLab2015.json > Results/S7e-LabD50-to-Lab2015.txt`

Demonstrates an *observer-only* change (illuminant stays D50, the
spectralViewingConditions / PCC tags of the destination profile carry
the CIE 2015 cone fundamentals). White patch output: `L=100 a=0 b=0`
— observer change is the identity for the perfect diffuser, but
chromatic patches differ slightly from S6d.

---

## S7f — E-Lab(D50, standard observer) → E-Lab encoded under D50 with Asano Cat8 observer

**ICS doc:** Scenario 7 — E source → E destination
**Driver:** `iccApplyNamedCmm -cfg config/ce-S7f-LabD50ToLabCat8.json > Results/S7f-LabD50-to-LabCat8.txt`

Mirror of S7e but using the Asano *Cat8* categorical observer for the
destination. Together with S6f this lets implementers compare
spectral→encoding versus encoding→encoding paths for the same observer.

---

## Notes on the S6 / S7 results

A few things worth eyeballing in the output files once the chain has
run end-to-end:

* **Reflectance → XYZ produces different white-patch values for each
  illuminant** (S6a / S6b / S6c). The perfect reflecting diffuser
  (PRD) row of `chartRef.txt` lands at *approximately the illuminant's
  white-point XYZ in PCS-normalized form*:
  `1.0984 / 1.0000 / 0.3559` under Illuminant A, `0.9642 / 1.0000 /
  0.8249` under D50, `0.9532 / 1.0000 / 1.4140` under D93. The XYZ
  encoding carries the illuminant's chromaticity directly.
* **Reflectance → Lab gives `100 / 0 / 0` for the PRD under every
  observer / illuminant** (S6d / S6e / S6f). Lab encoding normalizes
  to the destination's white point by construction, so the white
  reads as L\*=100, a\*=b\*=0 regardless. Differences between S6d,
  S6e and S6f only show up on chromatic patches, where they reflect
  the observer's spectral sensitivities (CIE 1931 vs CIE 2015 vs
  Asano Cat8).
* **Computing colorimetry directly from reflectance is not the same
  as converting one colorimetric encoding to another** (compare
  S7a / S7b against S7c / S7d). S7a and S7b start from the XYZ values
  produced by S6c (i.e., from reflectance evaluated under D93) and
  cross-convert to Lab under Illuminant A or D93 via the source
  profile's chromatic-adaptation matrices. S7c and S7d start from the
  Lab values produced by S6d (reflectance under D50) and cross-convert
  via the destination profile's `customToStandardPccTag` /
  `standardToCustomPccTag` machinery. The two paths share the same
  ISO-20677 PCS round-trip math but exercise different tags in the
  profile, so small numerical differences between the S7a/b values
  and the equivalent S6 values evaluated directly under
  Illuminant A or D93 are expected.

---

## Sanity check after a run

A quick way to confirm the package ran end-to-end:

```sh
ls ICC/           # 38 .icc files (13 scenario + 22 custom-observer + 1 spectral PCS + 2 XYZ encodings)
ls Results/       # 10 .tif files + 12 .txt files (6 S6 + 6 S7)
```

The build scripts also run `iccTiffDump` against `E-HappyBunnies-S1a.tif`,
`E-HappyBunnies-S1b.tif`, `E-HappyBunnies-S2.tif` and
`2-HappyBunniesS5a.tif` as the scenarios run, so the channel layout and
embedded profile of the colorimetrically-encoded outputs can be
inspected directly. For S6/S7 the easiest sanity check is to inspect
the first data row of each `Results/*.txt` and confirm the white-patch
values land near the standard whites listed in the per-scenario
sections above.
