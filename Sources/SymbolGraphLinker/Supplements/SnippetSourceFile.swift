import Symbols

@frozen public
struct SnippetSourceFile:Equatable, Sendable
{
    public
    let name:String
    public
    let text:String

    @inlinable public
    init(name:String, text:String)
    {
        self.name = name
        self.text = text
    }
}
extension SnippetSourceFile
{
    var id:Symbol.Module { .init(mangling: self.name) }
}
