import NIOCore
import NIOHTTP1

/// A user-defined type for a server’s representation of an HTTP request.
///
/// The purpose of this abstraction is to allow the server delegate type to reject malformed
/// or invalid requests before the server creates a promise on its event loop. The conforming
/// type’s initializer witnesses do not have any access to the instance state of the delegate,
/// so the implementation should only attempt to validate the request’s structure.
public
protocol HTTPServerOperation:Sendable
{
    init?(get uri:String,
        address:SocketAddress?,
        headers:HTTPHeaders)

    init?(post uri:String,
        address:SocketAddress?,
        headers:HTTPHeaders,
        body:[UInt8])
}
extension HTTPServerOperation
{
    @inlinable public
    init?(_ uri:String,
        address:SocketAddress?,
        headers:HTTPHeaders)
    {
        nil
    }

    @inlinable public
    init?(_ uri:String,
        address:SocketAddress?,
        headers:HTTPHeaders,
        body:[UInt8])
    {
        nil
    }
}
