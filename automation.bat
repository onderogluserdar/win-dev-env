@echo off

powershell -NoProfile -ExecutionPolicy bypass -command ". '%~dp0automation.ps1';init %*"