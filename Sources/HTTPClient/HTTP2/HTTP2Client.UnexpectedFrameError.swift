import NIOHTTP2

extension HTTP2Client
{
    @frozen public
    struct UnexpectedFrameError:Error, Sendable
    {
        public
        let payload:HTTP2Frame.FramePayload

        @inlinable public
        init(_ payload:HTTP2Frame.FramePayload)
        {
            self.payload = payload
        }
    }
}
