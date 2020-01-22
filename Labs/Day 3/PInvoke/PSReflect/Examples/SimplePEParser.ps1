#Requires -Version 2

<#
A very basic PE parser that demonstrates the usage of PSReflect

Author: Matthew Graeber (@mattifestation)
License: BSD 3-Clause
#>

$Mod = New-InMemoryModule -ModuleName Win32

$ImageDosSignature = psenum $Mod PE.IMAGE_DOS_SIGNATURE UInt16 @{
    DOS_SIGNATURE =    0x5A4D
    OS2_SIGNATURE =    0x454E
    OS2_SIGNATURE_LE = 0x454C
    VXD_SIGNATURE =    0x454C
}

$ImageFileMachine = psenum $Mod PE.IMAGE_FILE_MACHINE UInt16 @{
    UNKNOWN =   0x0000
    I386 =      0x014C # Intel 386.
    R3000 =     0x0162 # MIPS little-endian =0x160 big-endian
    R4000 =     0x0166 # MIPS little-endian
    R10000 =    0x0168 # MIPS little-endian
    WCEMIPSV2 = 0x0169 # MIPS little-endian WCE v2
    ALPHA =     0x0184 # Alpha_AXP
    SH3 =       0x01A2 # SH3 little-endian
    SH3DSP =    0x01A3
    SH3E =      0x01A4 # SH3E little-endian
    SH4 =       0x01A6 # SH4 little-endian
    SH5 =       0x01A8 # SH5
    ARM =       0x01C0 # ARM Little-Endian
    THUMB =     0x01C2
    ARMNT =     0x01C4 # ARM Thumb-2 Little-Endian
    AM33 =      0x01D3
    POWERPC =   0x01F0 # IBM PowerPC Little-Endian
    POWERPCFP = 0x01F1
    IA64 =      0x0200 # Intel 64
    MIPS16 =    0x0266 # MIPS
    ALPHA64 =   0x0284 # ALPHA64
    MIPSFPU =   0x0366 # MIPS
    MIPSFPU16 = 0x0466 # MIPS
    TRICORE =   0x0520 # Infineon
    CEF =       0x0CEF
    EBC =       0x0EBC # EFI public byte Code
    AMD64 =     0x8664 # AMD64 (K8)
    M32R =      0x9041 # M32R little-endian
    CEE =       0xC0EE
}

$ImageFileCharacteristics = psenum $Mod PE.IMAGE_FILE_CHARACTERISTICS UInt16 @{
    IMAGE_RELOCS_STRIPPED =         0x0001 # Relocation info stripped from file.
    IMAGE_EXECUTABLE_IMAGE =        0x0002 # File is executable  (i.e. no unresolved external references).
    IMAGE_LINE_NUMS_STRIPPED =      0x0004 # Line nunbers stripped from file.
    IMAGE_LOCAL_SYMS_STRIPPED =     0x0008 # Local symbols stripped from file.
    IMAGE_AGGRESIVE_WS_TRIM =       0x0010 # Agressively trim working set
    IMAGE_LARGE_ADDRESS_AWARE =     0x0020 # App can handle >2gb addresses
    IMAGE_REVERSED_LO =             0x0080 # public bytes of machine public ushort are reversed.
    IMAGE_32BIT_MACHINE =           0x0100 # 32 bit public ushort machine.
    IMAGE_DEBUG_STRIPPED =          0x0200 # Debugging info stripped from file in .DBG file
    IMAGE_REMOVABLE_RUN_FROM_SWAP = 0x0400 # If Image is on removable media copy and run from the swap file.
    IMAGE_NET_RUN_FROM_SWAP =       0x0800 # If Image is on Net copy and run from the swap file.
    IMAGE_SYSTEM =                  0x1000 # System File.
    IMAGE_DLL =                     0x2000 # File is a DLL.
    IMAGE_UP_SYSTEM_ONLY =          0x4000 # File should only be run on a UP machine
    IMAGE_REVERSED_HI =             0x8000 # public bytes of machine public ushort are reversed.
} -Bitfield

$ImageHdrMagic = psenum $Mod PE.IMAGE_NT_OPTIONAL_HDR_MAGIC UInt16 @{
    PE32 = 0x010B
    PE64 = 0x020B
}

