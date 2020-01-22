Import-Module PSReflect

$InMemoryModule = New-InMemoryModule -ModuleName Win32Funcs

$Type = Add-Win32Type -Namespace Win32Functions -DllName User32 -FunctionName MessageBox -EntryPoint MessageBoxW -ReturnType ([Int32]) -ParameterTypes ([IntPtr], [String], [String], [Int32]) -SetLastError -Module $InMemoryModule

function Show-MessageBox {
    [OutputType([Int32])]
    param (
        [Parameter(Mandatory)]
        [String]
        [ValidateNotNullOrEmpty()]
        $WindowTitle,

        [Parameter(Mandatory)]
        [String]
        [ValidateNotNullOrEmpty()]
        $Message,

        [String]
        [ValidateSet('AbortRetryIgnore', 'CancelTryContinue', 'Help', 'OK', 'OKCancel', 'RetryCancel', 'YesNo', 'YesNoCancel')]
        $ButtonSet = 'OK',

        [String]
        [ValidateSet('Exclamation', 'Information', 'Question', 'Stop')]
        $Icon
    )

    $Signature = @'
    [DllImport("user32.dll", CharSet = CharSet.Unicode, EntryPoint = "MessageBoxW", ExactSpelling = true)]
    public static extern int MessageBox(IntPtr hWnd, string text, string caption, int type);
'@

    Add-Type -MemberDefinition $Signature -Name User32 -Namespace Win32Functions

    $ButtonValue = 0

    switch ($ButtonSet) {
        'AbortRetryIgnore'  { $ButtonValue = 2 }
        'CancelTryContinue' { $ButtonValue = 6 }
        'Help'              { $ButtonValue = 0x4000 }
        'OK'                { $ButtonValue = 0 }
        'OKCancel'          { $ButtonValue = 1 }
        'RetryCancel'       { $ButtonValue = 5 }
        'YesNo'             { $ButtonValue = 4 }
        'YesNoCancel'       { $ButtonValue = 3 }
    }

    $IconValue = 0

    switch ($Icon) {
        'Exclamation' { $IconValue = 0x30 }
        'Information' { $IconValue = 0x40 }
        'Question'    { $IconValue = 0x20 }
        'Stop'        { $IconValue = 0x10 }
    }

    [Int] $TypeVal = $ButtonValue -bor $IconValue

    [Win32Functions.User32]::MessageBox([IntPtr]::Zero, $Message, $WindowTitle, $TypeVal)
}
