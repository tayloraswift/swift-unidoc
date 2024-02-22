import NIOCore

extension HTTP.Resource
{
    @frozen public
    enum Content:Equatable, Sendable
    {
        case binary(ArraySlice<UInt8>)
        case buffer(ByteBuffer)
        case string(String)
        case length(Int)
    }
}
extension HTTP.Resource.Content
{
    @inlinable public static
    func binary(_ bytes:[UInt8]) -> Self
    {
        .binary(bytes[...])
    }
}
extension HTTP.Resource.Content
{
    /// The size of the content to be transferred, in bytes. Unlike ``length``, this property
    /// is zero if the content is a ``length(_:)`` cache result.
    @inlinable public
    var size:Int
    {
        switch self
        {
        case .binary(let buffer):   buffer.count
        case .buffer(let buffer):   buffer.readableBytes
        case .string(let string):   string.utf8.count
        case .length:               0
        }
    }
    /// The logical length of the content, in bytes, which may not reflect the actual ``size``
    /// of the data to be transferred.
    @inlinable public
    var length:Int
    {
        switch self
        {
        case .binary(let buffer):   buffer.count
        case .buffer(let buffer):   buffer.readableBytes
        case .string(let string):   string.utf8.count
        case .length(let length):   length
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
