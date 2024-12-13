extension HTTP
{
    @frozen public
    enum ServerMethod:Sendable
    {
        case delete
        case get
        case head
        case post([UInt8])
        case put([UInt8])
    }
}
