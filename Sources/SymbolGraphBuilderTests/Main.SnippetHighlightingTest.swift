#if canImport(IndexStoreDB)

import class IndexStoreDB.IndexStoreDB
import MarkdownPluginSwift_IndexStoreDB
import MarkdownPluginSwift
import MarkdownRendering
@_spi(testable)
import SymbolGraphBuilder
import Testing_
import HTML

extension Main
{
    struct SnippetHighlightingTest
    {
        let parser:Markdown.SwiftLanguage
        let source:SSGC.LazyFile
        let html:[HTML]

        init(parser:Markdown.SwiftLanguage,
            source:SSGC.LazyFile,
            html:HTML...)
        {
            self.parser = parser
            self.source = source
            self.html = html
        }
    }
}
extension Main.SnippetHighlightingTest
{
    func run(in tests:TestGroup) throws
    {
        let utf8:[UInt8] = try self.source.read()
        let (_, slices):(String, [Markdown.SnippetSlice]) = self.parser.parse(snippet: utf8,
            from: "\(self.source.location)")

        if  let tests:TestGroup = tests / "Count"
        {
            tests.expect(slices.count ==? self.html.count)
        }
        for (i, expected):(Int, HTML) in self.html.enumerated()
        {
            guard
            let tests:TestGroup = tests / "\(i)"
            else
            {
                continue
            }
            if  slices.indices.contains(i)
            {
                let html:HTML = .init { $0 += slices[i].code.safe }
                tests.expect("\(html)" ==? "\(expected)")
            }
        }
    }
}

#endif
