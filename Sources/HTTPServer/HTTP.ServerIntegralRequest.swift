import HTTP
import IP
import NIOCore
import NIOHPACK
import NIOHTTP1

extension HTTP
{
    public
    protocol ServerIntegralRequest:Sendable
    {
        init?(get path:String,
            headers:borrowing HPACKHeaders,
            origin:IP.Origin)

        init?(get path:String,
            headers:borrowing HTTPHeaders,
            origin:IP.Origin)

        init?(post path:String,
            headers:borrowing HPACKHeaders,
            origin:IP.Origin,
            body:borrowing [UInt8])

        init?(post path:String,
            headers:borrowing HTTPHeaders,
            origin:IP.Origin,
            body:consuming [UInt8])
    }
}
extension HTTP.ServerIntegralRequest
{
    /// Inefficiently converts the headers to equivalent HPACK headers, and calls the witness
    /// for ``init?(get:headers:origin:)``.
    ///
    /// Servers that expect to handle a lot of HTTP/1.1 GET requests should override this with
    /// a more efficient implementation.
    @inlinable public
    init?(get path:String,
        headers:borrowing HTTPHeaders,
        origin:IP.Origin)
    {
        self.init(get: path,
            headers: .init(httpHeaders: copy headers),
            origin: origin)
    }

    /// Inefficiently converts the headers to equivalent HPACK headers, and calls the witness
    /// for ``init?(post:headers:origin:body:)``.
    ///
    /// Servers that expect to handle a lot of HTTP/1.1 POST requests should override this with
    /// a more efficient implementation.
    @inlinable public
    init?(post path:String,
        headers:borrowing HTTPHeaders,
        origin:IP.Origin,
        body:consuming [UInt8])
    {
        self.init(post: path,
            headers: .init(httpHeaders: copy headers),
            origin: origin,
            body: body)
    }
}
