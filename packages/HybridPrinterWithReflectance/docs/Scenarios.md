# Scenario reference — Hybrid Printer With Reflectance

This document is a companion to `ICS-HybridPrinterWithReflectance.pdf`
(the normative form of the ICS, summarised in Annex A of that document)
and to the top-level `README.md`. It explains, for each scenario
S1 … S6, exactly which iccDEV tool runs, what the driver JSON expresses,
and what the expected output is.

All paths below are written relative to the package root.

---

## Profiles that participate

| Symbolic name | Built file | Built from | Role |
|---------------|------------|------------|------|
| Hybrid printer | `ICC/P-CMYK_Hybrid_Profile.icc` | `CMYK_Hybrid_Profile.xml` | The profile under test. Hybrid = colorimetric base part + spectral reflectance v5 sub-profile. |
| PCS @ D93 | `ICC/1-Lab_float-D93_2deg-MAT.icc` | `Data/Lab_float-D93_2deg-MAT.xml` | Colorimetric PCS for D93 2° (chromatic adaptation MAT). |
| PCS @ A | `ICC/2-Lab_float-IllumA_2deg-MAT.icc` | `Data/Lab_float-IllumA_2deg-MAT.xml` | Colorimetric PCS for Illuminant A 2°. |
| PCS @ D50 | `ICC/3-Lab_float-D50_2deg.icc` | `Data/Lab_float-D50_2deg.xml` | Colorimetric PCS for D50 2° (the ICC reference). |
| PCS @ F11 | `ICC/4-Lab_float-F11_2deg-MAT.icc` | `Data/Lab_float-F11_2deg-MAT.xml` | Colorimetric PCS for F11 2°. |
| Spectral PCS | `ICC/S-Spec380_10_730-D50_2deg.icc` | `Data/Spec380_10_730-D50_2deg.xml` | Spectral PCS, 380…730 nm at 10 nm. |
| Multispectral RGB | `ICC/S-MultiSpectralRGB.icc` | `Data/MultiSpectralRGB.xml` | Multispectral RGB encoding profile (3 wide bands). |
| sRGB v4 | `Data/C-sRGB_v4_ICC_preference.icc` | (prebuilt) | The ICC sRGB v4 preference profile (used as a display proof target). |

`ICC/` is rebuilt every time `BuildAndTest.{bat,sh}` runs.

---

## S1 — Print output (sRGB → hybrid CMYK)

**Driver:** `iccApplyProfiles -cfg config/hpwr-S1-PrintOutput.json`

The source image `Data/HappyBunniesRGB.tif` carries an embedded sRGB
profile (`iccFile: null` + `intent: perceptual` in the first stage tells
`iccApplyProfiles` to use the embedded profile). It is rendered through
the hybrid printer profile using the perceptual intent, producing a 16-bit
CMYK TIFF.

```
src   : Data/HappyBunniesRGB.tif         (embedded sRGB)
stage1: <embedded>           perceptual
stage2: P-CMYK_Hybrid_Profile.icc  perceptual
dst   : Results/HappyBunniesCmyk.tif     (16-bit, compressed, ICC embedded)
```

The script follows S1 with `iccTiffDump Results/HappyBunniesCmyk.tif` so
the output channels and embedded profile can be inspected.

---

## S2 — Print proof (CMYK → sRGB, D50 absolute)

**Driver:** `iccApplyProfiles -cfg config/hpwr-S2-PrintProof.json`

Takes the CMYK output of S1 and proofs it back to sRGB on a D50 display
using the absolute colorimetric intent through the hybrid profile, then
perceptual rendering to sRGB. This is the *colorimetric* proof — it does
not consult the reflectance sub-profile.

```
src   : Results/HappyBunniesCmyk.tif      (embedded P-CMYK_Hybrid_Profile.icc)
stage1: <embedded>            absolute
stage2: C-sRGB_v4_ICC_preference.icc  perceptual
dst   : Results/HappyBunniesProofD50.tif  (8-bit)
```

---

## S3 — Spectral PCS access for two CMYK greys

**Driver:** `iccApplyNamedCmm -cfg config/hpwr-S3-SpectralPcsAccess.json > Results/cmykGraysRefPcs.txt`

The simplest use of the v5 reflectance sub-profile: a colour-list workflow
that stops at the spectral PCS. The two CMYK greys in `Data/cmykGrays.txt`

```
50  40  40   0     # a near-neutral CMY grey
 0   0   0  50     # a black-only grey
```

are passed through the hybrid profile (v5 sub-profile, absolute) and the
resulting spectral PCS values — reflectance vectors of 380…730 nm at a
10 nm step, 36 values per row — are written to
`Results/cmykGraysRefPcs.txt`.

