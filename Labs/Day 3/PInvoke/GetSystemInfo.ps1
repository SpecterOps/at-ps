function Get-SystemInfo {
    [OutputType('SYSINFO.SYSTEM_INFO')] # Quotes needed vs. [] type def due to dynamic typing
    Param ()

    # Create a new in-memory module. This serves as the
    # "storage container" for all the type definitions that will be defined.
    $Module = New-InMemoryModule -ModuleName SysInfoDemo

    # Processor arch and SYSTEM_INFO definitions are defined on MSDN - 
    # https://msdn.microsoft.com/en-us/library/windows/desktop/ms724958.aspx
    # and within Winbase.h in the SDK.

    # Being explicit with [UInt16] casting will ensure that the
    # default [Int32] conversion will take place.
    $ProcessorType = psenum $Module SYSINFO.PROCESSOR_ARCH UInt16 @{
        INTEL =   [UInt16] 0
        MIPS =    [UInt16] 1
        ALPHA =   [UInt16] 2
        PPC =     [UInt16] 3
        SHX =     [UInt16] 4
        ARM =     [UInt16] 5
        IA64 =    [UInt16] 6
        ALPHA64 = [UInt16] 7
        AMD64 =   [UInt16] 9
        UNKNOWN = [UInt16]::MaxValue # i.e. 0xFFFF
    }

    <# C definition of SYSTEM_INFO:

    typedef struct _SYSTEM_INFO {
      union {
        DWORD  dwOemId;
        struct {
          WORD wProcessorArchitecture;
          WORD wReserved;
        };
      };
      DWORD     dwPageSize;
      LPVOID    lpMinimumApplicationAddress;
      LPVOID    lpMaximumApplicationAddress;
      DWORD_PTR dwActiveProcessorMask;
      DWORD     dwNumberOfProcessors;
      DWORD     dwProcessorType;
      DWORD     dwAllocationGranularity;
      WORD      wProcessorLevel;
      WORD      wProcessorRevision;
    } SYSTEM_INFO;
    #>

    # PSReflect definition of SYSTEM_INFO:
    # I am using unsigned datatypes here to match the
    # unsigned types used in the SYSTEM_INFO structure
    # definition.
    $SYSTEM_INFO = struct $Module SYSINFO.SYSTEM_INFO @{
        ProcessorArchitecture = field 0 $ProcessorType
        # i.e. WORD but our defined enum will make the
        # parsed structure human-readable.
        # Note that the dwOemId is being ignored as it
        # is obsolete and superceded by the
        # wProcessorArchitecture/wReserved struct.
        Reserved = field 1 UInt16 # i.e. WORD
        PageSize = field 2 UInt32 # i.e. DWORD
        MinimumApplicationAddress = field 3 IntPtr # i.e. LPVOID
        MaximumApplicationAddress = field 4 IntPtr # i.e. LPVOID
        ActiveProcessorMask = field 5 IntPtr # i.e. DWORD_PTR
        NumberOfProcessors = field 6 UInt32 # i.e. DWORD
        ProcessorType = field 7 UInt32 # i.e. DWORD
        AllocationGranularity = field 8 UInt32 # i.e. DWORD
        ProcessorLevel = field 9 UInt16 # i.e. WORD
        ProcessorRevision = field 10 UInt16 # i.e. WORD
    }

    # Note: When defining structures, always make sure they
    # return sane values in both x86 and x64 PowerShell. If
    # they don't, you should play with -PackingSize and an
    # explicit layout, if necessary.

    # Splatted arguments to Add-Win32Type.
    # There are many ways to pass arguments. This way is more readable, IMO.
    $FuncDefArgs = @{
        Module = $Module
        Namespace = 'Demo.SysInfo'
        DllName = 'kernel32'
        FunctionName = 'GetSystemInfo'
        ReturnType = [Void]
        ParameterTypes = @($SYSTEM_INFO.MakeByRefType())
    }

    $Type = Add-Win32Type @FuncDefArgs
    # Add-Win32Type returns a hashtable where the keys are the
    # defined DLL names so let's pull out kernel32.
    $Kernel32 = $Type['kernel32']

    # Create in instance of the SYSTEM_INFO structure.
    # This is needed since an instance needs to be passed by reference.
    # Having to use Activator is a workaround for subtle reflection issues in PSv2.
    # In PSv3+, you could just do the following:
    # $SysInfo = New-Object SYSINFO.SYSTEM_INFO
    $SysInfo = [Activator]::CreateInstance($SYSTEM_INFO)
    $Kernel32::GetSystemInfo([Ref] $SysInfo)

    $SysInfo
}