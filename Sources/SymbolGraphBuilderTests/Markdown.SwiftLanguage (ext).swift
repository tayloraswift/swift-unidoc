import HTML
import MarkdownPluginSwift
import MarkdownPluginSwift_IndexStoreDB
import MarkdownRendering
@_spi(testable) import SymbolGraphBuilder
import Symbols
import Testing

extension Markdown.SwiftLanguage {
    func test(
        source: SSGC.LazyFile,
        slices: [CodeFragment]...,
        in test: String = #function
    ) throws {
        let utf8: [UInt8] = try source.read()
        let (_, parsed): (String, [Markdown.SnippetSlice]) = self.parse(
            snippet: utf8,
            from: "\(source.location)"
        )

        #expect(parsed.count == slices.count, "\(test)")

        for (parsed, expected): (Markdown.SnippetSlice<Symbol.USR>, [CodeFragment]) in zip(
                parsed,
                slices
            ) {
            let fragments: [CodeFragment] = parsed.code.map {
                .init(
                    token: .init(decoding: parsed.utf8[$0.range], as: Unicode.UTF8.self),
                    color: $0.color,
                    usr: $0.usr
                )
            }

            #expect(fragments.count == expected.count, "\(test)")

            for (fragment, expected): (CodeFragment, CodeFragment) in zip(
                    fragments,
                    expected
                ) {
                #expect(fragment == expected, "\(test)")
            }
        }
    }
}
