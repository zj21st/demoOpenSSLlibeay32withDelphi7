# Contributing

Contributions that improve this repository as a safe legacy migration
reference are welcome.

Useful changes include:

- reproducible Delphi 7 build instructions;
- independently verifiable test vectors;
- memory-ownership and error-handling fixes;
- clearer security boundaries;
- migration documentation for supported cryptographic APIs;
- removal of unnecessary legacy behavior.

## Before contributing

1. Read `README.md`, `SECURITY.md`, and `THIRD_PARTY_NOTICES.md`.
2. Discuss substantial API or compatibility changes in an issue first.
3. Never commit private keys, certificates containing personal data, DLLs,
   executables, compiler output, or Delphi IDE backup files.
4. Report vulnerabilities privately as described in `SECURITY.md`.

## Compatibility rules

Unless a change explicitly starts a separate modernization path:

- keep source compatible with Delphi 7 Win32;
- do not use Unicode-era Delphi language features;
- use `AnsiString` and byte buffers deliberately;
- keep OpenSSL object ownership and reference counting explicit;
- reject RSA keys whose modulus is shorter than 256 bytes;
- validate lengths before calling RSA functions;
- do not introduce SHA-1 or additional raw RSA operations.

## Testing

A pull request should document:

- the Delphi and Windows versions used;
- the exact build command;
- the locally observed self-test output;
- the OpenSSL binary's origin, version, architecture, and checksum;
- tests for both success and failure paths.

Use only freshly generated disposable keys under `build/`, which is ignored by
Git.

## Licensing and provenance

New original contributions are accepted under the MIT License.

By submitting a contribution, you represent that you have the right to submit
it under the applicable license. Do not copy code from another repository,
Delphi installation, article, forum post, or generated answer unless its
license permits redistribution and its provenance is documented.

Do not remove or alter the license header in
`src/legacy/libeay32.pas`. Changes to that file remain subject to its existing
license and do not become MIT licensed.

## Pull-request checklist

- [ ] No secret, private key, certificate, or personal data is included.
- [ ] No generated binary or IDE backup file is included.
- [ ] Licensing and provenance are documented.
- [ ] Delphi 7 compatibility is preserved or the incompatibility is explicit.
- [ ] Manual or automated verification is described.
- [ ] Security documentation is updated when behavior changes.
