import Sources
@_spi(testable) import SymbolGraphBuilder
import SymbolGraphCompiler
import SymbolGraphParts
import Symbols
import System
import Testing_

protocol CompilerTestBattery:TestBattery
{
    static
    var inputs:[Symbol.Module] { get }

    static
    func run(tests:TestGroup, declarations:SSGC.Declarations, extensions:SSGC.Extensions)
}
extension CompilerTestBattery
{
    static
    func run(tests:TestGroup) throws
    {
        let symbols:SSGC.SymbolDumps = try .collect(from: "TestModules/SymbolGraphs")

        let compiled:[(SSGC.Declarations, SSGC.Extensions)]? = (tests ! "Compilation").do
        {
            let base:Symbol.FileBase = "/swift/swift-unidoc/TestModules"

            return try Self.inputs.map
            {
                var typeChecker:SSGC.TypeChecker = .init()
                let symbols:SSGC.SymbolDump = try .init(loading: $0,
                    from: symbols,
                    base: base,
                    as: .swift)
                try typeChecker.add(symbols: symbols)
                return (
                    typeChecker.declarations(in: $0, language: .swift),
                    try typeChecker.extensions(in: $0)
                )
            }
        }

        guard
        let compiled:[(SSGC.Declarations, SSGC.Extensions)]
        else
        {
            return
        }

        for (declarations, extensions):(SSGC.Declarations, SSGC.Extensions) in compiled
        {
            Self.run(tests: tests, declarations: declarations, extensions: extensions)

            if  let tests:TestGroup = tests / "SourceLocations"
            {

                for (_, decls):(_, [SSGC.Decl]) in declarations.namespaces
                {
                    for decl:SSGC.Decl in decls
                    {
                        if  let location:SourceLocation<Symbol.File> = tests.expect(
                                value: decl.location)
                        {
                            tests.expect(true: location.file.path.starts(with: "Snippets/"))
                        }
                    }
                }
            }
        }
    }
}
