# import PowerView
Import-Module ..\PowerView.ps1

# enumerate all domain trusts (LDAP method is the default)
Get-DomainTrust

# enumerate all domain trusts w/ .NET methods
Get-DomainTrust -NET

# enumerate all domain trusts w/ API methods
Get-DomainTrust -API

# enumerate forest trusts
Get-ForestTrust

# enumerate trusts for covertius.local
Get-DomainTrust -Domain covertius.local



# the trust types enumerated are:
#   citadel.covertius.local <-> covertius.local (within_forest/parent_child)
#   covertius.local <-> cyberpartners.local (inter-forest)


# reveals that CITADEL\bharris_a is a member of COVERTIUS\MachineAdmins
Get-DomainForeignUser
Get-DomainForeignGroupMember -Domain covertius.local

<#
GroupDomain             : covertius.local
GroupName               : MachineAdmins
GroupDistinguishedName  : CN=MachineAdmins,OU=Seattle,OU=West,DC=covertius,DC=local
MemberDomain            : citadel.covertius.local
MemberName              : bharris_a
MemberDistinguishedName : CN=bharris_a,OU=IT,OU=Operations,OU=Workstations,DC=citadel,DC=covertius,DC=local
#>


# reveals that COVERTIUS\mnelson and COVERTIUS\sryan are members of CYBERPARTNERS\WorkstationAdmins
# reveals that COVERTIUS\breitz is a member of CYBERPARTNERS\DesktopAdmins
Get-DomainForeignGroupMember -Domain cyberpartners.local | %{ $_ | Add-Member Noteproperty 'ResolvedSID' $(ConvertFrom-SID $_.MemberName); $_}
