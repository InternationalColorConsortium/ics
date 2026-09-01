# ICC Interoperability Conformance Specification (ICS) Packages

## Introduction
The purpose of the International Color Consortium (ICC) is to promote the use and adoption of open, vendor-neutral, cross-platform color management systems. The International Color Consortium encourages vendors to support the ICC profile format and the workflows required to use ICC profiles.

This repository contains **Interoperability Conformance Specification (ICS)** packages
for iccMAX and hybrid iccMAX color management profiles. Each package provides:

* A **normative ICS document** (PDF) specifying the conformance requirements.
* **Worked-example profiles**, including their XML source definitions.
* **JSON scenario configurations** that drive end-to-end test runs.
* **Cross-platform build and test scripts** (`BuildAndTest.bat` and `BuildAndTest.sh`) that compile the profiles and execute every scenario from start to finish.

The iccMAX Profile Specification is available on the ICC website at <https://www.color.org/iccmax/>

---

## Getting Started

The packages are intended for use with the
[iccDEV](https://github.com/InternationalColorConsortium/iccDEV) command-line tool
suite (`iccFromXml`, `iccApplyProfiles`, `iccApplyNamedCmm`, `iccApplySearch`,
and `iccTiffDump`).

All packages use the `iccDEV` command-line tools. See the [iccDEV installation guide](https://github.com/InternationalColorConsortium/iccDEV/blob/HEAD/docs/install.md) and ensure the following executables are available on your `PATH`:

| Tool | Purpose |
|------|---------|
| `iccFromXml` | Compile `.icc` profiles from XML source definitions |
| `iccApplyProfiles` | Apply a profile sequence to a TIFF image |
| `iccApplyNamedCmm` | Apply a profile sequence to a colour list |
| `iccApplySearch` | Perform an inverse spectral search through a profile sequence |
| `iccTiffDump` | Dump TIFF header and embedded-profile metadata |

---

## Packages

Packages are added to this repository one at a time. Each package pull request
adds its own row to the table below, so this list grows as packages land.

| Package | What the ICS covers |
|---------|---------------------|

<!--
When adding a package, insert a row above in alphabetical order:

| [PackageName](PackageName/) | One-line summary of the conformance area. |

The package directory holds its normative ICS document (`ICS-PackageName.pdf`),
the profile XML sources, `config/` scenario drivers, `Data/` inputs, and the
`BuildAndTest` scripts.
-->

Each package is self-contained. Change to the package directory and run the
build-and-test script for your platform:

```sh
# macOS / Linux / Git Bash
cd <PackageName>
./BuildAndTest.sh
```

```bat
@REM Windows
cd <PackageName>
BuildAndTest.bat
```

The script builds every profile from its XML source into `ICC/` and runs every
scenario, writing images and colour lists to `Results/`. Both directories are
generated output and are not tracked in the repository.

---

## Contributing

Contributors are ICC members and other individual contributors who have volunteered to
maintain ICC software, documentation, or other technical artifacts. Our CONTRIBUTING
document explains our contribution processes and procedures, so please review it first:
[CONTRIBUTING](https://github.com/InternationalColorConsortium/ICS?tab=contributing-ov-file#contributing-to-international-color-consortium-software). Contributors are asked to sign a [Contributor License Agreement](https://github.com/InternationalColorConsortium/.github/blob/main/docs/CLA.md)

---

## License

Source code, scripts, and other software in this repository are licensed under the BSD 3-Clause License. See [LICENSE](LICENSE.md).

Published Interoperability Conformance Specification (ICS) documents are additionally subject to the ICC Specification Policy. See [SPECIFICATION_POLICY](SPECIFICATION_POLICY.md).

Membership in the International Color Consortium (ICC) is encouraged for organizations that use these packages in commercial products or services. Membership helps support the development and maintenance of ICC specifications and interoperability resources. For more information about the International Color Consortium, visit <https://www.color.org>.
