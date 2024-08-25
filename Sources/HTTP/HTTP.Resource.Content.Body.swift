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
    /// The size of the content to be transferred, in bytes.
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
}
