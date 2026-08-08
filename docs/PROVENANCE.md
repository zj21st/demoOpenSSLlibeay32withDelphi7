# Source Provenance

This document records what the maintained source tree contains and how its
licensing differs from earlier revisions.

## Current maintained tree

The following replacement files were written for this repository and are
offered under the repository-level MIT License:

- `src/Base64Url.pas`
- `src/OpenSslRsaDemo.pas`
- `examples/ConsoleDemo/Demo.dpr`
- `tests/Base64UrlTests.dpr`
- the repository documentation, checks, and key-generation scripts

Their design follows documented OpenSSL and RFC 4648 behavior. They do not
contain source text copied from the removed inherited implementations.

`src/legacy/libeay32.pas` is a pre-existing Delphi import unit by Marco
Ferrante and contributors. It retains its original copyright and separate
four-condition license. See `THIRD_PARTY_NOTICES.md`.

## Removed material

The maintained tree no longer contains:

- the historical GUI/demo implementation derived from
  `ddlencemc/RSA-via-OpenSSL-libeay32`, whose repository has no explicit
  license grant;
- `EncdDecd_suman.pas`, which was substantially derived from Delphi library
  source;
- compiled Delphi artifacts and IDE backup files;
- a prebuilt, unsupported OpenSSL 0.9.8h DLL;
- private keys, public keys, or certificates.

This removal avoids presenting inherited material as though it were covered by
the new MIT License.

## Git history

The repository-level MIT License applies to the maintained MIT-marked files;
it does not retroactively relicense deleted files in earlier commits.

Historical objects also remain retrievable until the repository history is
separately rewritten. Every key found in history is permanently compromised
and must never be reused. See `SECURITY.md`.
