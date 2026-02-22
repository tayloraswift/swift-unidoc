import NIOCore
import NIOHTTP2

extension HTTP {
    //  https://forums.swift.org/t/crash-in-nioasyncwriter-internalclass-deinit/68725
    final class Stream: Sendable {
        let frames: NIOAsyncChannel<HTTP2Frame.FramePayload, HTTP2Frame.FramePayload>
        let id: HTTP2StreamID

        init(
            frames: NIOAsyncChannel<HTTP2Frame.FramePayload, HTTP2Frame.FramePayload>,
            id: HTTP2StreamID
        ) {
            self.frames = frames
            self.id = id
        }

        deinit {
            Task<Void, any Error>.init {
                [frames] in
                try await frames.executeThenClose { _, _ in }
            }
        }
    }
}
