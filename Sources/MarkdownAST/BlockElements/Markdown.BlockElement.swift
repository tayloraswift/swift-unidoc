import MarkdownABI
import Sources

extension Markdown
{
    /// The basic unit of block structure in a markdown document.
    ///
    /// Unlike inline elements, block elements have reference semantics. This is useful for
    /// running structural markdown algorithms.
    open
    class BlockElement:TreeElement
    {
        @inlinable public
        init()
        {
        }

        /// Renders this element to bytecode.
        @inlinable open
        func emit(into _:inout Markdown.BinaryEncoder)
        {
        }

        /// Outlines symbolic references in this element, and any **non-block** children it may
        /// have. The implementation must not visit block children, to allow composing this
        /// method with ``traverse(with:)``.
        ///
        /// >   Warning:
        /// >   It is not a good idea to call this method directly if the goal is to outline
        /// >   all references in a document. Instead, wrap the call in ``traverse(with:)``.
        @inlinable open
        func outline(by _:(Markdown.InlineAutolink) throws -> Int?) rethrows
        {
        }

        /// Visits this block element, and then any block children it may have.
        ///
        /// This method must perform a **pre-order**, **depth-first** tree traversal. Throwing
        /// an error must abort the traversal.
        @inlinable open
        func traverse(with visit:(Markdown.BlockElement) throws -> ()) rethrows
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
    @inlinable public final
    func rewrite(by rewrite:(inout [Markdown.BlockElement]) -> ())
    {
        //  We’ve got to use a dynamic cast here, because generic classes can’t
        //  conditionally override superclass methods, and ``Markdown.BlockContainer`` is
        //  too useful to bifurcate into multiple non-generic classes.
        self.visit(only: Markdown.BlockContainer<Markdown.BlockElement>.self)
        {
            rewrite(&$0.elements)
        }
    }

    /// A shorthand for calling ``traverse(with:)`` but with a closure that only visits a
    /// specific type of block element.
    @inlinable public final
    func visit<Block>(only _:Block.Type = Block.self, with visit:(Block) throws -> ()) rethrows
        where Block:Markdown.BlockElement
    {
        try self.traverse
        {
            if  let block = $0 as? Block
            {
                try visit(block)
            }
        }
    }
}
