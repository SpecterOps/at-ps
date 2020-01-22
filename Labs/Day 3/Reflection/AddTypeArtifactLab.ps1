Add-Type -TypeDefinition @'
namespace Foo {
    public class Bar {
        public static string GetHelloWorld() {
            return "Hello, World!!!";
        }
    }
}
'@

[Foo.Bar]::GetHelloWorld()
