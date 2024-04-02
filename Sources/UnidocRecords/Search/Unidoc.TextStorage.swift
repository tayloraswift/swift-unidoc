extension Unidoc
{
    @frozen public
    enum TextStorage:Sendable
    {
        case utf8(ArraySlice<UInt8>)
        case gzip(Compressed)
    }
}
extension Unidoc.TextStorage
{
    @inlinable public static
    func gzip(_ bytes:ArraySlice<UInt8>) -> Self { .gzip(Compressed.init(bytes: bytes)) }
}
