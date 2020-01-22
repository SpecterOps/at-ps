# Get signature info for all signed files regardless of file extension and signature validation status.
$SignatureInfo = Get-ChildItem -Path C:\Windows\System32\* -Recurse -File |
    Get-AuthenticodeSignature -ErrorAction SilentlyContinue | ? { $_.SignerCertificate }

$SignatureInfo = Get-ChildItem -Path C:\Windows\System32\* -Recurse -File | ForEach-Object {
    try {
        # Get-AuthenticodeSignature can throw a terminating .NET exception so let's be sure to catch that.
        Get-AuthenticodeSignature -FilePath $_.FullName | Where-Object { $_.SignerCertificate }
    } catch {}
}

$GroupedByThumbprint = $SignatureInfo | Group-Object -Property { $_.SignerCertificate.Thumbprint } | Sort-Object -Property Count -Descending
