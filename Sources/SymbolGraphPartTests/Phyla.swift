import SymbolGraphParts
import Symbols
import Testing

@Suite struct Phyla {
    private let symbols: SymbolGraphPart

    init() throws {
        self.symbols = try .load(part: "TestModules/SymbolGraphs/Phyla.symbols.json")
    }

    @Test(
        arguments: [
            (["Actor"],                         .actor),
            (["Class"],                         .class),
            (["Enum"],                          .enum),
            (["Enum", "case"],                  .case),
            (["Protocol"],                      .protocol),
            (["Protocol", "AssociatedType"],    .associatedtype),
            (["Struct"],                        .struct),
            (["Typealias"],                     .typealias),
            (["Var"],                           .var(nil)),

            (["Func"],                          .func(nil)),
            (["Struct", "instanceMethod"],      .func(.instance)),
            (["Struct", "staticMethod"],        .func(.static)),

            (["Struct", "instanceProperty"],    .var(.instance)),
            (["Struct", "staticProperty"],      .var(.static)),

            (["Struct", "subscript"],           .subscript(.instance)),
            (["Struct", "subscript(_:)"],       .subscript(.static)),

            (["Class", "classMethod"],          .func(.class)),
            (["Class", "classProperty"],        .var(.class)),
            (["Class", "init"],                 .initializer),
            (["Actor", "init"],                 .initializer),

            (["?/(_:)"],                        .operator),
            (["<-(_:_:)"],                      .operator),
            (["/?(_:)"],                        .operator),

            (["Struct", "?/(_:)"],              .operator),
            (["Struct", "<-(_:_:)"],            .operator),
            (["Struct", "/?(_:)"],              .operator),
        ] as [([String], Phylum.Decl)]
    ) func Decls(_ symbol: [String], phylum: Phylum.Decl) throws {
        let vertex: SymbolGraphPart.Vertex? = self.symbols.first(named: symbol)
        #expect(vertex?.phylum == .decl(phylum))
    }

    func Deinit() throws {
        #expect(nil == self.symbols.vertices.first { $0.phylum == .decl(.deinitializer) })
    }
}
