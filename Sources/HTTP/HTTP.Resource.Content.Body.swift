import NIOCore

extension HTTP.Resource.Content
{
    @frozen public
    enum Body:Equatable, Sendable
    {
        case binary(ArraySlice<UInt8>)
        case buffer(ByteBuffer)
        case string(String)
    }
}
extension HTTP.Resource.Content.Body
{
    @inlinable public static
    func binary(_ bytes:[UInt8]) -> Self
    {
        .binary(bytes[...])
    }
}
extension HTTP.Resource.Content.Body:CustomStringConvertible
{
    @inlinable public
    var description:String
    {
        switch self
        {
        case .binary(let self): .init(decoding: self, as: Unicode.UTF8.self)
        case .buffer(let self): .init(decoding: self.readableBytesView, as: Unicode.UTF8.self)
        case .string(let self): self
        }
    }
}
extension HTTP.Resource.Content.Body
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
        }
    }
}
