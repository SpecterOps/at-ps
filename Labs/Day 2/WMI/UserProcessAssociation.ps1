Get-CimInstance -ClassName Win32_Account | ForEach-Object {
    $AccountName = $_.Name

    # I used the association graph to figure these association names out.
    $AssociatedProcesses = Get-CimAssociatedInstance -InputObject $_ -Association Win32_LoggedOnUser | Get-CimAssociatedInstance -Association Win32_SessionProcess

    # Don't bother listing users that don't have associated processes
    if ($AssociatedProcesses) {
        [PSCustomObject] @{ Account = $AccountName; Processes = $AssociatedProcesses }
    }
}