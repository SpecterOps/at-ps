# import PowerView
Import-Module ..\PowerView.ps1

# Find all users that have some type of constrained delegation set
#   create a DirectorySearcher object using the [adsisearcher] type accelerator with the msds-allowedtodelegateto=* filter
#       this means the account is set for constrained delegation
#       If we want to be more accurate, we could use a filter of '(&(sAMAccountType=805306368)(msds-allowedtodelegateto=*))'
#   Then we extract out the samaccountname property from the 'Properties' property for each object returned by FindAll()
([adsisearcher]'(msds-allowedtodelegateto=*)').FindAll() | %{$_.Properties.samaccountname}

<#
backupldap
#>

# Find all universal groups in covertius.local
#   first we have to bind to the foreign domain (DC=covertius,DC=local)
#   then we set the filter to be for group type Universal - this uses a binary LDAP filter
#   finally we return just the distinguished names from all the results
$Searcher = [ADSISearcher][ADSI]'LDAP://DC=covertius,DC=local'
$Searcher.Filter = '(groupType:1.2.840.113556.1.4.803:=8)'
$Searcher.FindAll() | %{$_.Properties.distinguishedname}

<#
CN=Schema Admins,CN=Users,DC=covertius,DC=local
CN=Enterprise Admins,CN=Users,DC=covertius,DC=local
CN=Enterprise Read-only Domain Controllers,CN=Users,DC=covertius,DC=local
CN=Contractors,OU=DC,OU=East,DC=covertius,DC=local
CN=C_Level,OU=Corporate,DC=covertius,DC=local
CN=MachineAdmins,OU=Seattle,OU=West,DC=covertius,DC=local
CN=Marketing,OU=Austin,OU=South,DC=covertius,DC=local
#>


# Find all users with Kerberos pre-authentication not enabled, returning display names
#   for this, we need to use another binary LDAP filter to search for the specific UAC property
([adsisearcher]'(userAccountControl:1.2.840.113556.1.4.803:=4194304)').FindAll() | %{"$($_.Properties.name),$($_.Properties.description)"}

<#
unixinteg,unix integration
#>

# Find all kerberoast-able accounts in the forest (users with "serviceprincipalname set), returning SPN and distinguished name
$Searcher = [ADSISearcher][ADSI]"GC://covertius.local"
$Searcher.Filter = '(&(sAMAccountType=805306368)(servicePrincipalName=*))'
$Searcher.PropertiesToLoad.AddRange(('distinguishedname', 'serviceprincipalname'))
$Searcher.FindAll() | %{"$($_.Properties.distinguishedname)`t`t$($_.Properties.serviceprincipalname)"}

<#
CN=krbtgt,CN=Users,DC=citadel,DC=covertius,DC=local		kadmin/changepw
CN=sqlsvc,OU=SQL,OU=Servers,DC=citadel,DC=covertius,DC=local		MSSQL/DIONYSUS.citadel.covertius.local
CN=scanservice,OU=Servers,DC=citadel,DC=covertius,DC=local		WSMAN/EXSRV01.citadel.covertius.local
CN=backupldap,OU=Servers,DC=citadel,DC=covertius,DC=local		backup/zeus.citadel.covertius.local
CN=krbtgt,CN=Users,DC=covertius,DC=local		kadmin/changepw
#>


# Find all "privileged" users in the forest (distinguished names)
([adsisearcher]'(admincount=1)').FindAll() | %{$_.Properties.distinguishedname}

<#
CN=Administrators,CN=Builtin,DC=citadel,DC=covertius,DC=local
CN=Print Operators,CN=Builtin,DC=citadel,DC=covertius,DC=local
CN=Backup Operators,CN=Builtin,DC=citadel,DC=covertius,DC=local
CN=Replicator,CN=Builtin,DC=citadel,DC=covertius,DC=local
CN=Server Operators,CN=Builtin,DC=citadel,DC=covertius,DC=local
CN=Account Operators,CN=Builtin,DC=citadel,DC=covertius,DC=local
CN=localadmin,CN=Users,DC=citadel,DC=covertius,DC=local
CN=krbtgt,CN=Users,DC=citadel,DC=covertius,DC=local
CN=Domain Controllers,CN=Users,DC=citadel,DC=covertius,DC=local
CN=Domain Admins,CN=Users,DC=citadel,DC=covertius,DC=local
CN=Read-only Domain Controllers,CN=Users,DC=citadel,DC=covertius,DC=local
CN=wschroeder_da,OU=Security,OU=Operations,OU=Workstations,DC=citadel,DC=covertius,DC=local
CN=arobbins_da,OU=IT,OU=Operations,OU=Workstations,DC=citadel,DC=covertius,DC=local
#>