$ImageNTSig = psenum $Mod PE.IMAGE_NT_SIGNATURE UInt32 @{
    VALID_PE_SIGNATURE = 0x00004550
}

$ImageSubsystem = psenum $Mod PE.IMAGE_SUBSYSTEM UInt16 @{
    UNKNOWN =                  0
    NATIVE =                   1 # Image doesn't require a subsystem.
    WINDOWS_GUI =              2 # Image runs in the Windows GUI subsystem.
    WINDOWS_CUI =              3 # Image runs in the Windows character subsystem.
    OS2_CUI =                  5 # Image runs in the OS/2 character subsystem.
    POSIX_CUI =                7 # Image runs in the Posix character subsystem.
    NATIVE_WINDOWS =           8 # Image is a native Win9x driver.
    WINDOWS_CE_GUI =           9 # Image runs in the Windows CE subsystem.
    EFI_APPLICATION =          10
    EFI_BOOT_SERVICE_DRIVER =  11
    EFI_RUNTIME_DRIVER =       12
    EFI_ROM =                  13
    XBOX =                     14
    WINDOWS_BOOT_APPLICATION = 16
}

$ImageDllCharacteristics = psenum $Mod PE.IMAGE_DLLCHARACTERISTICS UInt16 @{
    HIGH_ENTROPY_VA =       0x0020 # Opts in to high entropy ASLR
    DYNAMIC_BASE =          0x0040 # DLL can move.
    FORCE_INTEGRITY =       0x0080 # Code Integrity Image
    NX_COMPAT =             0x0100 # Image is NX compatible
    NO_ISOLATION =          0x0200 # Image understands isolation and doesn't want it
    NO_SEH =                0x0400 # Image does not use SEH.  No SE handler may reside in this image
    NO_BIND =               0x0800 # Do not bind this image.
    WDM_DRIVER =            0x2000 # Driver uses WDM model
    TERMINAL_SERVER_AWARE = 0x8000
} -Bitfield

$ImageScn = psenum $Mod PE.IMAGE_SCN Int32 @{
    TYPE_NO_PAD =               0x00000008 # Reserved.
    CNT_CODE =                  0x00000020 # Section contains code.
    CNT_INITIALIZED_DATA =      0x00000040 # Section contains initialized data.
    CNT_UNINITIALIZED_DATA =    0x00000080 # Section contains uninitialized data.
    LNK_INFO =                  0x00000200 # Section contains comments or some other type of information.
    LNK_REMOVE =                0x00000800 # Section contents will not become part of image.
    LNK_COMDAT =                0x00001000 # Section contents comdat.
    NO_DEFER_SPEC_EXC =         0x00004000 # Reset speculative exceptions handling bits in the TLB entries for this section.
    GPREL =                     0x00008000 # Section content can be accessed relative to GP
    MEM_FARDATA =               0x00008000
    MEM_PURGEABLE =             0x00020000
    MEM_16BIT =                 0x00020000
    MEM_LOCKED =                0x00040000
    MEM_PRELOAD =               0x00080000
    ALIGN_1BYTES =              0x00100000
    ALIGN_2BYTES =              0x00200000
    ALIGN_4BYTES =              0x00300000
    ALIGN_8BYTES =              0x00400000
    ALIGN_16BYTES =             0x00500000 # Default alignment if no others are specified.
    ALIGN_32BYTES =             0x00600000
    ALIGN_64BYTES =             0x00700000
    ALIGN_128BYTES =            0x00800000
    ALIGN_256BYTES =            0x00900000
    ALIGN_512BYTES =            0x00A00000
    ALIGN_1024BYTES =           0x00B00000
    ALIGN_2048BYTES =           0x00C00000
    ALIGN_4096BYTES =           0x00D00000
    ALIGN_8192BYTES =           0x00E00000
    ALIGN_MASK =                0x00F00000
    LNK_NRELOC_OVFL =           0x01000000 # Section contains extended relocations.
    MEM_DISCARDABLE =           0x02000000 # Section can be discarded.
    MEM_NOT_CACHED =            0x04000000 # Section is not cachable.
    MEM_NOT_PAGED =             0x08000000 # Section is not pageable.
    MEM_SHARED =                0x10000000 # Section is shareable.
    MEM_EXECUTE =               0x20000000 # Section is executable.
    MEM_READ =                  0x40000000 # Section is readable.
    MEM_WRITE =                 0x80000000 # Section is writeable.
} -Bitfield

