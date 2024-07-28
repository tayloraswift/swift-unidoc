import SymbolGraphCompiler
import Symbols
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
    let inputs:[Symbol.Module] =
    [
        "ExternalExtensionsWithConformances",
    ]

    static
    func run(tests:TestGroup, declarations:SSGC.Declarations, extensions:SSGC.Extensions)
    {
    }
}
