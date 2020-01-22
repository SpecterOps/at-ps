#Requires -Version 2


function Get-NetRDPSessions {
    <#
        .SYNOPSIS
        Gets active RDP sessions for a specified server.
        This is a essentialy replacement for qwinsta with
        the source IP added into the output.
        
        Author: @harmj0y
        License: BSD 3-Clause

        .PARAMETER HostName
        The hostname to query for active RDP sessions.

        .DESCRIPTION
        This function will execute the WTSEnumerateSessionsEx and 
        WTSQuerySessionInformation Win32API calls to query a given
        RDP remote service for active sessions and originating IPs.

        Note: only members of the Administrators or Account Operators local group
        can successfully execute this functionality on a remote target.

        .OUTPUTS
        A custom psobject with the HostName, SessionName, UserName, ID, connection state,
        and source IP of the connection.

        .EXAMPLE
        > Get-NetRDPSessions
        Returns active RDP/terminal sessions on the local host.

        .EXAMPLE
        > Get-NetRDPSessions -HostName "sqlserver"
        Returns active RDP/terminal sessions on the 'sqlserver' host.
    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline=$True)]
        [string]
        $HostName = 'localhost'
    )
    
    begin {
        If ($PSBoundParameters['Debug']) {
            $DebugPreference = 'Continue'
        }
    }

    process {
        # open up a handle to the Remote Desktop Session host
        $handle = $Wtsapi32::WTSOpenServerEx($HostName)

        # if we get a non-zero handle back, everything was successful
        if ($handle -ne 0){

            Write-Debug "WTSOpenServerEx handle: $handle"

            # arguments for WTSEnumerateSessionsEx
            $pLevel = 1
            $filter = 0
            $ppSessionInfo = [IntPtr]::Zero
            $pCount = 0
            
            # get information on all current sessions
            $Result = $Wtsapi32::WTSEnumerateSessionsEx($handle, [ref]1, 0, [ref]$ppSessionInfo, [ref]$pCount)

            # Locate the offset of the initial intPtr
            $offset = $ppSessionInfo.ToInt64()

            Write-Debug "WTSEnumerateSessionsEx result: $Result"
            Write-Debug "pCount: $pCount"

            if (($Result -ne 0) -and ($offset -gt 0)) {

                # Work out how mutch to increment the pointer by finding out the size of the structure
                $Increment = $WTS_SESSION_INFO_1::GetSize()

                # parse all the result structures
                for ($i = 0; ($i -lt $pCount); $i++){
     
                    # create a new int ptr at the given offset and cast
                    # the pointer as our result structure
                    $newintptr = New-Object system.Intptr -ArgumentList $offset
                    $Info = $newintptr -as $WTS_SESSION_INFO_1

                    $out = New-Object psobject
                    if (-not $Info.pHostName){
                        # if no hostname returned, use the specified hostname
                        $out | Add-Member Noteproperty 'HostName' $HostName
                    }
                    else{
                        $out | Add-Member Noteproperty 'HostName' $Info.pHostName
                    }
                    $out | Add-Member Noteproperty 'SessionName' $Info.pSessionName
                    if ($(-not $Info.pDomainName) -or ($Info.pDomainName -eq '')){
                        $out | Add-Member Noteproperty 'UserName' "$($Info.pUserName)"
                    }
                    else {
                        $out | Add-Member Noteproperty 'UserName' "$($Info.pDomainName)\$($Info.pUserName)"
                    }
                    $out | Add-Member Noteproperty 'ID' $Info.SessionID
                    $out | Add-Member Noteproperty 'State' $Info.State

                    $ppBuffer = [IntPtr]::Zero
                    $pBytesReturned = 0

                    # query for the source client IP
                    #   https://msdn.microsoft.com/en-us/library/aa383861(v=vs.85).aspx
                    $Result2 = $Wtsapi32::WTSQuerySessionInformation($handle,$Info.SessionID,14,[ref]$ppBuffer,[ref]$pBytesReturned) 
                    $offset2 = $ppBuffer.ToInt64()
                    $newintptr2 = New-Object System.Intptr -ArgumentList $offset2
                    $Info2 = $newintptr2 -as $WTS_CLIENT_ADDRESS
                    $ip = $Info2.Address         
                    if($ip[2] -ne 0){
                        $SourceIP = [string]$ip[2]+"."+[string]$ip[3]+"."+[string]$ip[4]+"."+[string]$ip[5]
                    }

                    $out | Add-Member Noteproperty 'SourceIP' $SourceIP
                    $out

                    # free up the memory buffer
                    $Null = $Wtsapi32::WTSFreeMemory($ppBuffer)

                    $offset += $increment
                }
                # free up the memory result buffer
                $Null = $Wtsapi32::WTSFreeMemoryEx(2, $ppSessionInfo, $pCount)
            }
            # Close off the service handle
            $Null = $Wtsapi32::WTSCloseServer($handle)
        }
        else{
            # otherwise it failed - get the last error
            $err = $Kernel32::GetLastError()
            # error codes - http://msdn.microsoft.com/en-us/library/windows/desktop/ms681382(v=vs.85).aspx
            Write-Verbuse "LastError: $err"
        }
    }
}

