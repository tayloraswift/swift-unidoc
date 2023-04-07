import MarkdownABI

extension MarkdownTree
{
    /// The basic unit of block structure in a markdown document.
    ///
    /// Unlike inline elements, block elements have reference semantics.
    /// This base class refines the requirements of `MarkdownElements`
    /// with non-mutating signatures, which is useful for structural
    /// markdown algorithms.
    public
    class Block:MarkdownElement
    {
        @inlinable public
        init()
        {
        }
        /// Does nothing.
        public
        func outline(by _:(_ symbol:String) throws -> UInt32) rethrows
        {
        }
        /// Emits nothing.
        public
        func emit(into _:inout MarkdownBinary)
        {
        }
    }
}
