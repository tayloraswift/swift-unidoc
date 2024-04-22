import SymbolGraphCompiler
import Testing_

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
        nominations:SSGC.Nominations,
        namespaces:[[SSGC.Namespace]],
        extensions:[SSGC.Extension])
    {
    }
}
