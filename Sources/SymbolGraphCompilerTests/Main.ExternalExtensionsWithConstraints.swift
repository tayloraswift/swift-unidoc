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
        nominations:SSGC.Nominations,
        namespaces:[[SSGC.Namespace]],
        extensions:[SSGC.Extension])
    {
    }
}
