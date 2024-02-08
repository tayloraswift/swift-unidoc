import Symbols

@frozen public
struct SnippetSourceFile:Equatable, Sendable
{
    public
    let name:String
    public
    let utf8:[UInt8]

    @inlinable public
    init(name:String, utf8:[UInt8])
    {
        self.name = name
        self.utf8 = utf8
    }
}
extension SnippetSourceFile
{
    var id:Symbol.Module { .init(mangling: self.name) }
}
