import NIOCore

extension ServerResource
{
    @frozen public
    enum Content:Equatable, Sendable
    {
        case binary([UInt8])
        case buffer(ByteBuffer)
        case string(String)
        case length(Int)
    }
}
extension ServerResource.Content
{
    @inlinable public
    var length:Int
    {
        switch self
        {
        case .binary(let buffer):   return buffer.count
        case .buffer(let buffer):   return buffer.readableBytes
        case .string(let string):   return string.utf8.count
        case .length(let length):   return length
        }
    }
    /// Drops any payload storage held by this instance, and replaces it with the length of the
    /// dropped payload. If the payload is already a ``length(_:)``, this function does nothing.
    @inlinable public mutating
    func drop()
    {
        self = .length(self.length)
    }
}
