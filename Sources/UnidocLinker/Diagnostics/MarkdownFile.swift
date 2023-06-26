import Symbols

@frozen public
struct MarkdownFile:Identifiable, Equatable, Sendable
{
    public
    let text:String
    public
    let name:String
    public
    let id:Symbol.File

    @inlinable public
    init(text:String, name:String, id:Symbol.File)
    {
        self.text = text
        self.name = name
        self.id = id
    }
}
