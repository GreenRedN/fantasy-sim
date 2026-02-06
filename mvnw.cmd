@ECHO OFF
SETLOCAL

SET "BASE_DIR=%~dp0"
SET "WRAPPER_DIR=%BASE_DIR%.mvn\wrapper"
SET "MVN_VERSION=3.9.6"
SET "MVN_DIST=apache-maven-%MVN_VERSION%"
SET "MVN_HOME=%WRAPPER_DIR%\%MVN_DIST%"
SET "MVN_BIN=%MVN_HOME%\bin\mvn.cmd"

IF EXIST "%MVN_BIN%" GOTO RUN

IF NOT EXIST "%WRAPPER_DIR%" MKDIR "%WRAPPER_DIR%"
SET "URL=https://archive.apache.org/dist/maven/maven-3/%MVN_VERSION%/binaries/%MVN_DIST%-bin.zip"
ECHO [mvnw] Downloading Maven %MVN_VERSION% ...

REM Use PowerShell to download + unzip
powershell -NoProfile -ExecutionPolicy Bypass -Command "^$
  $ProgressPreference = 'SilentlyContinue';
  $url = '%URL%';
  $zip = Join-Path '%WRAPPER_DIR%' ('%MVN_DIST%-bin.zip');
  Invoke-WebRequest -Uri $url -OutFile $zip;
  Expand-Archive -Path $zip -DestinationPath '%WRAPPER_DIR%' -Force;
  Remove-Item $zip -Force;
" 

:RUN
CALL "%MVN_BIN%" %*
ENDLOCAL
