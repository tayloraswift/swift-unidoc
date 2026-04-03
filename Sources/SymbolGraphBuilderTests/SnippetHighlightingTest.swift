// #if canImport(IndexStoreDB)

import HTML
// import class IndexStoreDB.IndexStoreDB
import MarkdownPluginSwift
import MarkdownPluginSwift_IndexStoreDB
import MarkdownRendering
@_spi(testable) import SymbolGraphBuilder
import Symbols
import Testing

struct SnippetHighlightingTest {
    let parser: Markdown.SwiftLanguage
    let source: SSGC.LazyFile
    let slices: [[ExpectedFragment]]

    init(
        parser: Markdown.SwiftLanguage,
        source: SSGC.LazyFile,
        slices: [ExpectedFragment]...
    ) {
        self.parser = parser
        self.source = source
        self.slices = slices
    }
}
extension SnippetHighlightingTest {
    func run(in test: String = #function) throws {
        let utf8: [UInt8] = try self.source.read()
        let (_, slices): (String, [Markdown.SnippetSlice]) = self.parser.parse(
            snippet: utf8,
            from: "\(self.source.location)"
        )

        #expect(slices.count == self.slices.count, "\(test)")

        for (i, expected): (Int, [ExpectedFragment]) in self.slices.enumerated() {
            guard slices.indices.contains(i) else {
                Issue.record("slice index \(i) out of bounds (\(test))")
                continue
            }

            let slice: Markdown.SnippetSlice<Symbol.USR> = slices[i]
            let fragments: [ExpectedFragment] = slice.code.map {
                .init(
                    token: .init(decoding: slice.utf8[$0.range], as: Unicode.UTF8.self),
                    color: $0.color,
                    usr: $0.usr
                )
            }

            #expect(fragments == expected, "\(test)")
        }
    }
}

// #endif
