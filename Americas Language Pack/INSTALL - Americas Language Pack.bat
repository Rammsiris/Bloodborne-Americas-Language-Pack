@echo off
rem Americas Language Pack v1.1 - Created by Rammsiris - Game Developer
rem Starts the installer, Americas_Language_Pack.ps1 (same folder),
rem with the PowerShell that comes with Windows. The path is escaped so
rem folders with [ ] in their names work too (plain path as a fallback).
setlocal
title Americas Language Pack v1.1
set "ALP_SCRIPT=%~dp0Americas_Language_Pack.ps1"
if not exist "%ALP_SCRIPT%" goto missing
"%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe" -NoProfile -ExecutionPolicy Bypass -Command "try { & ([WildcardPattern]::Escape($env:ALP_SCRIPT)) } catch [Management.Automation.CommandNotFoundException] { & $env:ALP_SCRIPT }"
if errorlevel 1 pause
exit /b

:missing
echo.
echo   Americas_Language_Pack.ps1 is missing from this folder.
echo   Extract the whole zip first. If you did, your antivirus probably
echo   put it in quarantine: see ANTIVIRUS in README.txt.
echo.
echo   Falta Americas_Language_Pack.ps1 en esta carpeta.
echo   Primero extrae todo el zip. Si ya lo hiciste, seguramente tu
echo   antivirus lo puso en cuarentena: lee ANTIVIRUS en el README.txt.
echo.
pause
