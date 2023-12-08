import SymbolGraphCompiler
import Testing

extension Main
{
    enum InternalExtensionsWithConformances
    {
    }
}
extension Main.InternalExtensionsWithConformances:CompilerTestBattery
{
    static
    let inputs:[String] =
    [
        "InternalExtensionsWithConformances",
    ]

    static
    func run(tests:TestGroup,
        nominations:Compiler.Nominations,
        namespaces:[[Compiler.Namespace]],
        extensions:[Compiler.Extension])
    {
    }
}