Because only the forward transform of the hybrid profile is used, there
is no PCS processing at all: no PCC, no destination profile, no spectral
PCS operations. This makes it the least demanding of the v5 scenarios —
it can be implemented as an extension of v4 (ISO 15076-1) processing
elements with no iccMAX PCS machinery, and is the reason it appears here
rather than after the scenarios that do consult the PCS.

---

## S4a — Spectral proof under Illuminant A

**Driver:** `iccApplyProfiles -cfg config/hpwr-S4a-SpectralPrintProof.json`

Identical workflow to S2 but with two key differences expressed in JSON:

* `"useV5SubProfile": true` — engage the v5 reflectance sub-profile of
  the hybrid profile rather than the colorimetric base part.
* `"pccFile": "ICC/2-Lab_float-IllumA_2deg-MAT.icc"` — evaluate the
  resulting reflectance under Illuminant A, 2° observer (with a MAT
  chromatic adaptation to D50 for proofing).

```
src   : Results/HappyBunniesCmyk.tif      (embedded hybrid profile)
stage1: <embedded v5 sub>     absolute   pcc = 2-Lab_float-IllumA_2deg-MAT.icc
stage2: C-sRGB_v4_ICC_preference.icc  perceptual
dst   : Results/HappyBunniesProofA.tif    (8-bit)
```

---

## S4b — Spectral proof under D93

**Driver:** `iccApplyProfiles -cfg config/hpwr-S4b-SpectralPrintProof.json`

Same as S4a but with `pccFile: ICC/1-Lab_float-D93_2deg-MAT.icc`. Output
goes to `Results/HappyBunniesProofD93.tif`.

S4a/S4b together demonstrate that the reflectance sub-profile lets the
same hybrid profile render correctly under different illuminants —
something a purely colorimetric base part cannot do.

---

## S5a — Multispectral RGB extraction

**Driver:** `iccApplyProfiles -cfg config/hpwr-S5a-SpectralExtraction.json`

Pulls reflectance out of the hybrid profile (v5 sub-profile, absolute)
and encodes it into the 3-band multispectral RGB profile.

```
src   : Results/HappyBunniesCmyk.tif      (embedded hybrid profile)
stage1: <embedded v5 sub>     absolute
stage2: S-MultiSpectralRGB.icc   absolute   (v5 sub-profile)
dst   : Results/HappyBunniesMSRGB.tif     (16-bit)
```

The script follows S5a with `iccTiffDump Results/HappyBunniesMSRGB.tif`
to show that the destination really has been written as a multispectral
RGB image (custom photometric interpretation 10003).

---

## S5b — Reflectance extraction for two CMYK greys

**Driver:** `iccApplyNamedCmm -cfg config/hpwr-S5b-SpectralExtraction.json > Results/cmykGraysRef.txt`

Replaces the imaging pipeline of S5a with a colour-list workflow: the same
two CMYK greys used by S3 are passed through the hybrid profile (v5
sub-profile, absolute) into the spectral PCS profile
`S-Spec380_10_730-D50_2deg.icc`, and the resulting reflectance vectors
(380…730 nm, 10 nm step → 36 values per row) are written to
`Results/cmykGraysRef.txt`.

Unlike S3, this scenario connects to a destination profile with a
spectral PCS, so spectral PCS operations are performed. This is the
*forward* half of the spectral round trip.

---

## S6 — Inverse spectral reproduction

**Driver:** `iccApplySearch -cfg config/hpwr-S6-SpectralReproduction.json > Results/cmykGraysEst.txt`

Closes the round trip. Given the 36-channel reflectance produced by S5b,
search for CMYK percentages that, when run through the hybrid profile,
reproduce those reflectances. The search uses a colorimetric distance
metric integrated over four PCCs (D93, A, D50, F11) with equal weight:

```
pccWeights:
  1-Lab_float-D93_2deg-MAT.icc    weight 1.0
  2-Lab_float-IllumA_2deg-MAT.icc weight 1.0
  3-Lab_float-D50_2deg.icc        weight 1.0
  4-Lab_float-F11_2deg-MAT.icc    weight 1.0

profileSequence (objective):
  S-Spec380_10_730-D50_2deg.icc   absolute (source spectral profile)
  3-Lab_float-D50_2deg.icc        absolute (interim profile use for seach)
  P-CMYK_Hybrid_Profile.icc       absolute (v5 sub-profile)
```

`Results/cmykGraysEst.txt` should be visibly close to `Data/cmykGrays.txt`
— the deviation is a measure of how well the hybrid profile inverts.

---

## Sanity check after a run

A quick way to confirm the package ran end-to-end:

```sh
ls ICC/                 # should list 7 .icc files (P-, 1-…4-, two S-)
ls Results/             # should list 5 .tif files and 3 .txt files
diff Data/cmykGrays.txt Results/cmykGraysEst.txt    # close, not identical
```

The plot in `Data/cmykGreysPlot.png` is the reference graphic that
accompanies the round-trip discussion in the ICS document.
