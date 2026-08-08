# RSA and OpenSSL Integration for Delphi 7

A lightweight Delphi 7 example demonstrating how to use OpenSSL (`libeay32.dll`)
for RSA cryptography, message digests, and digital signatures.

This project was originally created to provide a practical reference for Delphi 7
developers who need to integrate OpenSSL-based cryptographic operations into
existing applications.

Although Delphi 7 is a legacy development environment, a considerable amount of
business and industrial software built with it is still in use today. This
repository is intended to help developers maintain and integrate those systems
with cryptographic protocols and external services.

## Features

The project demonstrates:

- RSA public-key encryption
- RSA private-key decryption
- RSA private-key operations
- RSA public-key verification operations
- SHA-1 hashing
- SHA-256 hashing
- SHA-512 hashing
- SHA1withRSA signatures
- SHA256withRSA signatures
- SHA512withRSA signatures
- RSA signing scenarios used by JWT and similar protocols
- Loading RSA public and private keys from PEM files
- Calling OpenSSL functionality from Delphi 7

## Why This Project Exists

Modern programming languages usually provide mature cryptographic libraries and
package managers. Delphi 7 predates most of these ecosystems, which makes
integration with modern cryptographic systems considerably more difficult.

Many legacy Delphi applications still need to communicate with systems that use:

- RSA public/private key cryptography
- SHA-256 or SHA-512 digests
- RSA digital signatures
- JWT-style authentication
- HTTPS/API authentication mechanisms
- Third-party services requiring OpenSSL-compatible signatures

This repository provides working Delphi source code that developers can study,
adapt, and use when maintaining such applications.

The goal of the project is not to introduce a new cryptographic algorithm, but
to preserve practical interoperability knowledge for the legacy Delphi
ecosystem.

## Technology

- Delphi 7
- Object Pascal
- OpenSSL
- `libeay32.dll`
- RSA
- SHA-1 / SHA-256 / SHA-512

## Example

The demo application creates an OpenSSL RSA helper using a public and private
key:

```pascal
var
  RSAOpenSSL: TRSAOpenSSL;
begin
  RSAOpenSSL := TRSAOpenSSL.Create(
    '1public.pem',
    'pro22.pem'
  );
end;
