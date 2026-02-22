import NIOCore
import NIOHPACK
import NIOHTTP2

extension HTTP.Client2 {
    @frozen public struct Facet: Sendable {
        public var headers: HPACKHeaders?
        public var body: [UInt8]

        init(headers: HPACKHeaders? = nil, body: [UInt8] = []) {
            self.headers = headers
            self.body = body
        }
    }
}
extension HTTP.Client2.Facet: CustomStringConvertible {
    public var description: String {
        var string: String = ""
        for (key, value, _): (String, String, HPACKIndexing) in headers ?? [:] {
            string += "\(key): \(value)\n"
        }
        string.append("\n")
        string.append(String.init(decoding: body, as: Unicode.UTF8.self))
        return string
    }
}
extension HTTP.Client2.Facet {
    public var status: UInt? {
        if  let headers: [String] = self.headers?[canonicalForm: ":status"],
                headers.count == 1 {
            UInt.init(headers[0])
        } else {
            nil
        }
    }
}
extension HTTP.Client2.Facet {
    /// Validates the payload and adds it to the facet. Returns true if the frame is the last
    /// frame of the response stream, false otherwise.
    mutating func update(with payload: __owned HTTP2Frame.FramePayload) throws -> Bool {
        switch payload {
        case .headers(let frame):
            if  case nil = self.headers {
                self.headers = frame.headers
                return frame.endStream
            }

        case .data(let frame):
            if  case .byteBuffer(let buffer) = frame.data {
                buffer.withUnsafeReadableBytes { self.body += $0 }
                return frame.endStream
            }

        case .rstStream, .pushPromise, .goAway:
            break

        case _:
            return false
        }

        throw HTTP.Client2.UnexpectedFrameError.init(payload)
    }
}
