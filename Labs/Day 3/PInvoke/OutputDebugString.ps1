#region Technique #1: Calling the target function by locating a public .NET method

# Will throw an exception
[Microsoft.Win32.SafeNativeMethods]::OutputDebugString('Hello from PowerShell!!!')
$Listener = New-Object System.Diagnostics.DefaultTraceListener

#endregion

#region Technique #2: Calling the target function by calling a non-public .NET method

$SafeNativeMethods = [Uri].Assembly.GetType('Microsoft.Win32.SafeNativeMethods')
$OutputDebugString = $SafeNativeMethods.GetMethod('OutputDebugString')

#endregion

#region Technique #3: Calling the target function via compiling C# with Add-Type

$Signature = @'
[DllImport("kernel32.dll", BestFitMapping = true, CharSet = CharSet.Auto)]
public static extern void OutputDebugString(string message);
'@

Add-Type -MemberDefinition $Signature -Namespace Win32Functions -Name Kernel32

#endregion

#region Technique #4: Calling the target function by using refelction

$DynAssembly = New-Object System.Reflection.AssemblyName('ReflectionAssembly')
$AssemblyBuilder = [AppDomain]::CurrentDomain.DefineDynamicAssembly($DynAssembly, [Reflection.Emit.AssemblyBuilderAccess]::Run)
$ModuleBuilder = $AssemblyBuilder.DefineDynamicModule('ReflectionModule', $False)

$TypeBuilder = $ModuleBuilder.DefineType('Win32FunctionsReflection.Kernel32', 'Public, Class')
$DllImportConstructor = [Runtime.InteropServices.DllImportAttribute].GetConstructor(@([String]))

# Define [Win32.Kernel32]::DeviceIoControl
$PInvokeMethod = $TypeBuilder.DefinePInvokeMethod(
    'OutputDebugString',
    'kernel32.dll',
    ([Reflection.MethodAttributes]::Public -bor [Reflection.MethodAttributes]::Static),
    [Reflection.CallingConventions]::Standard,
    [Void],
    [Type[]]@([String]),
    [Runtime.InteropServices.CallingConvention]::Winapi,
    [Runtime.InteropServices.CharSet]::Auto
)

$Kernel32 = $TypeBuilder.CreateType()

#endregion

# Open dbgview.exe to view these messages
$Listener.Write('Win32 Technique #1: Calling OutputDebugString via a public .NET interface')
$OutputDebugString.Invoke($null, @('Win32 Technique #2: Calling OutputDebugString via a non-public .NET interface'))
[Win32Functions.Kernel32]::OutputDebugString('Win32 Technique #3: Calling OutputDebugString via compiled C#')
$Kernel32::OutputDebugString('Win32 Technique #4: Calling OutputDebugString via reflection.')