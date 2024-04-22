import SymbolGraphCompiler
import Testing_

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
        nominations:SSGC.Nominations,
        namespaces:[[SSGC.Namespace]],
        extensions:[SSGC.Extension])
    {
    }
}
