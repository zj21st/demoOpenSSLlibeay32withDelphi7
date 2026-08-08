@rem SPDX-License-Identifier: MIT
@echo off
setlocal

where openssl >nul 2>nul
if errorlevel 1 (
  echo OpenSSL CLI was not found in PATH.
  exit /b 1
)

set "KEY_DIR=%~1"
if "%KEY_DIR%"=="" set "KEY_DIR=%~dp0..\build\test-keys"

if not exist "%KEY_DIR%" (
  mkdir "%KEY_DIR%"
  if errorlevel 1 exit /b 1
)

if exist "%KEY_DIR%\private-key.pem" (
  echo Refusing to overwrite an existing private key in: %KEY_DIR%
  exit /b 1
)
if exist "%KEY_DIR%\public-key.pem" (
  echo Refusing to overwrite an existing public key in: %KEY_DIR%
  exit /b 1
)

openssl genrsa -help 2>&1 | findstr /C:"-traditional" >nul
if errorlevel 1 (
  openssl genrsa -out "%KEY_DIR%\private-key.pem" 2048
) else (
  openssl genrsa -traditional -out "%KEY_DIR%\private-key.pem" 2048
)
if errorlevel 1 exit /b 1

openssl rsa -in "%KEY_DIR%\private-key.pem" -pubout -out "%KEY_DIR%\public-key.pem"
if errorlevel 1 exit /b 1

echo Generated disposable demo keys in: %KEY_DIR%
echo Never commit or reuse these keys in a real system.