$Mod = New-InMemoryModule -ModuleName Win32

# all of the Win32 API functions we need
$FunctionDefinitions = @(
    (func wtsapi32 WTSOpenServerEx ([IntPtr]) @([string])),
    (func wtsapi32 WTSEnumerateSessionsEx ([Int]) @([IntPtr], [Int32].MakeByRefType(), [Int], [IntPtr].MakeByRefType(), [Int32].MakeByRefType())),
    (func wtsapi32 WTSQuerySessionInformation ([Int]) @([IntPtr], [Int], [Int], [IntPtr].MakeByRefType(), [Int32].MakeByRefType())),
    (func wtsapi32 WTSFreeMemoryEx ([Int]) @([Int32], [IntPtr], [Int32])),
    (func wtsapi32 WTSFreeMemory ([Int]) @([IntPtr])),
    (func wtsapi32 WTSCloseServer ([Int]) @([IntPtr])),
    (func kernel32 GetLastError ([Int]) @())
)


$WTSConnectState = psenum $Mod WTS_CONNECTSTATE_CLASS UInt16 @{
    Active       =    0
    Connected    =    1
    ConnectQuery =    2
    Shadow       =    3
    Disconnected =    4
    Idle         =    5
    Listen       =    6
    Reset        =    7
    Down         =    8
    Init         =    9
}


$WTSInfo = psenum $Mod WTS_INFO_CLASS UInt16 @{ 
    WTSInitialProgram         = 0
    WTSApplicationName        = 1
    WTSWorkingDirectory       = 2
    WTSOEMId                  = 3
    WTSSessionId              = 4
    WTSUserName               = 5
    WTSWinStationName         = 6
    WTSDomainName             = 7
    WTSConnectState           = 8
    WTSClientBuildNumber      = 9
    WTSClientName             = 10
    WTSClientDirectory        = 11
    WTSClientProductId        = 12
    WTSClientHardwareId       = 13
    WTSClientAddress          = 14
    WTSClientDisplay          = 15
    WTSClientProtocolType     = 16
    WTSIdleTime               = 17
    WTSLogonTime              = 18
    WTSIncomingBytes          = 19
    WTSOutgoingBytes          = 20
    WTSIncomingFrames         = 21
    WTSOutgoingFrames         = 22
    WTSClientInfo             = 23
    WTSSessionInfo            = 24
    WTSSessionInfoEx          = 25
    WTSConfigInfo             = 26
    WTSValidationInfo         = 27
    WTSSessionAddressV4       = 28
    WTSIsRemoteSession        = 29
}


$WTS_SESSION_INFO_1 = struct $Mod WTS_SESSION_INFO_1 @{
    ExecEnvId = field 0 UInt32
    State = field 1 $WTSConnectState
    SessionId = field 2 UInt32
    pSessionName = field 3 String -MarshalAs @('LPWStr')
    pHostName = field 4 String -MarshalAs @('LPWStr')
    pUserName = field 5 String -MarshalAs @('LPWStr')
    pDomainName = field 6 String -MarshalAs @('LPWStr')
    pFarmName = field 7 String -MarshalAs @('LPWStr')
}


$WTSCLIENT = struct $mod WTSCLIENT @{
    ClientName = field 0 UInt16[] -MarshalAs @('ByValArray', 21)
    Domain = field 1 UInt16[] -MarshalAs @('ByValArray', 18)
    UserName = field 2 UInt16[] -MarshalAs @('ByValArray', 21)
    WorkDirectory = field 3 UInt16[] -MarshalAs @('ByValArray', 261)
    InitialProgram = field 4 UInt16[] -MarshalAs @('ByValArray', 261)
    EncryptionLevel = field 5 Byte
    ClientAddressFamily = field 6 UInt64
    ClientAddress = field 7 UInt16[] -MarshalAs @('ByValArray', 31)
    HRes = field 8 UInt16
    VRes = field 9 UInt16
    ColorDepth = field 10 UInt16
    ClientDirectory = field 11 UInt16[] -MarshalAs @('ByValArray', 261)
    ClientBuildNumber = field 12 UInt64
    ClientHardwareId = field 13 UInt64
    ClientProductId = field 14 UInt16
    OutBufCountHost = field 15 UInt16
    OutBufCountClient = field 16 UInt16
    OutBufLength = field 17 UInt16
    DeviceId = field 18 UInt16[] -MarshalAs @('ByValArray', 261)
}


$WTS_CLIENT_ADDRESS = struct $mod WTS_CLIENT_ADDRESS @{
    AddressFamily = field 0 UInt32
    # Address = field 1 String -MarshalAs @('LPWStr')
    Address = field 1 Byte[] -MarshalAs @('ByValArray', 20)
}


$Types = $FunctionDefinitions | Add-Win32Type -Module $Mod -Namespace 'Win32'
$Wtsapi32 = $Types['wtsapi32']
$Kernel32 = $Types['kernel32']