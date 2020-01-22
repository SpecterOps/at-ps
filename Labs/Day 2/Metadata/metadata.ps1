# import PowerView
Import-Module ..\PowerView.ps1

# Find any users who were added and then deleted from any "privileged" groups
Get-DomainGroupMemberDeleted -LDAPFilter '(admincount=1)'

<#

GroupDN               : CN=Domain Admins,CN=Users,DC=citadel,DC=covertius,DC=local
MemberDN              : CN=fbaker,OU=Marketing,OU=Workstations,DC=citadel,DC=covertius,DC=local
TimeFirstAdded        : 2018-08-01T23:05:43Z
TimeDeleted           : 2018-08-01T23:05:56Z
LastOriginatingChange : 2018-08-01T23:05:56Z
TimesAdded            : 1
LastOriginatingDsaDN  : CN=NTDS Settings,CN=zeus,CN=Servers,CN=Default-First-Site-Name,CN=Sites,CN=Configuration,DC=covertius,DC=local

#>



# Find any user in the forest that may have been a subject to "targeted kerberoasting"

# correct-
Get-DomainObjectAttributeHistory -LDAPFilter '(&(samAccountType=805306368)(!(serviceprincipalname=*)))' -Properties servicePrincipalName -SearchBase "GC://$($ENV:USERDNSDOMAIN)"

<#
ObjectDN              : CN=jsimmons,OU=Marketing,OU=Workstations,DC=citadel,DC=covertius,DC=local
AttributeName         : servicePrincipalName
LastOriginatingChange : 2018-08-01T23:05:01Z
Version               : 2
LastOriginatingDsaDN  : CN=NTDS Settings,CN=zeus,CN=Servers,CN=Default-First-Site-Name,CN=Sites,CN=Configuration,DC=covertius,DC=local
#>



# Find the last time the ACLs on the AdminSDHolder object were modified in citadel.covertius.local
$AdminSDHolder = Get-DomainObjectAttributeHistory 'CN=AdminSDHolder,CN=System,DC=citadel,DC=covertius,DC=local' | ? {$_.AttributeName -eq 'ntsecuritydescriptor'}
$AdminSDHolder

<#
ObjectDN              : CN=AdminSDHolder,CN=System,DC=citadel,DC=covertius,DC=local
AttributeName         : nTSecurityDescriptor
LastOriginatingChange : 2018-08-01T23:05:06Z
Version               : 2
LastOriginatingDsaDN  : CN=NTDS Settings,CN=zeus,CN=Servers,CN=Default-First-Site-Name,CN=Sites,CN=Configuration,DC=covertius,DC=local
#>



# map the LastOriginatingDsaDN to a domain controller (ZEUS)
Get-DomainObject -LDAPFilter "(serverreference=$($AdminSDHolder.LastOriginatingDsaDN))" | %{ Get-DomainObject $_."msdfsr-computerreference" } | Select -Expand dnshostname

<#
zeus.citadel.covertius.local
#>
