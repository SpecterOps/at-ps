#region Creation of a self-signed code signing certificate
$Arguments = @{    
    Subject = 'CN=My Self-signed Code Signing'
    Type = 'CodeSigningCert'    
    KeySpec = 'Signature'     
    KeyUsage = 'DigitalSignature'    
    FriendlyName = 'My Self-signed Code Signing'    
    NotAfter = ((Get-Date).AddYears(3))
    CertStoreLocation = 'Cert:\CurrentUser\My'
}

$TestCodeSigningCert = New-SelfSignedCertificate @Arguments
#endregion

# Creating something to sign
Add-Type -TypeDefinition @'
using System;

public class Test {
    public static void Main(string[] args) {
        Console.WriteLine("Hello, PowerShell!");
        Console.ReadKey();
    }
}
'@ -OutputAssembly HelloPowerShell.exe

#region Trusting our self-signed certificate as a trusted root.
Set-AuthenticodeSignature -Certificate $TestCodeSigningCert -TimestampServer 'http://timestamp.digicert.com' -FilePath .\HelloPowerShell.exe

$TestCodeSigningCert = ls Cert:\CurrentUser\My\ | ? { $_.Subject -eq 'CN=My Self-signed Code Signing' }
Export-Certificate -FilePath exported_cert.cer -Cert $TestCodeSigningCert
Import-Certificate -FilePath exported_cert.cer -CertStoreLocation Cert:\CurrentUser\Root

Get-AuthenticodeSignature -Certificate $TestCodeSigningCert -FilePath HelloWorld.exe
#endregion

#region Catalog file creation and signing for Module publishing
mkdir NewModule
'Write-Host "This is an awesome module!!!"' | Out-File .\NewModule\NewModule.psm1

New-FileCatalog -CatalogVersion 2 -CatalogFilePath .\NewModule.cat -Path .\NewModule\
Move-Item -Path .\NewModule.cat -Destination .\NewModule\

Test-FileCatalog -FilesToSkip .\NewModule\NewModule.cat -CatalogFilePath .\NewModule\NewModule.cat -Detailed

$MySigningCert = ls Cert:\CurrentUser\My\ | ? { $_.Subject -eq 'CN=My Self-signed Code Signing' }
Set-AuthenticodeSignature -Certificate $MySigningCert -TimestampServer 'http://timestamp.digicert.com' -FilePath .\NewModule\NewModule.cat
#endregion