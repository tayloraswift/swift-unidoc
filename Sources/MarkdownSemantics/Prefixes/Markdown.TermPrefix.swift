extension Markdown {
    /// A `Term` appears in a list item that begins with `- term name:`, where
    /// *name* is the name of a defined term.
    struct TermPrefix: Equatable, Hashable, Sendable {
        let name: String
        let style: DefineStyle

        init(name: String, as style: Markdown.DefineStyle) {
            self.name = name
            self.style = style
        }
    }
}
extension Markdown.TermPrefix: Markdown.DefinePrefix {
    static var keyword: String { "term" }
}
