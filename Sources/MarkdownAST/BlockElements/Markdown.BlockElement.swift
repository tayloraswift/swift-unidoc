import MarkdownABI
import Sources

/// The basic unit of block structure in a markdown document.
///
/// Unlike inline elements, block elements have reference semantics.
/// This base class refines the requirements of `MarkdownElements`
/// with non-mutating signatures, which is useful for structural
/// markdown algorithms.
extension Markdown
{
    open
    class BlockElement:Markdown.TreeElement
    {
        @inlinable public
        init()
        {
        }
        /// Does nothing, unless it has been overridden.
        open
        func outline(by _:(Markdown.InlineAutolink) throws -> Int?) rethrows
        {
        }
        /// Emits nothing, unless it has been overridden.
        open
        func emit(into _:inout Markdown.BinaryEncoder)
        {
        }
    }
}
