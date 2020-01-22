# import PowerView
Import-Module ..\PowerView.ps1


# domain Kerberos settings
$Settings = Get-DomainPolicyData -Policy 'Domain'
$Settings.KerberosPolicy

<#
10 hours
#>

# who has SeEnableDelegationPrivilege
$Settings = Get-DomainPolicyData -Policy 'DomainController'
$Settings.PrivilegeRights

<#
*S-1-5-32-544, wschroeder
#>

# what GPOs are applied to the CITADEL domain controller
$DomainController = (Get-DomainController).Name
Get-DomainGPO -ComputerIdentity $DomainController

<#
Default Domain Controllers Policy
Default Domain Policy
#>

# Enumerate what GPOs set "interesting settings"


# enumerate all GptTmpl.inf settings for GPOs in the domain
Get-DomainGPO | Get-DomainPolicyData


# Find any GPOs that modify local group memberships through GPOs
Get-DomainGPOLocalGroup


# to find what machines an "interesting" GPO applies to:
Get-DomainGPO WorkstationGPO | %{Get-DomainOU -GPLink $_.Name} | % {Get-DomainComputer -SearchBase $_.distinguishedname -Properties dnshostname}
Get-DomainGPO ServerGPO | %{Get-DomainOU -GPLink $_.Name} | % {Get-DomainComputer -SearchBase $_.distinguishedname -Properties dnshostname}
