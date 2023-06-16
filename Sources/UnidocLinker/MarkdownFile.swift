import Symbols

@frozen public
struct MarkdownFile:Identifiable, Equatable, Sendable
{
    public
    let text:String
    public
    let name:String
    public
    let id:FileSymbol

    @inlinable public
    init(text:String, name:String, id:FileSymbol)
    {
        self.text = text
        self.name = name
        self.id = id
    }
}
