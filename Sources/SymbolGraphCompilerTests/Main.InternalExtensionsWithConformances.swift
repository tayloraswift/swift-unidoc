import SymbolGraphCompiler
import Symbols
import Testing_

extension Main
{
    enum InternalExtensionsWithConformances
    {
    }
}
extension Main.InternalExtensionsWithConformances:CompilerTestBattery
{
    static
    let inputs:[Symbol.Module] =
    [
        "InternalExtensionsWithConformances",
    ]

    static
    func run(tests:TestGroup, declarations:SSGC.Declarations, extensions:SSGC.Extensions)
    {
    }
}
