import NIOCore
import NIOHPACK
import NIOHTTP2

extension ClientInterface
{
    @frozen public
    struct Facet:Sendable
    {
        public
        var headers:HPACKHeaders?
        public
        var buffers:[ByteBuffer]

        init(headers:HPACKHeaders? = nil, buffers:[ByteBuffer] = [])
        {
            self.headers = headers
            self.buffers = buffers
        }
    }
}
extension ClientInterface.Facet
{
    /// Validates the payload and adds it to the facet. Returns true if the frame is the last
    /// frame of the response stream, false otherwise.
    mutating
    func update(with payload:__owned HTTP2Frame.FramePayload) throws -> Bool
    {
        switch payload
        {
        case .headers(let frame):
            if  case nil = self.headers
            {
                self.headers = frame.headers
                return frame.endStream
            }

        case .data(let frame):
            if  case .byteBuffer(let buffer) = frame.data
            {
                self.buffers.append(buffer)
                return frame.endStream
            }
        case _:
            break
        }

        throw ClientInterface.UnexpectedFrameError.init(payload)
    }
}
