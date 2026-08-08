# Third-Party Notices

This file records provenance and licensing boundaries. It is not a replacement
for the license text carried by each component.

The repository-level MIT License applies only to maintainer-authored material.
It does not relicense the components described below.

## `src/legacy/libeay32.pas`

This Delphi import unit for the historical OpenSSL `libeay32` ABI is
copyright (C) 2002-2010, Marco Ferrante. Additional copyright and contribution
notices for CSITA and DISI, University of Genoa, and other contributors remain
in the source-file header.

It is distributed under the following separate four-condition license,
reproduced from that header:

> Redistribution and use in source and binary forms, with or without
> modification, are permitted provided that the following conditions are met:
>
> 1. Redistributions of source code must retain the above copyright notice,
>    this list of conditions and the following disclaimer.
>
> 2. Redistributions in binary form must reproduce the above copyright
>    notice, this list of conditions and the following disclaimer in the
>    documentation and/or other materials provided with the distribution.
>
> 3. All advertising materials mentioning features or use of this software
>    must display the following acknowledgment:
>    "This product includes software developed by CSITA - University of Genoa
>    (Italy) (http://www.unige.it/)"
>
> 4. Redistributions of any form whatsoever must retain the following
>    acknowledgment:
>    "This product includes software developed by the University of Genoa
>    (Italy) (http://www.unige.it/) and its contributors"
>
> THIS SOFTWARE IS PROVIDED BY THE OpenSSL PROJECT ``AS IS'' AND ANY EXPRESSED
> OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
> OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN
> NO EVENT SHALL THE OpenSSL PROJECT OR ITS CONTRIBUTORS BE LIABLE FOR ANY
> DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
> (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
> LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
> ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
> (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
> SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

The repository-level MIT License does not apply to this file.

## OpenSSL runtime

The source imports functions from `libeay32.dll`, but the maintained tree does
not distribute an OpenSSL binary.

A binary formerly stored in repository history identified itself as OpenSSL
0.9.8h. OpenSSL 0.9.8 is covered by the OpenSSL License and Original SSLeay
License and is no longer supported. Its historical license text is available
from the [official OpenSSL source repository](https://github.com/openssl/openssl/blob/OpenSSL_0_9_8-stable/LICENSE).

Anyone redistributing an OpenSSL binary must provide the license and notices
applicable to that exact build. OpenSSL binaries are not covered by this
repository's MIT License.

## Removed historical demo lineage

Earlier revisions included files derived from:

- *RSA via OpenSSL libeay32*, copyright (C) 2015 Ivan Lodyanoy:
  <https://github.com/ddlencemc/RSA-via-OpenSSL-libeay32>
- the Delphi `EncdDecd` implementation distributed with Delphi.

The upstream RSA repository does not publish an explicit repository license,
and Delphi library source is not covered by this repository's MIT License.
Those inherited implementations have been removed from the maintained tree
and replaced. They must not be restored or copied into new contributions
without a valid license grant.
