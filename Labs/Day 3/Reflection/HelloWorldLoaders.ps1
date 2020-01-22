# A simple Hello World program that will be loaded with Assembly.Load and manually recreated using reflection.
Add-Type -TypeDefinition @'
using System;

public class MyClass {
    public static void Main(string[] args) {
        Console.WriteLine("Hello, world!");
    }
}
'@ -OutputAssembly HelloWorld.exe

$AssemblyBytes = [IO.File]::ReadAllBytes("$PWD\HelloWorld.exe")
$HelloWorldAssembly = [System.Reflection.Assembly]::Load($AssemblyBytes)
# Invoking the public method using standard .NET syntax:
[MyClass]::Main(@())
# Using reflection to invoke the Main method:
$HelloWorldAssembly.EntryPoint.Invoke($null, [Object[]] @(@(,([String[]] @()))))

<# Disassembled output from ildasm.exe. This is what I will use to manually build out the Hello World assembly using reflection code.

//  Microsoft (R) .NET Framework IL Disassembler.  Version 4.6.81.0
//  Copyright (c) Microsoft Corporation.  All rights reserved.

// Metadata version: v4.0.30319
.assembly extern mscorlib
{
  .publickeytoken = (B7 7A 5C 56 19 34 E0 89 )                         // .z\V.4..
  .ver 4:0:0:0
}
.assembly HelloWorld
{
  .custom instance void [mscorlib]System.Runtime.CompilerServices.CompilationRelaxationsAttribute::.ctor(int32) = ( 01 00 08 00 00 00 00 00 ) 
  .custom instance void [mscorlib]System.Runtime.CompilerServices.RuntimeCompatibilityAttribute::.ctor() = ( 01 00 01 00 54 02 16 57 72 61 70 4E 6F 6E 45 78   // ....T..WrapNonEx
                                                                                                             63 65 70 74 69 6F 6E 54 68 72 6F 77 73 01 )       // ceptionThrows.
  .hash algorithm 0x00008004
  .ver 0:0:0:0
}
.module HelloWorld.exe
// MVID: {922C653A-792F-48B0-99A9-68E9C3F37A90}
.imagebase 0x00400000
.file alignment 0x00000200
.stackreserve 0x00100000
.subsystem 0x0003       // WINDOWS_CUI
.corflags 0x00000001    //  ILONLY
// Image base: 0x04D00000

// =============== CLASS MEMBERS DECLARATION ===================

.class public auto ansi beforefieldinit MyClass
       extends [mscorlib]System.Object
{
  .method public hidebysig static void  Main(string[] args) cil managed
  {
    .entrypoint
    // Code size       11 (0xb)
    .maxstack  8
    IL_0000:  ldstr      "Hello, world!"
    IL_0005:  call       void [mscorlib]System.Console::WriteLine(string)
    IL_000a:  ret
  } // end of method MyClass::Main

  .method public hidebysig specialname rtspecialname 
          instance void  .ctor() cil managed
  {
    // Code size       7 (0x7)
    .maxstack  8
    IL_0000:  ldarg.0
    IL_0001:  call       instance void [mscorlib]System.Object::.ctor()
    IL_0006:  ret
  } // end of method MyClass::.ctor

} // end of class MyClass
#>

$Domain = [AppDomain]::CurrentDomain
$DynAssembly = New-Object System.Reflection.AssemblyName('HelloWorld')
$AssemblyBuilder = $Domain.DefineDynamicAssembly($DynAssembly, [Reflection.Emit.AssemblyBuilderAccess]::Run)
$ModuleBuilder = $AssemblyBuilder.DefineDynamicModule('HelloWorld.exe')
$TypeBuilder = $ModuleBuilder.DefineType('MyClass', [Reflection.TypeAttributes]::Public)
$MethodBuilder = $TypeBuilder.DefineMethod('Main', [Reflection.MethodAttributes] 'Public, Static', [Void], @([String[]]))
$Generator = $MethodBuilder.GetILGenerator()
$WriteLineMethod = [Console].GetMethod('WriteLine', [Type[]] @([String]))
# Recreate the MSIL from the disassembly listing.
$Generator.Emit([Reflection.Emit.OpCodes]::Ldstr, 'Hello, world!')
$Generator.Emit([Reflection.Emit.OpCodes]::Call, $WriteLineMethod)
$Generator.Emit([Reflection.Emit.OpCodes]::Ret)
$AssemblyBuilder.SetEntryPoint($MethodBuilder)
$TypeBuilder.CreateType()
[MyClass]::Main(@())
