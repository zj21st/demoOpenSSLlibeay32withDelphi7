# Delphi 7 / OpenSSL `libeay32` compatibility demo

[![Repository hygiene](https://github.com/zj21st/demoOpenSSLlibeay32withDelphi7/actions/workflows/repository-hygiene.yml/badge.svg)](https://github.com/zj21st/demoOpenSSLlibeay32withDelphi7/actions/workflows/repository-hygiene.yml)
[![License: MIT](https://img.shields.io/badge/maintainer%20code-MIT-blue.svg)](LICENSE)

A source-only Delphi 7 Win32 console demo showing how legacy Object Pascal
applications interacted with the pre-1.1 OpenSSL `libeay32` ABI.

This repository is maintained for code archaeology, interoperability testing,
security review, and migration of legacy Delphi systems. It is not a
production cryptography library.

> [!WARNING]
> This project targets an obsolete OpenSSL ABI. A DLL formerly committed to
> this repository identified itself as OpenSSL 0.9.8h, released in 2008.
> OpenSSL 0.9.8 has been
> [unsupported since 1 January 2016](https://mirror.openssl-library.org/news/vulnerabilities-0.9.8/).
>
> The example also demonstrates RSA PKCS#1 v1.5 encryption for historical
> compatibility. Do not use this design for new systems, do not download
> arbitrary `libeay32.dll` files, and never reuse any key found in this
> repository's history. Use a supported cryptographic API for new software.

## Purpose and scope

The project preserves practical interoperability knowledge for Delphi 7
systems that still need auditing or migration.

The replacement demo covers:

- loading unencrypted or password-protected PKCS#1/PKCS#8 PEM RSA private keys;
- loading SPKI or PKCS#1 PEM RSA public keys;
- rejecting RSA keys whose modulus is shorter than 256 bytes;
- SHA-256 hashing;
- RSASSA-PKCS1-v1_5 SHA-256 signing and verification;
- RSA PKCS#1 v1.5 public-key encryption and private-key decryption;
- strict, unpadded Base64URL encoding and decoding;
- explicit OpenSSL object ownership and error handling.

OpenSSH `ssh-rsa` public-key files are not supported. This project does not
implement JWT parsing, claim validation, TLS, certificate validation, key
management, or a general-purpose encryption protocol.

The wrapper API can load password-protected PEM private keys. The supplied
console program and key-generation scripts intentionally exercise only an
unencrypted, disposable local test key.

## Compatibility

- Compiler: Delphi 7
- Target: Win32
- Runtime ABI: legacy `libeay32.dll`
- Paths and text: ANSI
- Execution model: single-threaded compatibility demo
- Intended environment: an isolated maintenance or migration lab

The current maintained tree does not distribute OpenSSL DLLs, executables,
certificates, or keys. Modern OpenSSL DLLs are not ABI-compatible with this
legacy import unit.

## Repository layout

- `examples/ConsoleDemo/Demo.dpr` — console entry point and runtime self-test
- `src/OpenSslRsaDemo.pas` — independently written compatibility wrapper
- `src/Base64Url.pas` — independently written strict Base64URL codec
- `src/legacy/libeay32.pas` — separately licensed third-party import unit
- `tests/Base64UrlTests.dpr` — portable Pascal tests for the Base64URL codec
- `scripts/` — repository checks and local disposable-key generation
- `docs/` — provenance and migration notes

## Build

### Requirements

- a Windows machine or virtual machine;
- a licensed Delphi 7 installation;
- a trusted 32-bit `libeay32.dll` compatible with the imported ABI;
- an OpenSSL command-line tool for generating disposable local test keys.

Do not obtain legacy cryptographic DLLs from untrusted binary-download sites.
Anyone supplying or redistributing a DLL is responsible for its provenance,
license, vulnerabilities, and integrity.

From a Delphi 7 command prompt at the repository root:

```bat
mkdir build
dcc32 -B -Ebuild examples\ConsoleDemo\Demo.dpr
```

Alternatively, open `examples\ConsoleDemo\Demo.dpr` in the Delphi 7 IDE and
choose **Project > Build**. Place the locally supplied `libeay32.dll` beside
`build\Demo.exe`; both files are intentionally excluded from version control.

## Generate disposable test keys

On Windows:

```bat
scripts\generate-demo-keys.bat
```

On macOS or Linux, for preparing keys to copy into an isolated Windows test
machine:

```sh
./scripts/generate-demo-keys.sh
```

Both scripts write to the ignored `build/test-keys/` directory. These keys are
for a local test run only. Never replace them with production keys and never
commit them.

## Run and verify

```bat
build\Demo.exe build\test-keys\private-key.pem build\test-keys\public-key.pem
```

A successful self-test exits with status `0` after checking:

- the SHA-256 reference vector for `abc`;
- a Base64URL round trip;
- public-key encryption followed by private-key decryption;
- SHA-256 signing followed by public-key verification;
- rejection of a modified message and signature.

RSA PKCS#1 v1.5 encryption accepts at most `modulusBytes - 11` plaintext bytes.
It is not suitable for encrypting files or arbitrary-length messages.

GitHub Actions checks repository hygiene, licensing boundaries, generated
files, and accidental key material.

## Security

Read [SECURITY.md](SECURITY.md) before using the code. Every private key that
has ever appeared in this repository or its Git history must be considered
permanently compromised, even if it was described as a test key or has since
been deleted.

## Roadmap

- [x] Remove committed keys, certificates, executables, DLLs, compiler output,
      and IDE backup files from the maintained tree.
- [x] Replace inherited demo code with an independently written implementation.
- [x] Document provenance, licensing boundaries, and security limitations.
- [ ] Add independently verified RSA interoperability vectors.
- [ ] Create a separate binding for a supported cryptographic backend.
- [ ] Replace PKCS#1 v1.5 encryption with an authenticated hybrid design.
- [ ] Retire the legacy `libeay32` path after downstream users migrate.

See [docs/MIGRATION.md](docs/MIGRATION.md) for the intended modernization path.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). Security-sensitive reports must follow
[SECURITY.md](SECURITY.md) instead of being posted publicly.

## License

Maintainer-authored files are available under the [MIT License](LICENSE). The
MIT License does not relicense third-party or removed historical material.

`src/legacy/libeay32.pas` remains under the separate license reproduced in its
source header. See [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) and
[docs/PROVENANCE.md](docs/PROVENANCE.md) for the exact boundaries.

> This product includes software developed by CSITA - University of Genoa
> (Italy) (http://www.unige.it/)
