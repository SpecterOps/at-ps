$VideoController = Get-CimInstance -ClassName Win32_VideoController -Property VideoModeDescription
$ScreenWidth, $ScreenHeight = [UInt32[]] $VideoController.VideoModeDescription.Split(' x ', [StringSplitOptions]::RemoveEmptyEntries)[0..1]

$StartParams = New-CimInstance -ClassName Win32_ProcessStartup -ClientOnly -Property @{
    FillAttribute = ([UInt32] 256)
    Title = ''
    X = $ScreenWidth
    Y = $ScreenHeight
    ShowWindow = ([UInt16] 0)
}

Invoke-CimMethod -ClassName Win32_Process -MethodName Create -Arguments @{
    CommandLine = 'cmd.exe'
    ProcessStartupInformation = $StartParams
}
