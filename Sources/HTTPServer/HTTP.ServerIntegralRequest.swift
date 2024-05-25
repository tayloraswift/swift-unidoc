import HTTP
import IP
import NIOCore
import NIOHPACK
import NIOHTTP1
import URI

extension HTTP
{
    public
    protocol ServerIntegralRequest:Sendable
    {
        init?(get uri:URI, headers:HPACKHeaders, origin:IP.Origin)
        init?(get uri:URI, headers:HTTPHeaders, origin:IP.Origin)

        init?(post path:URI, headers:HPACKHeaders, origin:IP.Origin, body:borrowing [UInt8])
        init?(post path:URI, headers:HTTPHeaders, origin:IP.Origin, body:borrowing [UInt8])
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
    init?(get uri:URI, headers:HTTPHeaders, origin:IP.Origin)
    {
        self.init(get: uri,
            headers: .init(httpHeaders: headers),
            origin: origin)
    }

    /// Inefficiently converts the headers to equivalent HPACK headers, and calls the witness
    /// for ``init?(post:headers:origin:body:)``.
    ///
    /// Servers that expect to handle a lot of HTTP/1.1 POST requests should override this with
    /// a more efficient implementation.
    @inlinable public
    init?(post uri:URI, headers:HTTPHeaders, origin:IP.Origin, body:borrowing [UInt8])
    {
        self.init(post: uri,
            headers: .init(httpHeaders: headers),
            origin: origin,
            body: body)
    }
}
