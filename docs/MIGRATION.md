# Migration from the legacy `libeay32` path

The current demo exists to help identify and test old integration behavior
while a system is being migrated. It is not the desired end state.

## Legacy baseline

The compatibility layer assumes the pre-1.1 `libeay32` ABI and low-level RSA
operations. The DLL once stored in this repository identified itself as
OpenSSL 0.9.8h. That line has been unsupported for many years, and modern
OpenSSL releases are not binary-compatible with this import unit.

The example also demonstrates PKCS#1 v1.5 RSA encryption and
RSASSA-PKCS1-v1_5 signatures. These choices may be required to reproduce an
existing protocol, but they should not define a new protocol.

## Recommended migration sequence

1. **Inventory the existing protocol.** Record key formats, byte encodings,
   hash and padding choices, message-size limits, and the exact OpenSSL binary
   in use. Do not infer these from filenames.
2. **Create independent interoperability vectors.** Capture non-secret test
   messages, expected hashes, signatures, and ciphertext behavior with
   disposable keys. Exercise failure cases as well as success cases.
3. **Isolate the legacy boundary.** Keep the old ABI behind a narrow adapter so
   application code no longer imports `libeay32.pas` directly.
4. **Add a supported backend.** Prefer a maintained operating-system API or a
   supported OpenSSL release through its high-level EVP interfaces. OpenSSL 3
   deprecates the low-level RSA APIs used by historical code.
5. **Upgrade the protocol where both endpoints permit it.** Prefer an
   authenticated hybrid-encryption design instead of direct RSA encryption,
   and use an approved modern signature scheme. Treat any protocol change as
   a versioned interoperability change.
6. **Run both paths against the same vectors.** Account explicitly for
   character encoding, line endings, Base64URL padding, and key-container
   differences.
7. **Remove the legacy runtime.** Delete the old DLL and adapter after all
   callers have migrated, then rotate keys if the migration exposed or
   transformed them.

## OpenSSL references

- [OpenSSL 3.0 migration guide](https://docs.openssl.org/3.0/man7/migration_guide/)
- [OpenSSL `RSA_public_encrypt` documentation and deprecation notice](https://docs.openssl.org/3.0/man3/RSA_public_encrypt/)
- [OpenSSL release strategy](https://openssl-library.org/policies/releasestrat/)

These references describe modern OpenSSL, not an assurance that the legacy
binding in this repository is safe or ABI-compatible with a current release.
