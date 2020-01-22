function Get-ModifiablePath {
    [CmdletBinding()]
    param()

    function Test-ModifiablePath {
        [CmdletBinding()]
        Param(
            [Parameter(Position = 0, Mandatory = $True, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
            [Alias('FullName')]
            [String]
            $Path
        )

        BEGIN {
            # the permissions we care about (those that will allow modification of files in the target folder)
            $ModifiableRights = @('ChangePermissions', 'CreateFiles', 'FullControl', 'Modify', 'TakeOwnership', 'Write', 'WriteData')
            # this is used to cast the above modifiable rights to a comparable class
            $Type = [Security.AccessControl.FileSystemRights]
        }

        PROCESS {
            try {
                # use a try/catch because of the weird behavior of Get-ACL
                $DirectoryAcl = Get-Acl -Path $Path -ErrorAction Stop

                $DirectoryProperties = @{'Path' = $Path}

                ForEach ($Access in $DirectoryAcl.Access) {
                    $Include = $False
                    # check for the target user identities and 'Allow'
                    if ( ($Access.IdentityReference -match 'NT AUTHORITY\\Authenticated Users|BUILTIN\\Users|Everyone') -and ($Access.AccessControlType -eq 'Allow') ) {
                        ForEach ($ModifiableRight in $ModifiableRights) {
                            # cast the right as [Security.AccessControl.FileSystemRights]
                            $Right = $ModifiableRight -as $Type
                            # check if any of the modifiable rights are present
                            if (($Access.FileSystemRights -band $Right) -eq $Right) {
                                $Include = $True
                            }
                        }
                        if ($Include) {
                            # if the coditions were set, include the access rule in the object
                            $DirectoryProperties['Access'] += @($Access)
                        }
                    }
                }

                if ($DirectoryProperties['Access']) {
                    # create an output object if there were proper results
                    New-Object -TypeName PSObject -Property $DirectoryProperties
                }
            }
            catch {
                Write-Verbose "Error retrieving ACL for: $Path"
            }
        }
    }

    # check all folders in %PATH%
    $ENV:Path -split ';' | Where-Object { $_ -and (Test-Path ([Environment]::ExpandEnvironmentVariables($_))) } | Test-ModifiablePath

    # check all directories in C:\Windows\System32\ (note using $ENV:windir)
    Get-ChildItem -Directory "$ENV:windir\System32\" -Recurse -ErrorAction SilentlyContinue | Test-ModifiablePath
}
