@rethrows public
protocol MarkdownPrefixPattern
{
    init?(from spans:__shared [MarkdownTree.InlineBlock]) rethrows

    /// The maximum number of top-level spans ``extract(from:)`` will
    /// inspect for prefix patterns, including the span containing the
    /// `:` separator. This must be at least 2 if the conforming type
    /// accepts formatted prefixes, since the `:` separator can only
    /// appear in unformatted text.
    static
    var range:Int { get }
}
extension MarkdownPrefixPattern
{
    /// Extracts a prefix pattern from the given array of block elements, if
    /// one matches. This function only mutates the array if it returns a
    /// non-nil pattern.
    static
    func extract(from blocks:inout [MarkdownTree.Block]) rethrows -> Self?
    {
        guard let paragraph:MarkdownTree.Paragraph = blocks.first as? MarkdownTree.Paragraph
        else
        {
            return nil
        }
        guard let pattern:Self = try .extract(from: &paragraph.elements)
        else
        {
            return nil
        }

        if  paragraph.elements.isEmpty
        {
            blocks.removeFirst()
        }

        return pattern
    }
    /// Extracts a prefix pattern from the given array of spans, if one matches.
    /// This function only mutates the array if it returns a non-nil pattern.
    private static
    func extract(from spans:inout [MarkdownTree.InlineBlock]) rethrows -> Self?
    {
        for (index, span):(Int, MarkdownTree.InlineBlock)
            in zip(spans.indices, spans.prefix(Self.range))
        {
            if  case .text(let text) = span,
                let colon:String.Index = text.firstIndex(of: ":")
            {
                var outer:[MarkdownTree.InlineBlock] = .init(spans[..<index])
                let inner:Substring = text[..<colon]
                //  If the text before the `:` contains non-whitespace characters,
                //  add them to the list of elements.
                if  let last:String.Index = inner.lastIndex(where: { !$0.isWhitespace })
                {
                    outer.append(.text(.init(inner[...last])))
                }
                guard let pattern:Self = try .init(from: outer)
                else
                {
                    return nil
                }
                //  If the text after the `:` contains non-whitespace characters,
                //  use them to replace the current text, and delete the elements
                //  before the current span. If there is no such suffix, delete
                //  the current span too.
                let suffix:Substring = text.suffix(from: text.index(after: colon)).drop(
                    while: \.isWhitespace)
                if  suffix.isEmpty
                {
                    spans[...index] = []
                }
                else
                {
                    spans[   index] = .text(.init(suffix))
                    spans[..<index] = []
                }

                return pattern
            }
        }
        return nil
    }
}
