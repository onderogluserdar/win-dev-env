@echo off

powershell -NoProfile -ExecutionPolicy bypass -command ". '%~dp0setupdevenv.ps1';Get-DevEnv %*"