import SwiftIDEUtils
import Symbols

extension SyntaxClassificationCursor
{
    struct SpanIterator
    {
        private
        var links:[Int: Markdown.SwiftLanguage.IndexMarker]
        private
        var spans:Array<SyntaxClassifiedRange>.Iterator

        init(_ spans:consuming SyntaxClassifications,
            links:[Int: Markdown.SwiftLanguage.IndexMarker] = [:])
        {
            self.links = links
            self.spans = spans.makeIterator()
        }
    }
}
extension SyntaxClassificationCursor.SpanIterator:CustomDebugStringConvertible
{
    var debugDescription:String
    {
        self.links
            .sorted
        {
            $0.key < $1.key
        }
            .map
        {
            "[\($0.key)]: \($0.value)"
        }
            .joined(separator: "\n")
    }
}
extension SyntaxClassificationCursor.SpanIterator
{
    mutating
    func next() -> SyntaxClassificationCursor.Span?
    {
        guard
        var highlight:SyntaxClassifiedRange = self.spans.next()
        else
        {
            return nil
        }

        let marker:Markdown.SwiftLanguage.IndexMarker? = self.links[highlight.offset]

        if  let marker:Markdown.SwiftLanguage.IndexMarker,
            let phylum:Phylum.Decl = marker.phylum
        {
            switch phylum
            {
            case .actor:            highlight.kind = .type
            case .associatedtype:   highlight.kind = .type
            case .class:            highlight.kind = .type
            case .enum:             highlight.kind = .type
            case .protocol:         highlight.kind = .type
            case .struct:           highlight.kind = .type
            case .typealias:        highlight.kind = .type
            case .func:             highlight.kind = .identifier
            case .initializer:      highlight.kind = .keyword
            default:                break
            }
        }

        return .init(color: .init(classification: highlight.kind),
            usr: marker?.symbol,
            end: highlight.endOffset)
    }
}
