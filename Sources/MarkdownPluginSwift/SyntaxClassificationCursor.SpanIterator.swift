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
extension SyntaxClassificationCursor.SpanIterator
{
    mutating
    func next() -> SyntaxClassifiedRange?
    {
        guard
        var highlight:SyntaxClassifiedRange = self.spans.next()
        else
        {
            return nil
        }

        if  let marker:Markdown.SwiftLanguage.IndexMarker = self.links[highlight.offset],
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
            default:                break
            }
        }

        return highlight
    }
}
