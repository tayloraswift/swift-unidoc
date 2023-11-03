import HTTPServer
import NIOSSL

struct SwiftinitTest
{
    let tls:NIOSSLContext

    init(tls:NIOSSLContext)
    {
        self.tls = tls
    }
}
extension SwiftinitTest:ServerAuthority
{
    static
    var scheme:ServerScheme { .https }

    static
    var domain:String { "test.swiftinit.org" }

    static
    func redact(error _:any Error) -> String
    {
        "(error redacted)"
    }
}
