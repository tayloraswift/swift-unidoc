import NIOCore
import NIOHTTP2

extension HTTP
{
    struct Stream:Sendable
    {
        let frames:NIOAsyncChannel<HTTP2Frame.FramePayload, HTTP2Frame.FramePayload>
        let id:HTTP2StreamID

        init(
            frames:NIOAsyncChannel<HTTP2Frame.FramePayload, HTTP2Frame.FramePayload>,
            id:HTTP2StreamID)
        {
            self.frames = frames
            self.id = id
        }
    }
}
