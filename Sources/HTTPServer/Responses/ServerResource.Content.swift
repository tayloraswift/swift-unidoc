import NIOCore

extension ServerResource
{
    @frozen public
    enum Content:Equatable, Sendable
    {
        case buffer(ByteBuffer)
        case binary([UInt8])
        case text(String)
    }
}
