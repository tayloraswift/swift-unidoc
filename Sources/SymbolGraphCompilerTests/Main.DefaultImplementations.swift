import SymbolGraphCompiler
@_spi(testable)
import Symbols
import Testing

extension Main
{
    enum DefaultImplementations
    {
    }
}
extension Main.DefaultImplementations:CompilerTestBattery
{
    static
    let inputs:[String] =
    [
        "DefaultImplementations",
    ]

    static
    func run(tests:TestGroup,
        nominations:Compiler.Nominations,
        namespaces:[[Compiler.Namespace]],
        extensions:[Compiler.Extension])
    {
        for namespace:Compiler.Namespace in namespaces.joined()
        {
            for decl:Compiler.Decl in namespace.decls
            {
                switch decl.id
                {
                case "s22DefaultImplementations4EnumO":
                    tests.expect(decl.features ..?
                    [
                        "s22DefaultImplementations9ProtocolBPAAE1fyyF",
                    ])

                case _:
                    continue
                }
            }
        }
    }
}
