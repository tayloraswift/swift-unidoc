import SymbolGraphCompiler
@_spi(testable)
import Symbols
import Testing_

extension Main
{
    enum FeatureInheritance
    {
    }
}
extension Main.FeatureInheritance:CompilerTestBattery
{
    static
    let inputs:[Symbol.Module] =
    [
        "FeatureInheritance",
    ]

    static
    func run(tests:TestGroup, declarations:SSGC.Declarations, extensions:SSGC.Extensions)
    {
        let features:[Symbol.Decl: [Symbol.Decl]] = extensions.compiled.reduce(into: [:])
        {
            $0[$1.signature.extended.type, default: []] += $1.features
        }

        if  let tests:TestGroup = tests / "RandomAccessType",
            let features:[Symbol.Decl] = tests.expect(
                value: features["s18FeatureInheritance16RandomAccessTypeV"])
        {
            tests.expect(true: features.contains("sSKsE6suffixy11SubSequenceQzSiF"))
        }
    }
}
