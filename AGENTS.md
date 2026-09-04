# AGENTS.md

This repository contains ICC Interoperability Conformance Specification (ICS)
packages. Each package is self-contained and includes profile XML, scenario
configuration, input data, and platform build/test scripts.

## Dependencies
The packages are intended for use with the
[iccDEV](https://github.com/InternationalColorConsortium/iccDEV) command-line tool
suite (`iccFromXml`, `iccApplyProfiles`, `iccApplyNamedCmm`, `iccApplySearch`,
and `iccTiffDump`).

Assume the required `iccDEV` command-line tools are already installed unless the
task explicitly involves installation or environment setup.

## Build and Test
Each package has its own `BuildAndTest.bat` and `BuildAndTest.sh`, which `cd` to
their own directory and build into `ICC/` and `Results/`.

`packages/BuildAndTest.bat` and `packages/BuildAndTest.sh` run every package in
turn and print a pass/fail summary. They discover packages by looking for a
`BuildAndTest` script in each subdirectory, so adding a package requires no edit
there. They verify the `iccDEV` tools are on `PATH` first and stop if any are
missing, because without them the package scripts silently produce empty output
directories.

## Repository Rules
- Keep changes as small and focused as possible.
- Modify only the package(s) involved in the requested task.
- Do not reorganize package layouts or rename files or directories unless explicitly instructed.
- Do not perform unrelated cleanup, formatting, or refactoring.
- Do not edit the Interoperability Conformance Specification documents (`ICS-*.pdf` and `ICS-*.md` in each package directory). These are published artifacts produced under the ICC's specification development policy and procedures. Treat them as read-only reference input.
- Treat package XML and scenario files as authoritative sources.
- Keep package sources separate from generated outputs.
- Treat `ICC/`, `Results/`, generated profiles, TIFFs, PDFs, and logs as disposable build outputs.
- Do not commit generated outputs unless the task explicitly requests generated conformance artifacts.
- Preserve existing script entry points, command-line interfaces, and behavior.
- Preserve Windows batch and POSIX shell parity when modifying package scripts, and
  in the `packages/` build-and-test driver.
- Prefer deterministic outputs suitable for interoperability testing.
- Use ASCII for new automation and documentation files.
