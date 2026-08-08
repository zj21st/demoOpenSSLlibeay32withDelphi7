#!/usr/bin/env python3
# SPDX-License-Identifier: MIT
"""Fail when the maintained tree regresses on repository hygiene."""

from __future__ import annotations

import re
import subprocess
import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
HAN_CHARACTERS = re.compile(r"[\u3400-\u4dbf\u4e00-\u9fff\uf900-\ufaff]")

REQUIRED_FILES = {
    ".github/workflows/repository-hygiene.yml",
    ".gitignore",
    "CONTRIBUTING.md",
    "LICENSE",
    "MAINTAINERS.md",
    "README.md",
    "SECURITY.md",
    "THIRD_PARTY_NOTICES.md",
    "docs/MIGRATION.md",
    "docs/PROVENANCE.md",
    "examples/ConsoleDemo/Demo.dpr",
    "scripts/check_repository.py",
    "scripts/generate-demo-keys.bat",
    "scripts/generate-demo-keys.sh",
    "src/Base64Url.pas",
    "src/OpenSslRsaDemo.pas",
    "src/legacy/libeay32.pas",
    "tests/Base64UrlTests.dpr",
}

BLOCKED_SUFFIXES = {
    ".cer",
    ".cfg",
    ".crt",
    ".dcu",
    ".ddp",
    ".dll",
    ".dof",
    ".dcp",
    ".dsk",
    ".exe",
    ".identcache",
    ".key",
    ".local",
    ".map",
    ".obj",
    ".o",
    ".p12",
    ".pem",
    ".pfx",
    ".ppu",
    ".pyc",
    ".res",
    ".rsm",
    ".tds",
    ".tvsconfig",
    ".bpl",
    ".compiled",
}

BLOCKED_BASENAMES = {
    "id_dsa",
    "id_dsa.pub",
    "id_ecdsa",
    "id_ecdsa.pub",
    "id_ed25519",
    "id_ed25519.pub",
    "id_rsa",
    "id_rsa.pub",
}

REMOVED_LINEAGE_FILES = {
    "EncdDecd_suman.pas",
    "RSAOpenSSL.pas",
    "RSAUtil.dpr",
    "Unit1.dfm",
    "Unit1.pas",
}

MIT_MARKED_FILES = {
    ".github/workflows/repository-hygiene.yml",
    "examples/ConsoleDemo/Demo.dpr",
    "scripts/check_repository.py",
    "scripts/generate-demo-keys.bat",
    "scripts/generate-demo-keys.sh",
    "src/Base64Url.pas",
    "src/OpenSslRsaDemo.pas",
    "tests/Base64UrlTests.dpr",
}


def maintained_files() -> list[str]:
    result = subprocess.run(
        [
            "git",
            "ls-files",
            "--cached",
            "--others",
            "--exclude-standard",
            "-z",
        ],
        cwd=ROOT,
        check=True,
        capture_output=True,
    )
    return sorted(
        item.decode("utf-8") for item in result.stdout.split(b"\0") if item
    )


def fail(message: str) -> None:
    print(f"ERROR: {message}", file=sys.stderr)


def main() -> int:
    files = maintained_files()
    file_set = set(files)
    errors = 0

    for required in sorted(REQUIRED_FILES - file_set):
        fail(f"required repository file is missing: {required}")
        errors += 1

    for path_text in files:
        path = Path(path_text)
        lower_name = path.name.lower()
        lower_suffix = path.suffix.lower()

        if lower_name in BLOCKED_BASENAMES:
            fail(f"private-key filename is tracked: {path_text}")
            errors += 1
        if lower_suffix in BLOCKED_SUFFIXES:
            fail(f"generated, binary, key, or certificate file is tracked: {path_text}")
            errors += 1
        if path.name.startswith(".~") or ".~" in path.name:
            fail(f"IDE backup file is tracked: {path_text}")
            errors += 1
        if path.name in REMOVED_LINEAGE_FILES:
            fail(f"removed inherited implementation returned: {path_text}")
            errors += 1
        if "__pycache__" in path.parts:
            fail(f"Python cache directory is tracked: {path_text}")
            errors += 1

        full_path = ROOT / path
        try:
            content = full_path.read_bytes()
        except OSError as exc:
            fail(f"cannot read {path_text}: {exc}")
            errors += 1
            continue

        try:
            text_content = content.decode("utf-8")
        except UnicodeDecodeError:
            if path_text == "src/legacy/libeay32.pas":
                text_content = content.decode("latin-1")
            else:
                fail(f"maintainer-authored text is not valid UTF-8: {path_text}")
                errors += 1
                text_content = ""

        if HAN_CHARACTERS.search(text_content):
            fail(f"non-English Han characters were found: {path_text}")
            errors += 1

        private_key_marker = b"-----BEGIN " + b"PRIVATE KEY-----"
        encrypted_private_key_marker = (
            b"-----BEGIN " + b"ENCRYPTED PRIVATE KEY-----"
        )
        pgp_private_key_marker = (
            b"-----BEGIN PGP " + b"PRIVATE KEY BLOCK-----"
        )
        typed_private_key = re.compile(
            rb"-----BEGIN (?:RSA |EC |DSA |OPENSSH )PRIVATE KEY-----"
        )
        if (
            private_key_marker in content
            or encrypted_private_key_marker in content
            or pgp_private_key_marker in content
            or typed_private_key.search(content)
        ):
            fail(f"embedded private-key material was found: {path_text}")
            errors += 1

    for source in sorted(MIT_MARKED_FILES):
        if source not in file_set:
            fail(f"maintainer-authored file is missing: {source}")
            errors += 1
            continue
        first_lines = (ROOT / source).read_text(
            encoding="utf-8", errors="strict"
        ).splitlines()[:5]
        if not any("SPDX-License-Identifier: MIT" in line for line in first_lines):
            fail(f"MIT file lacks an SPDX header: {source}")
            errors += 1

    vendor = ROOT / "src/legacy/libeay32.pas"
    if vendor.is_file():
        vendor_text = vendor.read_text(encoding="latin-1")
        for marker in (
            "Copyright (C) 2002-2010, Marco Ferrante",
            "Redistribution and use in source and binary forms",
            "This product includes software developed by CSITA - University",
            "of Genoa (Italy) (http://www.unige.it/)",
        ):
            if marker not in vendor_text:
                fail(f"vendor license marker is missing: {marker}")
                errors += 1
    else:
        fail("separately licensed vendor import unit is missing")
        errors += 1

    if errors:
        print(f"Repository hygiene failed with {errors} error(s).", file=sys.stderr)
        return 1

    print(f"Repository hygiene passed for {len(files)} maintained file(s).")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
