New-PSRoleCapabilityFile -Path .\VulnJEAEndpoint.psrc
# Manually edit the role capability file now

New-PSSessionConfigurationFile -SessionType RestrictedRemoteServer -Path VulnJEAEndpoint.pssc
# Manually edit the session config now

# Place the JEA module intoyou module path now
# Test-PSSessionConfigurationFile should return true.
Test-PSSessionConfigurationFile -Path .\VulnJEAEndpoint.pssc

# Perform the following from an elevated prompt:
Register-PSSessionConfiguration -Path .\VulnJEAEndpoint.pssc -Name 'VulnJEAEndpoint' -Force

# Verify it was registered
Get-PSSessionConfiguration -Name VulnJEAEndpoint

# Connect to your JEA session
$JEASession = New-PSSession -ComputerName localhost -ConfigurationName VulnJEAEndpoint
$JEASession | Enter-PSSession
