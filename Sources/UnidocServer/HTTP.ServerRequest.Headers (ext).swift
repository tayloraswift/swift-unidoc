import HTTP
import MD5
import Multiparts

extension HTTP.ServerRequest.Headers {
    var authorization: Unidoc.Authorization {
        if  let authorization: String = self["authorization"].last {
            return .api(authorization: authorization)
        } else {
            return .web(cookie: self["cookie"])
        }
    }
}
