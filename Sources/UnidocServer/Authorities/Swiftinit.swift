import HTTPServer
import NIOSSL

struct Swiftinit
{
    let tls:NIOSSLContext

    init(tls:NIOSSLContext)
    {
        self.tls = tls
    }
}
extension Swiftinit:ServerAuthority
{
    static
    var scheme:ServerScheme { .https }

    static
    var domain:String { "swiftinit.org" }

    static
    func redact(error _:any Error) -> String
    {
        "(error redacted)"
    }
}
