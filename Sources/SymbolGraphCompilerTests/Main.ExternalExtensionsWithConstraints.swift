import SymbolGraphCompiler
import Symbols
import Testing_

extension Main
{
    enum ExternalExtensionsWithConstraints
    {
    }
}
extension Main.ExternalExtensionsWithConstraints:CompilerTestBattery
{
    static
    let inputs:[Symbol.Module] =
    [
        "ExternalExtensionsWithConstraints",
    ]

    static
    func run(tests:TestGroup, declarations:SSGC.Declarations, extensions:SSGC.Extensions)
    {
    }
}
