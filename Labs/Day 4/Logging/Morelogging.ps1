$EventTemplate = @'
	NewEngineState=Available
	PreviousEngineState=None

	SequenceNumber=32807

	HostName=Default Host
	HostVersion=5.1.16299.19
	HostId=0c8d6f6a-594c-4f1b-9a80-cff8c152c469
	HostApplication=C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe
	EngineVersion=5.1.16299.19
	RunspaceId=8c06e414-3e2e-488a-a072-c7e295b28631
	PipelineId=
	CommandName=
	CommandType=
	ScriptName=
	CommandPath=
	CommandLine=
'@

$Arguments = @('Windows PowerShell', '.', 'PowerShell')
$Instance = New-Object -TypeName Diagnostics.EventInstance -ArgumentList 400, 4
$PowerShellEventLog = New-Object -TypeName Diagnostics.EventLog -ArgumentList $Arguments
$PowerShellEventLog.WriteEvent($Instance, @('Available', 'None', 'Fake entry!!!'))

Write-EventLog -LogName 'Windows PowerShell' -Source PowerShell -Category 4 -EventId 1337 -RawData @(0,1,2,3) -Message ' '
Get-EventLog -LogName 'Windows PowerShell' -Source PowerShell -InstanceId 1337 | Select-Object -ExpandProperty Data

logman query providers | findstr PowerShell
logman query providers Microsoft-Windows-PowerShell
$OriginalProvider = Get-EtwTraceProvider -SessionName EventLog-Application -Guid '{A0C1853B-5C40-4B15-8766-3CF1C58F985A}'
Remove-EtwTraceProvider -SessionName EventLog-Application -Guid '{A0C1853B-5C40-4B15-8766-3CF1C58F985A}'
Add-EtwTraceProvider -SessionName EventLog-Application -Guid '{A0C1853B-5C40-4B15-8766-3CF1C58F985A}' -MatchAnyKeyword ([UInt64] $OriginalProvider.MatchAnyKeyword) 

