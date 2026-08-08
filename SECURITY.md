# Security Policy

## Project status

This repository is a historical compatibility and migration aid. No revision
is supported for production cryptographic use.

| Version or branch | Security status |
| --- | --- |
| Current default branch | Best-effort maintenance; isolated lab use only |
| Historical revisions and binaries | Unsupported |
| OpenSSL 0.9.x runtime | End of life and unsupported |

## Known limitations

The compatibility path depends on the obsolete pre-1.1 OpenSSL ABI. Its design
also includes RSA PKCS#1 v1.5 encryption, ANSI paths and strings, and Delphi 7
memory semantics. It is deliberately single-threaded because the demo does not
install the locking callbacks required by historical OpenSSL versions.

The project has not received a professional security audit. Passing repository
hygiene checks is not evidence that the cryptographic implementation is
suitable for production.

Use a supported operating-system or maintained cryptographic API for new
software.

## Historical key exposure

Earlier repository revisions contained unencrypted private keys,
certificates, an SSH private key, and private-key material embedded in source
code.

Every such key must be treated as permanently compromised. Deleting it from
the current branch does not make it secret again. If any historical key was
ever used outside a disposable test environment, revoke or rotate it
immediately and review the associated service for unauthorized use.

Never report a live credential by placing it in an issue, pull request, test
fixture, or log.

## Reporting a vulnerability

Use [GitHub private vulnerability reporting](https://github.com/zj21st/demoOpenSSLlibeay32withDelphi7/security/advisories/new).
Do not substitute a public issue when a report contains sensitive details.

Include:

- the affected file or revision;
- a concise description of the impact;
- reproduction steps or a minimal proof of concept;
- any suggested remediation;
- whether public disclosure has already occurred.

Do not include real private keys, credentials, personal data, or production
payloads.

Reports are handled on a best-effort basis. The maintainer may coordinate a
fix, documentation update, advisory, or removal of unsafe material depending
on the impact. There is no production-support or response-time guarantee.
