function New-AssemblyLoaderStub {
    [OutputType([ScriptBlock])]
    param (
        [Parameter(Mandatory = $True)]
        [String]
        $Path
    )

    $FullPath = Resolve-Path -Path $Path

    # Validate that the file passed in is an actual .NET assembly.
    $Assembly = [System.Reflection.Assembly]::ReflectionOnlyLoadFrom($FullPath)

    if ($Assembly) {
        $AssemblyBytes = [System.IO.File]::ReadAllBytes($FullPath)

        $EncodedAssembly = [System.Convert]::ToBase64String($AssemblyBytes)

        if ($Assembly.EntryPoint) {
            $LoaderStub = {
function Invoke-InMemoryMain {
    param (
        [String[]]
        $Arguments = @()
    )

    $EncodedAssembly = 'REPLACEME'
    $AssemblyBytes = [System.Convert]::FromBase64String($EncodedAssembly)
    $Assembly = [System.Reflection.Assembly]::Load($AssemblyBytes)

    $Assembly.EntryPoint.Invoke($null, [Object[]] @(@(,([String[]] $Arguments))))
}
            } -replace 'REPLACEME', $EncodedAssembly
        } else {
            # You're wanting to load a .NET DLL in memory. Invoking your method of choice is on you.
            # Fortunately, you know how to access and invoke class methods using reflection!

            $LoaderStub = {
$EncodedAssembly = 'REPLACEME'
$AssemblyBytes = [System.Convert]::FromBase64String($EncodedAssembly)
[System.Reflection.Assembly]::Load($AssemblyBytes)
            } -replace 'REPLACEME', $EncodedAssembly
        }

        [ScriptBlock]::Create($LoaderStub)
    }
}