import NIOCore
import NIOHPACK

extension HTTP2Client
{
    @frozen public
    struct Request:Sendable
    {
        public
        var headers:HPACKHeaders
        public
        var body:ByteBuffer?

        @inlinable public
        init(headers:HPACKHeaders = [:], body:ByteBuffer?)
        {
            self.headers = headers
            self.body = body
        }
    }
}
