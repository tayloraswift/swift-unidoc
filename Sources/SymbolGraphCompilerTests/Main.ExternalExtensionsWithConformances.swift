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
        "ExtendableTypesWithConstraints",
        "ExternalExtensionsWithConformances",
    ]

    static
    func run(tests:TestGroup, module:SSGC.ModuleIndex)
    {
    }
}
