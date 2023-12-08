import SymbolGraphCompiler
import Testing

extension Main
{
    enum ExternalExtensionsWithConformances
    {
    }
}
extension Main.ExternalExtensionsWithConformances:CompilerTestBattery
{
    static
    let inputs:[String] =
    [
        "ExternalExtensionsWithConformances",
        "ExternalExtensionsWithConformances@ExtendableTypesWithConstraints",
    ]

    static
    func run(tests:TestGroup,
        nominations:Compiler.Nominations,
        namespaces:[[Compiler.Namespace]],
        extensions:[Compiler.Extension])
    {
    }
}
