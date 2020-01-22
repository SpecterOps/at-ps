function Get-WmiNamespace {
<#
.SYNOPSIS

Returns a list of WMI namespaces present within the specified namespace.

.PARAMETER Namespace

Specifies the WMI repository namespace in which to list sub-namespaces. Get-WmiNamespace defaults to the ROOT namespace.

.PARAMETER Recurse

Specifies that namespaces should be recursed upon starting from the specified root namespace.

.EXAMPLE

Get-WmiNamespace

.EXAMPLE

Get-WmiNamespace -Recurce

.EXAMPLE

Get-WmiNamespace -Namespace ROOT\CIMV2

.EXAMPLE

Get-WmiNamespace -Namespace ROOT\CIMV2 -Recurse

.OUTPUTS

System.String

Get-WmiNamespace returns fully-qualified namespace names.
#>

    [OutputType([String])]
    Param (
        [String]
        [ValidateNotNullOrEmpty()]
        $Namespace = 'ROOT',

        [Switch]
        $Recurse
    )

    $BoundParamsCopy = $PSBoundParameters
    $null = $BoundParamsCopy.Remove('Namespace')

    # Exclude locale specific namespaces
    Get-WmiObject -Class __NAMESPACE -Namespace $Namespace -Filter 'NOT Name LIKE "ms_4%"' | ForEach-Object {
        $FullyQualifiedNamespace = '{0}\{1}' -f $_.__NAMESPACE, $_.Name
        $FullyQualifiedNamespace

        if ($Recurse) {
            Get-WmiNamespace -Namespace $FullyQualifiedNamespace @BoundParamsCopy
        }
    }
}

filter Get-WmiExtrinsicEvent {
<#
.SYNOPSIS

Returns all WMI extrinsic event types for the specified namespace.

.PARAMETER Namespace

Specifies the WMI repository namespace in which to list extrinsic event types.

.EXAMPLE

Get-WmiExtrinsicEvent

.EXAMPLE

Get-WmiNamespace -Recurce | Get-WmiExtrinsicEvent

.INPUTS

System.String

Get-WmiExtrinsicEvent accepts fully-qualified namespace names returned from Get-WmiNamespace.

.OUTPUTS

System.Management.ManagementClass

Get-WmiExtrinsicEvent returns extrinsic WMI class objects.
#>

    [OutputType([Management.ManagementClass])]
    Param (
        [Parameter(ValueFromPipeline = $True)]
        [String]
        $Namespace = 'ROOT\CIMV2'
    )

    # Exclude generic, system generated extrinsic events
    $ExclusionList = @(
        '__SystemEvent',
        '__EventDroppedEvent',
        '__EventQueueOverflowEvent',
        '__QOSFailureEvent',
        '__ConsumerFailureEvent')

    Get-WmiObject -Class Meta_Class -Namespace $Namespace |
        Where-Object { $_.Name -eq '__TimerEvent' -or ($_.Derivation.Contains('__ExtrinsicEvent') -and (-not ($ExclusionList -contains $_.Name))) }
}

filter Get-WmiIntrinsicEvent {
<#
.SYNOPSIS

Returns all WMI intrinsic event types for the specified namespace.

.PARAMETER Namespace

Specifies the WMI repository namespace in which to list intrinsic event types.

.EXAMPLE

Get-WmiIntrinsicEvent

.EXAMPLE

Get-WmiNamespace -Recurce | Get-WmiIntrinsicEvent

.INPUTS

System.String

Get-WmiIntrinsicEvent accepts fully-qualified namespace names returned from Get-WmiNamespace.

.OUTPUTS

System.Management.ManagementClass

Get-WmiIntrinsicEvent returns intrinsic WMI class objects.
#>

    [OutputType([Management.ManagementClass])]
    Param (
        [Parameter(ValueFromPipeline = $True)]
        [String]
        $Namespace = 'ROOT\CIMV2'
    )

    $ExclusionList = @(
        '__ExtrinsicEvent',
        '__TimerEvent'
    )

    Get-WmiObject -Class Meta_Class -Namespace $Namespace |
        Where-Object { $_.Derivation.Contains('__Event') -and (-not $_.Derivation.Contains('__ExtrinsicEvent') -and (-not ($ExclusionList -contains $_.Name))) }
}