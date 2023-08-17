import NIOCore

extension ServerResource
{
    @frozen public
    enum Content:Equatable, Sendable
    {
        case buffer(ByteBuffer)
        case binary([UInt8])
        case string(String)
        case length(Int)
    }
}
extension ServerResource.Content
{
    /// Drops any payload storage held by this instance, and replaces it with the length of the
    /// dropped payload. If the payload is already a ``length(_:)``, this function does nothing.
    @inlinable public mutating
    func drop()
    {
        switch self
        {
        case .buffer(let buffer):   self = .length(buffer.readableBytes)
        case .binary(let bytes):    self = .length(bytes.count)
        case .string(let string):   self = .length(string.utf8.count)
        case .length:               return
        }
    }
}
