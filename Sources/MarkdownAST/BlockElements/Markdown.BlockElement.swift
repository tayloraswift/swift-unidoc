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

        /// Renders this element to bytecode.
        open
        func emit(into _:inout Markdown.BinaryEncoder)
        {
        }

        /// Outlines symbolic references in this element, and any children it may have.
        ///
        /// This method must perform a **pre-order**, **depth-first** tree traversal. Throwing
        /// an error must abort the traversal.
        open
        func outline(by _:(Markdown.InlineAutolink) throws -> Int?) rethrows
        {
        }

        /// Visits this block element, and then any block children it may have.
        ///
        /// This method must perform a **pre-order**, **depth-first** tree traversal. Throwing
        /// an error must abort the traversal.
        open
        func traverse(_ visit:(Markdown.BlockElement) throws -> ()) rethrows
        {
            try visit(self)
        }
    }
}
extension Markdown.BlockElement
{
    /// Recursively modifies the children of block elements that can contain **arbitrary**
    /// block children.
    ///
    /// This is not a general-purpose tree transformation method. In particular, elements that
    /// contain typed children (like ``BlockListOrdered``) will not be rewritten. However, the
    /// grandchildren may still be rewritten.
    ///
    /// This method performs a **pre-order**, **depth-first** tree traversal, if that matters.
    public final
    func rewrite(by rewrite:(inout [Markdown.BlockElement]) -> ())
    {
        self.traverse
        {
            //  We’ve got to use a dynamic cast here, because generic classes can’t
            //  conditionally override superclass methods, and ``Markdown.BlockContainer`` is
            //  too useful to bifurcate into multiple non-generic classes.
            if  case let block as Markdown.BlockContainer<Markdown.BlockElement> = $0
            {
                rewrite(&block.elements)
            }
        }
    }
}
