import MarkdownABI

/// Common interface for ``Markdown.TreeContext.AttributeContext`` and
/// ``Markdown.TextContext.AttributeContext``.
///
/// We never actually dispatch through this protocol, but it is helpful for understanding how
/// the markdown VM works.
protocol MarkdownAttributeContext {
    init()

    /// Appends a single UTF-8 code unit to the current attribute, returning `nil` if and only
    /// if there is no current attribute.
    mutating func buffer(utf8 codeunit: UInt8) -> Void?

    /// Resets the attribute context to its initial state, possibly re-using existing array
    /// allocations.
    mutating func clear()

    /// Terminates the current attribute, if any, and begins a new attribute if `next` is
    /// non-nil.
    mutating func flush(beginning next: Markdown.Bytecode.Attribute?)
}
extension MarkdownAttributeContext {
    /// Replaces `self` with ``init``.
    mutating func clear() {
        self = .init()
    }
}
extension MarkdownAttributeContext {
    mutating func flush() {
        self.flush(beginning: nil)
    }
}
