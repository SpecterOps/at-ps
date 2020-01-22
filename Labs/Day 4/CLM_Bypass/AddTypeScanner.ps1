Get-ChildItem -Path C:\* -Include '*.ps1', '*.psm1' -Recurse | Select-String -Pattern 'Add-Type' | Select-Object -ExpandProperty Path | Sort-Object -Unique | ForEach-Object {
    $Signature = Get-AuthenticodeSignature -FilePath $_

    if ($Signature.SignerCertificate -and ($Signature.SignerCertificate.Subject -match '^CN=Microsoft Windows')) {
        $Signature
    }
}
