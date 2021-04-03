@echo off

rem Cf. C:/shells/msys2bash.cmd, but without BOM, from
rem https://github.com/actions/virtual-environments/blob/main/images/win/scripts/Installers/Configure-Shell.ps1

setlocal
IF NOT DEFINED MSYS2_PATH_TYPE set MSYS2_PATH_TYPE=strict
IF NOT DEFINED MSYSTEM set MSYSTEM=mingw64
set CHERE_INVOKING=1
C:\msys64\usr\bin\bash.exe -leo pipefail %*
