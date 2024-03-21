import MarkdownAST

extension Markdown
{
    @rethrows
    protocol SemanticPrefix
    {
        /// The maximum number of top-level elements ``extract(from:)`` will
        /// inspect for prefix patterns, including the span containing the
        /// `:` separator. This must be at least 2 if the conforming type
        /// accepts formatted prefixes, since the `:` separator can only
        /// appear in unformatted text.
        static
        var radius:Int { get }

        /// Detects an instance of this pattern type from the given array of
        /// inline block content. The array contains inline content up to, but
        /// not including, an unformatted `:` character.
        init?(from elements:__shared [InlineElement]) rethrows
    }
}
extension Markdown.SemanticPrefix
{
    /// Extracts a prefix pattern from the given array of block elements,
    /// if one matches. This function only mutates the array if it returns
    /// a non-nil pattern.
    static
    func extract(from blocks:inout [Markdown.BlockElement]) rethrows -> Self?
    {
        guard case (let paragraph as Markdown.BlockParagraph)? = blocks.first
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
    /// Extracts a prefix pattern from the given array of inline content,
    /// if one matches. This function only mutates the array if it returns
    /// a non-nil pattern.
    private static
    func extract(from elements:inout [Markdown.InlineElement]) rethrows -> Self?
    {
        for (index, span):(Int, Markdown.InlineElement) in zip(
            elements.indices,
            elements.prefix(Self.radius))
        {
            if  case .text(let text) = span,
                let colon:String.Index = text.firstIndex(of: ":")
            {
                var outer:[Markdown.InlineElement] = .init(elements[..<index])
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
                //  before the current span.
                let suffix:Substring = text.suffix(from: text.index(after: colon)).drop(
                    while: \.isWhitespace)
                if  suffix.isEmpty
                {
                    //  If there is no such suffix, delete the current span too.
                    //  Then keep erasing whitespace until we reach a formatted
                    //  element, or the end of the block.
                    var index:Int = elements.index(after: index)
                    while   index < elements.endIndex,
                            case .text(let text) = elements[index]
                    {
                        let suffix:Substring = text.drop(while: \.isWhitespace)
                        if  suffix.isEmpty
                        {
                            index = elements.index(after: index)
                        }
                        else
                        {
                            elements[index] = .text(.init(suffix))
                            break
                        }
                    }

                    elements[..<index] = []
                }
                else
                {
                    elements[   index] = .text(.init(suffix))
                    elements[..<index] = []
                }

                return pattern
            }
        }
        return nil
    }
}
