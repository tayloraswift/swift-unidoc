import MarkdownABI

extension Markdown.BlockItem {
    @frozen public enum Checkbox {
        case checked
        case unchecked
    }
}
extension Markdown.BlockItem.Checkbox {
    /// Emits an `input` element.
    func emit(into binary: inout Markdown.BinaryEncoder) {
        binary[.input] {
            $0[.checked] = self == .checked
            $0[.checkbox] = true
            $0[.disabled] = true
        }
    }
}
