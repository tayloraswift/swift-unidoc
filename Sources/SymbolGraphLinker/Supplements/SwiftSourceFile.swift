import Symbols

@frozen public
struct SwiftSourceFile:Equatable, Sendable
{
    public
    let name:String
    public
    let path:Symbol.File
    public
    let utf8:[UInt8]

    @inlinable public
    init(name:String, path:Symbol.File, utf8:[UInt8])
    {
        self.path = path
        self.name = name
        self.utf8 = utf8
    }
}