$ImageDosHeader = struct $Mod PE.IMAGE_DOS_HEADER @{
    e_magic =    field 0 $ImageDosSignature
    e_cblp =     field 1 UInt16
    e_cp =       field 2 UInt16
    e_crlc =     field 3 UInt16
    e_cparhdr =  field 4 UInt16
    e_minalloc = field 5 UInt16
    e_maxalloc = field 6 UInt16
    e_ss =       field 7 UInt16
    e_sp =       field 8 UInt16
    e_csum =     field 9 UInt16
    e_ip =       field 10 UInt16
    e_cs =       field 11 UInt16
    e_lfarlc =   field 12 UInt16
    e_ovno =     field 13 UInt16
    e_res =      field 14 UInt16[] -MarshalAs @('ByValArray', 4)
    e_oemid =    field 15 UInt16
    e_oeminfo =  field 16 UInt16
    e_res2 =     field 17 UInt16[] -MarshalAs @('ByValArray', 10)
    e_lfanew =   field 18 Int32
}

$ImageFileHeader = struct $Mod PE.IMAGE_FILE_HEADER @{
    Machine = field 0 $ImageFileMachine
    NumberOfSections = field 1 UInt16
    TimeDateStamp = field 2 UInt32
    PointerToSymbolTable = field 3 UInt32
    NumberOfSymbols = field 4 UInt32
    SizeOfOptionalHeader = field 5 UInt16
    Characteristics  = field 6 $ImageFileCharacteristics
}


$PeImageDataDir = struct $Mod PE.IMAGE_DATA_DIRECTORY @{
    VirtualAddress = field 0 UInt32
    Size = field 1 UInt32
}

$ImageOptionalHdr = struct $Mod PE.IMAGE_OPTIONAL_HEADER @{
    Magic = field 0 $ImageHdrMagic
    MajorLinkerVersion = field 1 Byte
    MinorLinkerVersion = field 2 Byte
    SizeOfCode = field 3 UInt32
    SizeOfInitializedData = field 4 UInt32
    SizeOfUninitializedData = field 5 UInt32
    AddressOfEntryPoint = field 6 UInt32
    BaseOfCode = field 7 UInt32
    BaseOfData = field 8 UInt32
    ImageBase = field 9 UInt32
    SectionAlignment = field 10 UInt32
    FileAlignment = field 11 UInt32
    MajorOperatingSystemVersion = field 12 UInt16
    MinorOperatingSystemVersion = field 13 UInt16
    MajorImageVersion = field 14 UInt16
    MinorImageVersion = field 15 UInt16
    MajorSubsystemVersion = field 16 UInt16
    MinorSubsystemVersion = field 17 UInt16
    Win32VersionValue = field 18 UInt32
    SizeOfImage = field 19 UInt32
    SizeOfHeaders = field 20 UInt32
    CheckSum = field 21 UInt32
    Subsystem = field 22 $ImageSubsystem
    DllCharacteristics = field 23 $ImageDllCharacteristics
    SizeOfStackReserve = field 24 UInt32
    SizeOfStackCommit = field 25 UInt32
    SizeOfHeapReserve = field 26 UInt32
    SizeOfHeapCommit = field 27 UInt32
    LoaderFlags = field 28 UInt32
    NumberOfRvaAndSizes = field 29 UInt32
    DataDirectory = field 30 $PeImageDataDir.MakeArrayType() -MarshalAs @('ByValArray', 16)
}

