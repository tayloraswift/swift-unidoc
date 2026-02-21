import MarkdownABI

extension Markdown {
    open class BlockContainer<Element>: BlockElement where Element: BlockElement {
        public final var elements: [Element]

        @inlinable public init(_ elements: [Element]) {
            self.elements = elements
        }

        /// Emits the elements in this container, with no framing.
        @inlinable open override func emit(into binary: inout Markdown.BinaryEncoder) {
            for element: Element in self.elements {
                element.emit(into: &binary)
            }
        }

        /// Visits this container, and then each of its children, if they are block elements.
        @inlinable open override func traverse(
            with visit: (Markdown.BlockElement) throws -> ()
        ) rethrows {
            try super.traverse(with: visit)
            for element: Markdown.BlockElement in self.elements {
                try element.traverse(with: visit)
            }
        }
    }
}
