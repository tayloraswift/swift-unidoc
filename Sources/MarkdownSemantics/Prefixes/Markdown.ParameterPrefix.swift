extension Markdown
{
    /// A `ParameterPrefix` appears in a list item that begins with `- parameter name:`, where
    /// *name* is the name of a parameter.
    struct ParameterPrefix:Equatable, Hashable, Sendable
    {
        let name:String

        init(name:String, as _:Markdown.DefineStyle)
        {
            self.name = name
        }
    }
}
extension Markdown.ParameterPrefix:Markdown.DefinePrefix
{
    static
    var keyword:String { "parameter" }
}
