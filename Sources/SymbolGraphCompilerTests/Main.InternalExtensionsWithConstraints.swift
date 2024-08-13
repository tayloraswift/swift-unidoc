import SymbolGraphCompiler
import Symbols
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
    let inputs:[Symbol.Module] =
    [
        "InternalExtensionsWithConstraints",
    ]

    static
    func run(tests:TestGroup, module:SSGC.ModuleIndex)
    {
    }
}
