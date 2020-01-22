# import PowerView
Import-Module ..\PowerView.ps1

# GPO misconfiguration enumeration
#   CITADEL\wschroeder has edit rights over "Default Domain Controllers Policy" in COVERTIUS
#   COVERTIUS\breitz has edit rights over "EastGPO" in COVERTIUS
Get-DomainObjectAcl -Domain 'covertius.local' -LDAPFilter '(objectCategory=groupPolicyContainer)' -ResolveGUIDs | ? {
    ($_.SecurityIdentifier -match '^S-1-5-.*-[1-9]\d{3,}$') -and `
    ($_.ActiveDirectoryRights -match 'WriteProperty|GenericAll|GenericWrite|WriteDacl|WriteOwner')
} | % {
    $PrincipalDN = Convert-ADName $_.SecurityIdentifier -OutputType DN
    New-Object PSObject -Property @{'ObjectDN'=$_.ObjectDN ; 'PrincipalSID'=$_.SecurityIdentifier; 'PrincipalDN'=$PrincipalDN }
} | fl


<#
PrincipalDN  : CN=wschroeder,OU=Security,OU=Operations,OU=Workstations,DC=citadel,DC=covertius,DC=local
PrincipalSID : S-1-5-21-3139859357-4265752099-2828883278-1156
ObjectDN     : CN={6AC1786C-016F-11D2-945F-00C04fB984F9},CN=Policies,CN=System,DC=covertius,DC=local

PrincipalDN  : CN=breitz,OU=IT,OU=Workstations,OU=DC,OU=East,DC=covertius,DC=local
PrincipalSID : S-1-5-21-819686047-643177524-144419956-1107
ObjectDN     : CN={A9B46C7F-F61C-4E38-A443-FC5551417069},CN=Policies,CN=System,DC=covertius,DC=local
#>


# other misconfigurations


# CITADEL\wschroeder -> DCSync rights for citadel.covertius.local
Get-DomainObjectAcl "DC=citadel,DC=covertius,DC=local" -ResolveGUIDs | ? {($_.ObjectAceType -match 'replication-get') -and ($_.SecurityIdentifier -match '^S-1-5-.*-[1-9]\d{3,}$')} | %{ConvertFrom-SID $_.SecurityIdentifier}

# CITADEL\arobbins -> GenericAll on the 'ServerAdmins' group in citadel.covertius.local
$User = Get-DomainObjectAcl -LDAPFilter '(objectclass=group)' -ResolveGUIDs | ? {($_.SecurityIdentifier -match '^S-1-5-.*-[1-9]\d{3,}$') -and ($_.ActiveDirectoryRights -match 'WriteProperty|GenericAll|GenericWrite|WriteDacl|WriteOwner')}
$User
ConvertFrom-SID $User.SecurityIdentifier

# CITADEL\jdimmock -> has User-Force-Change-Password to AdminSDHolder in citadel.covertius.local
Get-DomainObjectACL -ResolveGUIDs | ? {$_.ObjectAceType -match 'User-Force-Change-Password'}
Get-DomainObjectACL "CN=AdminSDHolder,CN=System,DC=citadel,DC=covertius,DC=local" -ResolveGUIDs | ? {$_.ObjectAceType -match 'User-Force-Change-Password'}
# Then use ConvertFrom-SID again

# COVERTIUS\mnelson -> DCSync rights for covertius.local
Get-DomainObjectAcl "DC=covertius,DC=local" -ResolveGUIDs  | ? {($_.ObjectAceType -match 'replication-get') -and ($_.SecurityIdentifier -match '^S-1-5-.*-[1-9]\d{3,}$')} | %{ConvertFrom-SID $_.SecurityIdentifier}
