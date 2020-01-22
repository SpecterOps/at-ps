$EventTemplate = @'
	NewEngineState={0}
	PreviousEngineState={1}

	SequenceNumber={2}

	HostName={3}
	HostVersion={4}
	HostId={5}
	HostApplication={6}
	EngineVersion={7}
	RunspaceId={8}
	PipelineId={9}
	CommandName={10}
	CommandType={11}
	ScriptName={12}
	CommandPath={13}
	CommandLine={14}
'@ -f 'Available',
      'None',
      '32807',
      'Default Host',
      '5.1.16299.19',
      '0c8d6f6a-594c-4f1b-9a80-cff8c152c469',
      'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe',
      '5.1.16299.19',
      '8c06e414-3e2e-488a-a072-c7e295b28631',
      '', '', '', '', '', ''

$EventInstance = New-Object -TypeName System.Diagnostics.EventInstance -ArgumentList 400, 4
$PowerShellEventLog = New-Object -TypeName System.Diagnostics.EventLog -ArgumentList 'Windows PowerShell', '.', 'PowerShell'
$PowerShellEventLog.WriteEvent($EventInstance, @('Available', 'None', $EventTemplate))
