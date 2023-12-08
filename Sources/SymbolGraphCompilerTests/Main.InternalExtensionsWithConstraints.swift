import SymbolGraphCompiler
import Testing

extension Main
{
    enum InternalExtensionsWithConstraints
    {
    }
}
extension Main.InternalExtensionsWithConstraints:CompilerTestBattery
{
    static
    let inputs:[String] =
    [
        "InternalExtensionsWithConstraints",
    ]

    static
    func run(tests:TestGroup,
        nominations:Compiler.Nominations,
        namespaces:[[Compiler.Namespace]],
        extensions:[Compiler.Extension])
    {
    }
}
