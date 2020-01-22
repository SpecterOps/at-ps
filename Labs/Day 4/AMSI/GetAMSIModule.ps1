function Get-AmsiModule {
<#
.SYNOPSIS

Retrieves information about AMSI and each registered AMSI provider.

.DESCRIPTION

Get-AmsiModule retrieves information about AMSI and registered AMSI providers. This is useful for defenders auditing the consistency of AMSI utilization across an environment.

Author: Matthew Graeber (@mattifestation)
License: BSD 3-Clause

.EXAMPLE

Get-AmsiModule

.OUTPUTS

AMSI.ModuleInfo

Outputs objects representing information about AMSI itself as well as each registered AMSI provider.

.NOTES

Get-AmsiModule only returns AMSI registrations that correspond to the architecture of the current PowerShell process. To return WOW64 registrations, run 32-bit PowerShell, if desired.
#>

    [CmdletBinding()]
    param()
    
    try {
        # Require PSv3+ due to use of Get-ItemPropertyValue.
        # This could be supported for PSv2 but why???
        Set-StrictMode -Version 3
    } catch {
        # A .NET exception is thrown here instead of a PowerShell error.
        throw $_
        return
    }

    $AmsiUtilsType = [PSObject].Assembly.GetType('System.Management.Automation.AmsiUtils')

    if ($AmsiUtilsType) {
        $IsInitialized = $AmsiUtilsType.GetField('AmsiInitialized').GetValue($null) > $null

        if (-not $IsInitialized) {
            Write-Verbose "AMSI is not initialized in the current process. Process ID: $PID"
        }
    } else {
        Write-Verbose 'The System.Management.Automation.AmsiUtils class is not present.'
    }

    # Get information for the base AMSI implementation
    # This could have been determined by searching the registry, reversing amsi.dll, or reading Matt Nelson's blog post:
    # https://enigma0x3.net/2017/07/19/bypassing-amsi-via-com-server-hijacking/
    $AMSIGuid = '{fdb00e52-a214-4aa1-8fba-4357bb0072ec}'

    # Note the registry path syntax. This avoids having to create a custom PSDrive.
    $AMSIHKCRPath = "Registry::HKEY_CLASSES_ROOT\CLSID\$AMSIGuid"

    $AMSIName = Get-ItemPropertyValue -Path $AMSIHKCRPath -Name '(default)'
    $AMSIPath = Get-ItemPropertyValue -Path "$AMSIHKCRPath\InprocServer32\" -Name '(default)'

    $AMSIFileInfo = Get-Item -Path $AMSIPath.Trim('"')
    $AMSISignature = Get-AuthenticodeSignature -FilePath $AMSIFileInfo.FullName

    [PSCustomObject] @{
        PSTypeName = 'AMSI.ModuleInfo'
        CLSID = [Guid] $AMSIGuid
        Name = $AMSIName
        Module = $AMSIFileInfo
        Signature = $AMSISignature
    }

    # Enumerate every registered AMSI provider
    # For example, Windows Defender will have a unique registration versus other AV vendors that support AMSI (like AVG).
    Get-ChildItem -Path HKLM:\Software\Microsoft\AMSI\Providers -ErrorAction SilentlyContinue | ForEach-Object {
        $ProviderGuid = $_.PSChildName

        $HKCRPath = "Registry::HKEY_CLASSES_ROOT\CLSID\$ProviderGuid"

        $ProviderName = Get-ItemPropertyValue -Path $HKCRPath -Name '(default)'
        $ProviderPath = Get-ItemPropertyValue -Path "$HKCRPath\InprocServer32\" -Name '(default)'

        $AMSIProviderModule = Get-Item -Path $ProviderPath.Trim('"')

        $ProviderSignature = Get-AuthenticodeSignature -FilePath $AMSIProviderModule.FullName

        [PSCustomObject] @{
            PSTypeName = 'AMSI.ModuleInfo'
            CLSID = [Guid] $ProviderGuid
            Name = $ProviderName
            Module = $AMSIProviderModule
            Signature = $ProviderSignature
        }
    }
}