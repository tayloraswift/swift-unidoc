import SwiftIDEUtils
import SwiftSyntax

struct SyntaxClassificationCursor
{
    private(set)
    var spans:SpanIterator
    private
    var span:SyntaxClassifiedRange?

    init(_ spans:consuming SyntaxClassifications,
        links:[Int: Markdown.SwiftLanguage.IndexMarker] = [:])
    {
        self.spans = .init(spans, links: links)
        self.span = self.spans.next()
    }

    mutating
    func step(through range:inout Range<Int>,
        _ yield:(Range<Int>, SyntaxClassification) throws -> ()) rethrows
    {
        while let highlight:SyntaxClassifiedRange = self.span
        {
            if  range.upperBound < highlight.endOffset
            {
                //  This range is strictly contained within the current highlight.
                try yield(range, highlight.kind)
                return
            }

            self.span = self.spans.next()

            if  range.lowerBound >= highlight.endOffset
            {
                //  This range does not overlap with the current highlight at all.
                continue
            }

            if  range.upperBound == highlight.endOffset
            {
                //  This range ends at the end of the current highlight.
                try yield(range, highlight.kind)
                return
            }
            else
            {
                //  This range ends after the end of the current highlight.
                let overlap:Range<Int> = range.lowerBound ..< highlight.endOffset
                try yield(overlap, highlight.kind)

                range = highlight.endOffset ..< range.upperBound
            }
        }
    }
}
