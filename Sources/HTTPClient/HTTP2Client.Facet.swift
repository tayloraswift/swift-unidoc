import NIOCore
import NIOHPACK
import NIOHTTP2

extension HTTP2Client
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
extension HTTP2Client.Facet
{
    public
    var status:UInt?
    {
        if  let headers:[String] = self.headers?[canonicalForm: ":status"],
                headers.count == 1
        {
            return UInt.init(headers[0])
        }
        else
        {
            return nil
        }
    }
}
extension HTTP2Client.Facet
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

        throw HTTP2Client.UnexpectedFrameError.init(payload)
    }
}
