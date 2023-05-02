import MarkdownABI

extension MarkdownTree
{
    /// The basic unit of block structure in a markdown document.
    ///
    /// Unlike inline elements, block elements have reference semantics.
    /// This base class refines the requirements of `MarkdownElements`
    /// with non-mutating signatures, which is useful for structural
    /// markdown algorithms.
    open
    class Block:MarkdownElement
    {
        @inlinable public
        init()
        {
        }
        /// Does nothing.
        open
        func outline(by _:(_ symbol:String) throws -> UInt32?) rethrows
        {
        }
        /// Emits nothing.
        open
        func emit(into _:inout MarkdownBinaryEncoder)
        {
        }
    }
}
