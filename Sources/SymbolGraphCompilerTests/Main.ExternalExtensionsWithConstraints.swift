import SymbolGraphCompiler
import Testing

extension Main
{
    enum ExternalExtensionsWithConstraints
    {
    }
}
extension Main.ExternalExtensionsWithConstraints:CompilerTestBattery
{
    static
    let inputs:[String] =
    [
        "ExternalExtensionsWithConstraints",
        "ExternalExtensionsWithConstraints@ExtendableTypesWithConstraints",
    ]

    static
    func run(tests:TestGroup,
        nominations:Compiler.Nominations,
        namespaces:[[Compiler.Namespace]],
        extensions:[Compiler.Extension])
    {
    }
}
