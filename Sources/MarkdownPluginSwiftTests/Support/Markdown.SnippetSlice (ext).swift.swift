import MarkdownABI
import Snippets

extension Markdown.SnippetSlice: CustomStringConvertible {
    public var description: String {
        """
        SnippetSlice(id: '\(self.id)', text: '\(self.text)')
        """
    }
}
extension Markdown.SnippetSlice {
    var text: String {
        var text: String = ""
        for fragment: Markdown.SnippetFragment in self.code {
            text += String.init(decoding: self.utf8[fragment.range], as: UTF8.self)
        }
        return text
    }
}
