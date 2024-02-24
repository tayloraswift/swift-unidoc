extension Unidoc
{
    @frozen public
    enum TextStorage:Sendable
    {
        case utf8(ArraySlice<UInt8>)
        case gzip(ArraySlice<UInt8>)
    }
}
