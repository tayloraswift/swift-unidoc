import SwiftIDEUtils
import SwiftSyntax

struct SyntaxClassificationCursor
{
    private(set)
    var spans:SpanIterator
    private
    var span:Span?

    init(_ spans:consuming SyntaxClassifications,
        links:[Int: Markdown.SwiftLanguage.IndexMarker] = [:])
    {
        self.spans = .init(spans, links: links)
        self.span = self.spans.next()
    }

    mutating
    func step(through range:inout Range<Int>,
        _ yield:(Range<Int>, Span) throws -> ()) rethrows
    {
        while let highlight:Span = self.span
        {
            if  range.upperBound < highlight.end
            {
                //  This range is strictly contained within the current highlight.
                try yield(range, highlight)
                return
            }

            self.span = self.spans.next()

            if  range.lowerBound >= highlight.end
            {
                //  This range does not overlap with the current highlight at all.
                continue
            }

            if  range.upperBound == highlight.end
            {
                //  This range ends at the end of the current highlight.
                try yield(range, highlight)
                return
            }
            else
            {
                //  This range ends after the end of the current highlight.
                let overlap:Range<Int> = range.lowerBound ..< highlight.end
                try yield(overlap, highlight)

                range = highlight.end ..< range.upperBound
            }
        }
    }
}
