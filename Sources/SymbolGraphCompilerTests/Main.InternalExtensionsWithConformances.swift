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
        nominations:SSGC.Nominations,
        namespaces:[[SSGC.Namespace]],
        extensions:[SSGC.Extension])
    {
    }
}
