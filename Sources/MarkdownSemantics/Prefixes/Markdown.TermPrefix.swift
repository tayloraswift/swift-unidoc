extension Markdown
{
    /// A `Term` appears in a list item that begins with `- term name:`, where
    /// *name* is the name of a defined term.
    struct TermPrefix:Equatable, Hashable, Sendable
    {
        let name:String

        init(name:String)
        {
            self.name = name
        }
    }
}
extension Markdown.TermPrefix:Markdown.DefinePrefix
{
    static
    var keyword:String { "term" }
}