$ImageOptionalHdr64 = struct $Mod PE.IMAGE_OPTIONAL_HEADER64 @{
    Magic = field 0 $ImageHdrMagic
    MajorLinkerVersion = field 1 Byte
    MinorLinkerVersion = field 2 Byte
    SizeOfCode = field 3 UInt32
    SizeOfInitializedData = field 4 UInt32
    SizeOfUninitializedData = field 5 UInt32
    AddressOfEntryPoint = field 6 UInt32
    BaseOfCode = field 7 UInt32
    ImageBase = field 8 UInt64
    SectionAlignment = field 9 UInt32
    FileAlignment = field 10 UInt32
    MajorOperatingSystemVersion = field 11 UInt16
    MinorOperatingSystemVersion = field 12 UInt16
    MajorImageVersion = field 13 UInt16
    MinorImageVersion = field 14 UInt16
    MajorSubsystemVersion = field 15 UInt16
    MinorSubsystemVersion = field 16 UInt16
    Win32VersionValue = field 17 UInt32
    SizeOfImage = field 18 UInt32
    SizeOfHeaders = field 19 UInt32
    CheckSum = field 20 UInt32
    Subsystem = field 21 $ImageSubsystem
    DllCharacteristics = field 22 $ImageDllCharacteristics
    SizeOfStackReserve = field 23 UInt64
    SizeOfStackCommit = field 24 UInt64
    SizeOfHeapReserve = field 25 UInt64
    SizeOfHeapCommit = field 26 UInt64
    LoaderFlags = field 27 UInt32
    NumberOfRvaAndSizes = field 28 UInt32
    DataDirectory = field 29 $PeImageDataDir.MakeArrayType() -MarshalAs @('ByValArray', 16)
}

$ImageNTHdrs = struct $mod PE.IMAGE_NT_HEADERS @{
    Signature = field 0 $ImageNTSig
    FileHeader = field 1 $ImageFileHeader
    OptionalHeader = field 2 $ImageOptionalHdr
}

$ImageNTHdrs64 = struct $mod PE.IMAGE_NT_HEADERS64 @{
    Signature = field 0 $ImageNTSig
    FileHeader = field 1 $ImageFileHeader
    OptionalHeader = field 2 $ImageOptionalHdr64
}

$FunctionDefinitions = @(
(func kernel32 GetProcAddress ([IntPtr]) @([IntPtr], [String])),
(func kernel32 GetModuleHandle ([Intptr]) @([String])),
(func ntdll RtlGetCurrentPeb ([IntPtr]) @())
)

$Types = $FunctionDefinitions | Add-Win32Type -Module $Mod -Namespace 'Win32'
$Kernel32 = $Types['kernel32']
$Ntdll = $Types['ntdll']

# Note: At this point, all the types defined are baked in
# and cannot be changed until you restart PowerShell

################################
# Example - A simple PE parser #
################################

# Now that all the structs, enums, and function defs are
# defined, working with them is easy!

# Parse the PE header of ntdll in memory
$ntdllbase = $Kernel32::GetModuleHandle('ntdll')
$DosHeader = $ntdllbase -as $ImageDosHeader
$NtHeaderOffset = [IntPtr] ($ntdllbase.ToInt64() + $DosHeader.e_lfanew)
$NTHeader = $NtHeaderOffset -as $ImageNTHdrs
if ($NtHeader.OptionalHeader.Magic -eq 'PE64')
{
    $NTHeader = $NtHeaderOffset -as $ImageNTHdrs64
}

$NtHeader.FileHeader
$NtHeader.OptionalHeader
$NtHeader.OptionalHeader.DataDirectory

# Parse the PE header of kernel32 on disk
$Bytes = [IO.File]::ReadAllBytes('C:\Windows\System32\kernel32.dll')
# Get the address of the byte array and tell the garbage collector
# not to move it.
$Handle = [Runtime.InteropServices.GCHandle]::Alloc($Bytes, 'Pinned')
$PEBaseAddr = $Handle.AddrOfPinnedObject()

$DosHeader = $PEBaseAddr -as $ImageDosHeader
$NtHeaderOffset = [IntPtr] ($PEBaseAddr.ToInt64() + $DosHeader.e_lfanew)
$NTHeader = $NtHeaderOffset -as $ImageNTHdrs
if ($NtHeader.OptionalHeader.Magic -eq 'PE64')
{
    $NTHeader = $NtHeaderOffset -as $ImageNTHdrs64
}

$NtHeader.FileHeader
$NtHeader.OptionalHeader
$NtHeader.OptionalHeader.DataDirectory
