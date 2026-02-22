import HTTP
import MD5
import Multiparts

extension HTTP.ServerRequest.Headers {
    var authorization: Unidoc.Authorization {
        switch self {
        case .http1_1(let self):    .from(self)
        case .http2(let self):      .from(self)
        }
    }

    var contentType: ContentType? {
        let contentType: String?

        switch self {
        case .http1_1(let self):    contentType = self["content-type"].first
        case .http2(let self):      contentType = self["content-type"].first
        }

        guard
        let contentType: String,
        let contentType: ContentType = .init(contentType) else {
            return nil
        }

        return contentType
    }

    var etag: MD5? {
        switch self {
        case .http1_1(let self):    .init(header: self["if-none-match"])
        case .http2(let self):      .init(header: self["if-none-match"])
        }
    }

    var host: String? {
        switch self {
        case .http1_1(let self):
            return self["host"].last

        case .http2(let self):
            return self[":authority"].last.map {
                if  let colon: String.Index = $0.lastIndex(of: ":") {
                    return String.init($0[..<colon])
                } else {
                    return $0
                }
            }
        }
    }
}
