# Trying to find WMI classes that might be vaguely related to processes or DLLs
# Note that 'root/cimv2' is implicit.
Get-CimClass -ClassName *Module*
Get-CimClass -ClassName *Process*

# CIM_ProcessExecutable is our candidate WMI class
Get-CimClass -ClassName CIM_ProcessExecutable | Select-Object -ExpandProperty CimClassProperties
# MSDN docs: https://msdn.microsoft.com/en-us/library/aa387977%28v=vs.85%29.aspx

# See what instances look like
Get-CimInstance -ClassName CIM_ProcessExecutable

# The Antecedent property contains the DLL filename. Let's start
# by grouping by filename and then look at the associated processes:
Get-CimInstance -ClassName CIM_ProcessExecutable | Group-Object -Property {$_.Antecedent.Name} | Sort-Object -Property Name

# Now let's filter the results to just return instances with System.Management.Automation(.ni).dll
Get-CimInstance -ClassName CIM_ProcessExecutable | Where-Object { $_.Antecedent.Name -match 'System\.Management\.Automation' }

# Now let's return proper Win32_Process instances for the running PowerShell host processes.
# The Dependent property only stores the Win32_Process.Handle property (presumably for perf/latency reasons)
Get-CimInstance -ClassName CIM_ProcessExecutable | Where-Object { $_.Antecedent.Name -match 'System\.Management\.Automation' } | ForEach-Object {
    # Note we're sticking to pure WMI to support consistent remote scenarios (if desired).
    Get-CimInstance -ClassName Win32_Process -Filter "ProcessId = $($_.Dependent.Handle)"
}

# Any other interesting fields to pivot off of for offense or defense? IDK. Let's see what the data tells us.

# Anything interesting with BaseAddress?
# See what modules are loaded the most frequently.
Get-CimInstance -ClassName CIM_ProcessExecutable | Group-Object -Property { $_.BaseAddress.ToString('X16') } |
    Sort-Object -Property Count -Descending

# Sorting by loaded base address. Could this maybe imply modules that don't opt in to ASLR?
Get-CimInstance -ClassName CIM_ProcessExecutable | Group-Object -Property { $_.BaseAddress.ToString('X16') } |
    Sort-Object -Property Name
# I think some inferences can be made but no solid conclusions can be drawn.

# Are BaseAddress and ModuleInstance related? I've seen that sometimes they're equal. Other times they're not.
Get-CimInstance -ClassName CIM_ProcessExecutable | Where-Object { $_.BaseAddress -eq $_.ModuleInstance } | Measure-Object
Get-CimInstance -ClassName CIM_ProcessExecutable | Where-Object { $_.BaseAddress -ne $_.ModuleInstance } | Measure-Object

# There aren't nearly as many instances where BaseAddress == ModuleInstance. Why?
Get-CimInstance -ClassName CIM_ProcessExecutable | Where-Object { $_.BaseAddress -eq $_.ModuleInstance } | ForEach-Object {
    $_.Antecedent.Name
} | Sort-Object -Unique
# IDK. I thought maybe these were modules that didn't opt in to ASLR. That's not necessarily the case.
# Anyway, this is a useful exercise to get in the mindset of defensive pattern recognition.
