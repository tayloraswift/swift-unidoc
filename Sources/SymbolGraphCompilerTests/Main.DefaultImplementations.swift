import SymbolGraphCompiler
@_spi(testable)
import Symbols
import Testing_

extension Main
{
    enum DefaultImplementations
    {
    }
}
extension Main.DefaultImplementations:CompilerTestBattery
{
    static
    let inputs:[Symbol.Module] =
    [
        "DefaultImplementations",
    ]

    static
    func run(tests:TestGroup, declarations:SSGC.Declarations, extensions:SSGC.Extensions)
    {
        let features:[Symbol.Decl: [Symbol.Decl]] = extensions.compiled.reduce(into: [:])
        {
            $0[$1.signature.extended.type, default: []] += $1.features
        }

        if  let tests:TestGroup = tests / "DefaultImplementationInheritance",
            let features:[Symbol.Decl] = tests.expect(
                value: features["s22DefaultImplementations4EnumO"])
        {
            tests.expect(features **?
            [
                "s22DefaultImplementations9ProtocolBPAAE1fyyF",
                "s22DefaultImplementations9ProtocolCPAAE2idSSvp",
            ])
        }

        let nested:[Symbol.Decl: [Symbol.Decl]] = extensions.compiled.reduce(into: [:])
        {
            $0[$1.signature.extended.type, default: []] += $1.nested
        }

        if  let tests:TestGroup = tests / "DefaultImplementationScopes",
            let nested:[Symbol.Decl] = tests.expect(
                value: nested["s22DefaultImplementations9ProtocolBP"])
        {
            tests.expect(nested **?
            [
                "s22DefaultImplementations9ProtocolBPAAE1fyyF",
            ])
        }

        let declsBySymbol:[Symbol.Decl: SSGC.Decl] = declarations.namespaces.reduce(into: [:])
        {
            for decl:SSGC.Decl in $1.decls
            {
                $0[decl.id] = decl
            }
        }

        //  This checks that we are stripping the inherited documentation comment
        if  let protocolB_f:SSGC.Decl = tests.expect(
                value: declsBySymbol["s22DefaultImplementations9ProtocolBPAAE1fyyF"])
        {
            tests.expect(nil: protocolB_f.comment)
        }
    }
}
