import HTTP
import HTTPClient
import LZ77

extension HTTP.Client2.Facet {
    @usableFromInline func content() throws -> ArraySlice<UInt8> {
        if  case "gzip"? = self.headers?["content-encoding"].first {
            return try Gzip.extract(from: self.body[...])[...]
        } else {
            return self.body[...]
        }
    }
}
