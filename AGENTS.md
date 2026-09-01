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
- Preserve Windows batch and POSIX shell parity when modifying package scripts.
- Prefer deterministic outputs suitable for interoperability testing.
- Use ASCII for new automation and documentation files.
