import MarkdownABI
import Sources

extension Markdown.Table {
    @frozen public struct Row<Cell> where Cell: AnyCell {
        public var alignments: [Alignment?]
        public var cells: [Cell]

        @inlinable public init(alignments: [Alignment?], cells: [Cell]) {
            self.alignments = alignments
            self.cells = cells
        }
    }
}
extension Markdown.Table.Row: RandomAccessCollection {
    @inlinable public var startIndex: Int {
        self.cells.startIndex
    }
    @inlinable public var endIndex: Int {
        self.cells.endIndex
    }
    @inlinable public subscript(index: Int) -> (
        alignment: Markdown.Table.Alignment?,
        cell: Cell
    ) {
        (
            self.alignments.indices.contains(index) ? self.alignments[index] : nil,
            self.cells[index]
        )
    }
}
extension Markdown.Table.Row: Markdown.TreeElement {
    public func emit(into binary: inout Markdown.BinaryEncoder) {
        binary[.tr] {
            for (alignment, cell): (Markdown.Table.Alignment?, Cell) in self {
                cell.emit(into: &$0, alignment: alignment)
            }
        }
    }
}
