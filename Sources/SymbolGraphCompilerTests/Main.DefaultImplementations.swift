import SymbolGraphCompiler
@_spi(testable)
import Symbols
import Testing

extension Main
{
    enum DefaultImplementations
    {
    }
}
extension Main.DefaultImplementations:CompilerTestBattery
{
    static
    let inputs:[String] =
    [
        "DefaultImplementations",
    ]

    static
    func run(tests:TestGroup,
        nominations:Compiler.Nominations,
        namespaces:[[Compiler.Namespace]],
        extensions:[Compiler.Extension])
    {
        var features:[Symbol.Decl: [Symbol.Decl]] = [:]
        for namespace:Compiler.Namespace in namespaces.joined()
        {
            for decl:Compiler.Decl in namespace.decls
            {
                features[decl.id, default: []] += decl.features
            }
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

        let nested:[Symbol.Decl: [Symbol.Decl]] = extensions.reduce(into: [:])
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
    }
}
